# Install RStudio Server Natively on ARM Machine

This tutorial will install the followings from scratch. The procedure has been tested on Raspberry PI 4B (ARMv8, x64 Debian buster). However, it might also work on x86 machines as well. **The tutorial might take 2+ hours. Therefore think twice on whether it's worth it.**

* R (4.1.0)
* RStudio-server (v1.4.1106)

For future versions of R or RStudio, this tutorial might work as well. However, there could be small adjustments.

## Requirements

* x64 Linux system (Debian or Ubuntu)
* patience and willing to read terminal messages (this is not a tutorial for noobs)

## Install R

> Debian buster installs R-3.5 by default. Following the instructions of R-cran official website often ends up with failure (r-base-core version is wrong). Therefore I choose to compile R from scratch. If you already have R installed, skip this section.

1. Open terminal, enter:

```
sudo apt install git wget curl sudo make libbz2-dev build-essential libpcre2-dev \
  fort77 gfortran gcc gobjc++ openjdk-11-jre-headless \
  libssl-dev libssh2-1-dev libv8-dev libxml2-dev libfftw3-dev \
  libtiff5-dev libhdf5-dev libcurl4-openssl-dev xorg-dev \
  libtiff-dev libcairo2-dev texlive texlive-fonts-extra texinfo
```

> Please make sure before answering `Y` to install these packages, no previous packages are removed (`0 to remove`)! If any packages are removed, google the potential issues of replacing such packages


This is for Raspberry Pi OS. In other systems, you might need to install `libX11-devel`, `libv8-3.14-dev`, `gcc-multilib` as well. Also the `openjdk` versions might be different. 


2. Compile and install R-4.1.0

```
RVER="R-4.1.0"
wget https://cran.r-project.org/src/base/R-4/$RVER.tar.gz
tar -xf ./$RVER.tar.gz
cd ./$RVER
./configure --enable-memory-profiling --enable-R-shlib
make
sudo make install
```

You can change `RVER="R-4.1.0"` to other versions (like `RVER="R-4.0.5"`)

3. Check and clean up

Check if R is installed. The following command should return R path (something like `/usr/local/bin/R`)

```
which R
# /usr/local/bin/R
```

Check device capabilities. Some graphics devices need `X11` and `cairo`. If you cannot plot figures. Please refer to [this article](https://github.com/dipterix/howtos/blob/master/linux/compile-r35-on-ubuntu18.md) on my previous solutions.

```
Rscript --no-save -e "capabilities()"
```

Finally, clean up installation files

```
cd ..
rm $RVER.tar.gz
rm -rf ./$RVER
```

## Install RStudio Server




