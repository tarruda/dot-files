from urlparse import urljoin
from json import dumps, loads
from requests_futures.sessions import FuturesSession

import sys, logging, socket, os.path
from subprocess import Popen, PIPE
from time import sleep
from traceback import format_exc
logger = logging.getLogger(__name__)
debug, warn = (logger.debug, logger.warn,)


class NvimYcm(object):
    def __init__(self, vim):
        self.vim = vim
        self.session = FuturesSession(max_workers=10)
        self.session.headers.update({'content-type': 'application/json'})


    def on_waiting_for_ycmd(self, data):
        ycmd_path = self.vim.eval('get(g:, "ycmd_path")')
        if not ycmd_path:
            warn('The ycmd_path variable needs to be set')
            return
        port = get_unused_port()
        self.server_address = 'http://127.0.0.1:%s' % port
        self.server = Popen([
            'python', ycmd_path,
            '--port', str(port),
            '--log', 'error'
        ], stdin=PIPE, stdout=PIPE, stderr=PIPE)
        if self.server.poll():
            warn('Server exited prematurely')
            return
        self.vim.eval('g:YcmSetup()')


    def on_begin_compilation(self, data):
        vim = self.vim
        filepath = data['filepath']

        request_data = {
            'event_name': 'FileReadyToParse',
            'filepath': filepath,
            'file_data': {
                filepath: {
                    'contents': '\n'.join(data.get('contents', None)),
                    'filetypes': [data['filetype']]
                }
            }
        }

        def cb(result):
            if result:
                result = convert_diagnostics_to_vim_qf(data, result)
            vim.push_message('end_compilation', [data, result])

        self._post('event_notification', request_data, cb)

    
    def on_end_compilation(self, args):
        self.vim.eval('ycm#EndCompilation({0})'.format(dumps(args)[1:-1]))


    def on_begin_completion(self, data):
        vim = self.vim
        filepath = data['filepath']
        position = data['position']
        cursor = data['cursor']

        request_data = {
            'line_num': cursor[1],
            'column_num': cursor[2],
            'filepath': filepath,
            'file_data': {
                filepath: {
                    'contents': '\n'.join(data.get('contents', None)),
                    'filetypes': [data['filetype']]
                }
            }
        }

        def cb(result):
            if result and 'completions' in result:
                result = convert_completions_to_vim(result['completions'])
            vim.push_message('end_completion', [data, result])

        self._post('completions', request_data, cb)
        

    def on_end_completion(self, args):
        self.vim.eval('ycm#EndCompletion({0})'.format(dumps(args)[1:-1]))


    def _post(self, handler, data, cb):
        bg_cb = lambda s, r: self._response_cb(s, r, cb)
        return self.session.post(self._build_url('/' + handler),
                                 data=dumps(data),
                                 background_callback=bg_cb)


    def _build_url(self, handler):
        return urljoin(self.server_address, handler)


    def _response_cb(self, sess, resp, cb):
        try:
            response = resp.json()
            if 'exception' in response:
                if response['exception']['TYPE'] == 'UnknownExtraConf':
                    filepath = response['exception']['extra_conf_file']
                    if self._ask(response['message'], "Ok\\nCancel"):
                        self._load_extra_conf(filepath)
                    else:
                        self._ignore_extra_conf(filepath)
                else:
                    warn('ycmd error: %s', response['message'])
                return
        except:
            response = 0
        cb(response)


    def _ask(self, message, choices):
        call = 'confirm("{0}", "{1}", {2})'.format(message, choices, 1)
        result = self.vim.eval(call)
        return int(result) == 1


    def _load_extra_conf(self, filepath):
        def cb(resp):
            vim.push_message('ycm_extra_conf_loaded', None)

        self._post('load_extra_conf_file',
                   {'filepath': filepath},
                   cb)


    def _ignore_extra_conf(self, filepath):
        self._post('ignore_extra_conf_file',
                   {'filepath': filepath},
                   lambda *a: None)



def convert_diagnostics_to_vim_qf(data, diagnostics):
  return [convert_diagnostic_to_vim_qf(data, d) for d in diagnostics \
            if d['location']['filepath'] == data['filepath']]


def convert_diagnostic_to_vim_qf(data, diagnostic):
    location = diagnostic['location']

    return {
        'bufnr': data['bufnum'],
        'lnum': location['line_num'],
        'col': location['column_num'],
        'text': diagnostic['text'],
        'type': diagnostic['kind'][0],
        'valid': 1
    }


def convert_completions_to_vim(completions):
    return [convert_completion_to_vim(c) for c in completions]


def convert_completion_to_vim(completion):
    rv = {
        'word': completion['insertion_text'],
        'dup': 1,
    }

    if 'menu_text' in completion:
        rv['abbr'] = completion['menu_text']
    if 'extra_menu_info' in completion:
        rv['menu'] = completion['extra_menu_info']
    if 'kind' in completion:
        rv['kind'] = completion['kind'][0].lower()
    if 'detailed_info' in completion:
        rv['info'] = completion['detailed_info']

    return rv


def get_unused_port():
  sock = socket.socket()
  sock.bind(('', 0))
  port = sock.getsockname()[1]
  sock.close()
  return port
