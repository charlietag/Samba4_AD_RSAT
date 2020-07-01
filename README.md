# Samba4 - Active Directory (CentOS8)
Samba4 with Active Directory (CentOS8) - Domain Controllers (AD-DC)

## Before Start
### Who You Are
* Small business owner
  * You might want a quick , easy to use, easy to maintain solution
  * You can try **NAS** to have both ***shared folder*** with ***AD*** **out of box**
    * https://www.synology.com/dsm/feature/active_directory
  
* IT engineer but **lazy** (or *productive* :D)
  * You might want to **build your own server** without any command line
  * You can try **ClearOS (community)**
    * https://www.clear.store/products/z-clearos-7-community
    * Quick glance on [YouTube Video](https://www.youtube.com/watch?v=pueCMuQ2acY&feature=emb_logo) (Shared by **Roger Nixon**)

* IT engineer and geek
  * You like to **build your own server** and figure out what is actually done
  * You can go on this document

### OS requirement
* I'm using ***CentOS 8*** to build ***Samba4-AD-DC*** here
* To avoid unpredictable exceptions, It might be a good choice to prepare your CentOS 8 through **[os_preparation](https://github.com/charlietag/os_preparation)**
  * https://github.com/charlietag/os_preparation

## Installation
### Automatically
---
#### Run script

```bash
# git clone https://github.com/charlietag/Samba4_AD_RSAT.git
# ./install.sh
```

### Manually
---
#### Prepare
Packages Dependencies Required to Build Samba4

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

#### Build Samba4 from source

RedHat does not support AD as a DC (only as a ad member), so we build it from source code. (ref. [SambaWiki](https://wiki.samba.org/index.php/Build_Samba_from_Source))

* Download source code (latest)
  
  ```bash
  wget https://download.samba.org/pub/samba/samba-latest.tar.gz
  ```
  
* configure

  ```bash
  # ./configure
  ```

  > if the configure script exits without an error, you see the following output:

    ```bash
    'configure' finished successfully (57.833s)`
    ```

* make

  ```bash
  # make
  ```

  > If the configure script exits without an error, you see the following output:

    ```bash
    `'build' finished successfully (10m34.907s)`
    ```

* make install

  ```bash
  # make install
  ```

  > If the configure script exits without an error, you see the following output:

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
  # smbd -b
  ```


## Setup
* 參考文件
  * https://wiki.samba.org/index.php/Setting_up_Samba_as_an_Active_Directory_Domain_Controller
* 開始設定
  * 問答式設定
    `samba-tool domain provision --use-rfc2307 --interactive`
  * 自動化設定
    * `# samba-tool domain provision --server-role=dc --use-rfc2307 --dns-backend=SAMBA_INTERNAL --realm=SAMDOM.EXAMPLE.COM --domain=SAMDOM --adminpass=Passw0rd`

---

```
Setting up sam.ldb rootDSE marking as synchronized
Fixing provision GUIDs
A Kerberos configuration suitable for Samba AD has been generated at /usr/local/samba/private/krb5.conf
Merge the contents of this file with your system krb5.conf or replace it with this one. Do not create a symlink!
Setting up fake yp server settings
nce the above files are installed, your Samba AD server will be ready to use
erver Role:           active directory domain controller
ostname:              DC1
etBIOS Domain:        SAMDOM
NS Domain:            samdom.example.com
OMAIN SID:            S-1-5-21-4151948209-2038588902-766361810
```

---

* 後面，就都可以交給 Windows RSAT 設定處理了
  * 樹系管理
  * GPO
  * Logon script
  * DNS
    * https://www.tecmint.com/manage-samba4-dns-group-policy-from-windows/
* 記得通通要用 DC1 (ostname)



## Manage Active Directory - DC with RSAT
* Logon script
  * net_share.bat
    ```
net use * /delete /Y
net use z: "\\192.168.1.73\shared_folder"
```
* [利用gpo自動部署網路磁碟機](https://www.azureunali.com/windows-ad-server%E5%88%A9%E7%94%A8gpo%E8%87%AA%E5%8B%95%E9%83%A8%E7%BD%B2%E7%B6%B2%E8%B7%AF%E7%A3%81%E7%A2%9F%E6%A9%9F/)

* [利用gpo自動部署網路磁碟機_方法二](https://activedirectorypro.com/map-network-drives-with-group-policy/)
  * The color of the triangle indicates the Action of the preference policy. If the Action is “`Update`”, you will see a `yellow` triangle. If the Action is “`Create`”, you will see a `green` triangle.

---

* 超完整說明
  * https://www.advancedinstaller.com/user-guide/tutorial-gpo.html

    ```
Methods of deployment
Group Policy supports two methods of deploying an MSI package:
Assign software - A program can be assigned per-user or per-machine. If its assigned per-user, it will be installed when the user logs on. However, if its assigned per-machine then the program will be installed for all users when the machine starts.
Publish software - A program can be published for one or more users. This program will be added to the Add or Remove Programs list and the user will be able to install it from there.
```

* 記得 AD 裡面的一切
  * 使用這個
    * `\\DC1\share_folder`
  * 不要這樣使用
    * `\\192.168.1.73\share_folder`

---
* [完整說明 2](https://newhelptech.wordpress.com/2017/06/29/step-by-step-deploying-software-using-group-policy-in-windows-server-2016/)
  * `gpupdate /force` (通常過一段時間 GPO 就會重新 update)
    * Ref. [link](https://www.urtech.ca/2017/01/solved-long-take-group-policies-take-effect/)
      * Unless you have changed the defaults, Group Policy is automatically updated `every 90 minutes` for both Computer and for User policies.  To stop all systems from flooding the servers and network, there is a random offset ranging from 0 to 30 minutes.  `This two hour window is the ‘background refresh’ time`.

  ```
10 – Now lets switch to our Windows 10 client PC, i do recommend that you run gpupdate /force in the client PC and then restart the client PC.
```
* https://www.youtube.com/watch?v=JRNCgvZs5v4

















## Reference
* Wiki
  * https://wiki.samba.org/index.php/User_Documentation

* Video
  * [YouTube](https://www.youtube.com/watch?v=FSDvz3_FFFc)
* Blog
  * 
  * RedHat does not support AD as a DC (only as a ad member)
    * compile from source
      * [Build_Samba_from_Source](https://wiki.samba.org/index.php/Build_Samba_from_Source)
      * [Package_Dependencies_Required_to_Build_Samba](https://wiki.samba.org/index.php/Package_Dependencies_Required_to_Build_Samba)



* ClearOS

  ---

  * 其他好用的中文分享
    * [2018/01/08/setting-samba-4-as-ad-domain-controller](https://william.pylabs.org/2018/01/08/setting-samba-4-as-ad-domain-controller/)
    * [2018/01/14/create-secondary-ad-using-samba](https://william.pylabs.org/2018/01/14/create-secondary-ad-using-samba/)
