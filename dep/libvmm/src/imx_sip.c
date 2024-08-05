#include <stdbool.h>
#include <libvmm/util/util.h>                    
#include <libvmm/arch/aarch64/smc.h>             
#include <libvmm/arch/aarch64/fault.h>           
#include <libvmm/arch/aarch64/imx_sip.h>         

bool handle_imx_sip(size_t vcpu_id, seL4_UserContext *regs,  uint64_t fn_number, uint32_t hsr)
{
    switch (fn_number) {
        case IMX_SIP_GET_SOC_INFO:
            uint32_t version = (0x02 << 4) & (0x01 << 0);
            smc_set_return_value(regs, version);
            break;

        default:
            LOG_VMM_ERR("Unhandled SIP function ID 0x%lx\n", fn_number);
            return false;
    }
    bool success = fault_advance_vcpu(vcpu_id, regs);
    assert(success);
    return success;
}
