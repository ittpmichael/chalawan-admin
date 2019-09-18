#!/bin/bash

echo conus.o.$$
exec > conus.o.$$ 2>conus.e.$$
JOB_ID=$$


ulimit -s unlimited
ulimit -c unlimited
ulimit -a

export MALLOC_MMAP_MAX_=0
export MALLOC_TRIM_THRESHOLD_=134217728 

export OMP_NUM_THREADS=2
#export OMP_NUM_THREADS=1
export OMP_STACKSIZE=480M

export IO_PROCS=0
export NPROC_X=8
export NPROC_Y=5
export NUMTILES=4
cat ./namelist.input.in | sed -e 's/NPROC_X/'${NPROC_X}'/' | sed -e 's/NPROC_Y/'${NPROC_Y}'/' | sed -e 's/NUMTILES/'${NUMTILES}'/'  | sed -e 's/IO_PROCS/'${IO_PROCS}'/'  > namelist.input

#SW=/home/guest/WRF/conus_12km/sw
#export LD_LIBRARY_PATH=$SW/netcdf-4.4.1.1/lib:$SW/hdf5-1.8.18/lib:$SW/szip-2.1/lib:$LD_LIBRARY_PATH
TMPDIR=/tmp # Spectrum MPI does not like TMPDIR in GPFS
prot=MCM
prot=PAMI
prot=pami_noib
#prefix="--bind-to none --tag-output -prot -$prot -x PAMI_IBV_ADAPTER_AFFINITY=0 -x PAMI_ENABLE_STRIPING=0 -x PAMI_IBV_DEVICE_NAME=mlx5_0:1 -x OMP_NUM_THREADS=$OMP_NUM_THREADS -x OMP_WAIT_POLICY=PASSIVE -x OMP_STACKSIZE=600M"
#prefix="--bind-to none --tag-output -btl_openib_warn_default_gid_prefix 0 -mca coll ^ibm -x OMP_NUM_THREADS=$OMP_NUM_THREADS -x OMP_WAIT_POLICY=PASSIVE -x OMP_STACKSIZE=480M"
prefix="--bind-to none --tag-output -$prot -mca coll ^ibm -x OMP_NUM_THREADS=$OMP_NUM_THREADS -x OMP_WAIT_POLICY=PASSIVE -x OMP_STACKSIZE=480M"
time mpiexec $prefix -n 40 ./wrapper.$(uname -m) ./wrf.exe
#mpiexec --tag-output -x OMP_NUM_THREADS=4 --bind-to none -n 18
#time mpiexec -n 18 $prefix ./wrf.exe





date

./wrfetime rsl.error.0000 | awk -f ./stats.awk > wrfetime_out.${NPROC_X}x${NPROC_Y}x${OMP_NUM_THREADS}

if [ -r perf.data.0 ] ; then
    perf report   --stdio -i perf.data.0 > perf.report.0.$JOB_ID
    perf annotate --stdio -i perf.data.0 > perf.annotate.0.$JOB_ID
    perf script -i perf.data.0 | ~/FlameGraph/stackcollapse.pl|~/FlameGraph/flamegraph.pl > out.svg.0.$JOB_ID
    mv perf.data.0 perf.data.0.$JOB_ID
fi

echo
cat wrfetime_out.${NPROC_X}x${NPROC_Y}x${OMP_NUM_THREADS}
echo

exit 0

