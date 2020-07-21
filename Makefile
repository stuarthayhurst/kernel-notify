CC=g++
CFLAGS:=-Wall -Wextra $(shell pkg-config --cflags libnotify)
LDFLAGS:=$(shell pkg-config --libs libnotify)
SHELL=bash

BUILD_DIR=build
DIST_DIR=dist

UNINSTALL_LIST:=$(shell cat src/lists/uninstall.list)
ICON_RESOLUTIONS=48 64 128 256

.PHONY: build install uninstall dist debian notifications icons docs check test clean

build:
	mkdir -p $(BUILD_DIR)
	sed "s|.*Exec=.*|Exec=kernel-notify -zw|" src/kernel-notify.desktop > build/kernel-notify.desktop
	make notifications
	make docs
install:
	mkdir -p "/usr/share/kernel-notify"
	if [[ ! -f /etc/xdg/autostart/kernel-notify.desktop ]]; then \
	  touch /tmp/remove-kernel-notify-autostart; \
	fi
	if [[ -f "/usr/share/kernel-notify/config" ]]; then \
	  mv /usr/share/kernel-notify/config /usr/share/kernel-notify/config.old; \
	fi
	if [[ -f "/etc/xdg/autostart/kernel-notify.desktop" ]]; then \
	  mv /etc/xdg/autostart/kernel-notify.desktop /usr/share/kernel-notify/kernel-notify.desktop.old; \
	fi
	while IFS='' read -r line || [ -n "$$line" ]; do \
	  if [[ "$$line" = *"+x"* ]]; then \
	    makeExecutable="true"; \
	    line="$${line// +x}"; \
	  fi; \
	  cp -v $$line; \
	  if [[ "$$makeExecutable" == "true" ]]; then \
	    chmod +x "$${line#* }"; \
	    makeExecutable="false"; \
	  fi; \
	done < src/lists/install.list
	./install.sh --make-assist
uninstall:
	rm -rf $(UNINSTALL_LIST)
dist:
	make debian
debian:
	make build
	mkdir -p $(DIST_DIR)
	cp -r src/debian $(DIST_DIR)
	for filelist in src/lists/install.list src/lists/debian.list; do \
	  while IFS='' read -r line || [ -n "$$line" ]; do \
	    if [[ "$$line" = *"+x"* ]]; then \
	      makeExecutable="true"; \
	      line="$${line// +x}"; \
	    fi; \
	    file="$${line% *}"; \
	    dir="$${line#* }"; \
	    dir="$(DIST_DIR)/debian$${dir%/*}/"; \
	    mkdir -p "$$dir"; \
	    cp "$$file" "$$dir"; \
	    if [[ "$$makeExecutable" == "true" ]]; then \
	      chmod +x "$(DIST_DIR)/debian$${line#* }"; \
	      makeExecutable="false"; \
	    fi; \
	  done < "$$filelist"; \
	done
	uid="$$(ls -nd $(DIST_DIR)/debian/ |cut -d' ' -f3)"; \
	gid="$$(ls -nd $(DIST_DIR)/debian/ |cut -d' ' -f4)"; \
	version="$$(sed -n '5p' $(BUILD_DIR)/kernel-notify.desktop)"; \
	version="$${version//Version=}"; \
	sudo chown -R root:root $(DIST_DIR)/debian/; \
	sudo dpkg --build $(DIST_DIR)/debian/ $(DIST_DIR)/kernel-notify-"$$version"_all.deb; \
	sudo chown -R "$$uid:$$gid" $(DIST_DIR)/debian/ $(DIST_DIR)/kernel-notify-"$$version"_all.deb
notifications:
	mkdir -p $(BUILD_DIR)
	$(CC) src/notifications.cpp -o $(BUILD_DIR)/notifications $(CFLAGS) $(LDFLAGS);
icons:
	for resolution in $(ICON_RESOLUTIONS); do \
	  mkdir -p "./icons/"$$resolution"x"$$resolution; \
	  mkdir -p "./icons/"$$resolution"x"$$resolution"/apps"; \
	  for filename in ./icons/*.svg; do \
	    inkscape --export-filename=$${filename//.svg/.png} -w $$resolution -h $$resolution $$filename; \
	    mv $${filename//.svg/.png} "./icons/"$$resolution"x"$$resolution"/apps"; \
	  done; \
	done
	for resolution in $(ICON_RESOLUTIONS); do \
	  for filename in "./icons/"$$resolution"x"$$resolution"/apps/*.png"; do \
	    optipng -o7 -strip all $$filename; \
	  done; \
	done
	cp ./icons/256x256/apps/kernel-notify.png ./docs/icon.png
docs:
	mkdir -p $(BUILD_DIR)
	gzip -cqv9 docs/kernel-notify.1 > $(BUILD_DIR)/kernel-notify.1.gz
check:
	make test
test:
	while IFS='' read -r line || [ -n "$$line" ]; do \
	  if [[ "$$line" = *"+x"* ]]; then \
	    line="$${line// +x}"; \
	  fi; \
	  if [[ ! -f "$${line% *}" ]]; then \
	    echo "$${line% *} is missing. Have you run 'make build'?"; \
	    failed="true"; \
	  fi; \
	done < src/lists/install.list; \
	if [[ "$$failed" == "true" ]]; then \
	  exit 1; \
	fi
clean:
	rm -rf $(BUILD_DIR) $(DIST_DIR)
