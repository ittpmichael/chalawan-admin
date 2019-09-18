# !/bin/bash 

export MPICH_DIR="/gpfs/gpfs_gl4_16mb/b8p113/apps/mpich-3.2.1"
export LD_LIBRARY_PATH=${MPICH_DIR}/lib:$LD_LIBRARY_PATH
export INCLUDE=${MPICH_DIR}/include:$INCLUDE
