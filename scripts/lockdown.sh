#!/bin/bash

if [ `whoami` != root ]; then
	echo "Run this script as root or with sudo"
	exit
fi

USER=$(echo $SUDO_USER)

# Moves to working directory
cd /home/$USER/

# Creates .bash_profile and disables use of export command
if [ -f .bash_profile ]; then
	echo ".bash_profile already exists, skipping creation."
else
	echo ".bash_profile does not exist, creating it."
	touch .bash_profile
	echo "if [ -f ~/.bashrc ]; then" >> .bash_profile
	echo "        . ~/.bashrc" >> .bash_profile
	echo "fi" >> .bash_profile
	echo ".bash_profile created successfully"
fi

# Denying unsafe commands
echo "alias export='printf \"Permission Denied\n\"'" >> .bashrc
echo "alias chmod='printf \"Permission Denied\n\"'" >> .bashrc
echo "alias nano='printf \"Permission Denied\n\"'" >> .bashrc
echo "alias emacs='printf \"Permission Denied\n\"'" >> .bashrc
echo "alias pico='printf \"Permission Denied\n\"'" >> .bashrc
echo "alias sed='printf \"Permission Denied\n\"'" >> .bashrc
echo "alias vi='printf \"Permission Denied\n\"'" >> .bashrc
echo "alias vim='printf \"Permission Denied\n\"'" >> .bashrc

# Prevents editing of the .bashrc and .bash_history file
chmod 444 .bashrc
chown root:root .bashrc
chmod 444 .bash_profile
chown root:root .bash_profile
echo ".bashrc and .bash_profile locked down."

# Removes ssh access for the user
echo "DenyUsers $USER" >> /etc/ssh/sshd_config
systemctl restart sshd
echo "SSH access for $USER removed"

# Removes user's sudo priviledges
deluser $USER sudo

# Applies changes to .bashrc to active user sessions, note user still has sudo until session is exited.
su - $USER -c "source /home/$USER/.bashrc"
echo "Changes applied."

# Change default shell to rbash
# Commented as it breaks startsample.sh as that requires use of cd which is disabled by rbash
# chsh -s /bin/rbash $USER
