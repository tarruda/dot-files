from urlparse import urljoin
from json import dumps, loads
from requests_futures.sessions import FuturesSession

import sys, logging, os.path
from traceback import format_exc
logger = logging.getLogger(__name__)
debug, warn = (logger.debug, logger.warn,)

class NvimYcmClient(object):
    def __init__(self, vim):
        self.vim = vim
        self.session = FuturesSession(max_workers=10)
        self.session.headers.update({'content-type': 'application/json'})
        self.server_address = 'http://192.168.56.50:3000'


    def on_begin_compilation(self, data):
        vim = self.vim
        filepath = data['filepath']

        request_data = {
            'event_name': 'FileReadyToParse',
            'compilation_flags': ['-x', 'c++'],
            'filepath': filepath,
            'file_data': {
                filepath: {
                    'contents': '\n'.join(data.get('contents', None)),
                    'filetypes': [data['filetype']]
                }
            }
        }

        def cb(sess, resp):
            try:
                data['result'] = resp.json()
            except ValueError:
                data['result'] = 0
            vim.push_message('end_compilation', data)

        self._send('event_notification', request_data, cb)

    
    def on_end_compilation(self, data):
        cmd = 'call ycm#EndCompilation({0})'.format(dumps(data))
        self.vim.command(cmd)


    def on_begin_completion(self, data):
        vim = self.vim
        filepath = data['filepath']
        position = data['position']
        cursor = data['cursor']

        request_data = {
            'line_num': cursor[1],
            'column_num': cursor[2],
            'compilation_flags': ['-x', 'c++'],
            'filepath': filepath,
            'file_data': {
                filepath: {
                    'contents': '\n'.join(data.get('contents', None)),
                    'filetypes': [data['filetype']]
                }
            }
        }

        def cb(sess, resp):
            json = resp.json()
            try:
                completions = convert_completions_to_vim(json['completions'])
            except:
                warn('error %s', format_exc(5))
                return
            data['result'] = completions
            vim.push_message('end_completion', data)

        self._send('completions', request_data, cb)
        

    def on_end_completion(self, data):
        cmd = 'call ycm#EndCompletion({0})'.format(dumps(data))
        self.vim.command(cmd)


    def _send(self, handler, data, cb):
        self.session.post(self._build_url('/' + handler),
                          data=dumps(data),
                          background_callback=cb)


    def _build_url(self, handler):
        return urljoin(self.server_address, handler)


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
