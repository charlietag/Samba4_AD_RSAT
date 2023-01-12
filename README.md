Table of Contents
=================
- [Samba4 - Active Directory (CentOS 8)](#samba4---active-directory-centos-8)
  - [Before Start](#before-start)
    - [Who You Are](#who-you-are)
    - [OS requirement](#os-requirement)
  - [Installation](#installation)
    - [Automatically](#automatically)
      - [Step 1 - Config](#step-1---config)
      - [Step 2 - Install](#step-2---install)
      - [Step 3 - Done and manage AD DC using RSAT](#step-3---done-and-manage-ad-dc-using-rsat)
    - [Manually](#manually)
      - [Prepare](#prepare)
      - [Preparing the Installation](#preparing-the-installation)
      - [Build Samba4 from source](#build-samba4-from-source)
  - [Setup](#setup)
    - [Provisioning Samba AD in Interactive Mode](#provisioning-samba-ad-in-interactive-mode)
    - [Provisioning Samba AD in Non-interactive Mode](#provisioning-samba-ad-in-non-interactive-mode)
  - [CentOS 8 - Samba configurations](#centos-8---samba-configurations)
    - [Managing the Samba AD DC Service Using Systemd](#managing-the-samba-ad-dc-service-using-systemd)
    - [Useful commands](#useful-commands)
  - [Manage Active Directory - DC with RSAT (Windows)](#manage-active-directory---dc-with-rsat-windows)
    - [After install RSAT](#after-install-rsat)
    - [Features](#features)
    - [RSAT Management (Windows GUI)](#rsat-management-windows-gui)
  - [Backup & Recovery](#backup--recovery)
    - [Backup](#backup)
    - [Restore](#restore)
  - [Note](#note)
  - [Other goodies](#other-goodies)
  - [Reference](#reference)

# Samba4 - Active Directory (CentOS 8)
[Samba4](https://wiki.samba.org/index.php/User_Documentation) with Active Directory (CentOS 8) - Domain Controllers (AD-DC)

> Windows Active Directory (Domain Controller) is just like [puppet](https://puppet.com/) in Microsoft world. Hope you enjoy it

Deploy MSI software via Active DIrectory GPO:<br/>
![AD_MSI_software](/screenshots/AD_MSI_software.png)

Mapping network drive via Active DIrectory GPO:<br/>
![map_net_drive_preference_script](/screenshots/map_net_drive_preference_script.png)

DNS management via RSAT:<br/>
![AD_DNS_manager](/screenshots/AD_DNS_manager.png)


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

**Reference** [Samba Wiki - Build_Samba_from_Source](https://wiki.samba.org/index.php/Build_Samba_from_Source)

RedHat does not support AD as a DC (only as a ad member), so we build it from source code.

### Automatically
---
#### Step 1 - Config
* Before installation

  ```bash
  dnf clean all
  dnf install -y git
  git clone https://github.com/charlietag/Samba4_AD_RSAT.git
  ```

* Make sure config files exists , you can copy from sample to **modify**.

  ```bash
  cd databag
  ls |xargs -I{} bash -c "cp {} \$(echo {}|sed 's/\.sample//g')"
  ```

* Mostly used configuration :

  ```bash
  databag/
  ├── F_10_PKG_01_samba_00_prepare_01_hostname.cfg
  ├── F_10_PKG_01_samba_04_provision_ad.cfg
  ```

* Verify **ONLY modified** config files (with syntax color).

  ```bash
  cd databag

  echo ; \
  ls *.cfg | xargs -I{} bash -c " \
  echo -e '\e[0;33m'; \
  echo ---------------------------; \
  echo {}; \
  echo ---------------------------; \
  echo -n -e '\033[00m' ; \
  echo -n -e '\e[0;32m'; \
  cat {} | grep -v 'plugin_load_databag.sh' | grep -vE '^\s*#' |sed '/^\s*$/d'; \
  echo -e '\033[00m' ; \
  echo "
  ```

#### Step 2 - Install
* Start installation

  ```bash
  ./start -a
  ```

#### Step 3 - Done and manage AD DC using RSAT
* On your windows
  1. Point your dns to Samba AD-DC
  1. Join domain (Samba AD-DC)
  1. Start to manage your AD DC ([RSAT](#manage-active-directory---dc-with-rsat-windows))

### Manually
---
#### Prepare
**Reference** [Samba Wiki - Package_Dependencies_Required_to_Build_Samba#Verified_Package_Dependencies](https://wiki.samba.org/index.php/Package_Dependencies_Required_to_Build_Samba#Verified_Package_Dependencies)

Packages Dependencies Required to Build Samba4

* Install dependent packages
  * https://git.samba.org/?p=samba.git;a=blob_plain;f=bootstrap/generated-dists/centos8/bootstrap.sh;hb=v4-12-test

#### Preparing the Installation
**Reference** [Samba Wiki - Setting_up_Samba_as_an_Active_Directory_Domain_Controller](https://wiki.samba.org/index.php/Setting_up_Samba_as_an_Active_Directory_Domain_Controller)

* Remove default Samba to avoid conflicts

  ```bash
  yum remove -y samba
  ```

* Verify that no Samba processes are running:

  ```bash
  ps ax | egrep "samba|smbd|nmbd|winbindd" | grep -v 'grep' | awk '{print $1}' | xargs -I{} bash -c "kill -9 {}"
  ```

* Verify that the `/etc/hosts` file on the DC correctly resolves the fully-qualified domain name (FQDN) and short host name to the LAN IP address of the DC. For example:

  ```bash
  127.0.0.1     localhost localhost.localdomain
  192.168.1.73  DC1.samdom.example.com DC1
  ```

* Remove the existing `smb.conf` file.

  ```bash
  smbd -b | grep "CONFIGFILE" | awk '{print $2}' | xargs -I{} bash -c "mv {} {}_bak"
  ```

* Remove all Samba database files, such as `*.tdb` and `*.ldb` files.

  ```bash
  smbd -b | egrep "LOCKDIR|STATEDIR|CACHEDIR|PRIVATE_DIR" | awk '{print $2}' | xargs -I{} bash -c "rm -fr {}/*"
  ```

* Remove an existing `/etc/krb5.conf` file

  ```bash
  mv /etc/krb5.conf /etc/krb5.conf.bak

  # After Buld from source
  cp /usr/local/samba/private/krb5.conf /etc/krb5.conf
  ```




#### Build Samba4 from source

* Download source code (latest)

  ```bash
  wget https://download.samba.org/pub/samba/samba-latest.tar.gz
  ```

* configure

  ```bash
  # ./configure
  ```

  * if the configure script exits without an error, you see the following output:

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

  *  If the configure script exits without an error, you see the following output:

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
**Reference** [Samba Wiki - Setting_up_Samba_as_an_Active_Directory_Domain_Controller](https://wiki.samba.org/index.php/Setting_up_Samba_as_an_Active_Directory_Domain_Controller)

### Provisioning Samba AD in Interactive Mode

To provision a Samba AD interactively, run:

  ```bash
  samba-tool domain provision --use-rfc2307 --interactive
  ```

  ```bash
  # samba-tool domain provision --use-rfc2307 --interactive
  Realm [SAMDOM.EXAMPLE.COM]: SAMDOM.EXAMPLE.COM
   Domain [SAMDOM]: SAMDOM
   Server Role (dc, member, standalone) [dc]: dc
   DNS backend (SAMBA_INTERNAL, BIND9_FLATFILE, BIND9_DLZ, NONE) [SAMBA_INTERNAL]: SAMBA_INTERNAL
   DNS forwarder IP address (write 'none' to disable forwarding) [10.99.0.1]: 8.8.8.8
  Administrator password: Passw0rd
  Retype password: Passw0rd
  Looking up IPv4 addresses
  Looking up IPv6 addresses
  No IPv6 address will be assigned
  Setting up share.ldb
  Setting up secrets.ldb
  Setting up the registry
  Setting up the privileges database
  Setting up idmap db
  Setting up SAM db
  Setting up sam.ldb partitions and settings
  Setting up sam.ldb rootDSE
  Pre-loading the Samba 4 and AD schema
  Adding DomainDN: DC=samdom,DC=example,DC=com
  Adding configuration container
  Setting up sam.ldb schema
  Setting up sam.ldb configuration data
  Setting up display specifiers
  Modifying display specifiers
  Adding users container
  Modifying users container
  Adding computers container
  Modifying computers container
  Setting up sam.ldb data
  Setting up well known security principals
  Setting up sam.ldb users and groups
  Setting up self join
  Adding DNS accounts
  Creating CN=MicrosoftDNS,CN=System,DC=samdom,DC=example,DC=com
  Creating DomainDnsZones and ForestDnsZones partitions
  Populating DomainDnsZones and ForestDnsZones partitions
  Setting up sam.ldb rootDSE marking as synchronized
  Fixing provision GUIDs
  A Kerberos configuration suitable for Samba 4 has been generated at /usr/local/samba/private/krb5.conf
  Setting up fake yp server settings
  Once the above files are installed, your Samba4 server will be ready to use
  Server Role:           active directory domain controller
  Hostname:              DC1
  NetBIOS Domain:        SAMDOM
  DNS Domain:            samdom.example.com
  DOMAIN SID:            S-1-5-21-2614513918-2685075268-614796884
  ```


### Provisioning Samba AD in Non-interactive Mode
For example, to provision a Samba AD non-interactively with the following settings:

* Server role: dc
* NIS extensions enabled
* Internal DNS back end
* Kerberos realm and AD DNS zone: samdom.example.com
* NetBIOS domain name: SAMDOM
* Domain administrator password: Passw0rd
* Server Name: dc1
* HOSTNAME
  * FQDN:       dc1.samdom.example.com
  * Realm:      samdom.example.com
  * Domain:     samdom
  * hostname:   dc1
* IP: 192.168.1.73

```bash
# samba-tool domain provision --server-role=dc --use-rfc2307 --dns-backend=SAMBA_INTERNAL --realm=SAMDOM.EXAMPLE.COM --domain=SAMDOM --adminpass=Passw0rd
```

```bash
 Setting up sam.ldb rootDSE marking as synchronized
 Fixing provision GUIDs
 A Kerberos configuration suitable for Samba AD has been generated at /usr/local/samba/private/krb5.conf
 Merge the contents of this file with your system krb5.conf or replace it with this one. Do not create a symlink!
 Setting up fake yp server settings
Once the above files are installed, your Samba AD server will be ready to use
Server Role:           active directory domain controller
Hostname:              DC1
NetBIOS Domain:        SAMDOM
DNS Domain:            samdom.example.com
DOMAIN SID:            S-1-5-21-4151948209-2038588902-766361810
```

## CentOS 8 - Samba configurations
* `/usr/local/samba/etc/smb.conf`

  ```bash
  # Global parameters
  [global]
          dns forwarder = 8.8.8.8
          netbios name = DC1
          realm = SAMDOM.EXAMPLE.COM
          server role = active directory domain controller
          workgroup = SAMDOM
          idmap_ldb:use rfc2307 = yes

  [sysvol]
          path = /usr/local/samba/var/locks/sysvol
          read only = No

  [netlogon]
          path = /usr/local/samba/var/locks/sysvol/samdom.example.com/scripts
          read only = No
  [shared_folder]
          comment = Just Share
          path = /SAMBA_SHARE
          guest ok = no
          browseable = yes
          writable = yes
  [shared_folder_A]
          comment = Just Share
          path = /SAMBA_SHARE_A
          guest ok = no
          browseable = yes
          writable = yes
  ```

* `/etc/hosts`

  ```bash
  127.0.0.1     localhost localhost.localdomain
  192.168.1.73  DC1.samdom.example.com DC1
  ```

* `/etc/resolv.conf`

  ```bash
  #nameserver 8.8.8.8
  #nameserver 8.8.4.4
  search samdom.example.com
  nameserver 192.168.1.73
  ```

### Managing the Samba AD DC Service Using Systemd
Reference [Samba Wiki - Managing_the_Samba_AD_DC_Service_Using_Systemd](https://wiki.samba.org/index.php/Managing_the_Samba_AD_DC_Service_Using_Systemd)

* Disable default samba services `smbd` `winbindd`

  ```bash
  # systemctl mask smbd nmbd winbind
  # systemctl disable smbd nmbd winbind
  ```

* Create the `/etc/systemd/system/samba-ad-dc.service` file with the following content:

  ```bash
  [Unit]
  Description=Samba Active Directory Domain Controller
  After=network.target remote-fs.target nss-lookup.target

  [Service]
  Type=forking
  ExecStart=/usr/local/samba/sbin/samba -D
  PIDFile=/usr/local/samba/var/run/samba.pid
  ExecReload=/bin/kill -HUP $MAINPID

  [Install]
  WantedBy=multi-user.target
  ```

* Reload the systemd configuration:

  ```bash
  # systemctl daemon-reload
  ```

* Start samba4 service via systemd

  ```bash
  # systemctl enable samba-ad-dc
  # systemctl start samba-ad-dc
  ```

### Useful commands
* Running samba server for debug

  ```bash
  # systemctl stop samba-ad-dc
  ```

  ```bash
  # samba -i
  samba version 4.12.3 started.
  Copyright Andrew Tridgell and the Samba Team 1992-2020
  binary_smbd_main: samba: using 'prefork' process model
  ...
  ```

* `# samba-tool domain level show`

  ```bash
  Domain and forest function level for domain 'DC=samdom,DC=example,DC=com'

  Forest function level: (Windows) 2008 R2
  Domain function level: (Windows) 2008 R2
  Lowest function level of a DC: (Windows) 2008 R2
  ```

* `# samba-tool fsmo show`

  ```bash
  SchemaMasterRole owner: CN=NTDS Settings,CN=DC1,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=samdom,DC=example,DC=com
  InfrastructureMasterRole owner: CN=NTDS Settings,CN=DC1,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=samdom,DC=example,DC=com
  RidAllocationMasterRole owner: CN=NTDS Settings,CN=DC1,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=samdom,DC=example,DC=com
  PdcEmulationMasterRole owner: CN=NTDS Settings,CN=DC1,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=samdom,DC=example,DC=com
  DomainNamingMasterRole owner: CN=NTDS Settings,CN=DC1,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=samdom,DC=example,DC=com
  DomainDnsZonesMasterRole owner: CN=NTDS Settings,CN=DC1,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=samdom,DC=example,DC=com
  ForestDnsZonesMasterRole owner: CN=NTDS Settings,CN=DC1,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=samdom,DC=example,DC=com
  ```

* `# samba-tool drs showrepl`

  ```bash
  Default-First-Site-Name\DC1
  DSA Options: 0x00000001
  DSA object GUID: d39c6176-a45b-41f0-a84b-43fd50b54613
  DSA invocationId: 50869469-3cbf-4e25-9bfc-cb6fb5641fb5

  ==== INBOUND NEIGHBORS ====

  ==== OUTBOUND NEIGHBORS ====

  ==== KCC CONNECTION OBJECTS ====

  ```

* `# smbclient //localhost/netlogon -UAdministrator -c 'ls'`

  ```bash
  Enter SAMDOM\Administrator's password:
    .                                   D        0  Fri Jun 19 14:23:11 2020
    ..                                  D        0  Sat Jun 20 09:16:15 2020

                  17811456 blocks of size 1024. 12197992 blocks available
  ```

* `# smbclient -L localhost -U%`

  ```bash
          Sharename       Type      Comment
          ---------       ----      -------
          sysvol          Disk
          netlogon        Disk
          IPC$            IPC       IPC Service (Samba 4.12.3)
  SMB1 disabled -- no workgroup available
  ```

* `# samba-tool user list`

  ```bash
  Guest
  Administrator
  charlie
  krbtgt
  ```

* Check samba status

  ```bash
  ps axf | egrep "samba|smbd|winbindd"
  ```

* Check samba config

  ```bash
  # testparm
  Load smb config files from /usr/local/samba/etc/smb.conf
  Loaded services file OK.
  Server role: ROLE_ACTIVE_DIRECTORY_DC

  Press enter to see a dump of your service definitions

  # Global parameters
  [global]
          dns forwarder = 8.8.8.8
          passdb backend = samba_dsdb
          realm = SAMDOM.EXAMPLE.COM
          server role = active directory domain controller
          workgroup = SAMDOM
          rpc_server:tcpip = no
          rpc_daemon:spoolssd = embedded
          rpc_server:spoolss = embedded
          rpc_server:winreg = embedded
          rpc_server:ntsvcs = embedded
          rpc_server:eventlog = embedded
          rpc_server:srvsvc = embedded
          rpc_server:svcctl = embedded
          rpc_server:default = external
          winbindd:use external pipes = true
          idmap_ldb:use rfc2307 = yes
          idmap config * : backend = tdb
          map archive = No
          vfs objects = dfs_samba4 acl_xattr


  [sysvol]
          path = /usr/local/samba/var/locks/sysvol
          read only = No


  [netlogon]
          path = /usr/local/samba/var/locks/sysvol/samdom.example.com/scripts
          read only = No


  [shared_folder]
          comment = Just Share
          path = /SAMBA_SHARE
          read only = No


  [shared_folder_A]
          comment = Just Share
          path = /SAMBA_SHARE_A
          read only = No
  ```

## Manage Active Directory - DC with RSAT (Windows)
**Reference** [Samba Wiki - Installing_RAST](https://wiki.samba.org/index.php/Installing_RSAT)

Now your Samba is built, you can let **Windows RSAT** to deal with left configuration

### After install RSAT

* Make sure
  1. THE DNS is pointed to the currect DNS SERVER (Mostly, the same as AD-DC server)
  1. THE ADMIN WINDOWS(RSAT) is joined to the domain
  1. Firewalld is setup correctly on Samba4 server (Ref. [SambaWiki-Samba_AD_DC_Port_Usage](https://wiki.samba.org/index.php/Samba_AD_DC_Port_Usage))

### Features
* Active Directory Forest Management
* GPO deploy
  * [tutorial-gpo](https://www.advancedinstaller.com/user-guide/tutorial-gpo.html) (Shared by **Advanced Installer**)
* DNS (Samba internal dns)
  * [Manage Samba4 AD Domain Controller DNS and Group Policy from Windows](https://www.tecmint.com/manage-samba4-dns-group-policy-from-windows/) (shared by **Matei Cezar**)

### RSAT Management (Windows GUI)
* In this sample : *Remember to use `DC1` (hostname) to connect*
  * DO
    * `\\DC1\share_folder`
  * DONT
    * `\\192.168.1.73\share_folder`

* GPO Deploy Sample (Map Network Drives)
  * Logon script
    * Reference
      * [link](https://newhelptech.wordpress.com/2017/07/06/step-by-step-how-to-configuring-scripts-with-gpos-in-windows-server-2016/) (Shared by **newhelptech**)
    * net_share.bat

      ```bash
      net use * /delete /Y
      net use z: "\\DC1\shared_folder"
      ```

  * RSAT GUI management
    * Reference
      * [link](https://activedirectorypro.com/map-network-drives-with-group-policy/) (Shared by **Sifad Hussain**)
    * The color of the triangle indicates the Action of the preference policy.
      * `yellow` triangle - the Action is “`Update`”
      * `green`  triangle - If the Action is “`Create`”

* GPO Deploy Sample (Deploy MSI software)
  * Reference
    * [link](https://www.advancedinstaller.com/user-guide/tutorial-gpo.html) (Shared by **Advanced Installer**)
    * [link](https://newhelptech.wordpress.com/2017/06/29/step-by-step-deploying-software-using-group-policy-in-windows-server-2016/) (Shared by newhelptech)
  * Methods of deployment - Group Policy supports two methods of deploying an MSI package:
    * Assign(**assign mode**) software - A program can be assigned ***per-user*** or ***per-machine***
      * per-user
        * It will be installed when the user logs on. However
      * Per-machine
        * The program will be installed for all users when the machine starts (**reboot**).
    * Publish(**publish mode**) software - A program can be published for one or more users.
      * This program will be added to the ***Add or Remove Programs list*** and the user will be able to install it themselves from there.

## Backup & Recovery
**Reference** [Samba Wiki - Back_up_and_Restoring_a_Samba_AD_DC](https://wiki.samba.org/index.php/Back_up_and_Restoring_a_Samba_AD_DC)

**Reference** [PDF](screenshots/samba_backup_restore.pdf) (Shared by **Catalyst**)

### Backup
* Be sure to run backup on AD-DC

  ```bash
  # mkdir -p /opt/ad_dc_bak_files/
  # samba-tool domain backup offline --targetdir=/opt/ad_dc_bak_files/
  ```

### Restore
* Be sure to restore to a brand new AD-DC CentOS 8 server

  ```bash
  # samba-tool domain backup restore \
      --backup-file=/opt/ad_dc_bak_files/samba-backup-2020-07-02T14-44-18.295073.tar.bz2
  ```

## Note
* After GPO is set, client user may not take effect immediately
  * Reference
    * [link](https://www.urtech.ca/2017/01/solved-long-take-group-policies-take-effect/)
  * Unless you have changed the defaults, Group Policy is automatically updated **`every 90 minutes`** for **both Computer and for User policies**.
  * To stop all systems from flooding the servers and network, there is a random offset ranging from 0 to 30 minutes.  **`This two hour window is the ‘background refresh’ time`**.

* Force client to update gpo
  * Reference
    * [YouTube Video](https://www.youtube.com/watch?v=JRNCgvZs5v4) (Shared by **Chris Walker**)
  * `gpupdate /force`

* AD-DC config screenshot (CentOS 8)
![ad_DC_config](/screenshots/ad_DC_config.png)

* Setting up logon script
![method_logon_script](/screenshots/method_logon_script.png)

* Method to activate gpo
![method_activate_gpo](/screenshots/method_activate_gpo.png)

* Upgrade Samba4
  * Just do the whole installation above again (It would be better to install Samba4 on a clean server)

## Other goodies

- [FreeIPA](https://www.freeipa.org) - FreeIPA is an integrated security information management solution combining Linux (Fedora), 389 Directory Server, MIT Kerberos, NTP, DNS, Dogtag (Certificate System). It consists of a web interface and command-line administration tools.

## Reference

* Video
  * [YouTube Video](https://www.youtube.com/watch?v=FSDvz3_FFFc) (Shared by **Networking SS**)
