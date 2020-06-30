# Samba4 - Active Directory (CentOS8)
  Samba4 with Active Directory (CentOS8) - Domain Controllers (AD-DC)

## Prepare
* Package Dependencies Required to Build Samba

  ```bash
  set -xueo pipefail

  yum update -y
  yum install -y dnf-plugins-core
  yum install -y epel-release
  yum config-manager --set-enabled PowerTools -y
  yum update -y
  
  yum install -y \
      --setopt=install_weak_deps=False \
      "@Development Tools" \
      acl \
      attr \
      autoconf \
      avahi-devel \
      bind-utils \
      binutils \
      bison \
      chrpath \
      cups-devel \
      curl \
      dbus-devel \
      docbook-dtds \
      docbook-style-xsl \
      flex \
      gawk \
      gcc \
      gdb \
      git \
      glib2-devel \
      glibc-common \
      glibc-langpack-en \
      glusterfs-api-devel \
      glusterfs-devel \
      gnutls-devel \
      gpgme-devel \
      gzip \
      hostname \
      htop \
      jansson-devel \
      keyutils-libs-devel \
      krb5-devel \
      krb5-server \
      libacl-devel \
      libarchive-devel \
      libattr-devel \
      libblkid-devel \
      libbsd-devel \
      libcap-devel \
      libcephfs-devel \
      libicu-devel \
      libnsl2-devel \
      libpcap-devel \
      libtasn1-devel \
      libtasn1-tools \
      libtirpc-devel \
      libunwind-devel \
      libuuid-devel \
      libxslt \
      lmdb \
      lmdb-devel \
      make \
      mingw64-gcc \
      ncurses-devel \
      openldap-devel \
      pam-devel \
      patch \
      perl \
      perl-Archive-Tar \
      perl-ExtUtils-MakeMaker \
      perl-Parse-Yapp \
      perl-Test-Simple \
      perl-generators \
      perl-interpreter \
      pkgconfig \
      popt-devel \
      procps-ng \
      psmisc \
      python3 \
      python3-devel \
      python3-dns \
      python3-gpg \
      python3-libsemanage \
      python3-markdown \
      python3-policycoreutils \
      readline-devel \
      redhat-lsb \
      rng-tools \
      rpcgen \
      rpcsvc-proto-devel \
      rsync \
      sed \
      sudo \
      systemd-devel \
      tar \
      tree \
      which \
      xfsprogs-devel \
      yum-utils \
      zlib-devel
  ```

## Build Samba4 from source
* Download source code (latest)
  * https://download.samba.org/pub/samba/samba-latest.tar.gz
* configure

  ```bash
  # ./configure
  ```

* If the configure script exits without an error, you see the following output:

  ```bash
  'configure' finished successfully (57.833s)`
  ```

* make

  ```bash
  # make
  ```

* If the configure script exits without an error, you see the following output:

  ```bash
  `'build' finished successfully (10m34.907s)`
  ```

* make install

  ```bash
  # make install
  ```

* If the configure script exits without an error, you see the following output:

  ```bash
  'install' finished successfully (3m57.107s)
  ```

* Adding Samba Commands to the $PATH Variable

  ```bash
  # cat .bash_profile [.bashrc]
  PATH=$PATH:$HOME/bin
  PATH=/usr/local/samba/bin/:/usr/local/samba/sbin/:$PATH
  export PATH
  ```

* Viewing Built Options of an Existing Installation

  ```bash
  `smbd -b`
  ```
