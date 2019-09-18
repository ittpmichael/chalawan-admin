# !/bin/sh

module purge && module load openmpi/2.1.2/2017 intel/intel2015

export PGPLOT_DIR=/opt/psrchive/pgplot
export TEMPO=/opt/psrchive/tempo2

./configure \
	--prefix=/opt/psrchive \
	--with-compiler=gnu \
	--with-fftw3-include-dir=/usr/include \
	--with-fftw3-lib-dir=/usr/lib64 \
	--with-ipp-include-dir=/opt/intel/composer_xe_2015.1.133/ipp/include \
	--with-ipp-lib-dir=/opt/intel/composer_xe_2015.1.133/ipp/lib/intel64 \
	--with-cfitsio-include-dir=/usr/include \
	--with-cfitsio-lib-dir=/usr/lib64 \
	--with-mpi \
	--with-mpi-dir=/opt/pgi/linux86-64/2017/mpi/openmpi-2.1.2 \
	--with-Qt-include-dir=/usr/lib64/qt-3.3/include \
	--with-Qt-lib-dir=/usr/lib64/qt-3.3/lib \
	--with-Qt-bin-dir=/usr/lib64/qt-3.3/bin \
	X_LIBS=/usr/lib64 \
	PATH=$PATH:/opt/psrchive/pgplot \
	LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib:/opt/psrchive/pgplot \
	INCLUDE=$INCLUDE:/usr/include:/opt/psrchive/pgplot \
	CXX=/usr/bin/g++ \
	CC=/usr/bin/gcc \
	CFLAGS="-Wall -O2 -fPIC -mtune=generic -pipe" \
	CXXFLAGS="-Wall -O2 -fPIC -mtune=generic -pipe" \
	F77=/usr/bin/gfortran \
	FFLAGS="-O -g -ffixed-line-length-none" 
