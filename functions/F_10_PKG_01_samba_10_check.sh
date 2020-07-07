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

