# Install RStudio Server Natively on ARM Machine

This tutorial will install the followings from scratch. The procedure has been tested on Raspberry PI 4B (ARMv8, x64 Debian buster). However, it might also work on x86 machines as well. **The tutorial might take 2+ hours. Therefore think twice on whether it's worth it.**

* R (4.1.0)
* RStudio-server (v1.4.1106)

For future versions of R or RStudio, this tutorial might work as well. However, there could be small adjustments.

## Requirements

* x64 Linux system (Debian or Ubuntu)
* patience and willing to read terminal messages (this is not a tutorial for noobs)
* `bash` terminal (not `csh`, `tcsh`, `zsh`, nor `sh`)
* Deactivate `conda` if you have it installed (see below)

> If you have conda installed, please do the followings. Do NOT simply run `conda deactivate`.

* Backup `~/.bashrc` (or `~/.bash_profile`)
* Go to `~/.bashrc` (or `~/.bash_profile`), use your favorite editor (I prefer `vim` or `nano`) to open it, scroll to lines starting with `# >>> conda initialize >>>` and ending with `# <<< conda initialize <<<`, remove these lines. They will screw up your installations. 
* Start a new terminal. If you use `ssh`, exit and login again.

## Install R

> Debian buster installs R-3.5 by default. Following the instructions of R-cran official website often ends up with failure (r-base-core version is wrong). Therefore I choose to compile R from scratch. If you already have R installed, skip this section.

1. Open terminal, enter:

```
sudo apt install git wget curl sudo make libbz2-dev build-essential libpcre2-dev \
  cmake fort77 gfortran gcc gobjc++ openjdk-11-jre-headless \
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

3. Check if R is installed. The following command should return R path (something like `/usr/local/bin/R`)

```
which R
# /usr/local/bin/R
```

4. (Optional) Check device capabilities. Some graphics devices need `X11` and `cairo`. If you cannot plot figures. Please refer to [this article](https://github.com/dipterix/howtos/blob/master/linux/compile-r35-on-ubuntu18.md) on my previous solutions.

```
Rscript --no-save -e "capabilities()"
```

5. Finally, clean up installation files

```
cd ..
rm $RVER.tar.gz
rm -rf ./$RVER
```

## Install RStudio Server

Credits: https://github.com/jrowen/ARM-rstudio-server

`@jrowen`'s version requires massive changes for the new RStudio server, I will mark them out in the following guide.

1. Install prerequisites:

```
sudo apt install git pandoc libcurl4-openssl-dev ant debsigs npm \
  dpkg-sig expect fakeroot gcc gnupg1 libacl1-dev libattr1-dev \
  clang bzip2 cmake libboost-all-dev libxml-commons-external-java \
  lsof make mesa-common-dev patchelf python rrdtool uuid-dev \
  wget zlib1g libcap-dev libcurl4-openssl-dev libffi-dev \
  libglib2.0-dev libpam0g-dev libpango-1.0-0 libpq-dev libssl-dev \
  libuser1-dev openjdk-11-jdk libsqlite3-dev libxml2-dev
```

> Please make sure before answering `Y` to install these packages, no previous packages are removed (`0 to remove`)! If any packages are removed, google the potential issues of replacing such packages

**Please read the following notes before proceeding**

* If you don't have R installed, add `r-base`
* `openjdk` version might be different on your machine
* The changes are: `clang-4 --> clang`, `libsqlite0-dev --> libsqlite3-dev`, added `npm`
* I haven't tried yet, but `pandoc` might not be needed

2. Check clang version

```
clang --version
> clang version 7.0.1-8+deb10u2 (tags/RELEASE_701/final)
> Target: aarch64-unknown-linux-gnu
> Thread model: posix
> InstalledDir: /usr/bin
```

In my case, it's version 7. Change the following `clang-7` and `clang++-7` to whatever version you have. For example, if you have version `11.x`, then use `clang-11`. You can always use `ls /usr/bin | grep clang` to see if the files exist.

```
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-7 100
sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-7 100
```

3. Download and extract RStudio 

Choose desired RStudio version by editing `VERS` variable. Download rstudio server as follows:

```
VERS=v1.4.1106

mkdir /tmp
cd /tmp
wget -O $VERS https://github.com/rstudio/rstudio/tarball/$VERS
mkdir /tmp/rstudio
tar xvf /tmp/$VERS -C /tmp/rstudio --strip-components 1
rm /tmp/$VERS
```

4. Install dependencies (a.k.a the long step part 1)

```
cd /tmp/rstudio/dependencies/common
./install-dictionaries
./install-mathjax
./install-pandoc
./install-sentry-cli

# needs npm!
./install-npm-dependencies

# This can run without boost library
./install-packages &

# Will take long to run
./install-boost
./install-soci
```

* In `./install-soci`, you need to make sure `sqlite3` is linked correctly (read the terminal messages!). If compile failed, fix the issue by adding required libraries, then go to `/opt/rstudio-tools/` and `sudo rm -rf /opt/rstudio-tools/soci`, followed by re-runing `./install-soci`.
* `./install-packages` will install some R packages. It can go in parallel. 
* `./install-boost` will take long to run. Go and get a coffee. However, `soci` might require `boost` library, so no parallel installation can be done here.

5. Build RStudio server (a.k.a the long step part 2)

Once dependencies are installed, run

```
cd /tmp/rstudio
mkdir build
sudo cmake -DRSTUDIO_TARGET=Server -DCMAKE_BUILD_TYPE=Release
```

Go work out in the gym!

6. Install and register RStudio server as a service

Install:

```
cd /tmp/rstudio
sudo make install
```

Add rstudio-server as an user and register the service

```
sudo useradd -r rstudio-server
sudo cp /usr/local/lib/rstudio-server/extras/init.d/debian/rstudio-server /etc/init.d/rstudio-server
sudo chmod +x /etc/init.d/rstudio-server 
sudo ln -f -s /usr/local/lib/rstudio-server/bin/rstudio-server /usr/sbin/rstudio-server

# Setup locale
sudo apt-get install -y locales
sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# Start the service for the first time
sudo /etc/init.d/rstudio-server start

# Enable at start-up
sudo systemctl enable rstudio-server
```

7. Clean-ups

```
sudo rm -rf /tmp/rstudio/
sudo rm -rf /opt/rstudio-tools/depot_tools/
sudo rm -rf /opt/rstudio-tools/soci/
sudo rm -rf /opt/rstudio-tools/boost/
sudo apt-get autoremove
```

7. Configure rstudio-server

Credit: https://support.rstudio.com/hc/en-us/articles/200552316-Configuring-the-Server

First, stop the service and add two files:

```
sudo rstudio-server stop
sudo mkdir /etc/rstudio/
sudo touch /etc/rstudio/rserver.conf
sudo touch /etc/rstudio/rsession.conf
```

Next, edit the following configurations accordingly. Check [here](https://support.rstudio.com/hc/en-us/articles/200552316-Configuring-the-Server) for details.

```
# Listen to port 8787
echo "www-port=8787" | sudo tee -a /etc/rstudio/rserver.conf
echo "www-address=0.0.0.0" | sudo tee -a /etc/rstudio/rserver.conf
echo "rsession-which-r=$(which R)" | sudo tee -a /etc/rstudio/rserver.conf

# No session time out
echo "session-timeout-minutes=0" | sudo tee -a /etc/rstudio/rsession.conf
```

Finally, update and restart the service

```
sudo rstudio-server verify-installation
sudo rstudio-server start
```


How, go to http://127.0.0.1:8787 you should be able to see the login screen.





















