#!/usr/bin/env python

import pandas as pd
import numpy as np
import datetime as dt

#Filenames to read and write
F_SENT="/home/ittipat/Documents/testlog/sentJobs.log"
F_WALLCOM="/home/ittipat/Documents/testlog/walltimeComplete.log"
F_USER="/home/ittipat/Documents/testlog/userRuntime.csv"

# Read data from file generated from 'qacct -o' 
# which generate statistic of total running time for all processes type.
# Remove NaN row
df_wallcom = pd.read_table(F_WALLCOM,delim_whitespace=True,header=2)
df_wallcom = df_wallcom[1:]

# Read data from file generated from 'qstat -u "*"'.
df_wallrun = pd.read_table(F_SENT,delim_whitespace=True,header=2)
df_wallrun = df_wallrun[1:]
# Drop state != 'r'
df_wallrun[df_wallrun.state == 'r']

# Connecting time strings
df_wallrun['time_start']=df_wallrun['submit/start'].map(str)+" "+ df_wallrun['at'].map(str)
df_wallrun['time_start']=pd.to_datetime(df_wallrun['time_start'])

# calculate time since submit
df_wallrun['time_til_now']=(dt.datetime.now()-df_wallrun['time_start'])/dt.timedelta(seconds=int(1))

# calculate CPU seconds for each user
df_wallrun['cpus_secs']=df_wallrun['slots']*df_wallrun['time_til_now']

dfuser = df_wallrun.groupby(['user']).sum()
dfuser = dfuser.reset_index()

for i in range(len(dfuser)):
    x = dfuser.ix[i,0]
    for j in range(1,len(df_wallcom)):
        if df_wallcom.ix[j,0]==x:
            df_wallcom.ix[j,1]+=dfuser.ix[i,4]
            df_wallcom.ix[j,4]+=dfuser.ix[i,5]

pd.DataFrame.to_csv(df_wallcom,path_or_buf=F_USER,sep=',',header=True,columns=None)


