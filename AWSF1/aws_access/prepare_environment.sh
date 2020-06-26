#!/bin/bash

printf 'y\n' | sudo yum groupinstall "Development Tools"
printf 'y\n' | sudo yum install kernel kernel-devel

################################################################################

printf 'y\n' | sudo yum install cmake
printf 'y\n' | sudo yum install armadillo-devel
printf 'y\n' | sudo yum install gmp-devel
printf 'y\n' | sudo yum install mpfr-devel
printf 'y\n' | sudo yum install libpcap-devel

mkdir bin
mkdir bin/nfllib
git clone https://github.com/quarkslab/NFLlib.git
cd NFLlib
mkdir _build
cd _build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/home/centos/bin/nfllib
make
# make test
make install

# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/centos/bin/nfllib/lib
# sudo ldconfig /home/centos/bin/nfllib/lib/
# ulimit -S -s 256000

################################################################################

cd
git clone https://github.com/aws/aws-fpga.git
cd aws-fpga
# git checkout ed564e7a87be1ad75b629d628b6e933f27b5bf26
source sdk_setup.sh

sudo rmmod xocl

cd sdk/linux_kernel_drivers/xdma
make
sudo make install

# Clear
sudo fpga-clear-local-image  -S 0

# Check 
# sudo fpga-describe-local-image -S 0 -H

# Load Accelerator afi-0da97a1d59bf1e558
sudo fpga-load-local-image -S 0 -I agfi-05bfb2806dd7970d2
