set history filename ~/.gdb_history
set history save
python
import sys, os
sys.path.append(os.environ['DOTDIR'])
end
