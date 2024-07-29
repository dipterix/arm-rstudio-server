## Compile RStudio-Server on MacOS ARM CPU

### Download RStudio-Server

Go to Github, git-clone the RStudio-Server source code to the `Downloads` folder. Do not use the released version (the compiling process requires `.git` folder to exists for some reason.

Open terminal, run

```sh
cd ~/Downloads
git clone https://github.com/rstudio/rstudio.git
cd rstudio
RSTUDIO_SRCDIR=~/Downloads/rstudio/
```

In the following text, I'll use `${RSTUDIO_SRCDIR}` to reference the RStudio source directory.

### Install pre-requisites

#### 1. Remove x86 dependence

Open `${RSTUDIO_SRCDIR}/dependencies/osx`, use your text editor to open all the files starting with "install-dependencies-" and find lines that require `x86` brew. Delete them.

For example, remove something like

```
find-program BREW_X86 brew       \
      "${HOME}/homebrew/x86_64/bin" \
      "/usr/local/bin"
```

The reason to remove them is because old RStudio depends on `qt`, which compiles on `x86` intel chips, but new RStudio is built with Electron. 
However, the devs haven't removed this dependency.

#### 2. Fix `soci` makefile

As of writing this memo, `soci` (one of the dependencies) does not compile correctly. The reason is because `cmake` has deprecated certain old flags. 
Temporary fix is to open `${RSTUDIO_SRCDIR}/dependencies/common/install-soci` with your editor, go to near line 87, append the following line `CMAKE_GENERATOR="Unix Makefiles"`. 
Then go to line 98, add `-DCMAKE_MACOSX_RPATH=ON \`

So basically

```
if has-program ninja
then 
   CMAKE_GENERATOR="Ninja"
   MAKEFLAGS="-w dupbuild=warn ${MAKEFLAGS}"
else
   CMAKE_GENERATOR="Unix Makefiles"
fi
CMAKE_GENERATOR="Unix Makefiles"

...

"${CMAKE}" -G"${CMAKE_GENERATOR}"                      \
   -DCMAKE_MACOSX_RPATH=ON \
   -DCMAKE_POLICY_DEFAULT_CMP0063="NEW"                \
...
```

The goal is to force cmake to use "Unix Makefiles" and also set `CMAKE_MACOSX_RPATH` to `ON`.

#### 3. Make sure `$PATH` is clean

Close your corrent terminal, start a clean new terminal and run

```sh
echo $PATH
```

Make sure the `PATH` environment is as clean as possible. For example, remove any path that contains conda, node.js, and homebrew. They will cause packages such `xml2` to fail.

If you are inside of python virtual environment or conda environment, quit that environment first! Thanks for miniconda, I learnt a hard-lesson by letting it screw up everything in my first attempt. 

My `PATH` is set as 

```sh
PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin
```


#### 4. Run `install-dependencies-osx`

```sh
cd "${RSTUDIO_SRCDIR}/dependencies/osx"
./install-dependencies-osx
```

This process usually takes 30 min to finish.

#### 5. Fix `node` folder name

Go to `${RSTUDIO_SRCDIR}/dependencies/common/node`, duplicate all the folders within, and remove `-arm` from the folder names. This is because the make process requires the node folders to be something like `20.15.1` rather than `20.15.1-arm64`. 

Here's the folder before:

```
20.15.1-arm64
20.15.1-arm64-patched
```

Here's after:

```
20.15.1
20.15.1-arm64
20.15.1-arm64-patched
20.15.1-patched
```

### Compile & install

Follow the "INSTALL" file (included in the source tar ball), you can run

```sh
cd "${RSTUDIO_SRCDIR}"
mkdir build
cd build
/opt/homebrew/bin/cmake .. -DRSTUDIO_TARGET=Server -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/Applications/RStudioServer
```

Alternatively, you can download `cmake` GUI and configure from there

Once `cmake` finishes without error, run

```sh
sudo make install
```

to install.

This will install RStudio server to `/Applications/RStudioServer`. 
