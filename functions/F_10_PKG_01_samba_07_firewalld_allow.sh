# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable

if [[ "${firewalld_enabled}" = "auto" ]]; then
  firewalld_enabled="$(systemctl is-enabled firewalld | grep -Eo "enable|disable" )" # return : enable / disable
fi

if [[ "${firewalld_enabled}" = "disable" ]]; then
  echo "------- Stop / Disable Firewalld ------"
  systemctl stop firewalld
  systemctl disable firewalld

else
  echo "------- Start / Enable Firewalld ------"
  systemctl start firewalld
  systemctl enable firewalld
  echo ""

  for firewalld_allow_port in ${firewalld_allow_ports[@]} ; do
    echo "--------Allow Port: ${firewalld_allow_port} -----------"
    firewall-cmd --add-port=${firewalld_allow_port}
    firewall-cmd --add-port=${firewalld_allow_port} --permanent
    echo ""
  done

  echo "--------------Firewalld Reload-------------"
  firewall-cmd --reload
  echo "--------------Firewalld Rules-------------"
  firewall-cmd --list-all

fi
