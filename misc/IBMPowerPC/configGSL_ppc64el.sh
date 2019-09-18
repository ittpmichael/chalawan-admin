# !/bin/bash

module purge ; module load xlc

./configure \
	--prefix=/gpfs/gpfs_gl4_16mb/b8p113/apps/gsl-2.5 \
	--build=ppc64le \
	CCFLAGS="-O3 -qarch=pwr8 -qtune=pwr8"
