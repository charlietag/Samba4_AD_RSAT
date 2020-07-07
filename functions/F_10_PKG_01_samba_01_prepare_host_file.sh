# for fail2ban WARNING !
#   - Ref. https://github.com/charlietag/os_security#fail2ban-usage
#   * Classify /etc/hosts
#   * Add current hostname into /etc/hosts


# ----------------------------------------
# host file path
# ----------------------------------------
local target_host="/etc/hosts"
local backup_host="/etc/hosts.bak"



local host_contents="$(cat ${target_host})"
local host_name="$(hostname)"
local host_name_short="$(hostname -s)"
local host_name_all="${host_name_short} ${host_name}"
local host_ip="$(hostname -I | grep -Eo '(([0-9]{1,3})\.){3}([0-9]{1,3}){1}' | head -n 1)"
local host_contents_new=""
local host_hostname_only=""
# ----------------------------------------
# IPv4
# ----------------------------------------
# Process
local ipv4_contents="$(echo "${host_contents}"|grep -vE '^\s*#' | sed -re 's/#[[:print:]]*//g' |grep -E '(([0-9]{1,3})\.){3}([0-9]{1,3}){1}')"
local ipv4_filter_out_hostname="$(echo "${ipv4_contents}" |grep -vE "(([0-9]{1,3})\.){3}([0-9]{1,3}){1}[[:space:]]+( ${host_name}$)" | sed "s/ ${host_name}//g" | sed "s/ ${host_name_short}[[:space:]]*$//g")"
local only_ip_ipv4s="$(echo "${ipv4_filter_out_hostname}" | awk '{print $1}' | sed 's/\s*//g' | sort -n | uniq )"

# output
for only_ip_ipv4 in ${only_ip_ipv4s}; do

  host_hostname_only="$(echo "${ipv4_filter_out_hostname}" | grep "${only_ip_ipv4}" | sed "s/${only_ip_ipv4}//g"| sed 's/\s\+/\n/g'| sort -n|uniq |sed '/^\s*$/d' | sed ':a;N;$!ba;s/\n/ /g')"
  if [[ -n "${host_hostname_only}" ]]; then
    host_contents_new="${host_contents_new}${only_ip_ipv4} "
    host_contents_new="${host_contents_new}${host_hostname_only}\n"
  fi
done


# ----------------------------------------
# IPv6
# ----------------------------------------
# Process
local ipv6_contents="$(echo "${host_contents}"|grep -vE '^\s*#' | sed -re 's/#[[:print:]]*//g' |grep -E '([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}')"
local ipv6_filter_out_hostname="$(echo "${ipv6_contents}" |grep -vE "([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}[[:space:]]+( ${host_name}$)" | sed "s/ ${host_name}//g" | sed "s/ ${host_name_short}[[:space:]]*$//g")"
local only_ip_ipv6s="$(echo "${ipv6_filter_out_hostname}" | awk '{print $1}' | sed 's/\s*//g' | sort -n | uniq )"

# output
for only_ip_ipv6 in ${only_ip_ipv6s}; do

  host_hostname_only="$(echo "${ipv6_filter_out_hostname}" | grep "${only_ip_ipv6}" | sed "s/${only_ip_ipv6}//g"| sed 's/\s\+/\n/g'| sort -n|uniq |sed '/^\s*$/d' | sed ':a;N;$!ba;s/\n/ /g')"
  if [[ -n "${host_hostname_only}" ]]; then
    host_contents_new="${host_contents_new}${only_ip_ipv6} "
    host_contents_new="${host_contents_new}${host_hostname_only}\n"
  fi
done

# ----------------------------------------
# Result
# ----------------------------------------
host_contents_new="${host_contents_new}\n"
host_contents_new="${host_contents_new}${host_ip} ${host_name_all}\n"
host_contents_new="${host_contents_new}::1 ${host_name_all}"

\cp -a --backup=t ${target_host} ${backup_host}
echo -e "${host_contents_new}" > ${target_host}

# ----------------------------------------
# Print out msg and result
# ----------------------------------------
echo "for Samba4 requirements !"
echo "  - Ref. https://wiki.samba.org/index.php/Setting_up_Samba_as_an_Active_Directory_Domain_Controller#Preparing_the_Installation"
echo "  * Classify /etc/hosts"
echo "  * Add current hostname into /etc/hosts"
echo ""
echo "--------------------------------------------"
echo "/etc/hosts"
echo "--------------------------------------------"
echo "------ Before ------"
echo -e "${host_contents}"
echo ""
echo "------ After ------"
cat ${target_host}
echo ""
