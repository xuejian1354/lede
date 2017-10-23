# 
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=go
PKG_VERSION:=1.4.3

PKG_SOURCE:=$(PKG_NAME)$(PKG_VERSION).src.tar.gz
PKG_SOURCE_URL:=https://storage.googleapis.com/golang
PKG_MD5SUM:=dfb604511115dd402a77a553a5923a04

include $(INCLUDE_DIR)/host-build.mk

define Host/Prepare
	$(call Host/Prepare/Default)
	cp -R $(HOST_BUILD_DIR)/. $(BUILD_DIR_HOST)/go
	rm -rf $(HOST_BUILD_DIR)
	mv $(BUILD_DIR_HOST)/go $(HOST_BUILD_DIR)
endef

define Host/Compile
	cd $(HOST_BUILD_DIR)/src; ./make.bash
endef

define Host/Install
	rm -rf $(STAGING_DIR_HOST)/share/go
	cp -ad $(HOST_BUILD_DIR) $(STAGING_DIR_HOST)/share/go
endef

$(eval $(call HostBuild))
