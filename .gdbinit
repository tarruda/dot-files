set history filename ~/.gdb_history
set history save
python
import sys, os
sys.path.append(os.environ['DOTDIR'])
end
# python must have been compiled with '--with-pydebug' for this to 
# produce useful information
# python import python_gdb
