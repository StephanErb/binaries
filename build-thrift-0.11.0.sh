#!/bin/bash

root=$(pwd -P)
INSTALL_PREFIX=install_dir

# NB: The custom bison/yacc setup works around old versions in Centos 6,
# OSX Yosemite, and OSX Sierra which are too old for Thrift 0.11.
#
# On OSX we also boostrap a custom flex. On Centos you will need to install
# it manually via:
#   yum install -y flex flex-devel

curl -O http://ftp.gnu.org/gnu/bison/bison-2.5.1.tar.gz && \
rm -rf bison-2.5.1 && \
tar -xzf bison-2.5.1.tar.gz && (
  cd bison-2.5.1 && \
  sh ./configure --prefix="$(pwd -P)/$INSTALL_PREFIX" && \
  make install
)

curl -O ftp://ftp.invisible-island.net/byacc/byacc-20140715.tgz && \
rm -rf byacc-20140715 && \
tar -xzf byacc-20140715.tgz && (
  cd byacc-20140715 && \
  sh ./configure --prefix="$(pwd -P)/$INSTALL_PREFIX" && \ 
  make install
)

export PATH=$(pwd -P)/bison-2.5.1/$INSTALL_PREFIX/bin:$(pwd -P)/byacc-20140715/$INSTALL_PREFIX/bin:$PATH

if [[ "`uname`" == "Darwin"* ]]; then
  # Upgraded to 2.6.0 to pick up OSX linker fix: https://sourceforge.net/p/flex/bugs/182/
  curl -L -O http://sourceforge.mirrorservice.org/f/fl/flex/flex-2.6.0.tar.gz && \
  rm -rf flex-2.6.0 && \
  tar -xzf flex-2.6.0.tar.gz && (
    cd flex-2.6.0 && \
    ./autogen.sh
    sh ./configure --prefix="$(pwd -P)/$INSTALL_PREFIX" && \
    make install
  )

  export PATH=$(pwd -P)/flex-2.6.0/$INSTALL_PREFIX/bin:$PATH
  LDFLAGS="-L$(pwd -P)/flex-2.6.0/$INSTALL_PREFIX/lib"
fi

# NB: The configure --wthout-* flags just disable building any runtime libs
# for the generated code.  We only want the codegen side of things.
curl -O http://archive.apache.org/dist/thrift/0.11.0/thrift-0.11.0.tar.gz && \
rm -rf thrift-0.11.0 && \
tar -xzf thrift-0.11.0.tar.gz && \ 
LDFLAGS="-all-static $LDFLAGS" && \
cd thrift-0.11.0 && \
sh ./configure \
  --disable-shared \
  --without-cpp \
  --without-c_glib \
  --without-csharp \
  --without-erlang \
  --without-java \
  --without-erlang \
  --without-lua \
  --without-python \
  --without-perl \
  --without-php \
  --without-php_extension \
  --without-qt4 \
  --without-qt5 \
  --without-dart \
  --without-ruby \
  --without-haskell \
  --without-go \
  --without-nodejs \
  --without-rs \
  --without-haxe \
  --without-dotnetcore \
  --without-d && \
make clean && \
make LDFLAGS="$LDFLAGS"
mv compiler/cpp/thrift ${root}/thrift-0.11.0.binary
