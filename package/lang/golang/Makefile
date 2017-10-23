#
# Copyright (C) 2006-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=go
PKG_VERSION:=1.8.3
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)$(PKG_VERSION).src.tar.gz
PKG_SOURCE_URL:=https://storage.googleapis.com/golang
PKG_MD5SUM:=64e9380e07bba907e26a00cf5fcbe77e

TARGET_OS:=linux
TARGET_ARCH:=$(ARCH)
ifeq ($(ARCH),mipsel)
TARGET_ARCH:=mipsle
else ifeq ($(ARCH),i386)
TARGET_ARCH:=386
endif

include $(INCLUDE_DIR)/package.mk

define Package/golang
  SUBMENU:=Golang
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=A open source programing language
  URL:=https://golang.org
endef

define Package/golang/description
  Go is an open source programming language that makes
  it easy to build simple, reliable, and efficient software.
endef

define Package/golang/config
	source "$(SOURCE)/config.in"
endef

define Build/Prepare
	$(Build/Prepare/Default)
	cp -R $(PKG_BUILD_DIR)/. $(BUILD_DIR)/go
	rm -rf $(PKG_BUILD_DIR)
	mv $(BUILD_DIR)/go $(PKG_BUILD_DIR)
endef

define Build/Compile
	cd $(PKG_BUILD_DIR)/src; \
	  GOROOT_BOOTSTRAP=$(STAGING_DIR_HOST)/share/go GOOS=$(TARGET_OS) GOARCH=$(TARGET_ARCH) ./make.bash;
	[ "$(CONFIG_PACKAGE_gin-gonic)" != "y" ] || \
	 (GOROOT=$(PKG_BUILD_DIR) GOPATH=$(PKG_BUILD_DIR)/vendor $(PKG_BUILD_DIR)/bin/go get github.com/gin-gonic/gin; \
	  GOROOT=$(PKG_BUILD_DIR) GOPATH=$(PKG_BUILD_DIR)/vendor GOOS=$(TARGET_OS) GOARCH=$(TARGET_ARCH) $(PKG_BUILD_DIR)/bin/go get github.com/gin-gonic/gin)
endef

define Build/InstallDev
	mkdir -p $(1)/host/bin
	mkdir -p $(1)/host/share/gocode/pkg;
	mkdir -p $(1)/host/share/gocode/src;
	$(CP) $(PKG_BUILD_DIR)/bin/* $(1)/host/bin
	$(CP) $(PKG_BUILD_DIR)/pkg/* $(1)/host/share/gocode/pkg
	$(CP) $(PKG_BUILD_DIR)/src/* $(1)/host/share/gocode/src
	[ "$(CONFIG_PACKAGE_gin-gonic)" != "y" ] || \
	  $(CP) $(PKG_BUILD_DIR)/vendor/* $(1)/host/share/gocode
endef

$(eval $(call BuildPackage,golang))
