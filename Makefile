.PHONY: all
all:
	csc -o mimic -O5 -d0 -strict-types mimic.scm

.PHONY: debug
debug:
	csc -o mimic -O0 -d3 -strict-types mimic.scm
