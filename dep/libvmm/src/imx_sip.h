#pragma once

#include <stddef.h>
#include <microkit.h>

typedef enum imx_sip {
    IMX_SIP_GPC = 0x0,
    IMX_SIP_DDR_DVFS = 0x4,
    IMX_SIP_SRC = 0x5,
    IMX_SIP_GET_SOC_INFO = 0x6,
    IMX_SIP_HAB = 0x7,
    IMX_SIP_NOC = 0x8,
} imx_sip_t;

bool handle_imx_sip(size_t vcpu_id, seL4_UserContext *regs,  uint64_t fn_number, uint32_t hsr);
