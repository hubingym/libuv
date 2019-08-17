# https://github.com/hubingym/cbm

examples=\
	1helloworld\
	1idle-compute

all:
	for dir in $(examples); do cbm -d $$dir build; cbm -d $$dir run; done

clean:
	for dir in $(examples); do cbm -d $$dir clean; done

.PHONY: all clean