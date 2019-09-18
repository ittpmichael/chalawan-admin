# !/bin/bash

module purge; module load smpi
./configure \
	FC=gfortran \
	F77=gfortran \
	MPIF90=mpif90 \
	CC=gcc \
	--prefix="/gpfs/gpfs_gl4_16mb/b8p113/apps/qe-6.0-generic/" \
	ARCH=ppc64
