# !/bin/bash

# We use this script to monitor traffic of InfiniBand in the com-
# pute nodes

# compute-0-10 connect through lid 26 port 1
# compute-0-11 connect through lid 27 port 1
# compute-0-12 connect through lid 19 port 1
# compute-0-14 connect through lid 28 port 1
# compute-0-13 connect through lid 21 port 1

export F_LOG="/home/ittipat/log/ibMonitor_$(date +%s).log"

filterData() {
	lid=$1
	type=$2
	returnStrings=$(perfquery $lid 1 -x | grep Port${type}Data | sed 's/[^0-9]//g')
	echo $returnStrings
}

touch $F_LOG
cat <<EOM >$F_LOG
Time, status, com14 Xmit (4*octets), com14 Rcv, com15 Xmit, com15 Rcv,
EOM

JOB_ID=$1

while [ -n "$(qstat | grep $JOB_ID)" ]
do 	
	status=$(qstat | grep $JOB_ID | awk '{print $5}')
	#COM12_Rcv=$(filterData 19 "Rcv")
	#COM12_Xmit=$(filterData 19 "Xmit")
	#COM13_Rcv=$(filterData 21 "Rcv")
	#COM13_Xmit=$(filterData 21 "Xmit")
	COM14_Rcv=$(filterData 28 "Rcv")
	COM14_Xmit=$(filterData 28 "Xmit")
	#COM11_Rcv=$(filterData 27 "Rcv")
	#COM11_Xmit=$(filterData 27 "Xmit")
	COM15_Rcv=$(filterData 29 "Rcv")
	COM15_Xmit=$(filterData 29 "Xmit")
	echo "$(date +%s), $status, ${COM14_Rcv}, ${COM14_Xmit}, ${COM15_Rcv}, ${COM15_Xmit}" >> $F_LOG
	sleep 60
done

