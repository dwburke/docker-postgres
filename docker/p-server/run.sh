#!/usr/bin/bash

LWCONFIGS=/usr/local/lp/configs

if [ ${LWDEVPATH} ]; then
	LWCONFIGS=$LWDEVPATH/lwconfigs
fi

if [ -e "${HOME}/lwconfigs" ]; then
	LWCONFIGS=$HOME/lwconfigs
fi
echo $LWCONFIGS

if [ ! -d "${HOME}/lw" ]; then
	echo "You do not have lw.git cloned in your home directory."
	exit;
fi

docker run -t -i --rm=true \
	--name=$USER-pserver-$$ \
	-p 5000:5000 \
	-v $LWCONFIGS:/usr/local/lp/configs \
	-v $HOME/lw:/usr/local/lp/git/lw \
	-v $HOME/lw-plack-app-provision-server:/usr/local/lp/git/lw-plack-app-provision-server \
	liquidweb/plack-pserver



