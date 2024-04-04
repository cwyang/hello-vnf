# -*- Mode: makefile-gmake -*-
# 4 Apr 2024
# Chul-Woong Yang

ifeq ($(BUILDNAME),)
BUILDDIR:=build
else
BUILDDIR:=build-$(BUILDNAME)
endif

CC=gcc
JOBS=-j40
DOCKER=$(shell which docker 2> /dev/null)
PROGNAME=hello
PROGS=hello helloctl
BUILD_DATE=$(shell date +%y%m%d%H%M)
VERSION_FILE=include/version.h

.PHONY: tags package start stop stat restart reset reload run docker clean check_precondition all

.NOTPARALLEL:

all: check_precondition $(BUILDDIR)/Makefile
	(cd $(BUILDDIR); make ${JOBS} CC=$(CC))
	@echo
	@echo "Done: The built files are in [$(realpath ./$(BUILDDIR)/bundle)]."

PROGS_IN_NEED=ls wget
check_precondition:
	@which $(PROGS_IN_NEED) > /dev/null 2>&1 || \
	(echo; \
	 echo "Please install following programs: $(PROGS_IN_NEED)"; \
	 echo && exit 1)

$(BUILDDIR)/Makefile: CMakeLists.txt
	rm -f CMakeCache.txt
	mkdir -p $(BUILDDIR)
	(cd $(BUILDDIR); CC=$(CC) cmake ..)

clean:
	cd $(BUILDDIR); make clean

DOCKER_TARGETS := docker alpine
ifeq ($(filter $(MAKECMDGOALS),$(TARGETS)),)
GETNUM = $(shell sed -n 's/.*$1 *\([0-9]*\)/\1/p' ${VERSION_FILE})
HELLO_VERSION := $(call GETNUM,MAJOR).$(call GETNUM,MINOR).$(call GETNUM,PATCH)-${BUILD_DATE}
HELLO_IMG := cwyang/${PROGNAME}
HELLO_REPO := cwyang/${PROGNAME}
ifeq ($(MAKECMDGOALS),docker)
DOCKERFILE=Dockerfile
else
DOCKERFILE=Dockerfile.alpine
endif
endif
docker alpine: all
	[ -x "$(DOCKER)" ] || (echo "docker is not installed in this machine." && exit 1)
	docker build --build-arg BUILD_DATE=${BUILD_DATE} \
		     --build-arg DESTDIR=/opt/${PROGNAME} \
		     -f misc/${DOCKERFILE} -t ${HELLO_IMG}:latest .
	docker tag ${HELLO_IMG}:latest ${HELLO_REPO}:latest
	docker push ${HELLO_REPO}:latest
	docker tag ${HELLO_IMG}:latest ${HELLO_REPO}:${HELLO_VERSION}
	docker push ${HELLO_REPO}:${HELLO_VERSION}

.PHONY: $(COMMANDS)
COMMANDS := start stop restart reset reload stat
$(COMMANDS):
	./$(BUILDDIR)/bundle/helloctl $@

run:
	./$(BUILDDIR)/bundle/hello -c etc/hello.conf

package: all
	@bname=`git rev-parse --abbrev-ref HEAD`; \
	TEMPDIR=`mktemp -d`; \
	DESTDIR=$$TEMPDIR/out; \
	mkdir -p $$DESTDIR/bin; \
	today=`date +%y%m%d`; \
	whoami=`whoami`; \
	cp ./$(BUILDDIR)/bundle/hello ./$(BUILDDIR)/bundle/helloctl $$DESTDIR/bin/; \
	(cd $$TEMPDIR; tar cvfz /tmp/$(PROGNAME)-$$whoami-$$bname-$$today.tgz *); \
	rm -rf $$TEMPDIR; \
	echo '### package' /tmp/$(PROGNAME)-$$whoami-$$bname-$$today.tgz created..; \
	if [ "$$SCPHOST" != "" ]; then \
		scp /tmp/$(PROGNAME)-$$whoami-$$bname-$$today.tgz $$SCPHOST: && \
		echo '### package' /tmp/$(PROGNAME)-$$whoami-$$bname-$$today.tgz copied to $$SCPHOST.; \
	fi

tags:
	rm -f TAGS
	find . -name \*.[ch] | xargs etags --append --output=TAGS

