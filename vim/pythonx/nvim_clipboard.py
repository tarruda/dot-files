import xerox

class NvimClipboard(object):
    def __init__(self, vim):
        self.provides = ['clipboard_get', 'clipboard_set']

    def clipboard_get(self):
        return xerox.paste().split('\n')
    
    def clipboard_set(self, lines):
        xerox.copy('\n'.join(lines))


