include $(TOPDIR)/rules.mk

PKG_NAME:=gotest
PKG_VERSION:=0.0.1
PKG_RELEASE:=1

PKG_SOURCE:=$(shell pwd)

PKG_BUILD_DIR:=$(BUILD_DIR)/gotest-v$(PKG_VERSION)

GO:=$(STAGING_DIR)/host/bin/go
GOROOT=$(STAGING_DIR)/host/share/gocode
GOPATH=$(GOROOT)

TARGET_OS:=linux
TARGET_ARCH:=$(ARCH)
ifeq ($(ARCH),mipsel)
TARGET_ARCH:=mipsle
else ifeq ($(ARCH),i386)
TARGET_ARCH:=386
endif

PKG_CONFIG_DEPENDS := \
        CONFIG_PACKAGE_gotest

include $(INCLUDE_DIR)/package.mk


define Package/gotest
	SECTION:=apps
	CATEGORY:=Apps
	TITLE:=Applications test for go language
	DEPENDS:=@+PACKAGE_golang @+PACKAGE_gin-gonic
endef

define Build/Prepare
	$(CP) $(PKG_SOURCE)/src/test.go $(PKG_BUILD_DIR)
endef

define Build/Compile
	cd $(PKG_BUILD_DIR); \
	  CGO_ENABLED=0 GOROOT=$(GOROOT) GOPATH=$(GOPATH) GOOS=$(TARGET_OS) GOARCH=$(TARGET_ARCH) $(GO) build test.go
endef

define Package/gotest/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/test $(1)/usr/bin
endef

$(eval $(call BuildPackage,gotest))
