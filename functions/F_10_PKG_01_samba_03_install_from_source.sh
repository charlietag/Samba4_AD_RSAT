
#-----------------------------------------------------------------------------------------
# Compile and install samba4
#-----------------------------------------------------------------------------------------
cd $TMP

#wget https://download.samba.org/pub/samba/samba-latest.tar.gz  -O - | tar -xz

#cd samba-*

check_install_status() {
  local this_rc=$1
  local this_process="$2"
  if [[ ${this_rc} -ne 0 ]]; then
    echo "Failed installing Samba4 while \"${this_process}\"......."
    exit
  fi
}

local inst_cmd


# Configure
inst_cmd='./configure'

eval "${inst_cmd}"
check_install_status $? "${inst_cmd}"

# Make
inst_cmd='make'

eval "${inst_cmd}"
check_install_status $? "${inst_cmd}"

# Make Install
inst_cmd='make install'

eval "${inst_cmd}"
check_install_status $? "${inst_cmd}"

# Setup PATH
echo "Setup PATH..."

sed -i '/export PATH/d' /root/.bash_profile
sed -i '/\/usr\/local\/samba\/bin\//d' /root/.bash_profile

echo 'PATH=/usr/local/samba/bin/:/usr/local/samba/sbin/:$PATH' >> /root/.bash_profile
echo "export PATH" >> /root/.bash_profile

