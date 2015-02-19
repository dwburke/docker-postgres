
PSERVER_CONTAINER_ID=$(shell docker ps -a | grep p-server | cut -d ' ' -f 1)


all: default

default:
	${MAKE} build


build:
	docker build --tag="liquidweb/plack-pserver" .

run:
	docker run -d \
		--name=p-server \
		-p 5000:5000 \
		-v ${HOME}/lwconfigs:/usr/local/lp/configs \
		-v ${HOME}/lw:/usr/local/lp/git/lw \
		-v ${HOME}/lw-plack-app-provision-server:/usr/local/lp/git/lw-plack-app-provision-server \
		liquidweb/plack-pserver

restart:
	${MAKE} stop
	${MAKE} start

start:
	docker start p-server

stop:
	if [ "${PSERVER_CONTAINER_ID}" ]; then \
		docker stop p-server; \
	fi

clean:
	${MAKE} stop
	if [ "${PSERVER_CONTAINER_ID}" ]; then \
		docker rm p-server; \
	fi

delete:
	${MAKE} clean
	docker rmi liquidweb/plack-pserver
