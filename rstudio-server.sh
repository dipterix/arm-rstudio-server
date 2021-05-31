#!/usr/bin/bash

# deactivate conda

VERS=v1.4.1106
mkdir /tmp/
cd /tmp/
wget -O $VERS https://github.com/rstudio/rstudio/tarball/$VERS
mkdir /tmp/rstudio
tar xvf /tmp/$VERS -C /tmp/rstudio --strip-components 1
rm /tmp/$VERS

sudo apt iinstall git pandoc libcurl4-openssl-dev ant debsigs npm \
  dpkg-sig expect fakeroot gcc gnupg1 libacl1-dev libattr1-dev \
  clang bzip2 cmake libboost-all-dev libxml-commons-external-java \
  lsof make mesa-common-dev patchelf python rrdtool uuid-dev \
  wget zlib1g libcap-dev libcurl4-openssl-dev libffi-dev \
  libglib2.0-dev libpam0g-dev libpango-1.0-0 libpq-dev libssl-dev \
  libuser1-dev openjdk-11-jdk libsqlite3-dev libxml2-dev

sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-7 100
sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-7 100

cd /tmp/rstudio/dependencies/common
./install-dictionaries
./install-mathjax
./install-sentry-cli
./install-pandoc
# needs npm!
./install-npm-dependencies

# can run without other dependencies
./install-packages &

./install-boost
./install-soci


# sudo chmod 0777 /opt/rstudio-tools/
# ./install-crashpad

cd /tmp/rstudio
mkdir build
sudo cmake -DRSTUDIO_TARGET=Server -DCMAKE_BUILD_TYPE=Release


sudo make install


# Additional install steps
sudo useradd -r rstudio-server
sudo cp /usr/local/lib/rstudio-server/extras/init.d/debian/rstudio-server /etc/init.d/rstudio-server
sudo chmod +x /etc/init.d/rstudio-server 
sudo ln -f -s /usr/local/lib/rstudio-server/bin/rstudio-server /usr/sbin/rstudio-server
sudo chmod 777 -R /usr/local/lib/R/site-library/

# Setup locale
sudo apt-get install -y locales
sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
#echo 'export LANG=en_US.UTF-8' >> ~/.bashrc
#echo 'export LANGUAGE=en_US.UTF-8' >> ~/.bashrc


# uncomment if you want to clean up
# sudo apt autoremove pandoc libboost-all-dev
# sudo apt-get autoremove -y
# sudo rm -rf /tmp/rstudio
# sudo rm -rf /opt/rstudio-tools/depot_tools/
# sudo rm -rf /opt/rstudio-tools/soci/
# sudo rm -rf /opt/rstudio-tools/boost/

sudo /etc/init.d/rstudio-server start
sudo systemctl enable rstudio-server

# ------------------------------------------------------------------------

# configure rs-server
sudo mkdir /etc/rstudio/
sudo touch /etc/rstudio/rserver.conf
sudo touch /etc/rstudio/rsession.conf

echo "www-port=8787" | sudo tee -a /etc/rstudio/rserver.conf
echo "www-address=0.0.0.0" | sudo tee -a /etc/rstudio/rserver.conf
# other options see https://support.rstudio.com/hc/en-us/articles/200552316-Configuring-the-Server
echo "rsession-which-r=$(which R)" | sudo tee -a /etc/rstudio/rserver.conf

echo "session-timeout-minutes=0" | sudo tee -a /etc/rstudio/rsession.conf

# For pro-users
sudo touch /etc/rstudio/jupyter.conf
echo "jupyter-exe=/usr/local/bin/jupyter" | sudo tee -a /etc/rstudio/jupyter.conf
echo "notebooks-enabled=1" | sudo tee -a /etc/rstudio/jupyter.conf
echo "default-session-cluster=Local" | sudo tee -a /etc/rstudio/jupyter.conf


# To add users
# sudo groupadd rstudio-user
# sudo useradd -m -G rstudio-user dipterix

sudo rstudio-server stop
sudo rstudio-server verify-installation
sudo rstudio-server start


sudo systemctl status rstudio-server
