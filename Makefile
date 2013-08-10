#
# Copyright (c) SAS Institute Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


all: default-subdirs default-all

export TOPDIR = $(shell pwd)
export DISTDIR = $(TOPDIR)/rmake-$(VERSION)
SUBDIRS=rmake commands extra man rmake_plugins

.PHONY: clean dist install subdirs

subdirs: default-subdirs

install: install-subdirs 
	make -C rmake_plugins install || exit 1

install-client: install-client-subdirs

clean: clean-subdirs default-clean

version:
	sed -i 's/@NEW@/$(VERSION)/g' NEWS

show-version:
	@echo $(VERSION)

dist:
	if ! grep "^Changes in $(VERSION)" NEWS > /dev/null 2>&1; then \
		echo "no NEWS entry"; \
		exit 1; \
	fi
	$(MAKE) forcedist


archive:
	@rm -rf /tmp/rmake-$(VERSION) /tmp/rmake$(VERSION)-tmp
	@mkdir -p /tmp/rmake-$(VERSION)-tmp
	@git archive --format tar $(VERSION) | (cd /tmp/rmake-$(VERSION)-tmp/ ; tar x )
	@mv /tmp/rmake-$(VERSION)-tmp/ /tmp/rmake-$(VERSION)/
	@dir=$$PWD; cd /tmp; tar -c --bzip2 -f $$dir/rmake-$(VERSION).tar.bz2 rmake-$(VERSION)
	@rm -rf /tmp/pesign-$(VERSION)
	@echo "The archive is in rmake-$(VERSION).tar.bz2"

sanitycheck: archive
	@echo "=== sanity building/testing rmake ==="; \
	rm -rf $(DISTDIR); \
	tar xjf rmake-$(VERSION).tar.bz2; \
	cd $(DISTDIR); \
	make > /dev/null || exit 1; \
	./bin/rmake --version --skip-default-config > /dev/null || echo "RMAKE DOES NOT WORK" || exit 1; \
	cd -; \
	rm -rf $(DISTDIR)

forcedist: archive sanitycheck

tag:
	git tag $(VERSION) refs/heads/master

clean: clean-subdirs default-clean

test: all
	if [ `id -u` ] ; then \
		if [ -f /usr/bin/sudo ] ; then \
			SUDO="sudo bash -c"; \
		else \
			SUDO="su -c" ;\
		fi; \
	else \
		SUDO=bash -c ;\
	fi ;\
	$${SUDO} 'chown root.root commands/chroothelper; \
		  chmod 4755 commands/chroothelper'

include Make.rules
include Make.defs
 
# vim: set sts=8 sw=8 noexpandtab :
