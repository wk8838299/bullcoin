#!/bin/bash

set -e

date

#################################################################
# Update Ubuntu and install prerequisites for running Feecoin   #
#################################################################
sudo apt-get update
#################################################################
# Build Feecoin from source                                     #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building Feecoin           #
#################################################################
sudo apt-get install -y qt4-qmake libqt4-dev libminiupnpc-dev libdb++-dev libdb-dev libcrypto++-dev libqrencode-dev libboost-all-dev build-essential libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libssl-dev libdb++-dev libssl-dev ufw git
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

# By default, assume running within repo
repo=$(pwd)
file=$repo/src/feecoind
if [ ! -e "$file" ]; then
	# Now assume running outside and repo has been downloaded and named feecoin
	if [ ! -e "$repo/feecoin/build.sh" ]; then
		# if not, download the repo and name it feecoin
		git clone https://github.com/feecoind/source feecoin
	fi
	repo=$repo/feecoin
	file=$repo/src/feecoind
	cd $repo/src/
fi
make -j$NPROC -f makefile.unix

cp $repo/src/feecoind /usr/bin/feecoind

################################################################
# Configure to auto start at boot                                      #
################################################################
file=$HOME/.feecoin
if [ ! -e "$file" ]
then
        mkdir $HOME/.feecoin
fi
printf '%s\n%s\n%s\n%s\n' 'daemon=1' 'server=1' 'rpcuser=u' 'rpcpassword=p' | tee $HOME/.feecoin/feecoin.conf
file=/etc/init.d/feecoin
if [ ! -e "$file" ]
then
        printf '%s\n%s\n' '#!/bin/sh' 'sudo feecoind' | sudo tee /etc/init.d/feecoin
        sudo chmod +x /etc/init.d/feecoin
        sudo update-rc.d feecoin defaults
fi

/usr/bin/feecoind
echo "Feecoin has been setup successfully and is running..."

