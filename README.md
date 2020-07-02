Table of Contents
=================
- [Samba4 - Active Directory (CentOS8)](#samba4---active-directory--centos8-)
  * [Before Start](#before-start)
    + [Who You Are](#who-you-are)
    + [OS requirement](#os-requirement)
  * [Installation](#installation)
    + [Automatically](#automatically)
      - [Run script](#run-script)
    + [Manually](#manually)
      - [Prepare](#prepare)
      - [Preparing the Installation](#preparing-the-installation)
      - [Build Samba4 from source](#build-samba4-from-source)
  * [Setup](#setup)
    + [Provisioning Samba AD in Interactive Mode](#provisioning-samba-ad-in-interactive-mode)
    + [Provisioning Samba AD in Non-interactive Mode](#provisioning-samba-ad-in-non-interactive-mode)
  * [CentOS 8 - Samba configurations](#centos-8---samba-configurations)
    + [Managing the Samba AD DC Service Using Systemd](#managing-the-samba-ad-dc-service-using-systemd)
    + [Useful commands](#useful-commands)
  * [Manage Active Directory - DC with RSAT (Windows)](#manage-active-directory---dc-with-rsat--windows-)
    + [After install RSAT](#after-install-rsat)
    + [Features](#features)
    + [RSAT Management (Windows GUI)](#rsat-management--windows-gui-)
  * [Backup & Recovery](#backup---recovery)
    + [Backup](#backup)
    + [Restore](#restore)
  * [Note](#note)
  * [Reference](#reference)

# Samba4 - Active Directory (CentOS8)
[Samba4](https://wiki.samba.org/index.php/User_Documentation) with Active Directory (CentOS8) - Domain Controllers (AD-DC)

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
#### Run script

```bash
# git clone https://github.com/charlietag/Samba4_AD_RSAT.git
# ./install.sh
```

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
  ps ax | egrep "samba|smbd|nmbd|winbindd" | grep -v 'grep' | awk '{print $1}' | xargs -i bash -c "kill -9 {}"
  ```

* Verify that the `/etc/hosts` file on the DC correctly resolves the fully-qualified domain name (FQDN) and short host name to the LAN IP address of the DC. For example:

  ```bash
  127.0.0.1     localhost localhost.localdomain
  192.168.1.73  DC1.samdom.example.com DC1
  ```

* Remove the existing `smb.conf` file.

  ```bash
  smbd -b | grep "CONFIGFILE" | awk '{print $2}' | xargs -i bash -c "mv {} {}_bak"
  ```

* Remove all Samba database files, such as `*.tdb` and `*.ldb` files.

  ```bash
  smbd -b | egrep "LOCKDIR|STATEDIR|CACHEDIR|PRIVATE_DIR" | awk '{print $2}' | xargs -i bash -c "rm -fr {}/*"
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
nce the above files are installed, your Samba AD server will be ready to use
erver Role:           active directory domain controller
ostname:              DC1
etBIOS Domain:        SAMDOM
NS Domain:            samdom.example.com
OMAIN SID:            S-1-5-21-4151948209-2038588902-766361810
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
* `# samba-tool domain level show`

  ```bash
  Domain and forest function level for domain 'DC=samdom,DC=example,DC=com'

  Forest function level: (Windows) 2008 R2
  Domain function level: (Windows) 2008 R2
  Lowest function level of a DC: (Windows) 2008 R2
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

* Check samba status

  ```bash
  ps axf | egrep "samba|smbd|winbindd"
  ```

## Manage Active Directory - DC with RSAT (Windows)
**Reference** [Samba Wiki - Installing_RAST](https://wiki.samba.org/index.php/Installing_RSAT)

Now your Samba is built, you can let **Windows RSAT** to deal with left configuration

### After install RSAT
* Make sure THE ADMIN WINDOWS(RSAT) is joined to the domain
* Make sure THE DNS is pointed to the currect DNS SERVER (Mostly, the same as AD-DC server)

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

## Reference

* Video
  * [YouTube Video](https://www.youtube.com/watch?v=FSDvz3_FFFc) (Shared by **Networking SS**)
