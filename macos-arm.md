## Compile RStudio-Server on MacOS ARM CPU

* Status: Still trying... (Please do not use this guide for now as it's not working)

Useful resources: https://github.com/rstudio/rstudio/wiki/M1-Mac-Dev-Machine-Setup

### Before configuring

* Create an Admin user `rstudio-server` in your system settings, login with this account (please don't install anything as we want to make sure `$PATH` is clean).

* Install Rosetta2 so Intel binaries will work. You will be prompted to do this when necessary, but I like to get it out of the way up front. From the terminal: /usr/sbin/softwareupdate --install-rosetta --agree-to-license
  - You might see a "Package Authoring Error" message when running this command. You can ignore this.


* Instal Homwbrew using command shown at https://brew.sh; when it completes
  - Make sure you run `echo 'eval $(/opt/homebrew/bin/brew shellenv)' >> $HOME/.zprofile` after installation
  - Run the install command again, prefixed with arch -x86_64 to force it to install the Intel flavor
  - At this point confirm (in terminal) that which brew points to /opt/homebrew/bin/brew; this is the native M1 brew and is what you normally want to use
  - If /usr/local/bin is first on the path you will need to adjust your path to put /opt/homebrew/bin first

### Download RStudio-Server

Go to Github, git-clone the RStudio-Server source code to the `Downloads` folder. Do not use the released version (the compiling process requires `.git` folder to exists for some reason.

Open terminal, run

```sh
cd ~/
git clone https://github.com/rstudio/rstudio.git
cd rstudio
RSTUDIO_SRCDIR=~/rstudio/
```

In the following text, I'll use `${RSTUDIO_SRCDIR}` to reference the RStudio source directory.

### Install dependencies

* Open `~/rstudio/dependencies/common/install-soci` with text editor. Add `CMAKE_GENERATOR="Unix Makefiles"` before `${CMAKE} ...` line, this forces `soci` to be compiled without `ninja`. Otherwise `soci` won't compile.

Run the following commands:

```sh
cd ~/rstudio/dependencies/osx
./install-dependencies-osx
```

### Compile & install

* Follow the "INSTALL" file (included in the source tar ball), you can run

```sh
cd "${RSTUDIO_SRCDIR}"
mkdir build
cd build
/opt/homebrew/bin/cmake .. -DRSTUDIO_TARGET=Server -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/rstudio-server
```

* Once configured, install to `/opt/rstudio-server` folder

```sh
sudo make install
```

* Go to `/opt/rstudio-server` folder, right-click on the `RStudio.app` and view package contents. You should see

```
/Contents
  /MacOS
  /Resources
```

* You can't directly run this app, you need to copy them out
  - Copy the folder `/opt/rstudio-server/RStudio.app/Contents/MacOS` out and paste under `/opt/rstudio-server` directly, rename the `MacOS` to `bin`
  - Open `/opt/rstudio-server/RStudio.app/Contents/Resources` and copy the sub-items out (this time do not copy the whole folder, copy the sub-folders) and paste under `/opt/rstudio-server` 

* 
