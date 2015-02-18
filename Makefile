
include Makefile.conf


all: default

default:
	${MAKE} pull
	${MAKE} psql-init
	${MAKE} rmq-init
	${MAKE} psql-provdb

pull:
	${MAKE} psql-pull
	${MAKE} rmq-pull

clean:
	${MAKE} psql-clean
	${MAKE} rmq-clean


print-targets:
	@make -qp | awk -F':' '/^[a-zA-Z0-9][^$$#\/\t=]*:([^=]|$$)/ {split($$1,A,/ /);for(i in A)print A[i]}'     |sort|uniq|grep -v all|grep -v Makefile


include Makefile.rmq
include Makefile.psql

