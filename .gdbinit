set history filename ~/.gdb_history
set history save
python
import sys, os
sys.path.append(os.environ['DOTDIR'])
end

add-auto-load-safe-path /home/tarruda/pub-dev/neovim/src/nvim/testdir/.gdbinit

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

define lua-bt
  set $p = L->ci
  while ($p > L->base_ci )
    if ( $p->func->value.gc->cl.c.isC == 1 )
      printf "0x%x   C FUNCTION ", $p
      output $p->func->value.gc->cl.c.f
      printf "\n"
    else
      if ($p->func.tt==6)
        set $proto = $p->func->value.gc->cl.l.p
        set $filename = (char*)(&($proto->source->tsv) + 1)
        set $lineno = $proto->lineinfo[ $p->savedpc - $proto->code -1 ]
        printf "0x%x LUA FUNCTION : %d %s\n", $p, $lineno, $filename
      else
        printf "0x%x LUA BASE\n", $p
      end
    end
    set $p = $p - 1
  end
end
