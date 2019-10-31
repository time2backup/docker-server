#!/bin/bash
set -e

# reset config
cp /time2backup-server/config/time2backup-server.default.conf /time2backup-server/config/time2backup-server.conf
sed -i 's|^destination.*|destination = /backups|' /time2backup-server/config/time2backup-server.conf

# reset sudoers
rm -f /etc/sudoers.d/time2backup

# copy auth.conf if exists
if [ -f /config/auth.conf ] ; then
	cp /config/auth.conf /time2backup-server/config/auth.conf
else
	rm -f /time2backup-server/config/auth.conf
fi

# secure config
chown -R root:t2b /time2backup-server/config
chmod -R 750 /time2backup-server/config

# set custom config
if [ -f /config/time2backup-server.conf ] ; then
	for param in hard_links force_hard_links sudo_mode token_expiration debug_mode ; do
		value=$(grep "^$param" /config/time2backup-server.conf | cut -d= -f2- | tr -d '[:space:]')
		if [ -n "$value" ] ; then
			sed -i "s|^$param.*|$param = $value|" /time2backup-server/config/time2backup-server.conf
			
			# sudo mode case
			if [ "$param" == sudo_mode ] ; then
				# edit sudoers
				if [ "$value" == true ] ; then
					echo "t2b	ALL = NOPASSWD:/usr/bin/time2backup-server" > /etc/sudoers.d/time2backup
				fi
			fi
		fi
	done
fi

# create SSH authorized keys file
mkdir -p /home/t2b/.ssh
touch /home/t2b/.ssh/authorized_keys

# copy SSH keys
if [ -f /config/ssh_keys ] ; then
	cat /config/ssh_keys > /home/t2b/.ssh/authorized_keys
else
	echo "WARNING: SSH keys not set"
fi
	
# check files ownership
chown -R t2b:t2b /home/t2b
chmod 700 /home/t2b/.ssh
chmod 400 /home/t2b/.ssh/authorized_keys

touch /time2backup-server/.access /time2backup-server/server.log
chown root:t2b /time2backup-server/.access /time2backup-server/server.log
chmod 660 /time2backup-server/.access /time2backup-server/server.log

# run command (sshd by default)
exec "$@"
