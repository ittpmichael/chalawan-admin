# !/bin/bash

F_LOG="/root/log/sge_status.log"
MAX_TRIES=4
COUNT=0

while [ $COUNT -lt $MAX_TRIES ]; do
  timeout 10s qhost
  SIGNAL=$?
  if [ $SIGNAL -eq 0 ]; then
    exit 0
  fi
  let COUNT=COUNT+1 
done
if [ $SIGNAL -ne 0 ]; then
  echo `date +%y/%m/%d" "%H:%M:%S` "$SIGNAL $COUNT" >> $F_LOG
  # bash /root/scripts/restart_sge.sh
fi
