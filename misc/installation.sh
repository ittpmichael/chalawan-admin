# !/bin/sh

yum update -y

echo "Performing mvapich installation...\n"
wget https://kojipkgs.fedoraproject.org/packages/mpich/3.2.1/5.fc29/x86_64/mpich-3.2.1-5.fc29.x86_64.rpm

echo "Performing hdf5-1.8.20 installation...\n"
wget https://support.hdfgroup.org/ftp/HDF5/current18/src/hdf5-1.8.20.tar.gz
yum install -y openmpi.x86_64 zlib.x86_64
cp ./configHDF5.sh ./hdf5-1.8.20
cd ./hdf5-1.8.20

echo "Performing QuantumEspresso 6.0 installtion...\n"
git clone https://github.com/fspiga/qe-gpu.git
