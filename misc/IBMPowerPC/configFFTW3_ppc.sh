# !/bin/bash

module purge; module load smpi

./configure \
	--prefix=/gpfs/gpfs_gl4_16mb/b8p113/apps/fftw-3.3.8 \
	--build=powerpc-linux \
	--enable-float \
	--disable-fortran \
	--enable-mpi \
	CFLAGS="-O3" \
	MPICC=mpicc \
	CPPFLAGS="-O3"
		
