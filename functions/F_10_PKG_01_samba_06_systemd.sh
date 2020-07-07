
# Disable built in services
systemctl mask smbd nmbd winbind
systemctl disable smbd nmbd winbind

# Add samba4 service
task_copy_using_cat

# Activate samba4 systemd
systemctl daemon-reload
systemctl enable samba-ad-dc
systemctl start samba-ad-dc
