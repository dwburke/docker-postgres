

PSQL_SERVER_CONTAINER_NAME ?= postgres
POSTGRES_IMAGE   ?= postgres
POSTGRES_VERSION ?= 9.2
POSTGRES_USER    ?= postgres
POSTGRES_PASS    ?= abc123

POSTGRES_CONTAINER_ID=$(shell docker ps -a | grep ${PSQL_SERVER_CONTAINER_NAME} | cut -d ' ' -f 1)


all: default

default:
	${MAKE} psql-init
	${MAKE} rmq-init
	${MAKE} psql-provdb


psql-init:
	@echo "Checking postgres..."
	@if [ ! "${POSTGRES_CONTAINER_ID}" ]; then \
		echo "Starting postgres..."; \
		docker run -d \
			--name ${PSQL_SERVER_CONTAINER_NAME} \
			-e POSTGRES_PASSWORD=${POSTGRES_PASS} \
			postgres:${POSTGRES_VERSION}; \
		sleep 7; \
	fi


psql-clean:
	${MAKE} psql-destroy
	rm -f out/psql-*.x


clean:
	${MAKE} psql-destroy
	${MAKE} rmq-destroy


psql-provdb:
	${MAKE} psql-provdb-createdb
	${MAKE} psql-provdb-set-password
	${MAKE} psql-provdb-import-schema

psql-provdb-import-schema:
	@echo import schema
	@if [ ! -e out/psql-provdb-import-schema.x ]; then \
		docker run -t -i \
			--rm \
			-v ${HOME}/lw:/usr/local/lp/git/lw \
			--link ${PSQL_SERVER_CONTAINER_NAME}:PSQL \
			-e PGPASSWORD=${POSTGRES_PASS} \
			${PSQL_USER_OPTS} ${POSTGRES_IMAGE}:${POSTGRES_VERSION} \
			sh -c 'exec psql -h "$$PSQL_PORT_5432_TCP_ADDR" -p "$$PSQL_PORT_5432_TCP_PORT" -U $(POSTGRES_USER) < /usr/local/lp/git/lw/sql/provision/schema.sql'; \
		touch out/psql-provdb-import-schema.x; \
	fi

psql-provdb-createdb:
	@echo create prov user and prov db
	@if [ ! -e out/psql-provdb-createdb.x ]; then \
		docker run -t -i \
			--rm \
			-v ${HOME}/lw:/usr/local/lp/git/lw \
			--link ${PSQL_SERVER_CONTAINER_NAME}:PSQL \
			-e PGPASSWORD=${POSTGRES_PASS} \
			${PSQL_USER_OPTS} ${POSTGRES_IMAGE}:${POSTGRES_VERSION} \
			sh -c 'exec psql -h "$$PSQL_PORT_5432_TCP_ADDR" -p "$$PSQL_PORT_5432_TCP_PORT" -U $(POSTGRES_USER) < /usr/local/lp/git/lw/sql/provision/database.sql'; \
		touch out/psql-provdb-createdb.x; \
	fi

psql-provdb-set-password:
	@if [ ! -e out/psql-provdb-set-password.x ]; then \
		echo "set password"; \
		echo " alter user prov with password '$(POSTGRES_PASS)';" > user.sql; \
		docker run -t -i \
			--rm \
			-v ${HOME}/lw:/usr/local/lp/git/lw \
			--link ${PSQL_SERVER_CONTAINER_NAME}:PSQL \
			-v $(shell pwd):/usr/local/lp/tmp \
			-e PGPASSWORD=${POSTGRES_PASS} \
			${PSQL_USER_OPTS} ${POSTGRES_IMAGE}:${POSTGRES_VERSION} \
			sh -c 'psql -h "$$PSQL_PORT_5432_TCP_ADDR" -p "$$PSQL_PORT_5432_TCP_PORT" -U $(POSTGRES_USER) < /usr/local/lp/tmp/user.sql'; \
		rm -f user.sql; \
		touch out/psql-provdb-set-password.x; \
	fi

psql-provdb-client:
	@docker run -t -i \
		--rm \
		-v ${HOME}/lw:/usr/local/lp/git/lw \
		--link ${PSQL_SERVER_CONTAINER_NAME}:PSQL \
		-e PGPASSWORD=${POSTGRES_PASS} \
		${PSQL_USER_OPTS} ${POSTGRES_IMAGE}:${POSTGRES_VERSION} \
		sh -c 'exec psql -h "$$PSQL_PORT_5432_TCP_ADDR" -p "$$PSQL_PORT_5432_TCP_PORT" -U prov provision'


psql-client:
	@docker run -t -i \
		--rm \
		-v ${HOME}/lw:/usr/local/lp/git/lw \
		--link ${PSQL_SERVER_CONTAINER_NAME}:PSQL \
		-e PGPASSWORD=${POSTGRES_PASS} \
		${PSQL_USER_OPTS} ${POSTGRES_IMAGE}:${POSTGRES_VERSION} \
		sh -c 'exec psql -h "$$PSQL_PORT_5432_TCP_ADDR" -p "$$PSQL_PORT_5432_TCP_PORT" -U postgres'

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


print-targets:
	@make -qp | awk -F':' '/^[a-zA-Z0-9][^$$#\/\t=]*:([^=]|$$)/ {split($$1,A,/ /);for(i in A)print A[i]}'     |sort|uniq|grep -v all|grep -v Makefile


include Makefile.rmq
