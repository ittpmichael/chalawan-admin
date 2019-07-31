#!/bin/bash
source /etc/profile.d/sge-binaries.sh
module load python2.7

D_TRACE=30

###          FOR TESTING, ENABLE 3 LINES BELOW               ###
F_SENT="/home/ittipat/Documents/testlog/sentJobs.log"
F_COM="/home/ittipat/Documents/testlog/completedJobs.csv"
F_SUM="/home/ittipat/Documents/testlog/summary.csv"
F_FGANGLIA="/home/ittipat/Documents/testlog/fullGanglia.xml"
F_SENT_XML="/home/ittipat/Documents/testlog/qstat.xml"
F_WALLCOM="/home/ittipat/Documents/testlog/walltimeComplete.log"
F_WALLCOM1="/home/ittipat/Documents/testlog/walltimeComplete2.log"
F_PYSCRIPT="/home/ittipat/Documents/calStat.py"
F_USER="/home/ittipat/Documents/testlog/userRuntime.csv"
F_TEMP="/home/ittipat/Documents/testlog/temp"

###          FOR SERIOUS, ENABLE 3 LINES BELOW               ###
#F_SENT="/home/ittipat/Documents/weeklog/sent_$time_gen.log"
#F_COM="/home/ittipat/Documents/weeklog/completed_$time_gen.csv"
#F_SUM="/home/ittipat/Documents/weeklog/sum_$time_gen.csv"
#F_SENT_XML="/home/ittipat/Documents/weeklog/qstat_full.xml"

writeOut()
{
  F_TO_WRITE=$1
  TEMP=$2
  cat <<EOM >$F_TO_WRITE
File generated on $(date)
==============================================
EOM
  cat $TEMP >> $F_TO_WRITE
}

#______________________________________________________________#

#generating list of running jobs
#-------------------------------
qstat -u "*" > $F_TEMP
if [ $? -eq 0 ]; then
  writeOut $F_SENT $F_TEMP
fi

#counting running jobs
#---------------------
num_run=$(gawk 'BEGIN {num_r=0}
 $5=="r" {num_r++}
  END {print num_r}
  ' $F_SENT)

#generating list of running jobs IN XML
#--------------------------------------
qstat -u "*" -f -xml > $F_TEMP
if [ $? -eq 0 ]; then
  writeOut $F_SENT_XML $F_TEMP
fi

#generating list of finished jobs last month
#-------------------------------------------
qacct -d $D_TRACE -j | \
  gawk 'BEGIN {FS=" "; OFS=","; ORS="\n"; n_set=43; i=0;
        print "job-ID", "name", "user", "state", "submit/start", "at", "end", "at", "queue", "granted_pe", "slots"}
        NR==2+n_set*i {jqname=$2}	#qname
        NR==3+n_set*i {jhost=$2}	#hostname
        NR==5+n_set*i {juser=$2}	#user
        NR==8+n_set*i {jname=$2}	#name
        NR==9+n_set*i {jnumber=$2}	#job-ID
        NR==14+n_set*i {		#start_time
          jmonth_s=$3;
          jday_s=$4;
          jyear_s=$6;
          jtime_s=$5;
          jstart=jday_s"/"jmonth_s"/"jyear_s;
          }
        NR==15+n_set*i {		#end_time
          jmonth_e=$3;
          jday_e=$4;
          jyear_e=$6;
          jtime_e=$5;
          jend=jday_e"/"jmonth_e"/"jyear_e;
          }
        NR==16+n_set*i {jpe=$2}	#pe
        NR==17+n_set*i {jslots=$2}	#slots
        NR==18+n_set*i {		#state
          if ($2==0) jstate="completed"
          else jstate=$2;
          print jnumber, jname, juser, jstate, jstart, jtime_s, jend, jtime_e, jqname"@"jhost, jpe, jslots;
          i++;
          }
       ' > $F_TEMP
if [ $? -eq 0 ]; then
  writeOut $F_COM $F_TEMP
fi

#counting completed and failed jobs
#----------------------------------
temp=$(wc -l $F_COM | cut -d' ' -f 1)
num_comnfail=$(expr $temp - 3)

#counting actual completed jobs
#------------------------------
num_com=$(gawk 'BEGIN {FS=","; num_r=0}
  $4=="completed" {num_r++}
  END {print num_r}
  ' $F_COM)

#counting sent jobs
#------------------
temp=$(wc -l $F_SENT | cut -d' ' -f 1)
num_sent=$(expr $temp - 4)

#counting slots used
#-------------------
num_slot=$(gawk 'BEGIN {FS=" "; num_s=0;}
  $5=="r" {num_s+=$9}
  END {print num_s}
  ' $F_SENT)

#counting all (submitted) jobs
#-----------------------------
num_sub=$(expr $num_comnfail + $num_sent)

#counting queue wating
#---------------------
num_q=$(expr $num_sent - $num_run)

#summarize data
cat <<EOM >$F_SUM
File generated on $(date)
==============================================
JOBS RUNNING, $num_run,
JOBS WAITING, $num_q,
COMPLETED JOBS, $num_com,
SUBMITTED JOBS, $num_sub,
CORES IN-USED, $num_slot,
EOM

cat $F_SUM

qacct -o -d $D_TRACE > $F_TEMP
if [ $? -eq 0 ]; then
  writeOut $F_WALLCOM $F_TEMP
fi

#qstat -u "*" | \
#  gawk 'NR<3 {print $0; next}{print $0 | "sort -k 6.9 -k 7"}' \
#  > $F_TEMP
#if [ $? -eq 0 ]; then
#  writeOut $F_WALLRUN $F_TEMP
#fi

python $F_PYSCRIPT
echo "userrunrime.csv was generated"

cat $F_USER | \
  gawk 'BEGIN {FS=","; OFS="\t"}
  NR==1 {print $2, $3, $6}
  NR>1  {print $2, $3/3600 "h", $6/3600 "h"; next}
' > $F_WALLCOM1

cat $F_WALLCOM1

#generating list of running jobs IN XML
#--------------------------------------
ganglia --xml > $F_TEMP
if [ $? -eq 0 ]; then
  writeOut $F_FGANGLIA $F_TEMP
fi

