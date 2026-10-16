//=============================================================================
// Project       : APB VIP
//=============================================================================
// Filename      : ahb_define.sv
// Author        : Minh Phan
// Email         : ?
// Date          : 15-10-2026
//=============================================================================
// Description   : Define can override by environment
//
//
//
//=============================================================================
`ifndef GUARD_APB_DEFINE__SV
`define GUARD_APB_DEFINE__SV

  `ifndef APB_ADDR_WIDTH
     `define APB_ADDR_WIDTH   12
  `endif
  `ifndef APB_DATA_WIDTH
     `define APB_DATA_WIDTH   32 
  `endif

`endif

