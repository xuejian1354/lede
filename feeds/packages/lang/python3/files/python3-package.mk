#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

$(call include_mk, python3-version.mk)

PYTHON3_DIR:=$(STAGING_DIR)/usr
PYTHON3_BIN_DIR:=$(PYTHON3_DIR)/bin
PYTHON3_INC_DIR:=$(PYTHON3_DIR)/include/python$(PYTHON3_VERSION)
PYTHON3_LIB_DIR:=$(PYTHON3_DIR)/lib/python$(PYTHON3_VERSION)

PYTHON3_PKG_DIR:=/usr/lib/python$(PYTHON3_VERSION)/site-packages

PYTHON3:=python$(PYTHON3_VERSION)

PYTHON3PATH:=$(PYTHON3_LIB_DIR):$(STAGING_DIR)/$(PYTHON3_PKG_DIR):$(PKG_INSTALL_DIR)/$(PYTHON3_PKG_DIR)

# These configure args are needed in detection of path to Python header files
# using autotools.
CONFIGURE_ARGS += \
	_python_sysroot="$(STAGING_DIR)" \
	_python_prefix="/usr" \
	_python_exec_prefix="/usr"

PKG_USE_MIPS16:=0
# This is required in addition to PKG_USE_MIPS16:=0 because otherwise MIPS16
# flags are inherited from the Python base package (via sysconfig module)
ifdef CONFIG_USE_MIPS16
  TARGET_CFLAGS += -mno-mips16 -mno-interlink-mips16
endif

define Py3Package

  # Add default PyPackage filespec none defined
  ifndef Py3Package/$(1)/filespec
    define Py3Package/$(1)/filespec
      +|$(PYTHON3_PKG_DIR)
    endef
  endif

  ifndef Py3Package/$(1)/install
    define Py3Package/$(1)/install
		if [ -d $(PKG_INSTALL_DIR)/usr/bin ]; then \
			$(INSTALL_DIR) $$(1)/usr/bin \
			$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $$(1)/usr/bin/
		fi
    endef
  endif

  $(call shexport,Py3Package/$(1)/filespec)

  define Package/$(1)/install
	find $(PKG_INSTALL_DIR) -name "*\.pyc" -o -name "*\.pyo" -o -name "*\.exe" | xargs rm -f
	@echo "$$$$$$$$$$(call shvar,Py3Package/$(1)/filespec)" | ( \
		IFS='|'; \
		while read fop fspec fperm; do \
		  fop=`echo "$$$$$$$$fop" | tr -d ' \t\n'`; \
		  if [ "$$$$$$$$fop" = "+" ]; then \
			if [ ! -e "$(PKG_INSTALL_DIR)$$$$$$$$fspec" ]; then \
			  echo "File not found '$(PKG_INSTALL_DIR)$$$$$$$$fspec'"; \
			  exit 1; \
			fi; \
			dpath=`dirname "$$$$$$$$fspec"`; \
			if [ -n "$$$$$$$$fperm" ]; then \
			  dperm="-m$$$$$$$$fperm"; \
			else \
			  dperm=`stat -c "%a" $(PKG_INSTALL_DIR)$$$$$$$$dpath`; \
			fi; \
			mkdir -p $$$$$$$$$dperm $$(1)$$$$$$$$dpath; \
			echo "copying: '$$$$$$$$fspec'"; \
			cp -fpR $(PKG_INSTALL_DIR)$$$$$$$$fspec $$(1)$$$$$$$$dpath/; \
			if [ -n "$$$$$$$$fperm" ]; then \
			  chmod -R $$$$$$$$fperm $$(1)$$$$$$$$fspec; \
			fi; \
		  elif [ "$$$$$$$$fop" = "-" ]; then \
			echo "removing: '$$$$$$$$fspec'"; \
			rm -fR $$(1)$$$$$$$$fspec; \
		  elif [ "$$$$$$$$fop" = "=" ]; then \
			echo "setting permissions: '$$$$$$$$fperm' on '$$$$$$$$fspec'"; \
			chmod -R $$$$$$$$fperm $$(1)$$$$$$$$fspec; \
		  fi; \
		done; \
	)
	$(call Py3Package/$(1)/install,$$(1))
  endef
endef

$(call include_mk, python3-host.mk)

# $(1) => commands to execute before running pythons script
# $(2) => python script and its arguments
# $(3) => additional variables
define Build/Compile/HostPy3RunTarget
	$(call HostPython3, \
		$(if $(1),$(1);) \
		CC="$(TARGET_CC)" \
		CCSHARED="$(TARGET_CC) $(FPIC)" \
		CXX="$(TARGET_CXX)" \
		LD="$(TARGET_CC)" \
		LDSHARED="$(TARGET_CC) -shared" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="$(TARGET_CPPFLAGS) -I$(PYTHON3_INC_DIR)" \
		LDFLAGS="$(TARGET_LDFLAGS) -lpython$(PYTHON3_VERSION)" \
		_PYTHON_HOST_PLATFORM=linux2 \
		__PYVENV_LAUNCHER__="/usr/bin/$(PYTHON3)" \
		$(3) \
		, \
		$(2) \
	)
endef

# $(1) => build subdir
# $(2) => additional arguments to setup.py
# $(3) => additional variables
define Build/Compile/Py3Mod
	$(INSTALL_DIR) $(PKG_INSTALL_DIR)/$(PYTHON3_PKG_DIR)
	$(call Build/Compile/HostPy3RunTarget, \
		cd $(PKG_BUILD_DIR)/$(strip $(1)), \
		./setup.py $(2), \
		$(3))
	find $(PKG_INSTALL_DIR) -name "*\.pyc" -o -name "*\.pyo" -o -name "*\.exe" | xargs rm -f
endef

define Py3Build/Compile/Default
	$(call Build/Compile/Py3Mod,, \
		install --prefix="/usr" --root="$(PKG_INSTALL_DIR)" \
		--single-version-externally-managed \
	)
endef

ifeq ($(BUILD_VARIANT),python3)
define Build/Compile
	$(call Py3Build/Compile/Default)
endef
endif # python3
