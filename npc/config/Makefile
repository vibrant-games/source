CONTENT_REPO_DIR=../../../content

all: clean npcs

.PHONY:
clean:
	rm -f *~
	rm -f npcs.js

.PHONY: npcs
npcs:
	./generate_npcs.sh "$(CONTENT_REPO_DIR)"
