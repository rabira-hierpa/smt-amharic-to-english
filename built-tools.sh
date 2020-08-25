#!/bin/bash

# create a working directory for the tools needed
cd ;
mkdir smt;
cd smt;

# install the reqired packages to build the tools
apt-get install build-essential git-core pkg-config automake libtool wget zlib1g-dev python-dev libbz2-dev -y;
apt-get install libsoap-lite-perl -y;

# clone moses from github
git clone https://github.com/moses-smt/mosesdecoder.git;
# download and install GIZA++
git clone https://github.com/moses-smt/giza-pp.git;
cd giza-pp;
make;

# copy giza++ binaries to MossesDecoder
cd ../mosesdecoder;
mkdir tools;
cp ../giza-pp/GIZA++-v2/GIZA++ ../giza-pp/GIZA++-v2/snt2cooc.out ../giza-pp/mkcls-v2/mkcls tools;
cd ..;

# install iRSTLM
mkdir irstlm;
cd irstlm-5.80.08;
cd trunk;
./regenerate-makefiles.sh
./configure ?prefix=$HOME/smt/irstlm
make install;
echo "if you are facing challenges to make files like ?cstdlib ? fatal error: stdlib.h: No such file or directory?, 
please https://achrafothman.net/site/how-to-downgrade-gcc-and-g-in-ubuntu/ to downgrade the version of gcc and g++ in order to build IRSTLM 5.80.08 successfully."
cd ../../;

# install boost 1.72
wget https://dl.bintray.com/boostorg/release/1.72.0/source/boost_1_72_0.tar.gz;
tar zxvf boost_1_72_0.tar.gz;
cd boost_1_72_0/;
./bootstrap.sh;
./b2  ?layout=system link=static install || echo FAILURE;
cd ..;

# install cmph2.0
wget http://www.achrafothman.net/aslsmt/tools/cmph_2.0.orig.tar.gz;
tar zxvf cmph_2.0.orig.tar.gz;
cd cmph-2.0/;
./configure;
make;
make install;

# install xml-rpc
wget http://www.achrafothman.net/aslsmt/tools/xmlrpc-c_1.33.14.orig.tar.gz;
tar zxvf xmlrpc-c_1.33.14.orig.tar.gz;
cd xmlrpc-c-1.33.14/;
./configure;
make;
make install;
cd ..;

#
cd mosesdecoder;
make -f contrib/Makefiles/install-dependencies.gmake;
./bjam --with-boost=../boost_1_72_0 --with-cmph=../cmph-2.0 --with-irstlm=../irstlm;
