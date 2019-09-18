# !/bin/sh

./configure \
	LD_LIBRARY_PATH=/usr/lib/gcc/x86_64-redhat-linux/4.4.7:$LD_LIBRARY_PATH:/usr/lib64 \
	INCLUDE=/usr/lib/gcc/x86_64-redhat-linux/4.4.7/include:/usr/include/c++/4.4.7:$INCLUDE:/usr/include \
	CC="/usr/bin/gcc44" \
	CXX="/usr/bin/g++44" \
	--with-compiler="gnu" \
	--with-psrchive-dir=/opt/psrchive \
	--with-mpi=/opt/pgi/linux86-64/2017/mpi/openmpi-2.1.2 \
	--with-cuda-dir=usr/local/cuda-9.1 \
	--with-cfitsio-include-dir=/usr/include/cfitsio \
	--with-cfitsio-lib-dir=/usr/lib64 \
	FFLAGS="-O -ffixed-line-length-none"
