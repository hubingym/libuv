examples=\
	timer\
	file-system\
	queue-work\
	tcp-client\
	tcp-server\
	idle-basic

all:
	mkdir -p ./.bin
	for dir in $(examples); do echo -- compile $$dir --; v -o ./.bin/$$dir $$dir; echo ; done

clean:
	rm -rf .bin

.PHONY: all clean