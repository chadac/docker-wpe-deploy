# Based on https://spin.atomicobject.com/2015/11/30/command-line-tools-docker/
PREFIX ?= /usr/local
REPO = "utulsa/wpe-deploy"
VERSION = "1.0"

all: build

build:
	@docker build -t $(REPO):$(VERSION) . \
	&& docker tag $(REPO):$(VERSION) $(REPO):latest

install: build
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	install -m 0755 wpe-deploy $(DESTDIR)$(PREFIX)/bin/wpe-deploy

uninstall:
	@$(RM) $(DESTDIR)$(PREFIX)/bin/wpe-deploy
	@docker rmi $(REPO):$(VERSION)
	@docker rmi $(REPO):latest

publish: build
	@docker push $(REPO):$(VERSION) \
	&& docker push $(REPO):latest
