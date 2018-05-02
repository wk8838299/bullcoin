#!/bin/bash

set -e

date

#################################################################
# Update Ubuntu and install prerequisites for running Lemanum   #
#################################################################
sudo apt-get update
#################################################################
# Build Lemanum from source                                     #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building Lemanum           #
#################################################################
sudo apt-get install -y qt4-qmake libqt4-dev libminiupnpc-dev libdb++-dev libdb-dev libcrypto++-dev libqrencode-dev libboost-all-dev build-essential libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libssl-dev libdb++-dev libssl-dev ufw git
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

# By default, assume running within repo
repo=$(pwd)
file=$repo/src/lemanumd
if [ ! -e "$file" ]; then
	# Now assume running outside and repo has been downloaded and named lemanum
	if [ ! -e "$repo/lemanum/build.sh" ]; then
		# if not, download the repo and name it lemanum
		git clone https://github.com/lemanumd/source lemanum
	fi
	repo=$repo/lemanum
	file=$repo/src/lemanumd
	cd $repo/src/
fi
make -j$NPROC -f makefile.unix

cp $repo/src/lemanumd /usr/bin/lemanumd

################################################################
# Configure to auto start at boot                                      #
################################################################
file=$HOME/.lemanum
if [ ! -e "$file" ]
then
        mkdir $HOME/.lemanum
fi
printf '%s\n%s\n%s\n%s\n' 'daemon=1' 'server=1' 'rpcuser=u' 'rpcpassword=p' | tee $HOME/.lemanum/lemanum.conf
file=/etc/init.d/lemanum
if [ ! -e "$file" ]
then
        printf '%s\n%s\n' '#!/bin/sh' 'sudo lemanumd' | sudo tee /etc/init.d/lemanum
        sudo chmod +x /etc/init.d/lemanum
        sudo update-rc.d lemanum defaults
fi

/usr/bin/lemanumd
echo "Lemanum has been setup successfully and is running..."

