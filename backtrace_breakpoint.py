import gdb
import os


class BacktraceBreakpoint(gdb.Breakpoint):

    """Breakpoint that only stops when the backtrace matches a certain spec."""

    def __init__(self, backtrace_specs, *args, **kwargs):
        specs = list(backtrace_specs)
        spec = specs[0]
        super(BacktraceBreakpoint, self).__init__('{0}:{1}'.format(spec.filename, spec.line), *args, **kwargs)
        self._backtrace_specs = specs[1:]


    def stop(self):
        frame = gdb.selected_frame().older()
        for spec in self._backtrace_specs:
            if not (frame and spec.matches(frame)):
                return False
            frame = frame.older()
        return True


class Spec(object):
    def __init__(self, filename, line):
        self.filename = filename
        self.line = line


    def matches(self, frame):
        symtab = frame.find_sal()
        return (symtab
                and symtab.line == self.line
                and os.path.basename(symtab.symtab.filename) == os.path.basename(self.filename))
