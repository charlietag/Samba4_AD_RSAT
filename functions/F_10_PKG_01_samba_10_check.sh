# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable

# --------------Load .bash_profile-------------
# Load .bash_profile to activate samba commands
. ${PLUGINS}/plugin_load_bash_profile.sh
# --------------Load .bash_profile-------------

echo "--------------------------------------------"
echo "samba-tool domain level show"
echo "--------------------------------------------"
samba-tool domain level show
echo ""
echo ""


echo "--------------------------------------------"
echo "samba-tool fsmo show"
echo "--------------------------------------------"
samba-tool fsmo show
echo ""
echo ""


echo "--------------------------------------------"
echo "samba-tool drs showrepl"
echo "--------------------------------------------"
samba-tool drs showrepl
echo ""
echo ""


echo "--------------------------------------------"
echo "samba-tool user list"
echo "--------------------------------------------"
samba-tool user list
echo ""
echo ""


echo "--------------------------------------------"
echo "smbclient -L localhost -U%"
echo "--------------------------------------------"
smbclient -L localhost -U%
echo ""
echo ""


echo "--------------------------------------------"
echo "testparm"
echo "--------------------------------------------"
testparm -s
echo ""
echo ""


echo "--------------------------------------------"
echo "You could now manage AD via RSAT"
echo "https://github.com/charlietag/Samba4_AD_RSAT#manage-active-directory---dc-with-rsat-windows"
echo "--------------------------------------------"
echo ""
echo ""
echo "--------------------------------------------"
echo "--------------------------------------------"
echo "Before go on, maybe you could try command below to verify your samba-ad-dc status:"
echo "    . ~/.bash_profile (if need)"
echo ""
echo "    smbclient //localhost/netlogon -UAdministrator -c 'ls'"
echo "    (DEFAULT ADMIN PASSWORD: ${samba_admin_password})"
