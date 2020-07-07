# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable


# --------------Load .bash_profile-------------
# Load .bash_profile to activate samba commands
. ${PLUGINS}/plugin_load_bash_profile.sh
# --------------Load .bash_profile-------------


samba-tool domain provision --server-role=${samba_server_role} --use-rfc2307 --dns-backend=${samba_dns_backend} --realm=${samba_realm} --domain=${samba_domain} --adminpass=${samba_admin_password}



# A Kerberos configuration suitable for Samba AD has been generated
if [[ -f /usr/local/samba/private/krb5.conf ]]; then
  cat /usr/local/samba/private/krb5.conf > /etc/krb5.conf
fi
