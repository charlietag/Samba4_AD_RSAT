
# --------------Load .bash_profile-------------
# Load .bash_profile to activate samba commands
. ${PLUGINS}/plugin_load_bash_profile.sh
# --------------Load .bash_profile-------------


local smbd_command="$(command -v smbd)"

# Remove default Samba to avoid conflicts
echo "--- Remove default Samba package ---"
rpm --quiet -q samba && dnf remove -y samba

# Make sure that no Samba processes are running
echo "--- Stop samba daemon if exists ---"

# Avoid to kill this script itself --->  grep -Ev "grep|${FUNCNAME[1]}"
ps ax | egrep "samba|smbd|nmbd|winbindd" |  grep -Ev "grep|${FUNCNAME[1]}" | awk '{print $1}' | xargs -I{} bash -c "kill -9 {}"

# Remove the existing smb.conf file
echo "--- Remove samba config if exists ---"
[[ -n "${smbd_command}" ]] && smbd -b | grep "CONFIGFILE" | awk '{print $2}' | xargs -I{} bash -c "\cp -a --backup=t {} {}_bak; rm -f {}"

# Remove all Samba database files, such as *.tdb and *.ldb files.
echo "--- Remove samba database files if exists ---"
[[ -n "${smbd_command}" ]] && smbd -b | egrep "LOCKDIR|STATEDIR|CACHEDIR|PRIVATE_DIR" | awk '{print $2}' | xargs -I{} bash -c "rm -fr {}/*"

# Remove an existing /etc/krb5.conf file
echo "--- Remove /etc/krb5.conf files if exists ---"
if [[ -f /etc/krb5.conf ]]; then
  \cp -a --backup=t /etc/krb5.conf /etc/krb5.conf.bak
  rm -f /etc/krb5.conf
fi
