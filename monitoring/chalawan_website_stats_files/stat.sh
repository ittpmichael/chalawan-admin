#!/bin/bash
source /etc/profile.d/sge-binaries.sh


D_TRACE=30

###          FOR TESTING, ENABLE 3 LINES BELOW               ###
#F_SENT="/home/ittipat/Documents/testlog/sentJobs.log"
#F_COM="/home/ittipat/Documents/testlog/completedJobs.csv"
#F_SUM="/home/ittipat/Documents/testlog/summary.csv"
#F_FGANGLIA="/home/ittipat/Documents/testlog/fullGanglia.xml"
#F_NODESTS="/home/ittipat/Documents/testlog/nodeStatus.csv"
#F_SENT_XML="/home/ittipat/Documents/testlog/qstat.xml"
#F_WALLCOM="/home/ittipat/Documents/testlog/walltimeComplete.log"
#F_PYSCRIPT="/home/ittipat/Documents/calStat.py"
#F_USER="/home/ittipat/Documents/testlog/userRuntime.csv"
#F_TEMP="/home/ittipat/Documents/testlog/temp"

###          FOR SERIOUS, ENABLE 3 LINES BELOW               ###
F_SENT="/home/ittipat/Documents/testlog/sentJobs.log"
F_COM="/home/ittipat/Documents/testlog/completedJobs.csv"
F_SUM="/home/ittipat/Documents/weeklog/summary.csv"
#F_FGANGLIA="/home/ittipat/Documents/weeklog/fullGanglia.xml"
F_NODESTS="/home/ittipat/Documents/weeklog/nodeStatus.csv"
F_SENT_XML="/home/ittipat/Documents/weeklog/sentJobs.xml"
#F_WALLCOM="/home/ittipat/Documents/weeklog/walltimeComplete.log"
#F_PYSCRIPT="/home/ittipat/Documents/calStat.py"
#F_USER="/home/ittipat/Documents/weeklog/userRuntime.csv"
F_TEMP="/home/ittipat/Documents/testlog/temp"

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

#python $F_PYSCRIPT
#if [ $? -eq 0 ]; then
#  echo "userrunrime.csv was generated"
#fi

#cat $F_USER | \
#  gawk 'BEGIN {FS=","; OFS="\t"}
#  NR==1 {print $2, $3, $6}
#  NR>1  {print $2, $3/3600 "h", $6/3600 "h"; next}
#' > $F_WALLCOM1

#cat $F_WALLCOM1

#generate full list of nodes status IN XML
#-----------------------------------------
#ganglia --xml > $F_TEMP
#if [ $? -eq 0 ]; then
#  writeOut $F_FGANGLIA $F_TEMP
#fi

#generate lesser list of nodes status IN CSV
#-------------------------------------------
qhost | \
  awk '
    BEGIN {FS=" "; OFS=","}
    NR==1 {print $1,$3,$4,$5,$6,$7,$8}
    NR>3  {print $1,$3,$4,$5,$6,$7,$8}
' > $F_TEMP
if [ $? -eq 0 ]; then
  writeOut $F_NODESTS $F_TEMP
fi
#cat $F_NODESTS

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

ganglia metric load_one cpu_num mem_free mem_total | \
  awk 'BEGIN {FS=" "; OFS=","; totLoadCPU=0; totCPU=0; memUsed=0; memTot=0}
       $1!="mds-0-1" && $1!="mds-0-2" && $1!="login-0-0" &&
       $1!="mic-compute-0-0-mic0" && $1!="mic-compute-0-0-mic1" &&
       $1!="oss-0-1" && $1!="oss-0-2" {if ($2>$3) totalLoadCPU+=$3
        else totalLoadCPU+=$2;
        totCPU+=$3; memUsed+=$4; memTot+=$5;
        next}
      END {print "TOTAL CLUSTER LOAD (%)", totalLoadCPU/totCPU*100;
      print "TOTAL CLUSTER CPUs", totCPU;
      print "TOTAL MEM USED (%)", (memTot-memUsed)/memTot*100;
      print "TOTAL MEM (TB)", memTot/1024/1024/1024}
' >> $F_SUM

df -B G | \
  awk 'BEGIN {FS=" "; OFS=","}
  $6=="/export" {print "LOCAL DISK USED (%)", $5 | "cut -d'%' -f 1,2"}
' >> $F_SUM
df -B G | \
  awk 'BEGIN {FS=" "; OFS=","}
  $6=="/export" {print "LOCAL DISK TOTAL (GB)", $2 | "cut -d'G' -f 1,2"}
' >> $F_SUM
df -B T | \
  awk 'BEGIN {FS=" "; OFS=","}
  $5=="/lustre" {print "LUSTRE USED (%)", $4 | "cut -d'%' -f 1,2"}
' >> $F_SUM
df -B T | \
  awk 'BEGIN {FS=" "; OFS=","}
  $5=="/lustre" {print "LUSTRE TOTAL (TB)", $1 | "cut -d'T' -f 1,2,3,4,5"}
' >> $F_SUM
#cat $F_SUM
