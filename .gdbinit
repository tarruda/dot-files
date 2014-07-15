set history filename ~/.gdb_history
set history save
python
import sys, os
sys.path.append(os.environ['DOTDIR'])
end

define log-bt
  set logging file gdb-backtrace.log
  set logging redirect on
  set logging on
  set pagination off
  bt
  set logging off
  set logging redirect off
  set pagination on
end

define py-log-bt
  # python must have been compiled with '--with-pydebug' for this to 
  # produce useful information
  python import python_gdb
  set logging file python-backtrace.log
  set logging redirect on
  set logging on
  set pagination off
  py-bt
  set logging off
  set logging redirect off
  set pagination on
end

