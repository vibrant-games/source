all: source container

clean: clean-source clean-container
	rm -f *~

start:
	cd container \
	    && make start

stop:
	cd container \
	    && make stop


.PHONY: clean-source
clean-source:
	cd source \
	    && make clean

.PHONY: clean-container
clean-container:
	cd container \
	    && make clean


.PHONY: source
source:
	cd source \
	    && make all

.PHONY: container
container:
	cd container \
	    && make all
