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
get: | ${TMP_PATH}/sel4devkit-maaxboard-microkit

${TMP_PATH}/sel4devkit-maaxboard-microkit: | ${TMP_PATH}
	git -C ${TMP_PATH} clone --branch "main" "git@github.com:sel4devkit/sel4devkit-maaxboard-microkit.git" sel4devkit-maaxboard-microkit
	make -C ${TMP_PATH}/sel4devkit-maaxboard-microkit get

.PHONY: all
all: ${OUT_PATH}/microkit-sdk-1.4.1

${TMP_PATH}:
	mkdir ${TMP_PATH}

${OUT_PATH}:
	mkdir ${OUT_PATH}

${OUT_PATH}/microkit-sdk-1.4.1: ${TMP_PATH}/sel4devkit-maaxboard-microkit/out/microkit-sdk-1.4.1 | ${OUT_PATH}
	cp -r $< $@

${TMP_PATH}/sel4devkit-maaxboard-microkit/out/microkit-sdk-1.4.1: | ${TMP_PATH}
	make -C ${TMP_PATH}/sel4devkit-maaxboard-microkit all

.PHONY: clean
clean:
	rm -rf ${TMP_PATH}
	rm -rf ${OUT_PATH}

################################################################################
# End of file
################################################################################
