# !/bin/sh

module purge && module load psrchive cuda/cuda-9.1

./configure \
	--prefix=/opt/dspsr2
        #--with-psrchive-dir=/opt/psrchive \
	#--with-psrchive=/opt/psrchive/bin \
        #--with-cfitsio-include-dir=/usr/include/cfitsio \
        #--with-cfitsio-lib-dir=/usr/lib64 \
