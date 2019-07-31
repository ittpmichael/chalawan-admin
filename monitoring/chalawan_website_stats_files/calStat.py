#!/usr/bin/env python

import pandas as pd
import numpy as np
import datetime as dt

D_TRACE=30

#Filenames to read and write
F_SENT="/home/ittipat/Documents/testlog/sentJobs.log"
F_WALLCOM="/home/ittipat/Documents/testlog/walltimeComplete.log"
F_USER="/home/ittipat/Documents/testlog/userRuntime.csv"

#Read files and remove NaN column
df_wallcom = pd.read_table(F_WALLCOM,delim_whitespace=True,header=2)
df_wallcom = df_wallcom[1:]

df_wallrun = pd.read_table(F_SENT,delim_whitespace=True,header=2)
df_wallrun = df_wallrun[1:]

#Connecting time strings
df_wallrun['time']=df_wallrun['submit/start'].map(str)+" "+ df_wallrun['at'].map(str)
df_wallrun['time']=pd.to_datetime(df_wallrun['time'])

#Convert to new dtype
date_w = dt.datetime.now()-dt.timedelta(days=D_TRACE)
sec_w = dt.timedelta(days=D_TRACE).total_seconds()

df_wallrun['time_delta']=[sec_w if x<=date_w else (dt.datetime.now()-x)/dt.timedelta(seconds=1) for x in df_wallrun['time']]
wall_time=np.sum(df_wallrun['time_delta'])

df_wallrun['cpus_secs']=df_wallrun['slots']*df_wallrun['time_delta']

dfuser=df_wallrun.groupby(['user']).sum()
dfuser = dfuser.reset_index()

for i in range(len(dfuser)):
    x = dfuser.ix[i,0]
    for j in range(1,len(df_wallcom)):
        if df_wallcom.ix[j,0]==x:
            df_wallcom.ix[j,1]+=dfuser.ix[i,4]
            df_wallcom.ix[j,4]+=dfuser.ix[i,5]

pd.DataFrame.to_csv(df_wallcom,path_or_buf=F_USER,sep=',',header=True,columns=None)


