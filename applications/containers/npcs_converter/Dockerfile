FROM debian:bullseye-slim

RUN apt-get update
RUN apt-get install -y apt-utils sudo

COPY ./temp_container/source /vibrant_games/source

RUN /vibrant_games/source/applications/tools/setup.sh

COPY ./temp_container/content_in /vibrant_games/content_in

RUN echo "You must bind /vibrant_games/content_out in order to get output files"

ENTRYPOINT /vibrant_games/source/applications/tools/npcs_yaml_to_html.sh /vibrant_games/content_in \
           && cp -r /vibrant_games/content_in/npcs/* /vibrant_games/content_out/npcs/
