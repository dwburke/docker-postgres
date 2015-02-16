
1. Initialize a postgres docker container.

2. Import your schema.

3. Profit



Instructions:

Currently, its taking variable values from the env, or setting defaults
if they need them.  These are at the top of the Makefile, identified by
the ?= initialization.


Initial setup:

To create a prov database, with a prov user:

 # make


Your password is not secure.  You have been warned.

