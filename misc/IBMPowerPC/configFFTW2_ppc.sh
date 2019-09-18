# !/bin/bash

module purge; module load smpi

./configure \
	--prefix=/gpfs/gpfs_gl4_16mb/b8p113/apps/fftw-2.1.5 \
	--build=powerpc-linux \
	--enable-threads \
	--enable-float \
	--enable-type-prefix \
	--disable-fortran \
	--enable-mpi \
	CFLAGS="-O3" \
	MPICC=mpicc \
	CPPFLAGS="-O3"
		
