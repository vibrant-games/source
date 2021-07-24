VERSION=0.0.1
PORT=8081

CONTENT_REPO_DIR=`pwd`/../../../content

all: clean npc-container

clean:
	rm -f *~
	rm -rf ./_build/
	@echo "Cleaning unversioned Docker images:"; \
	UNVERSIONED_IMAGES=`sudo docker images \
	                        | grep '<none>' \
	                        | awk '{ print $$3; }'`; \
	if test ! -z "$$UNVERSIONED_IMAGES"; \
	then \
	    echo "   $$UNVERSIONED_IMAGES" \
	        | awk '{ printf " " $$0; }'; \
	    sudo docker rmi $$UNVERSIONED_IMAGES; \
	else \
	    echo "    (No unversioned Docker images to clean)"; \
	fi

	@echo "Cleaning Exited Docker containers:"; \
	EXITED_CONTAINERS=`sudo docker ps -a \
	                        | grep 'Exited' \
	                        | awk '{ print $$1; }'`; \
	if test ! -z "$$EXITED_CONTAINERS"; \
	then \
	    echo "   $$EXITED_CONTAINERS" \
	        | awk '{ printf " " $$0; }'; \
	    sudo docker rm $$EXITED_CONTAINERS; \
	else \
	    echo "    (No exited Docker containers to clean)"; \
	fi

npc-container:
	@echo "Building Docker container 'npc' version $(VERSION)"
	rm -rf ./_build/
	mkdir ./_build
	cp -i -r \
	  ../source/ \
	  ../config/ \
	  _build/
	sudo docker build --file Dockerfile --tag npc:$(VERSION) --tag npc:latest _build
	@echo "You can now run 'make start' then 'make stop'"

start:
	@echo "Starting npc server..."
	sudo docker run --mount type=bind,readonly=false,source=$(CONTENT_REPO_DIR)/npcs/html,destination=/var/npcs/html npc:$(VERSION) &
	@sleep 1
	@CONTAINER_IDS=`sudo docker ps -a \
	                  | grep 'npc:$(VERSION)' \
	                  | grep -v 'Exited' \
	                  | awk '{ print $$1; }'`; \
	for CONTAINER_ID in $$CONTAINER_IDS; \
	do \
	    CONTAINER_IP_ADDRESS=`sudo docker inspect $$CONTAINER_ID \
	                              | grep '"IPAddress"[ ]*:[ ]*"[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*"' \
	                              | head -1 \
	                              | sed 's|^.*"\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\)".*$$|\\1|'`; \
	    if test ! -z "$$CONTAINER_IP_ADDRESS"; \
	    then \
	        echo "    $$CONTAINER_ID:"; \
	        echo "        You can browse to:    http://$$CONTAINER_IP_ADDRESS:$(PORT)"; \
	    else \
	        echo "    WARNING Docker container $$CONTAINER_ID does not have an IPAddress for some reason"; \
	    fi; \
	done
	@echo "Started npc server"

stop:
	@echo "Stopping npc server(s)..."
	@CONTAINER_IDS=`sudo docker ps -a \
	                  | grep 'npc:$(VERSION)' \
	                  | grep -v 'Exited' \
	                  | awk '{ print $$1; }'`; \
	for CONTAINER_ID in $$CONTAINER_IDS; \
	do \
	    echo "    Stopping $$CONTAINER_ID:"; \
	    sudo docker kill $$CONTAINER_ID \
	        || exit 1; \
	done
	@echo "Stopped npc server(s)"
