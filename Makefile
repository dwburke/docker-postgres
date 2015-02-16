

PSQL_SERVER_CONTAINER_NAME ?= postgres

POSTGRES_PASS    ?= abc123
POSTGRES_VERSION ?= 9.2
POSTGRES_IMAGE   ?= postgres
POSTGRES_USER    ?= postgres

POSTGRES_CONTAINER_ID=$(shell docker ps -a | grep ${PSQL_SERVER_CONTAINER_NAME} | cut -d ' ' -f 1)

all: default

default:
	${MAKE} psql-init
	${MAKE} psql-provdb-init


psql-init:
	@if [ ! "${POSTGRES_CONTAINER_ID}" ]; then \
		docker run -d \
			--name ${PSQL_SERVER_CONTAINER_NAME} \
			-e POSTGRES_PASSWORD=${POSTGRES_PASS} \
			postgres:${POSTGRES_VERSION}; \
		sleep 7; \
	fi


psql-provdb-init: psql-init
	@docker run -t -i \
		--rm \
		-v ${HOME}/lw:/usr/local/lp/git/lw \
		--link ${PSQL_SERVER_CONTAINER_NAME}:PSQL \
		-e PGPASSWORD=${POSTGRES_PASS} \
		${PSQL_USER_OPTS} ${POSTGRES_IMAGE}:${POSTGRES_VERSION} \
		sh -c 'exec psql -h "$$PSQL_PORT_5432_TCP_ADDR" -p "$$PSQL_PORT_5432_TCP_PORT" -U $(POSTGRES_USER) < /usr/local/lp/git/lw/sql/provision/database.sql'
	docker run -t -i \
		--rm \
		-v ${HOME}/lw:/usr/local/lp/git/lw \
		--link ${PSQL_SERVER_CONTAINER_NAME}:PSQL \
		-e PGPASSWORD=${POSTGRES_PASS} \
		${PSQL_USER_OPTS} ${POSTGRES_IMAGE}:${POSTGRES_VERSION} \
		sh -c 'exec psql -h "$$PSQL_PORT_5432_TCP_ADDR" -p "$$PSQL_PORT_5432_TCP_PORT" -U $(POSTGRES_USER) -c "alter user prov with password \E'$(POSTGRES_PASS)';"'


psql-destroy:
	docker stop ${PSQL_SERVER_CONTAINER_NAME}
	docker rm ${PSQL_SERVER_CONTAINER_NAME}


psql-print-env:
	#Print out the environment a container linking to the server would see
	#Requires the postgresql server to be running
	docker run \
		--rm \
		--link ${PSQL_SERVER_CONTAINER_NAME}:PSQL \
		${PSQL_USER_OPTS} ${POSTGRES_IMAGE}:${POSTGRES_VERSION} \
		env


