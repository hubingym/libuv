# https://github.com/hubingym/cbm

examples=\
	timer\
	idle-basic

all:
	mkdir -p ./.bin
	for dir in $(examples); do echo -- runing $$dir --; v run $$dir -o ./.bin/$$dir; echo ; done

clean:
	rm -rf .bin

.PHONY: all clean