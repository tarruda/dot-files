set history filename ~/.gdb_history
set history save
python
import sys, os
sys.path.append(os.environ['DOTDIR'])
# python must have been compiled with '--with-pydebug'
import python_gdb
end
