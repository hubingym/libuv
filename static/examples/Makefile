# https://github.com/hubingym/cbm

examples=\
	helloworld\
	idle-compute

all:
	for dir in $(examples); do echo -- runing $$dir --; cbm -d $$dir build; cbm -d $$dir run; echo ; done

clean:
	for dir in $(examples); do echo -- clean $$dir --; cbm -d $$dir clean; echo ; done

.PHONY: all clean