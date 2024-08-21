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
DEP_PATH := dep
SRC_PATH := src
TMP_PATH := tmp
OUT_PATH := out

DEP_DTS_PATH := ${DEP_PATH}/dts
DEP_GST_PATH := ${DEP_PATH}/guest
DEP_LVM_PATH := ${DEP_PATH}/libvmm
DEP_MKT_PATH := ${DEP_PATH}/microkit

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

MKT_BOARD := maaxboard
MKT_CONFIG := debug

MKT_SDK := ${DEP_MKT_PATH}/out/microkit-sdk-1.4.1

MKT_PATH_FILE := ${MKT_SDK}/bin/microkit
MKT_RTM_PATH_FILE := ${MKT_SDK}/board/${MKT_BOARD}/${MKT_CONFIG}

CPU := cortex-a53
TCH := aarch64-linux-gnu
CC := ${TCH}-gcc
LD := ${TCH}-ld
AS := ${TCH}-as

CC_OPS := -mcpu=${CPU} \
          -ffreestanding \
          -nostdlib \
          -mstrict-align \
          -g3 \
          -O3 \
          -Wall -Wno-unused-function -Werror -Wno-unused-value -Wno-int-conversion

LVM_CFG_BOARD := BOARD_maaxboard

LIBVMM_OBJS := \
    ${TMP_PATH}/console.o \
    ${TMP_PATH}/fault.o \
    ${TMP_PATH}/guest.o \
    ${TMP_PATH}/imx_sip.o \
    ${TMP_PATH}/linux.o \
    ${TMP_PATH}/mmio.o \
    ${TMP_PATH}/printf.o \
    ${TMP_PATH}/psci.o \
    ${TMP_PATH}/smc.o \
    ${TMP_PATH}/tcb.o \
    ${TMP_PATH}/util.o \
    ${TMP_PATH}/vcpu.o \
    ${TMP_PATH}/vgic.o \
    ${TMP_PATH}/vgic_v3.o \
    ${TMP_PATH}/virq.o \


SDDF_OBJS := \
    ${TMP_PATH}/assert.o \
    ${TMP_PATH}/bitarray.o \
    ${TMP_PATH}/cache.o \
    ${TMP_PATH}/fsmalloc.o \
    ${TMP_PATH}/newlibc.o \
    ${TMP_PATH}/putchar_debug.o \
    ${TMP_PATH}/sddf_printf.o \


#-------------------------------
# Target
#-------------------------------

.PHONY: get
get: dep-get

.PHONY: dep-get
dep-get:
	make -C ${DEP_DTS_PATH} get
	make -C ${DEP_GST_PATH} get
	make -C ${DEP_LVM_PATH} get
	make -C ${DEP_MKT_PATH} get
	
.PHONY: all
all: dep-all ${OUT_PATH}/loader.img

.PHONY: dep-all
dep-all: 
	make -C ${DEP_DTS_PATH} all
	make -C ${DEP_GST_PATH} all
	make -C ${DEP_LVM_PATH} all
	make -C ${DEP_MKT_PATH} all

${TMP_PATH}:
	mkdir ${TMP_PATH}

${OUT_PATH}:
	mkdir ${OUT_PATH}

${OUT_PATH}/loader.img: ${MKT_PATH_FILE} ${SRC_PATH}/main.system ${TMP_PATH}/client_vmm_1.elf ${TMP_PATH}/client_vmm_2.elf ${TMP_PATH}/serial_virt_tx.elf ${TMP_PATH}/serial_virt_rx.elf ${TMP_PATH}/uart_driver.elf ${OUT_PATH}
	${MKT_PATH_FILE} ${SRC_PATH}/main.system --search-path ${TMP_PATH} --board ${MKT_BOARD} --config ${MKT_CONFIG} --output ${OUT_PATH}/main.img --report ${OUT_PATH}/report.txt


${TMP_PATH}/client_vmm_1.elf: ${TMP_PATH}/client_vmm.o ${TMP_PATH}/client_images_1.o ${LIBVMM_OBJS} ${SDDF_OBJS} | ${TMP_PATH}
	${LD} \
	-L $(MKT_RTM_PATH_FILE)/lib \
	$^ \
	-lmicrokit \
	-Tmicrokit.ld \
	-o $@

${TMP_PATH}/client_vmm_2.elf: ${TMP_PATH}/client_vmm.o ${TMP_PATH}/client_images_2.o ${LIBVMM_OBJS} ${SDDF_OBJS} | ${TMP_PATH}
	${LD} \
	-L $(MKT_RTM_PATH_FILE)/lib \
	$^ \
	-lmicrokit \
	-Tmicrokit.ld \
	-o $@

${TMP_PATH}/client_vmm.o: ${SRC_PATH}/client_vmm.c ${DEP_LVM_PATH}/out/libvmm | ${TMP_PATH}
	${CC} \
	-c \
	${CC_OPS} \
	-D ${LVM_CFG_BOARD} \
	-I ${SRC_PATH} \
	-I ${DEP_LVM_PATH}/out/libvmm/include \
    -I ${DEP_LVM_PATH}/out/libvmm/dep/sddf/include \
	-I ${MKT_RTM_PATH_FILE}/include \
	$< \
	-o $@

${TMP_PATH}/client_images_1.o: ${DEP_LVM_PATH}/out/libvmm/tools/package_guest_images.S ${DEP_GST_PATH}/out/Image ${DEP_GST_PATH}/out/rootfs.cpio.gz ${TMP_PATH}/maaxboard.dtb ${DEP_LVM_PATH}/out/libvmm | ${TMP_PATH}
	${CC} \
	-c \
	-g3 \
	-x assembler-with-cpp \
	-DGUEST_KERNEL_IMAGE_PATH=\"${DEP_GST_PATH}/out/Image\" \
	-DGUEST_DTB_IMAGE_PATH=\"${TMP_PATH}/maaxboard.dtb\" \
	-DGUEST_INITRD_IMAGE_PATH=\"${DEP_GST_PATH}/out/rootfs.cpio.gz\" \
	"${DEP_LVM_PATH}/out/libvmm/tools/package_guest_images.S" \
	-o $@

${TMP_PATH}/client_images_2.o: ${DEP_LVM_PATH}/out/libvmm/tools/package_guest_images.S ${DEP_GST_PATH}/out/Image ${DEP_GST_PATH}/out/rootfs.cpio.gz ${TMP_PATH}/maaxboard.dtb ${DEP_LVM_PATH}/out/libvmm | ${TMP_PATH}
	${CC} \
	-c \
	-g3 \
	-x assembler-with-cpp \
	-DGUEST_KERNEL_IMAGE_PATH=\"${DEP_GST_PATH}/out/Image\" \
	-DGUEST_DTB_IMAGE_PATH=\"${TMP_PATH}/maaxboard.dtb\" \
	-DGUEST_INITRD_IMAGE_PATH=\"${DEP_GST_PATH}/out/rootfs.cpio.gz\" \
	"${DEP_LVM_PATH}/out/libvmm/tools/package_guest_images.S" \
	-o $@

${TMP_PATH}/maaxboard.dtb: ${DEP_DTS_PATH}/out/maaxboard.dts ${SRC_PATH}/maaxboard-overlay.dts | ${TMP_PATH}
	cat $^ > ${TMP_PATH}/guest.dts
	dtc -q -I dts -O dtb ${TMP_PATH}/guest.dts -o $@

${TMP_PATH}/%.o: ${DEP_LVM_PATH}/out/libvmm/src/%.c | ${TMP_PATH}
	${CC} \
	-c \
	${CC_OPS} \
	-I ${DEP_LVM_PATH}/out/libvmm/include \
	-I ${MKT_RTM_PATH_FILE}/include \
	$< \
	-o $@

${TMP_PATH}/%.o: ${DEP_LVM_PATH}/out/libvmm/src/util/%.c | ${TMP_PATH}
	${CC} \
	-c \
	${CC_OPS} \
	-I ${DEP_LVM_PATH}/out/libvmm/include \
	-I ${MKT_RTM_PATH_FILE}/include \
	$< \
	-o $@

${TMP_PATH}/%.o: ${DEP_LVM_PATH}/out/libvmm/src/virtio/%.c | ${TMP_PATH}
	${CC} \
	-c \
	${CC_OPS} \
	-I ${DEP_LVM_PATH}/out/libvmm/include \
	-I ${DEP_LVM_PATH}/out/libvmm/src/arch/aarch64 \
	-I ${DEP_LVM_PATH}/out/libvmm/dep/sddf/include \
	-I ${MKT_RTM_PATH_FILE}/include \
	$< \
	-o $@

${TMP_PATH}/%.o: ${DEP_LVM_PATH}/out/libvmm/src/arch/aarch64/%.c | ${TMP_PATH}
	${CC} \
	-c \
	${CC_OPS} \
	-D ${LVM_CFG_BOARD} \
	-I ${DEP_LVM_PATH}/out/libvmm/include \
	-I ${DEP_LVM_PATH}/out/libvmm/src/arch/aarch64 \
	-I ${MKT_RTM_PATH_FILE}/include \
	$< \
	-o $@

${TMP_PATH}/%.o: ${DEP_LVM_PATH}/out/libvmm/src/arch/aarch64/vgic/%.c | ${TMP_PATH}
	${CC} \
	-c \
	${CC_OPS} \
	-D ${LVM_CFG_BOARD} \
	-I ${DEP_LVM_PATH}/out/libvmm/include \
	-I ${DEP_LVM_PATH}/out/libvmm/src/arch/aarch64 \
	-I ${MKT_RTM_PATH_FILE}/include \
	$< \
	-o $@

${TMP_PATH}/serial_virt_tx.elf: ${TMP_PATH}/virt_tx.o ${SDDF_OBJS} | ${TMP_PATH}
	${LD} \
	-L $(MKT_RTM_PATH_FILE)/lib \
	$^ \
	-lmicrokit \
	-Tmicrokit.ld \
	-o $@

${TMP_PATH}/serial_virt_rx.elf: ${TMP_PATH}/virt_rx.o ${SDDF_OBJS} | ${TMP_PATH}
	${LD} \
	-L $(MKT_RTM_PATH_FILE)/lib \
	$^ \
	-lmicrokit \
	-Tmicrokit.ld \
	-o $@

${TMP_PATH}/uart_driver.elf: ${TMP_PATH}/uart.o ${SDDF_OBJS} | ${TMP_PATH}
	${LD} \
	-L $(MKT_RTM_PATH_FILE)/lib \
	$^ \
	-lmicrokit \
	-Tmicrokit.ld \
	-o $@

${TMP_PATH}/%.o: ${DEP_LVM_PATH}/out/libvmm/dep/sddf/serial/components/%.c | ${TMP_PATH}
	${CC} \
	-c \
	${CC_OPS} \
	-I ${SRC_PATH} \
	-I ${DEP_LVM_PATH}/out/libvmm/dep/sddf/include \
	-I ${DEP_LVM_PATH}/out/libvmm/dep/sddf/drivers/serial/imx/include \
	-I ${MKT_RTM_PATH_FILE}/include \
	$< \
	-o $@

${TMP_PATH}/uart.o: ${DEP_LVM_PATH}/out/libvmm/dep/sddf/drivers/serial/imx/uart.c | ${TMP_PATH}
	${CC} \
	-c \
	${CC_OPS} \
	-I ${SRC_PATH} \
	-I ${DEP_LVM_PATH}/out/libvmm/dep/sddf/include \
	-I ${DEP_LVM_PATH}/out/libvmm/dep/sddf/drivers/serial/imx/include \
	-I ${MKT_RTM_PATH_FILE}/include \
	$< \
	-o $@



${TMP_PATH}/sddf_printf.o: ${DEP_LVM_PATH}/out/libvmm/dep/sddf/util/printf.c | ${TMP_PATH}
	${CC} \
	-c \
	${CC_OPS} \
	-I ${DEP_LVM_PATH}/out/libvmm/dep/sddf/include \
	-I ${MKT_RTM_PATH_FILE}/include \
	$< \
	-o $@

${TMP_PATH}/%.o: ${DEP_LVM_PATH}/out/libvmm/dep/sddf/util/%.c | ${TMP_PATH}
	${CC} \
	-c \
	${CC_OPS} \
	-I ${DEP_LVM_PATH}/out/libvmm/dep/sddf/include \
	-I ${MKT_RTM_PATH_FILE}/include \
	$< \
	-o $@

.PHONY: clean
clean:
	make -C ${DEP_DTS_PATH} clean
	make -C ${DEP_GST_PATH} clean
	make -C ${DEP_LVM_PATH} clean
	rm -rf ${TMP_PATH}

.PHONY: reset
reset: clean
	make -C ${DEP_DTS_PATH} reset
	make -C ${DEP_GST_PATH} reset
	make -C ${DEP_LVM_PATH} reset
	rm -rf ${OUT_PATH}

#===============================================================================
# End of file
#===============================================================================
