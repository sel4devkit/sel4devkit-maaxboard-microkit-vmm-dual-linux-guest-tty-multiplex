################################################################################
# Makefile
################################################################################

#===========================================================
# Check
#===========================================================
ifndef FORCE
    EXP_INFO := sel4devkit-maaxboard-microkit-docker-dev-env 1 *
    CHK_PATH_FILE := /check.mk
    ifeq ($(wildcard ${CHK_PATH_FILE}),)
        HALT := TRUE
    else
        include ${CHK_PATH_FILE}
    endif
    ifdef HALT
        $(error Expected Environment Not Found: ${EXP_INFO})
    endif
endif

#===========================================================
# Layout
#===========================================================
TMP_PATH := tmp
OUT_PATH := out

#===========================================================
# Usage
#===========================================================
.PHONY: usage
usage: 
	@echo "usage: make <target> [FORCE=TRUE]"
	@echo ""
	@echo "<target> is one off:"
	@echo "get"
	@echo "all"
	@echo "clean"

#===========================================================
# Target
#===========================================================
.PHONY: get
get: | ${TMP_PATH}
	git -C ${TMP_PATH} clone --branch "main" "git@github.com:sel4devkit/sel4devkit-maaxboard-linux-guest.git" sel4devkit-maaxboard-linux-guest
	make -C ${TMP_PATH}/sel4devkit-maaxboard-linux-guest get

.PHONY: all
all: ${OUT_PATH}/Image ${OUT_PATH}/rootfs.cpio.gz

${TMP_PATH}:
	mkdir ${TMP_PATH}

${OUT_PATH}:
	mkdir ${OUT_PATH}

${OUT_PATH}/Image: ${TMP_PATH}/sel4devkit-maaxboard-linux-guest/out/Image | ${OUT_PATH}
	cp -r $< $@

${OUT_PATH}/rootfs.cpio.gz: ${TMP_PATH}/sel4devkit-maaxboard-linux-guest/out/rootfs.cpio.gz | ${OUT_PATH}
	cp -r $< $@

${TMP_PATH}/sel4devkit-maaxboard-linux-guest/out/Image ${TMP_PATH}/sel4devkit-maaxboard-linux-guest/out/rootfs.cpio.gz: | ${TMP_PATH}
	make -C ${TMP_PATH}/sel4devkit-maaxboard-linux-guest all

.PHONY: clean
clean:
	rm -rf ${TMP_PATH}
	rm -rf ${OUT_PATH}

#===============================================================================
# End of file
#===============================================================================
