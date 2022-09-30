#!/usr/bin/bash

RVER="R-4.2.1"

# In other linux, you might need X11 support, but in raspberry, this is not required
sudo apt-get install libbz2-dev build-essential libpcre2-dev \
  fort77 gfortran gcc gobjc++ openjdk-11-jdk openjdk-11-jre-headless \
  libssl-dev libssh2-1-dev libv8-dev libxml2-dev libfftw3-dev \
  libtiff5-dev libhdf5-dev libcurl4-openssl-dev xorg-dev \
  libtiff-dev libcairo2-dev texlive texlive-fonts-extra texinfo \
  libblas-dev liblapack-dev liblzma-dev libreadline-dev


mkdir /tmp/
cd /tmp/
wget https://cran.r-project.org/src/base/R-4/$RVER.tar.gz
tar -xf ./$RVER.tar.gz && rm $RVER.tar.gz
cd ./$RVER

./configure --enable-memory-profiling --enable-R-shlib

make
sudo make install

rm -rf ./$RVER
