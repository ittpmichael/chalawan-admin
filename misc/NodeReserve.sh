# !/bin/bash

bsub  -q "s822lc_p100" -n 4 -R "span[ptile=4]" -R "rusage[ngpus_excl_p=1]" vmstat 15
