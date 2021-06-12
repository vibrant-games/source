.PHONY: all
all: container npcs

NPCS_CONVERTER_VERSION=0.0.1

RUN_USER=`id --user --name`
RUN_GROUP=`id --group --name`

.PHONY: container
container:
	sudo echo "sudo permission is required to run Docker."
	rm -rf ./temp_container
	mkdir -p \
		./temp_container \
		./temp_container/source/applications/tools
	cp -r ../../../../content ./temp_container/content_in
	cp -r ../../tools/* ./temp_container/source/applications/tools/
	sudo docker build . --tag npcs_converter:$(NPCS_CONVERTER_VERSION)
	rm -rf ./temp_container

.PHONY: npcs
npcs:
	sudo echo "sudo permission is required to run Docker."
	sudo docker run --mount type=bind,readonly=false,source=`pwd`/../../../../content,destination=/vibrant_games/content_out npcs_converter:$(NPCS_CONVERTER_VERSION)
	sudo chown -R $(RUN_USER):$(RUN_GROUP) ../../../../content/npcs/
