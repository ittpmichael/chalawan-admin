#%%
import pandas as pd
import matplotlib.pyplot as plt

#%%
df = pd.read_csv('~/log/ibMonitor_1534822491.log', usecols=(0,1,2,3,4,5))
df.head()
dfdiff = pd.DataFrame(columns=['state', 'com14Rcv', 'com14Xmit','com15Rcv', 'com15Xmit'])
dfdiff['com14Rcv'] = df[' com14Rcv'].diff()*4/1e6/60
dfdiff['com14Xmit']= df[' com14Xmit'].diff()*4/1e6/60
dfdiff['com15Rcv'] = df[' com15Rcv'].diff()*4/1e6/60
dfdiff['com15Xmit']= df[' com15Xmit'].diff()*4/1e6/60
dfdiff['state']=df[' status']
dfdiff.head()

#%%
plt.style.use("seaborn-whitegrid")
plt.rcParams["figure.figsize"] = [12,8]
fig, ax = plt.subplots()
plot14Rcv = ax.plot(dfdiff['com14Rcv'], label='compute-0-14 Rcv')
plot14Xmit = ax.plot(dfdiff['com14Rcv'], label='compute-0-14 Xmit')
plot15Rcv = ax.plot(dfdiff['com15Rcv'], label='compute-0-15 Rcv')
plot15Xmit = ax.plot(dfdiff['com15Xmit'], label='compute-0-15 Xmit')
plt.xlabel("time (min.)")
plt.ylabel("Transfer rate (MB/s)")
plt.legend()
plt.show()
plt.draw()