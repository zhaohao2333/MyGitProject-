
//********************************************************************************//
//********** 		(C) Copyright 2018 SMIC Inc.			**********//
//**********   		    SMIC Verilog Models       			**********//
//********************************************************************************//
//	 FileName   : SP018V3EBCDD5SVRP.v  					  //
//	 Function   : Verilog Models (zero timing)	  			  //
//	 Version    : 0.1	  						  //
//	 Author     : Fang_Li	  						  //
//	 CreateDate : September-07-2018	  					  //
//********************************************************************************//
////////////////////////////////////////////////////////////////////////////////////
//DISCLAIMER                                                                      //
//                                                                                //
//   SMIC hereby provides the quality information to you but makes no claims,     //
// promises or guarantees about the accuracy, completeness, or adequacy of the    //
// information herein. The information contained herein is provided on an "AS IS" //
// basis without any warranty, and SMIC assumes no obligation to provide support  //
// of any kind or otherwise maintain the information.                             //
//   SMIC disclaims any representation that the information does not infringe any //
// intellectual property rights or proprietary rights of any third parties.SMIC   //
// makes no other warranty, whether express, implied or statutory as to any       //
// matter whatsoever,including but not limited to the accuracy or sufficiency of  //
// any information or the merchantability and fitness for a particular purpose.   //
// Neither SMIC nor any of its representatives shall be liable for any cause of   //
// action incurred to connect to this service.                                    //
//                                                                                //
// STATEMENT OF USE AND CONFIDENTIALITY                                           //
//                                                                                //
//   The following/attached material contains confidential and proprietary        //
// information of SMIC. This material is based upon information which SMIC        //
// considers reliable, but SMIC neither represents nor warrants that such         //
// information is accurate or complete, and it must not be relied upon as such.   //
// This information was prepared for informational purposes and is for the use    //
// by SMIC's customer only. SMIC reserves the right to make changes in the        //
// information at any time without notice.                                        //
//   No part of this information may be reproduced, transmitted, transcribed,     //
// stored in a retrieval system, or translated into any human or computer         //
// language, in any form or by any means, electronic, mechanical, magnetic,       //
// optical, chemical, manual, or otherwise, without the prior written consent of  //
// SMIC. Any unauthorized use or disclosure of this material is strictly          //
// prohibited and may be unlawful. By accepting this material, the receiving      //
// party shall be deemed to have acknowledged, accepted, and agreed to be bound   //
// by the foregoing limitations and restrictions. Thank you.                      //
////////////////////////////////////////////////////////////////////////////////////

// ****** (C) Copyright 2018 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: p1diode8r_d5.v
// Description  	: power cut for high voltage
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module P1DIODE8R_D5 (VSS1,VSS2);

inout VSS1;
inout VSS2;

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine
 
// ****** (C) Copyright 2018 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : p2diode8r_d5.v
// Description          : Power-Cut Cell for High Voltage Drop for different voltage level between digital and analog 
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module P2DIODE8R_D5(VSS1,VSS2);

inout VSS1;
inout VSS2;

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine

// ****** (C) Copyright 2018 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pana1apr_d5.v
// Description  	: antenna pad
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PANA1APR_D5 (PAD);
inout PAD;


   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine
 
 
// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pb4cud16svr.v
// Description  	: CMOS 3-state bi-direction I/O pad with controlled
// 			  driving strength of four level and
//                        pull-down, pull-up resistor
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif 


module PB4CUD16R_D5 (PAD,OEN,PU,PD,I,DS0,DS1,C,IE);

output  C;
input   OEN,PU,PD,I,DS0,DS1,IE;
inout   PAD;

  supply1 my1;
  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and     (C,PAD,IE);
  rnmos   #0.01 (C_buf,my1,PU);
  rnmos   #0.01 (C_buf,my0,PD);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (PAD => C) = (0,0);

 (IE => C) = (0,0);

 if(DS0 === 1'b0 && DS1 === 1'b0 ) (I => PAD) = (0,0);
 if(DS0 === 1'b1 && DS1 === 1'b0 ) (I => PAD) = (0,0);
 if(DS0 === 1'b0 && DS1 === 1'b1 ) (I => PAD) = (0,0);
 if(DS0 === 1'b1 && DS1 === 1'b1 ) (I => PAD) = (0,0);
 ifnone (I => PAD) = (0,0);

 if(DS0 === 1'b0 && DS1 === 1'b0 ) (OEN => PAD) = (0,0,0,0,0,0);
 if(DS0 === 1'b1 && DS1 === 1'b0 ) (OEN => PAD) = (0,0,0,0,0,0);
 if(DS0 === 1'b0 && DS1 === 1'b1 ) (OEN => PAD) = (0,0,0,0,0,0);
 if(DS0 === 1'b1 && DS1 === 1'b1 ) (OEN => PAD) = (0,0,0,0,0,0);
 ifnone (OEN => PAD) = (0,0,0,0,0,0);

endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults

 
// ****** (C) Copyright 2018 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pdiode8sr_d5.v
// Description  	: power cut for high voltage and short ground
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PDIODE8SR_D5 ();

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine
 

 
// ****** (C) Copyright 2018 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pvdd1r_d5.v
// Description  	: VDD Pad 
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVDD1R_D5 (VDD);

   inout VDD;

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine
 
// ****** (C) Copyright 2018 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pvdd1apr_d5.v
// Description  	: analog vdd
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVDD1APR_D5 (SVDD1AP);

   inout SVDD1AP;

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine
 
 
// ****** (C) Copyright 2018 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pvdd2r_d5.v
// Description  	: VDD Pad 
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVDD2R_D5 ();


   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine
 
// ****** (C) Copyright 2018 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pvdd3r_d5.v
// Description  	: VDD Pad 
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVDD3R_D5 (VDD50);

   inout VDD50;

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine
 
// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pvdd3apr_D5.v
// Description  	: analog vdd
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVDD3APR_D5 (SAVDD);

   inout SAVDD;

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine
 
 
// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pvss1r_d5.v
// Description  	: VSS Pad 
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVSS1R_D5 (VSS);

   inout VSS;

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine
 
// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pvss1apr_d5.v
// Description  	: analog vss
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVSS1APR_D5 (SVSS1AP);

   inout SVSS1AP;

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine
 
 
 
// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pvss2r_d5.v
// Description  	: VSS Pad 
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVSS2R_D5 ();


   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine
 
 
// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pvss3r_d5.v
// Description  	: VSS Pad 
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVSS3R_D5 (VSS);

   inout VSS;

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine
 
// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pvss3apr_d5.v
// Description  	: analog vss
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVSS3APR_D5 (SAVSS);

   inout SAVSS;

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine
 
 

// ****** (C) Copyright 2018 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvdd1anpr_D5.v
// Description          : VDD analog PAD within digital power domain 
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVDD1ANPR_D5 (SVDD1ANP);

   inout SVDD1ANP;

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine

// ****** (C) Copyright 2013 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvss1anpr_d5.v
// Description          : VSS analog PAD within digital power domain 
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVSS1ANPR_D5 (SVSS1ANP);

   inout SVSS1ANP;

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine

// ****** (C) Copyright 2018 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : vdd2ce.v
// Description          : 5V efuse ESD protection cell
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module VDD2CER_D5 (VDD50_CP,VSS_CP);

   inout VDD50_CP;
   inout VSS_CP;

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine
