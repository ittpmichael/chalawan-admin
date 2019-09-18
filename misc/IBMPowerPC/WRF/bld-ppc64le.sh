#!/bin/bash

ml load smpi/10.2.0.4_beta
ml load xlf/16.1.0
ml load xlc/16.1.0
export IBM_SPECTRUM_MPI_LICENSE_ACCEPT=yes
export XLF_BASE=$(which xlf)/..

rm -rf WRFV3
tar zxf downloads/WRFV3.8.1.TAR.gz
cd WRFV3
#export NETCDF=$(pwd)/../sw/netcdf-4.4.1.1
SDIR=/gpfs/gpfs_stage1/fthomas
export NETCDF=$SDIR/local/xl_/netcdf-4.4.1.1
./configure << EOF
39
1
EOF
patch -p1 < ../xlf.patch
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(pwd)/../sw/hdf5-1.8.18/lib:$(pwd)/../sw/szip-2.1/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SDIR/local/xl_/hdf5-1.8.18/lib:$SDIR/local/xl_/szip-2.1/lib
./compile -j 40 em_real 

cd ..
mkdir rundir;cd rundir
tar zxf ../downloads/conus12km_data_v3-2.tar.gz
cp ../WRFV3/test/em_real/* .
cp ../scripts/* .


