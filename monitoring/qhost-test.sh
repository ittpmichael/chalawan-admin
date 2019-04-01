# !/bin/bash

qstat -f | awk -F '[ /]' '
	BEGIN {OFS=" "; print "hostname", "resv", "used", "tot.", "load_avg"}
	NR>3 && NR%2==1 {print $9,$10,$11,$19}
'
