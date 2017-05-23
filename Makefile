
CONFIG_DIR=$(shell pwd)/config

sudo:
	@sudo echo "=sudo permission="

apt-update: sudo
	@echo [phase] apt-update
	sudo apt-get clean
	sudo apt-get update

basic-pkg: sudo apt-update
	@echo [phase] basic-pkg
	sudo apt-get install -y ssh vim git
	cp -f $(CONFIG_DIR)/vimrc $$HOME/.vimrc
	@sudo bash -c "echo -e \"/dev/sda1\t$$HOME/storage\text4\tdefaults\t0\t2\" >> /etc/fstab"

ftp: sudo apt-update
	@echo [phase] ftp
	sudo apt-get install -y vsftpd

samba: sudo apt-update
	@echo [phase] samba
	sudo apt-get install -y samba
	@echo -n "Enter samba user : "
	@read SMB_USER; \
	sudo smbpasswd -a $$SMB_USER
	@sudo bash -c "echo -e \"[rasp]\" >> /etc/samba/smb.conf"
	@sudo bash -c "echo -e \"\tpath = $$HOME\" >> /etc/samba/smb.conf"
	@sudo bash -c "echo -e \"\twritable = yes\" >> /etc/samba/smb.conf"
	@sudo bash -c "echo -e \"\tguest ok = no\" >> /etc/samba/smb.conf"
	@sudo bash -c "echo -e \"\tcomment = rasp_samba\" >> /etc/samba/smb.conf"

docker: sudo apt-update
	@echo [phase] docker
	sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository "deb [arch=armhf] https://download.docker.com/linux/ubuntu $$(lsb_release -cs) stable"
	sudo apt-get update
	sudo apt-get install -y docker-ce

build: basic-pkg ftp samba docker
	@echo Build done

