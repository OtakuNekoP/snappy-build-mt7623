include common.mk
include device.mk

SNAPPY_VERSION := `date +%Y%m%d`-0
SNAPPY_IMAGE := fukuoka-${SNAPPY_VERSION}.img
# yes for latest version; no for the specific revision of edge/stable channel
SNAPPY_CORE_NEW := yes
SNAPPY_CORE_VER ?=
SNAPPY_CORE_CH := stable
#OEM_SNAP := mt7623_0.1_all.snap
OEM_SNAP := mt7623.woodrow
REVISION ?=
SNAPPY_WORKAROUND := no

all: build

clean:
		rm -f $(OUTPUT_DIR)/*.img.xz
distclean: clean

build-snappy:
ifeq ($(SNAPPY_CORE_NEW),no)
		$(eval REVISION = --revision $(SNAPPY_CORE_VER))
endif
		@echo "build snappy..."
		sudo ubuntu-device-flash core 15.04 -v \
			--oem $(OEM_SNAP) \
			--device-part=$(DEVICE_TAR) \
			--channel $(SNAPPY_CORE_CH) \
			-o $(SNAPPY_IMAGE) \
			$(REVISION)

fix-bootflag:
		dd conv=notrunc if=boot_fix.bin of=$(SNAPPY_IMAGE) seek=440 oflag=seek_bytes	

workaround:
ifeq ($(SNAPPY_WORKAROUND),yes)
		./snappy-workaround.sh $(SNAPPY_IMAGE)
endif

pack:
		xz -0 $(SNAPPY_IMAGE)

build: build-snappy fix-bootflag workaround pack 

.PHONY: build-snappy fix-bootflag workaround pack build
