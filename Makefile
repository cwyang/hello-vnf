# -*- Mode: makefile-gmake -*-
# 4 Apr 2024
# Chul-Woong Yang

SUBDIRS := app

# Targets
.PHONY: all clean $(SUBDIRS)

all clean : $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)
