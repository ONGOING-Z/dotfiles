python
import sys
sys.path.insert(0, '/home/fifth/.gdb/stl_pretty_printer/python')
from libstdcxx.v6.printers import register_libstdcxx_printers
register_libstdcxx_printers (None)
end

set print pretty on

# enable ctrl + r to search history
set history save on
set history size 10000
set history filename ~/.gdb_history
