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
SRC_PATH := src
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
get: | ${OUT_PATH}
	git -C ${OUT_PATH} clone --branch "main" "git@github.com:au-ts/libvmm.git" libvmm
	git -C ${OUT_PATH}/libvmm submodule update --init

.PHONY: all
all: ${OUT_PATH}/libvmm
	cp ${SRC_PATH}/imx_sip.h ${OUT_PATH}/libvmm/include/libvmm/arch/aarch64/imx_sip.h
	cp ${SRC_PATH}/imx_sip.c ${OUT_PATH}/libvmm/src/arch/aarch64/imx_sip.c
	if  ! grep -ir imx_sip.h '${OUT_PATH}/libvmm/src/arch/aarch64/smc.c'; then \
		sed --in-place --expression "/#include <.*psci.h>/i#include <libvmm/arch/aarch64/imx_sip.h>" ${OUT_PATH}/libvmm/src/arch/aarch64/smc.c; \
		sed --in-place --expression "/case SMC_CALL_STD_SERVICE:/icase SMC_CALL_SIP_SERVICE: return handle_imx_sip(vcpu_id, \&regs, fn_number, hsr); break;" ${OUT_PATH}/libvmm/src/arch/aarch64/smc.c; \
	fi

${OUT_PATH}:
	mkdir ${OUT_PATH}

.PHONY: clean
clean:
	rm -rf ${OUT_PATH}

#===============================================================================
# End of file
#===============================================================================
