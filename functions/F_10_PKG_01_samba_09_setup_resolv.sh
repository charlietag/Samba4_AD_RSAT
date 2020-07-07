# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable

\cp -a --backup=t /etc/resolv.conf /etc/resolv.conf.bak
task_copy_using_render_sed
