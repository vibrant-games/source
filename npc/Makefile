all: config source container

clean: clean-config clean-source clean-container
	rm -f *~

start:
	cd container \
	    && make start

stop:
	cd container \
	    && make stop


.PHONY: clean-config
clean-config:
	cd config \
	    && make clean

.PHONY: clean-container
clean-container:
	cd container \
	    && make clean

.PHONY: clean-source
clean-source:
	cd source \
	    && make clean


.PHONY: config
config:
	cd config \
	    && make all

.PHONY: container
container:
	cd container \
	    && make all

.PHONY: source
source:
	cd source \
	    && make all
