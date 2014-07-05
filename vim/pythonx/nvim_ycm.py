import sys, logging, socket, os, tempfile, hashlib, hmac, os.path
from base64 import b64encode, b64decode
from urlparse import urljoin
from json import dump, dumps, loads
from requests_futures.sessions import FuturesSession

from subprocess import Popen, PIPE
from time import sleep
from traceback import format_exc
logger = logging.getLogger(__name__)
debug, warn = (logger.debug, logger.warn,)


_HMAC_HEADER = 'x-ycm-hmac'


class NvimYcm(object):
    def __init__(self, vim):
        self.vim = vim
        self.session = FuturesSession(max_workers=10)
        self.hmac_secret = os.urandom(16)


    def on_vim_enter(self, ycmd_path):
        port = get_unused_port()
        self.server_address = 'http://127.0.0.1:%s' % port

        with tempfile.NamedTemporaryFile(delete=False) as options_file:
            self._load_defaults_into_vim_globals()
            dump(self._build_options_dict(), options_file)
            options_file.flush()
            self.server = Popen([
                'python', ycmd_path,
                '--port={0}'.format(port),
                '--stdout=/tmp/ycmd-out.log',
                '--stderr=/tmp/ycmd-err.log',
                '--options_file={0}'.format(options_file.name),
                '--log=debug'
            ], stdin=PIPE, stdout=PIPE, stderr=PIPE)
            if self.server.poll():
                warn('Server exited prematurely')
                return
        self.vim.eval('ycm#Setup()')


    def on_vim_leave(self, data):
        if self.server.poll() is None:
            self.server.terminate()
            debug('Killed ycmd')


    def on_buffer_unload(self, filepath):
        request_data = {
            'event_name': 'BufferUnloaded',
            'unloaded_buffer': filepath
        }

        self._post('event_notification', request_data)


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


    def _post(self, handler, data, cb=None):
        bg_cb = lambda s, r: self._response_cb(s, r, cb) if cb else None
        body = dumps(data).encode('utf8')
        return self.session.post(self._build_url('/' + handler),
                                 data=body,
                                 headers=self._compute_headers(body),
                                 background_callback=bg_cb)


    def _compute_headers(self, request_body=''):
        rv = {'content-type': 'application/json'}
        hmac_header_value = hmac.new(self.hmac_secret,
                                     msg=request_body,
                                     digestmod=hashlib.sha256).hexdigest()
        rv[_HMAC_HEADER] = b64encode(hmac_header_value)
        return rv


    def _build_url(self, handler):
        return urljoin(self.server_address, handler)


    def _response_cb(self, sess, resp, cb):
        # TODO may need to validate the reponse hmac header
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


    def _load_defaults_into_vim_globals(self):
        defaults = default_options()
        vim_defaults = {}
        for key, value in defaults.iteritems():
            vim_defaults['ycm_' + key] = value
        self.vim.eval('extend(g:, {0}, "keep")'.format(dumps(vim_defaults)))


    def _build_options_dict(self):
        ycm_var_prefix = 'ycm_'
        vim_globals = self.vim.eval('g:')
        rv = {}
        for key, value in vim_globals.items():
            if not key.startswith(ycm_var_prefix):
                continue
            try:
                new_value = int(value)
            except:
                new_value = value
            new_key = key[len(ycm_var_prefix):]
            rv[new_key] = new_value

        rv['hmac_secret'] = b64encode(self.hmac_secret)
        return rv




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


def default_options():
    return {
      "filepath_completion_use_working_dir": 0,
      "auto_trigger": 1,
      "min_num_of_chars_for_completion": 2,
      "min_num_identifier_candidate_chars": 0,
      "semantic_triggers": {},
      "filetype_specific_completion_to_disable": {
        "gitcommit": 1
      },
      "seed_identifiers_with_syntax": 0,
      "collect_identifiers_from_comments_and_strings": 0,
      "collect_identifiers_from_tags_files": 0,
      "extra_conf_globlist": [],
      "global_ycm_extra_conf": "",
      "confirm_extra_conf": 1,
      "complete_in_comments": 0,
      "complete_in_strings": 1,
      "max_diagnostics_to_display": 30,
      "filetype_whitelist": {
        "*": 1
      },
      "filetype_blacklist": {
        "tagbar": 1,
        "qf": 1,
        "notes": 1,
        "markdown": 1,
        "unite": 1,
        "text": 1,
        "vimwiki": 1,
        "pandoc": 1,
        "infolog": 1,
        "mail": 1
      },
      "auto_start_csharp_server": 1,
      "auto_stop_csharp_server": 1,
      "use_ultisnips_completer": 1,
      "csharp_server_port": 2000,
      "hmac_secret": ""
    }
