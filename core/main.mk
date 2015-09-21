.PHONY: kernel
kernel:
	@echo "\033[32m Starting build \033[0m"
	@mkdir -p $(OUT_DIR)/system
	make -j$(CORE_COUNT) -C $(PRODUCT_KERNEL_SOURCE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(PRODUCT_DEFCONFIG)
	make -j$(CORE_COUNT) -C $(PRODUCT_KERNEL_SOURCE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE)
	make -j$(CORE_COUNT) -C $(PRODUCT_KERNEL_SOURCE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) dtbs
	make -j$(CORE_COUNT) -C $(PRODUCT_KERNEL_SOURCE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) modules
	make -j$(CORE_COUNT) -C $(PRODUCT_KERNEL_SOURCE) INSTALL_MOD_PATH=../../$(KERNEL_MODULES_INSTALL) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) modules_install
	@cp $(PRODUCT_KERNEL_SOURCE)/$(ZIMAGE) $(OUT_DIR)
	$(mv-modules)
	$(clean-module-folder)


.PHONY: kernelclean
kernelclean:
	@echo "\033[32m Cleaning source \033[0m"
	make -C $(PRODUCT_KERNEL_SOURCE) mrproper

.PHONY: kernelclobber
kernelclobber: kernelclean
	@echo "\033[32m Full cleaning \033[0m"
	$(shell rm -rf $OUT_DIR/*)

BUILD_SYSTEM := $(TOPDIR)build/core

include $(BUILD_SYSTEM)/envsetup.mk

ifneq ($(dont_bother),true)
subdir_makefiles := \
		$(shell build/tools/findleaves.py --prune=.repo --prune=.git $(PWD) Android.mk)
$(foreach mk, $(subdir_makefiles), $(eval include $(mk)))
endif

# Figure out where we are.
define my-dir
$(strip \
  $(eval LOCAL_MODULE_MAKEFILE := $$(lastword $$(MAKEFILE_LIST))) \
  $(if $(filter $(BUILD_SYSTEM)/% $(OUT_DIR)/%,$(LOCAL_MODULE_MAKEFILE)), \
    $(error my-dir must be called before including any other makefile.) \
   , \
    $(patsubst %/,%,$(dir $(LOCAL_MODULE_MAKEFILE))) \
   ) \
 )
endef

include $(BUILD_SYSTEM)/definitions.mk
include $(BUILD_SYSTEM)/dumpvar.mk

# ---------------------------------------------------------------
# figure out the output directories

ifeq (,$(strip $(OUT_DIR)))
ifeq (,$(strip $(OUT_DIR_COMMON_BASE)))
ifneq ($(TOPDIR),)
OUT_DIR := $(TOPDIR)out
else
OUT_DIR := $(CURDIR)/out
endif
else
OUT_DIR := $(OUT_DIR_COMMON_BASE)/$(notdir $(PWD))
endif
endif
