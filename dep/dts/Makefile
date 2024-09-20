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
	@echo "reset"

#===========================================================
# Target
#===========================================================
ifneq ($(wildcard ${OUT_PATH}/maaxboard.dts),)

.PHONY: get
get:

.PHONY: all
all:

else

.PHONY: get
get: | ${TMP_PATH}/linux-imx

${TMP_PATH}/linux-imx: | ${TMP_PATH}
	git -C ${TMP_PATH} clone --branch "maaxboard_lf-6.1.22-2.0.0" "git@github.com:Avnet/linux-imx.git" linux-imx

.PHONY: all
all: ${OUT_PATH}/maaxboard.dts

${TMP_PATH}:
	mkdir ${TMP_PATH}

${OUT_PATH}:
	mkdir ${OUT_PATH}

${OUT_PATH}/maaxboard.dts: ${TMP_PATH}/maaxboard.dts | ${OUT_PATH}
	cp -r $< $@

${TMP_PATH}/maaxboard.dts: | ${TMP_PATH}/linux-imx/arch/arm64/boot/dts/freescale/maaxboard.dts ${TMP_PATH}
	cpp -nostdinc -I ${TMP_PATH}/linux-imx/include -undef -x assembler-with-cpp $< -o $@

endif

.PHONY: clean
clean:
	rm -rf ${TMP_PATH}

.PHONY: reset
reset: clean
	rm -rf ${OUT_PATH}

################################################################################
# End of file
################################################################################
