/***********************************************************************************
** DISCLAIMER                                                                     **
**                                                                                **
**   SMIC hereby provides the quality information to you but makes no claims,     **
** promises or guarantees about the accuracy, completeness, or adequacy of the    **
** information herein. The information contained herein is provided on an "AS IS" **
** basis without any warranty, and SMIC assumes no obligation to provide support  **
** of any kind or otherwise maintain the information.                             **
**   SMIC disclaims any representation that the information does not infringe any **
** intellectual property rights or proprietary rights of any third parties.SMIC   **
** makes no other warranty, whether express, implied or statutory as to any       **
** matter whatsoever,including but not limited to the accuracy or sufficiency of  **
** any information or the merchantability and fitness for a particular purpose.   **
** Neither SMIC nor any of its representatives shall be liable for any cause of   **
** action incurred to connect to this service.                                    **
**                                                                                **
** STATEMENT OF USE AND CONFIDENTIALITY                                           **
**                                                                                **
**   The following/attached material contains confidential and proprietary        **
** information of SMIC. This material is based upon information which SMIC        **
** considers reliable, but SMIC neither represents nor warrants that such         **
** information is accurate or complete, and it must not be relied upon as such.   **
** This information was prepared for informational purposes and is for the use    **
** by SMIC's customer only. SMIC reserves the right to make changes in the        **
** information at any time without notice.                                        **
**   No part of this information may be reproduced, transmitted, transcribed,     **
** stored in a retrieval system, or translated into any human or computer         **
** language, in any form or by any means, electronic, mechanical, magnetic,       **
** optical, chemical, manual, or otherwise, without the prior written consent of  **
** SMIC. Any unauthorized use or disclosure of this material is strictly          **
** prohibited and may be unlawful. By accepting this material, the receiving      **
** party shall be deemed to have acknowledged, accepted, and agreed to be bound   **
** by the foregoing limitations and restrictions. Thank you.                      **
************************************************************************************
**  Check tool version:
**  VCS       :  vcs_2011.12-SP1
**  NC-Verilog:  INCISIV10.20.035
**  ModelSim  :  ams_2012.1_1 
** 
************************************************************************************
**  Project : S018V3EBCDEFUSE_SISO32B3M (IP DesignKit)                                
**                                                                                 
************************************************************************************
**  History:                                                                       
**  Version   Date         Author       Description                                
************************************************************************************
**  V0.1.1    2018/09/05    Kessy	Initial release 
**  V0.2.2    2019/02/28    Kessy       Update AVDD function to allow accumulative total time of AVDD can exceed 1s
**                                      Update timing check for TSP_AVDD_RW&THP_AVDD_RW&TSP_RW_CS&THP_RW_CS 
***********************************************************************************/
`celldefine
`timescale 1ns/1ps

////////////////////////////////////////////////////////////////////// 
//  IMPORTANT!!! Before using the model, must be familiar with:
//  user defined compile directives or options as listed below
////////////////////////////////////////////////////////////////////// 

    /**********************************************************************************/
    /* | NO_TIMING_OP | if defined, no timing check or timing constraint is performed */
    /**********************************************************************************/

//  `define NO_TIMING_OP 

    /**************************************************************************************/
    /* | NO_SIM_STOP_OP | if defined, simulation won't stop regardless of error or timing */
    /*                    violation, except for errors relating to power supplies         */
    /**************************************************************************************/

    `define NO_SIM_STOP_OP

//  -------------------------------------------------------------------------
//  Macro definition
//  -------------------------------------------------------------------------
    /**********************/
    /* Timing definitions */
    /**********************/
    /* Program mode timing definitions */
    `define TSP_CK       50    // CS to SCLK rising edge setup time into program mode
    `define THP_CK       50    // CS to SCLKs falling edge hold time out of program mode
    `define TCKLP_P      100    // SCLK low period in program mode
    `define TPGM_MIN     9000   // Burning minimum time 
    `define TPGM_MAX	 11000  // Burning maximum time
    `define TS_PGM       2      // PGM to SCLK setup time 
    `define TH_PGM	 0      // PGM to SCLK hold time 
    `define TSP_AVDD_RW  1000   // RW to AVDD setup time into program mode
    `define THP_AVDD_RW  1000   // RW to AVDD hold time out of program mode
    `define TSP_RW_CS	 50    // AVDD to CS setup time into program mode
    `define THP_RW_CS	 50    // AVDD to CS hold time out of program mode
    /* Read mode timing definitions */
    `define TCKHP        500    // SCLK high period in read mode
    `define TCKLP_R      500    // SCLK low period in read mode
    `define TSR_CK	 50    // CS to SCLK setup time into read mode
    `define THR_CK	 50      // CS to SCLK hold time out of read mode
    `define TSR_RW	 50    // RW to CS setup time into read mode
    `define THR_RW	 50    // RW to CS hold time out of read mode
    `define TDQH         0     // DOUT to CS hold time out of read mode
//  `define TDQH         15     // DOUT to CS hold time out of read mode
    `define TCKDQ	 400    // DOUT to SCLK rising edge delay time
//  `define TCKDQ	 2.0    // DOUT to SCLK rising edge delay time
    `define TCKDQ_H	 0    // DOUT to SCLK rising edge hold time
    /* Timing definitions for all modes */
    `define TAVDD_ACC_MAX 1000000000 //	AVDD accumulative high time (in all modes)
    /* Power sequence timing definitions */
    `define TPS          0 	// Power on sequence AVDD to DVDD setup time
    `define TPH          0     // Power off sequence AVDD to DVDD hold time

    /*****************************************************/
    /* Monitoring Efuse state for debugging purpose only */
    /*****************************************************/
//  `define SM_MON       $display("    Current Efuse state is %s",efuse_sm)

module S018V3EBCDEFUSE_SISO32B3M ( 
    CS,
    RW,
    PGM,
    SCLK,
    DOUT,
    AVDD,
    DVDD,
    DVSS
);

    input         CS;     // Chip select(active-high)
    input         RW;     // Read/write selection active-high (5.0V) for program mode
                          // "low" (0V) for read mode
    input         PGM;    // Program enable
    input         SCLK;   // Serial clock
    output        DOUT;   // Data out
    input         AVDD;   // 5V burning voltage supply
    input         DVDD;   // 5.0V (Typ) core voltage supply
    input         DVSS;   // Ground

////////////////////////////////////////
//  Parameter definition              //
////////////////////////////////////////
    
    /***********************/
    /* SIMULATION CONTROLS */
    /***********************/
`ifdef NO_SIM_STOP_OP
    parameter NO_SIM_STOP    = 1;              // if =1, simulation will continue regardless of errors
`else
    parameter NO_SIM_STOP    = 0;              // if =0, simulation will end if simulation errror occurs
`endif
    parameter TAVDD_MAX_TEST = 1;              // if =1, TAVDD_MAX (accumulative) violation will be detected
    parameter LOG_TIME       = 50;             // Simulation continue time after Efuse enters SM_SIM_STOP state
                                               // sim_stop/sim_stop_forced signal cancelled and replaced by SM_SIM_STOP state
    /*********************/
    /* Timing parameters */
    /*********************/
    parameter TAVDD_MAX      = `TAVDD_ACC_MAX; // AVDD accumulative max high time
    parameter TDELTA         = 0.01;           // Small simulation time offset

    /*********************/
    /* Efuse volumn size */
    /*********************/
    parameter FUSE_SIZE = 32;          // Total Efuse strorage bit size

    /* Efuse state machine */
    parameter SM_PWROFF      = "DVDD POWER OFF";  // DVDD off (0/Z)
    parameter SM_INIT        = "INIT";            // Intial state when power on
    parameter SM_RD_RDY      = "READ REDAY";      // Read ready state
    parameter SM_PGM_RDY     = "PROGRAM REDAY";   // Program ready state
    parameter SM_IN_RD       = "IN READING";      // State when in reading process
    parameter SM_IN_PGM      = "IN PROGRAMMING";  // State when in programming process
    parameter SM_INACTIVE    = "INACTIVE";        // Inactive state
    parameter SM_ERR_CSVDD   = "ERR CS NOT 0 WHEN DVDD UP"; // Error state if CS is not low when DVDD being up
    parameter SM_ERR_XZ      = "ERR X/Z";         // Errors when certain signals take X/Z value illegally
    parameter SM_ERR_TG      = "ERR TOGGLE";      // Errors when certain signals toggle illegally
    parameter SM_ERR_AVDD    = "ERR AVDD";        // Errors when AVDD takes X or toggles illegally
    parameter SM_ERR_DVDD    = "ERR DVDD";        // Errors when DVDD takes X or toggles illegally
    parameter SM_ERR_PWROFF  = "ERR DVDD POWER OFF";                // Illegal DVDD power off
    parameter SM_ERR_AVDDVDD = "ERR AVDD NOT DOWN WHEN DVDD UP";     // Errors AVDD is high when DVDD being up 
    parameter SM_SIM_STOP    = "SIM STOP";                          // Simulation stop state

//  Signal declarations

    /* Buffered signals */
    reg           dout_rd;               // Data read from Efuse
    /* Notifier signals */
    reg notify_tsp_ck;                   // Notifier for TSP_CK violation
    reg notify_thp_ck;                   // Notifier for THP_CK violation
    reg notify_tcklp_p;                  // Notifier for TCKLP_P violation
    reg notify_tpgm_min;                 // Notifier for TPGM_MIN violation
    reg notify_ts_pgm;                   // Notifier for TS_PGM violation
    reg notify_th_pgm;                   // Notifier for TH_PGM violation
    reg notify_tckhp;                    // Notifier for TCKHP violation
    reg notify_tcklp_r;                  // Notifier for TCKLP_R violation
    reg notify_tsr_ck;                   // Notifier for TSR_CK violation
    reg notify_thr_ck;                   // Notifier for THR_CK violation
    reg notify_tsr_rw;                   // Notifier for TSR_RW violation
    reg notify_thr_rw;                   // Notifier for THR_RW violation
    /* Functional violation error flags */
    reg cs_xz_err;                       // =1 when CS becomes X/Z after simulation
    reg pgm_xz_err;                      // =1 when PGM becomes X/Z after simulation
    reg sclk_xz_err;                     // =1 when SCLK becomes X/Z after simulation
    reg rd_max_err;                      // =1 when in read attempt after max read bit # is reached
    reg pgm_max_err;                     // =1 when in program attempt after max program bit # is reached
    reg rd_max_flg;                      // =1 after max read bit # is reached and raised at SCLK 1->0
    reg rd_exit_en;                      // =1 to enable read mode exit
    reg pgm_max_flg;                     // =1 after max program bit # is reached and raised at SLKC 1->0
    reg pgm_exit_en;                     // =1 to enable program mode exit
    reg pgm_all_fused;                   // =1 if Efuse has been programmed once
    reg pgm_bit_fused;                   // =1 if a bit of Efuse has been programmed
    reg rw_xz_err;                       // =1 when RW becomes X/Z after simulation
    reg rw_tg_inpgm_err;                 // =1 when RW toggles in programming
    reg rw_tg_pgm_err;                   // =1 when RW toggles in program ready state
    reg rw_tg_inrd_err;                  // =1 when RW toggles in reading
    reg rw_tg_pgmpre_err;                // =1 when RW toggles in program preparation
    reg avdd_x_err;                      // =1 when AVDD becomes X after simulation
    reg avdd1_pwroff_err;                // =1 when AVDD becomes high in DVDD power off state
    reg avdd1_cs1_err;                   // =1 if AVDD power on after CS is high
    /* Timing violation error flags */
    reg tsr_rw_err;                      // =1 if TSR_RW violation occurs
    reg tsp_rw_err;                      // =1 if TSP_AVDD_RW violation occurs
    reg thp_rw_err;                      // =1 if THP-RW violation occurs
    reg tsp_avdd_cs_err;                 // =1 if TSP_RW_CS violation occurs
    reg thp_avdd_cs_err;                 // =1 if THP_RW_CS violation occurs
    /* Internal control, data and status signals */
    reg  [FUSE_SIZE-1:0]  fuse_data;     // Contents in Efuse storage bits 
    reg           cs_1st_vld;            // =1 when CS takes 1/0 other than X/Z after simulation
    reg           pgm_1st_vld;           // =1 when PGM takes 1/0 other than X/Z after simulation
    reg           sclk_1st_vld;          // =1 when SCLK takes 1/0 other than X/Z after simulation
    reg           rw_1st_vld;            // =1 when RW tales 1/0 other than X/Z after simulation
    reg           avdd_1st_vld;          // =1 when AVDD takes 1/0/Z other than X after simulation
    reg           dvdd_1st_vld;          // =1 when DVDD takes 1/0/Z other than X after simulation
    wire          inactive;              // =1 when inactive mode entered
    wire          pgm;                   // =1 when program mode entered
    wire          rd;                    // =1 when read mode entered
    reg           dout_change;           // =1 if D will change after an upcoming read
    integer       adr_cnt;               // Bit number counter for read and program
    integer       pgm_bit_pre;           // Bit address for which Efuse is just programmed
    wire          cs_is_1;               // =1 when CS is 1
    wire          cs_is_0;               // =1 when CS is 0
    wire          pgm_is_1;              // =1 if input PGM is 1
    wire          pgm_is_0;              // =1 if input PGM is 0
    wire          sclk_is_1;             // =1 if input SCLK is 1
    wire          sclk_is_0;             // =1 if input SCLK is 0
    wire          rw_is_1;               // =1 if input RW is 1
    wire          rw_is_0;               // =1 if input RW is 0
    wire          avdd_is_1;             // =1 if input AVDD is 1
    wire          avdd_is_0;             // =1 if input AVDD is 0
    wire          avdd_is_0z;            // =1 if input AVDD is 0 or Z
    wire          dvdd_is_1;             // =1 if input DVDD is 1
    wire          dvdd_is_0;             // =1 if input DVDD is 0
    wire          dvdd_is_0z;            // =1 if input DVDD is 0 or Z
    reg           function_in_err_state; // =1 if any function error state entered
    reg           function_in_err_flg;   // =1 if any function error flag raised
    wire          efuse_sm_is_inactive;  // =1 if efuse_sm is SM_INACTIVE
    reg           fuse_pgm_done;         // =1 once an Efuse bit is programmed successfully
    /* Efuse RD PGM mode state machine */
    reg [271:0]   efuse_sm;
    /* Timing check and record signals */
    real          avdd_to_1_time;        // The time when AVDD changes to high
    integer       avdd_to_1_time_int;    // avdd_to_1_time in integer format
    real          avdd_from_1_time;      // The time when AVDD changes to 0/X/Z
    integer       avdd_from_1_time_int;  // avdd_from_1_time in interger format
    reg           avdd_max_chk_clk;      // TAVDD_MAX check sequencer
    real          avdd_1_sum_time;       // The accumulative time AVDD has been high
    integer       avdd_1_sum_time_int;   // The accumulative time AVDD has been high in integer
    real          sclk_to_1_time_tpgm_max_det;        // The time when SCLK 0->1 for TPGM_MAX timing check   
    integer       sclk_to_1_time_tpgm_max_det_int;    // sclk_to_1_time_tpgm_max_det in integer format
    real          dvdd_pwron_time_tps_1rst_det;       // The time when DVDD X->1 right after simulation for TPS timing check
    integer       dvdd_pwron_time_tps_1rst_det_int;   // dvdd_pwron_time_tps_1rst_det in integer format
    real          dvdd_pwron_time_tps_det;            // The time when DVDD 0/Z->1 for TPS timing check
    integer       dvdd_pwron_time_tps_det_int;        // dvdd_pwron_time_tps_det in integer format
    real          avdd_pwroff_time_tph_det;           // The time when AVDD power off for TPH timing check
    integer       avdd_pwroff_time_tph_det_int;       // avdd_pwroff_time_tph_det in integer format
    real          rw_to_1_time_tsp_rw_det;            // The time when RW toggles to 1 for TSP_AVDD_RW timing check
    integer       rw_to_1_time_tsp_rw_det_int;        // rw_to_1_time_tsp_rw_det in integer format
    real          avdd_pwron_time_thp_rw_det;         // AVDD power on time for THP_AVDD_RW timing check
    integer       avdd_pwron_time_thp_rw_det_int;     // avdd_pwron_time_thp_rw_det in integer format
    real          avdd_pwron_time_tsp_avdd_cs_det;    // AVDD power on time for TSP_RW_CS timing check
    integer       avdd_pwron_time_tsp_avdd_cs_det_int;// avdd_pwron_time_tsp_avdd_cs_det in integer format
    real          cs_to_0_time_thp_avdd_cs_det;       // The time when CS toggles to 0 for THP_RW_CS timing check
    integer       cs_to_0_time_thp_avdd_cs_det_int;   // cs_to_0_time_thp_avdd_cs_det in integer format
    /* Port buffers */
    wire          cs_buf;
    wire          pgm_buf;
    wire          sclk_buf;
    wire          buf_dout;
    wire          avdd_buf;
    wire          dvdd_buf;
    /* Timing check condition signals */
    wire          tsp_ck_en;             // TSP_CK check enable
    wire          thp_ck_en;             // THP_CK check enable
    wire          tcklp_p_en;            // TCKLP_P check enable
    wire          ts_pgm_en;             // TS_PGM check enable
    wire          th_pgm_en;             // TH_PGM check enable
    wire          tckhp_en;              // TCKHP check enable
    wire          tcklp_r_en;            // TCKLP_R check enable
    wire          tsr_ck_en;             // TSR_CK check enable
    wire          thr_ck_en;             // THR_CK check enable
    wire          tsr_rw_en;             // TSR_RW check enable
    wire          thr_rw_en;             // THR_RW check enable
    wire          tdqh_en;               // TDQH check enable
    wire          tckdq_en;              // TCKDQ check enable
    wire          tsp_rw_en;             // TSP_AVDD_RW check enable
    wire          thp_rw_en;             // THP_AVDD_RW check enable
    wire          tsp_avdd_cs_en;        // TSP_RW_CS check enable
    wire          thp_avdd_cs_en;        // THP_RW_CS check enable
    wire          tpgm_min_en;              // TPGM_MIN check enable
    /* Other signals */
    integer       i;
    real rw_pos_time;
    real pgm_pos_time;

//  Port buffering
    /* Input signal buffers */
    buf    (cs_buf, CS);
    buf    (pgm_buf,PGM);
    buf    (sclk_buf,SCLK);
    buf    (rw_buf,RW);
    /* Output signal buffer */
    buf    (DOUT, buf_dout);
    /* AVDD buffer */
    assign avdd_buf    = AVDD;
    /* DVDD buffer */
    assign dvdd_buf    = DVDD;

//  Signal assignment
    /* Output port assignment */
    wire #(0,`TDQH) cs_read = cs_buf;
    assign buf_dout  = (dout_rd && (cs_read===1'b1));
    /* Assignment of internal control, data and status signals */
    assign cs_is_1   =(cs_buf===1'b1);
    assign cs_is_0   =(cs_buf===1'b0);
    assign pgm_is_1  =(pgm_buf===1'b1);
    assign pgm_is_0  =(pgm_buf===1'b0);
    assign sclk_is_1 =(sclk_buf===1'b1);
    assign sclk_is_0 =(sclk_buf===1'b0);
    assign rw_is_1   =(rw_buf===1'b1);
    assign rw_is_0   =(rw_buf===1'b0);
    assign avdd_is_1 =(avdd_buf===1'b1);
    assign avdd_is_0 =(avdd_buf===1'b0);
    assign avdd_is_0z=(avdd_buf===1'b0||avdd_buf===1'bz);
    assign dvdd_is_1 =(dvdd_buf===1'b1);
    assign dvdd_is_0 =(dvdd_buf===1'b0);
    assign dvdd_is_0z=(dvdd_buf===1'b0||dvdd_buf===1'bz);
    assign inactive  =(cs_buf===1'b0&&pgm_buf!==1'bx&&sclk_buf!==1'bx&&rw_buf!==1'bx/*&&(avdd_buf===1'b0||avdd_buf===1'bz)*/&&dvdd_buf===1'b1);
    assign pgm       =(cs_buf===1'b1&&pgm_buf!==1'bx&&sclk_buf!==1'bx&&rw_buf==1'b1&&avdd_buf===1'b1&&dvdd_buf===1'b1);
    assign rd        =(cs_buf===1'b1&&pgm_buf!==1'bx&&sclk_buf!==1'bx&&rw_buf==1'b0/*&&(avdd_buf===1'b0||avdd_buf===1'bz)*/&&dvdd_buf===1'b1);
    assign efuse_sm_is_inactive = (efuse_sm==SM_INACTIVE);
    /* Timing check condition signals */
    assign tsp_ck_en  =(DVDD===1'b1)&(AVDD===1'b1)&(CS===1'b1)&(PGM===1'b1)&(SCLK!==1'bx)&(SCLK!==1'bz)&(RW===1'b1);
    assign thp_ck_en  =(DVDD===1'b1)&(AVDD===1'b1)&(CS===1'b1)&(PGM===1'b1|PGM===1'b0)&(SCLK!==1'bx)&(SCLK!==1'bz)&(RW===1'b1);
    assign tpgm_min_en=(DVDD===1'b1)&(AVDD===1'b1)&(CS===1'b1)&(PGM!==1'bx)&(PGM!==1'bz)&(SCLK!==1'bx)&(SCLK!==1'bz)&(RW===1'b1);
    assign tcklp_p_en =(DVDD===1'b1)&(AVDD===1'b1)&(CS===1'b1)&(PGM!==1'bx)&(PGM!==1'bz)&(SCLK!==1'bx)&(SCLK!==1'bz)&(RW===1'b1);
    assign ts_pgm_en  =(DVDD===1'b1)&(AVDD===1'b1)&(CS===1'b1)&(PGM===1'b1)&(SCLK!==1'bx)&(SCLK!==1'bz)&(RW===1'b1);
    assign th_pgm_en  =(DVDD===1'b1)&(AVDD===1'b1)&(CS===1'b1)&(PGM===1'b1)&(SCLK!==1'bx)&(SCLK!==1'bz)&(RW===1'b1);
    assign tckhp_en   =(DVDD===1'b1)/*&(AVDD===1'b0|AVDD===1'bz)*/&(CS===1'b1)&(PGM===1'b1|PGM===1'b0)&(SCLK!==1'bx)&(SCLK!==1'bz)&(RW===1'b0);
    assign tcklp_r_en =(DVDD===1'b1)/*&(AVDD===1'b0|AVDD===1'bz)*/&(CS===1'b1)&(PGM===1'b1|PGM===1'b0)&(SCLK!==1'bx)&(SCLK!==1'bz)&(RW===1'b0);
    assign tsr_ck_en  =(DVDD===1'b1)/*&(AVDD===1'b0|AVDD===1'bz)*/&(CS===1'b1)&(PGM===1'b1|PGM===1'b0)&(RW===1'b0);
    assign thr_ck_en  =(DVDD===1'b1)/*&(AVDD===1'b0|AVDD===1'bz)*/&(CS===1'b1)&(PGM===1'b1|PGM===1'b0)&(RW===1'b0);
    assign tsr_rw_en  =(DVDD===1'b1)/*&(AVDD===1'b0|AVDD===1'bz)*/&(PGM===1'b1|PGM===1'b0)&(RW===1'b0);
    assign thr_rw_en  =(DVDD===1'b1)/*&(AVDD===1'b0|AVDD===1'bz)*/&(PGM===1'b1|PGM===1'b0)&(RW===1'b0);
    assign tdqh_en    =(DVDD===1'b1)/*&(AVDD===1'b0|AVDD===1'bz)*/&(CS===1'b0)&(PGM===1'b1|PGM===1'b0)&(SCLK===1'b0)&(RW===1'b0);
//  assign tdqh_en    =(DVDD===1'b1)/*&(AVDD===1'b0|AVDD===1'bz)*/&(CS!==1'bx)&(CS!==1'bz)&(PGM===1'b1|PGM===1'b0)&(SCLK===1'b0)&(RW===1'b0);
//  assign tdqh_en    =(DVDD===1'b1)/*&(AVDD===1'b0|AVDD===1'bz)*/&(PGM===1'b1|PGM===1'b0)&(RW===1'b0);
    assign tckdq_en   =(DVDD===1'b1)/*&(AVDD===1'b0|AVDD===1'bz)*/&(PGM===1'b1|PGM===1'b0)&(SCLK===1'b1)&(RW===1'b0);
    assign tsp_rw_en  =(DVDD===1'b1)&(AVDD===1'b1)&(PGM===1'b1|PGM===1'b0)&(SCLK===1'b1|SCLK===1'b0)&(RW===1'b1);
    assign thp_rw_en  =(DVDD===1'b1)&(AVDD===1'b0|AVDD===1'bz)&(CS===1'b0)&(PGM===1'b0|PGM===1'b1)&(SCLK===1'b1|SCLK===1'b0)&(RW===1'b1);
    assign tsp_avdd_cs_en=(DVDD===1'b1)&(AVDD===1'b1)&(CS===1'b1)&(PGM===1'b1|PGM===1'b0)&(SCLK===1'b1|SCLK===1'b0)&(RW===1'b1);
    assign thp_avdd_cs_en=(DVDD===1'b1)&(AVDD===1'b1)&(CS===1'b0)&(PGM===1'b1|PGM===1'b0)&(SCLK===1'b0)&(RW===1'b1);
/////////////////////////////////
//  Intialize signals or states
/////////////////////////////////
    initial begin
        /*********************************/
        /* Initialize the data in Efuse  */
        /*********************************/
        $display("------------------------------------------------");
        $display ("Info(@%0.3f ns): All Efuse data initialized as 0s.", $realtime);
        INIT_EFUSE;
        /* Initialize buffered signals */
        dout_rd             = 1'bx;
        /* Intialize notifiers */ 
        notify_tsp_ck  =1'b0; // Notifier for TSP_CK violation
        notify_thp_ck  =1'b0; // Notifier for THP_CK violation
        notify_tcklp_p =1'b0; // Notifier for TCKLP_P violation
        notify_tpgm_min=1'b0; // Notifier for TPGM_MIN violation
        notify_ts_pgm  =1'b0; // Notifier for TS_PGM violation
        notify_th_pgm  =1'b0; // Notifier for TH_PGM violation
        notify_tckhp   =1'b0; // Notifier for TCKHP violation
        notify_tcklp_r =1'b0; // Notifier for TCKLP_R violation
        notify_tsr_ck  =1'b0; // Notifier for TSR_CK violation
        notify_thr_ck  =1'b0; // Notifier for THR_CK violation
        notify_tsr_rw  =1'b0; // Notifier for TSR_RW violation
        notify_thr_rw  =1'b0; // Notifier for THR_RW violation
        /* Intialize functional violation error flags */
        cs_xz_err       =1'b0;// =1 when CS becomes X/Z after simulation
        pgm_xz_err      =1'b0;// =1 when PGM becomes X/Z after simulation
        sclk_xz_err     =1'b0;// =1 when SCLK becomes X/Z after simulation
        rd_max_err      =1'b0;// =1 when in read attempt after max read bit # is reached
        pgm_max_err     =1'b0;// =1 when in program attempt after max program bit # is reached
        rd_max_flg      =1'b0;// =1 after max read bit # is reached and raised at SCLK 1->0
        rd_exit_en      =1'b0;// =1 to enable read mode exit
        pgm_max_flg     =1'b0;// =1 after max program bit # is reached and raised at SCLK 1->0
        pgm_exit_en     =1'b0;// =1 to enable program mode exit
        pgm_all_fused   =1'b0;// =1 if Efuse has been programmed once
        pgm_bit_fused   =1'b0;// =1 if a bit of Efuse has been programmed
        rw_xz_err       =1'b0;// =1 when RW becomes X/Z after simulation
        rw_tg_inpgm_err =1'b0;// =1 when RW toggles in programming
        rw_tg_pgm_err   =1'b0;// =1 when RW toggles in program ready state
        rw_tg_inrd_err  =1'b0;// =1 when RW toggles in reading
        rw_tg_pgmpre_err=1'b0;// =1 when RW toggles in program preparation
        avdd_x_err      =1'b0;// =1 when AVDD becomes X after simulation
        avdd1_pwroff_err=1'b0;// =1 when AVDD becomes high in DVDD power off state
        avdd1_cs1_err   =1'b0;// =1 if AVDD power on after CS is high
        function_in_err_state=1'b0;// =1 if any function error state entered
        function_in_err_flg  =1'b0;// =1 if any funciton error flag raised
        /* Initialize timing violation error flags */
        tsr_rw_err      =1'b0;// =1 if TSR_RW violation occurs
        tsp_rw_err      =1'b0;// =1 if TSP_AVDD_RW violation occurs
        thp_rw_err      =1'b0;// =1 if THP-RW violation occurs
        tsp_avdd_cs_err =1'b0;// =1 if TSP_RW_CS violation occurs
        thp_avdd_cs_err =1'b0;// =1 if THP_RW_CS violation occurs
        /* Iniitialize internal control, data and status signals */
        cs_1st_vld      =1'b0;// =1 when CS takes 1/0 other than X/Z after simulation
        pgm_1st_vld     =1'b0;// =1 when PGM takes 1/0 other than X/Z after simulation
        sclk_1st_vld    =1'b0;// =1 when SCLK takes 1/0 other than X/Z after simulation
        rw_1st_vld      =1'b0;// =1 when RW tales 1/0 other than X/Z after simulation
        avdd_1st_vld    =1'b0;// =1 when AVDD takes 1/0/Z other than X after simulation
        dvdd_1st_vld    =1'b0;// =1 when DVDD takes 1/0/Z other than X after simulation
        adr_cnt         =0;
        dout_change     =1'b1;// =1 if DOUT will change after an upcoming read
        fuse_pgm_done   =1'b0;
        
        /* Efuse RD PGM mode state machine */
        efuse_sm  = SM_PWROFF;
        /* Initialize signals that record timing */
        avdd_to_1_time          =-1;    // The time when AVDD changes to high
        avdd_from_1_time        =-1;    // The time when AVDD changes to 0/X/Z
        avdd_max_chk_clk        =1'b0;  // TAVDD_MAX check sequencer
        sclk_to_1_time_tpgm_max_det=-1; // The time when SCLK 0->1 for TPGM_MAX timing check   
        avdd_1_sum_time=-1;             // The accumulative time AVDD has been high
        dvdd_pwron_time_tps_1rst_det=-1;// The time when DVDD X->1 right after simulation for TPS timing check
        dvdd_pwron_time_tps_det=-1;     // The time when DVDD 0/Z->1 for TPS timing check
        avdd_pwroff_time_tph_det=-1;    // The time when AVDD power off for TPH timing check
        rw_to_1_time_tsp_rw_det=-1;     // The time when RW toggles to 1 for TSP_AVDD_RW timing check
        avdd_pwron_time_thp_rw_det=-1;  // AVDD power on time for THP_AVDD_RW timing check
        avdd_pwron_time_tsp_avdd_cs_det=-1;// AVDD power on time for TSP_RW_CS timing check
        cs_to_0_time_thp_avdd_cs_det=-1;   // The time when CS toggles to 0 for THP_RW_CS timing check
    end
//////////////////////////////////////////////
// Record signals conversion to integer format
//////////////////////////////////////////////
    always@(avdd_to_1_time or avdd_from_1_time or sclk_to_1_time_tpgm_max_det or avdd_1_sum_time
         or dvdd_pwron_time_tps_1rst_det or dvdd_pwron_time_tps_det or avdd_pwroff_time_tph_det
         or rw_to_1_time_tsp_rw_det or avdd_pwron_time_thp_rw_det or avdd_pwron_time_tsp_avdd_cs_det 
         or cs_to_0_time_thp_avdd_cs_det) begin
        avdd_to_1_time_int = avdd_to_1_time;
        avdd_from_1_time_int = avdd_from_1_time;
        avdd_1_sum_time_int = avdd_1_sum_time;
        sclk_to_1_time_tpgm_max_det_int = sclk_to_1_time_tpgm_max_det;
        dvdd_pwron_time_tps_1rst_det_int = dvdd_pwron_time_tps_1rst_det;
        dvdd_pwron_time_tps_det_int = dvdd_pwron_time_tps_det;
        avdd_pwroff_time_tph_det_int = avdd_pwroff_time_tph_det;
        rw_to_1_time_tsp_rw_det_int = rw_to_1_time_tsp_rw_det;
        avdd_pwron_time_thp_rw_det_int = avdd_pwron_time_thp_rw_det;
        avdd_pwron_time_tsp_avdd_cs_det_int = avdd_pwron_time_tsp_avdd_cs_det;
        cs_to_0_time_thp_avdd_cs_det_int = cs_to_0_time_thp_avdd_cs_det;
    end
//////////////////////////
//  Detect inactive mode 
//////////////////////////
    always @(posedge efuse_sm_is_inactive) begin
        $display("------------------------------------------------");
        $display("Info(@%0.3f ns): Efuse enters inactive mode ...",$realtime);
    end
    always @(negedge efuse_sm_is_inactive) begin
        if ($realtime>0) begin
            $display("------------------------------------------------");
            $display("Info(@%0.3f ns): Efuse exits inactive mode ...", $realtime);
        end
    end 
////////////////////////////////////////////////////////////////////////////////////
//  Efuse state machine transitions. States depending on values of multiple signals
////////////////////////////////////////////////////////////////////////////////////
    /*************************************/
    /* SM_SIM_STOP -- 1st priority state */
    /*************************************/

    /* SM_INIT, SM_INACTIVE */
    always @(inactive) begin
//  always @(cs_buf or pgm_buf or sclk_buf or rw_buf or avdd_buf or dvdd_buf or inactive) begin
        if (efuse_sm!=SM_SIM_STOP) begin
            case (efuse_sm)
            SM_PWROFF: begin
                if (inactive==1'b1) efuse_sm=SM_INACTIVE;
//              if ( (cs_buf===1'b0&&pgm_buf!==1'bx&&sclk_buf!==1'bx&&rw_buf!==1'bx&&
//                   (avdd_buf===1'b0||avdd_buf===1'bz)&&dvdd_buf===1'b1) )
//                  efuse_sm=SM_INACTIVE;
                else if (dvdd_buf===1'b1) efuse_sm=SM_INIT;
            end
            SM_INIT,SM_PGM_RDY,SM_RD_RDY: begin
                if (inactive==1'b1) efuse_sm=SM_INACTIVE;
//              if ( (cs_buf===1'b0&&pgm_buf!==1'bx&&sclk_buf!==1'bx&&rw_buf!==1'bx&&
//                   (avdd_buf===1'b0||avdd_buf===1'bz)&&dvdd_buf===1'b1) )
//                  efuse_sm=SM_INACTIVE;
            end
            /* If it is in error state (excluding SM_ERR_CSVDD and SM_ERR_AVDDVDD), */
            /* INACTIVE state can be entered to reset error state or flags                */
//          SM_ERR_XZ,SM_ERR_TG,SM_ERR_AVDD,SM_ERR_DVDD,SM_ERR_PWROFF: begin
            SM_ERR_XZ,SM_ERR_AVDD,SM_ERR_DVDD,SM_ERR_PWROFF: begin
                if (inactive==1'b1) efuse_sm=SM_INACTIVE;
//              if ( (cs_buf===1'b0&&pgm_buf!==1'bx&&sclk_buf!==1'bx&&rw_buf!==1'bx&&
//                   (avdd_buf===1'b0||avdd_buf===1'bz)&&dvdd_buf===1'b1) )
//                  efuse_sm=SM_INACTIVE;
            end
            endcase
        end
    end
    always @(inactive) begin
        #(TDELTA);
        if (efuse_sm==SM_ERR_TG&&inactive==1'b1) efuse_sm=SM_INACTIVE;
    end
////////////////////////////////////////////////////////////////////////
//  Efuse state machine transitions. States depending on toggle events
//  Signal toggle events and invalid values detection
////////////////////////////////////////////////////////////////////////

    /* CS first valid value detection */
    always @(cs_buf) begin
        if (cs_buf!==1'bx&&cs_1st_vld===1'b0)
            cs_1st_vld = 1'b1;
    end
    
    /* CS X/Z error detection after simulation */
    /* Note error state SM_ERR_XZ can be overridden by other states that are error types */
    /* Only assured now is SM_SIM_STOP will not be overidden */
    always @(cs_buf) begin: CS_XZ_DET
        if (efuse_sm==SM_SIM_STOP) disable CS_XZ_DET;
        if (cs_1st_vld==1'b1&&cs_buf===1'bx) begin
            cs_xz_err = 1'b1;
            $display("------------------------------------------------");
            case (efuse_sm)
                SM_IN_PGM: begin
                    $display("Error!!!(@%0.3f ns): Unknown CS detected when in programming ...", $realtime);
                    if (pgm_buf==1'b1&&pgm_max_err==1'b0) begin // Exclude Max# error in program/read
                        fuse_data[adr_cnt] = 1'bx;
                        $display("Error!!!: Efuse bit %2d in programing is damaged!!!",adr_cnt);
                    end
                    else begin
                        $display("Error!!!: Efuse storage bit can be damaged!!!");
                    end
                    pgm_all_fused = 1'b1;
                end
                SM_PGM_RDY: begin
                    $display("Error!!!(@%0.3f ns): Unknown CS detected when in program mode!!!", $realtime);
                    if (pgm_bit_fused==1'b1) pgm_all_fused=1'b1;
                end
                SM_IN_RD: begin
                    $display("Error!!!(@%0.3f ns): Unknown CS detected when in reading mode ...", $realtime);
                    if (rd_max_err==1'b0) begin
                    //  disable FUSE_READ_PROCESS;disable RD_FUSE;
                        $display("Error!!!: Efuse bit %2d read corrupted!!!",adr_cnt);
                        $display("Error!!!: DOUT become invalid!");
                        dout_rd = 1'bx;
                    end
                end
                default: begin
                    $display("Error!!!(@%0.3f ns): Unknown CS detected after simulation!!!", $realtime);
                    $display("        DOUT will be invalid!");
                end
            endcase
            $display("        Please power off Efuse or go to inactive mode before any Efuse operation!!!");
            efuse_sm=SM_ERR_XZ;
        end
    end
    /* CS X/Z error flag cs_xz_err cleanup */
    always @(efuse_sm) begin
        if (efuse_sm==SM_PWROFF||efuse_sm==SM_INACTIVE)
            cs_xz_err = 1'b0; 
    end
    /* CS illegal toggle detection, 1->0, 0->1 and excluding X/Z detection */
    /* Note error state SM_ERR_TG can be overidden by other error state */
    always @(negedge cs_is_1) begin        // 1->0
    #0.01
        if (efuse_sm!=SM_SIM_STOP&&$realtime>0) begin
//      if (efuse_sm!=SM_SIM_STOP) begin
        if (cs_buf===1'b0) begin
            case (efuse_sm)
                SM_IN_PGM: begin
                    $display("------------------------------------------------");
                    $display("Error!!!(@%0.3f ns): CS 1->0 detected when in programming ...", $realtime);
                    if (pgm_buf==1'b1&&pgm_max_err==1'b0) begin // Exclude Max# error in program/read
                        fuse_data[adr_cnt] = 1'bx;
                        $display("Error!!!: Efuse bit %2d in programing is damaged!!!",adr_cnt);
                    end
                    else begin
                        $display("Error!!!: Efuse storage bit can be damaged!!!");
                    end
                    pgm_all_fused = 1'b1;
                    efuse_sm = SM_ERR_TG;
                end
                SM_PGM_RDY: begin
                    if (pgm_exit_en==1'b0) begin 
                        $display("------------------------------------------------");
                        $display("Error!!!(@%0.3f ns): CS 1->0 detected when all %2d bits program are not finished yet!!!",
                                          $realtime,                             FUSE_SIZE); 
                        $display("Error!!!: All %2d bits should be countered in programming before exiting program mode!!!",
                                                FUSE_SIZE);   
                        if (pgm_bit_fused==1'b1) pgm_all_fused = 1'b1;
                        efuse_sm = SM_ERR_TG;
                    end
                end
                SM_IN_RD: begin
                    $display("------------------------------------------------");
                    $display("Error!!!(@%0.3f ns): CS 1->0 detected when in reading mode!!!", $realtime);
                    if (rd_max_err==1'b0) begin
                        $display("Error!!!: Efuse bit %2d read corrupted!!!",adr_cnt);
                        $display("Error!!!: DOUT become invalid!");
                        dout_rd = 1'bx;
                    end
                    efuse_sm = SM_ERR_TG;
                end
                SM_RD_RDY: begin
                    if (rd_exit_en==1'b0) begin
                        dout_rd  = 1'bx;
                        $display("------------------------------------------------");
                        $display("Error!!!(@%0.3f ns): CS 1->0 detected when all %2d bits read are not finished yet!!!", 
                                              $realtime,                             FUSE_SIZE);
                        $display("Error!!!: All %2d bits should be read before exiting read mode!!!", FUSE_SIZE); 
                        efuse_sm = SM_ERR_TG;
                    end
                end
            endcase
        end
        end // if (efuse_sm!=SM_SIM_STOP)
    end
    always @(negedge cs_is_0) begin: CS_0_1_TG_DET // 0->1
    #0.01
        if (efuse_sm!=SM_SIM_STOP&&$realtime>0) begin
//      if (efuse_sm!=SM_SIM_STOP) begin
        if (cs_buf===1'b1) begin
//          if ((efuse_sm!=SM_INACTIVE)||(rd!=1'b1&&pgm!=1'b1)) begin  // Not going to any mode in rd or pgm
            if ( !(pgm_buf!==1'bx&&sclk_buf!==1'bx&&rw_buf!==1'bx/*&&(avdd_buf===1'b0||avdd_buf===1'bz)*/&&dvdd_buf===1'b1) &&
                 !(pgm_buf!==1'bx&&sclk_buf!==1'bx&&rw_buf==1'b1/*&&avdd_buf===1'b1*/&&dvdd_buf===1'b1)                     &&
                 !(pgm_buf!==1'bx&&sclk_buf!==1'bx&&rw_buf==1'b0/*&&(avdd_buf===1'b0||avdd_buf===1'bz)*/&&dvdd_buf===1'b1) 
               ) begin
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): Illegal CS 0->1 detected.", $realtime);
                $display("Error!!!: It does not lead to any of these legal modes: read, program or inactive.");
                efuse_sm = SM_ERR_TG;
            end
            else if (efuse_sm==SM_INACTIVE) begin
//              if (pgm==1'b1) begin
                if (pgm_buf!==1'bx&&sclk_buf!==1'bx&&rw_buf==1'b1&&avdd_buf===1'b1&&dvdd_buf===1'b1) begin
                    if (pgm_all_fused==1'b1) begin // If Efuse has been programmed
                        efuse_sm = SM_ERR_TG;
                        $display("Error!!!(@%0.3f ns): Attempt to enter program mode detected after Efuse has been programmed!!!",
                                           $realtime); 
                        $display("Error!!!: Entry to program mode is forbidden if Efuse has already been programmed!!!");
                    end
                end
            end
        end
        end // if (efuse_sm!=SM_SIM_STOP)
    end
    /* CS legal change detection 0->1 */
    always @(negedge cs_is_0) begin // 0->1
    #0.01
        if (efuse_sm!=SM_SIM_STOP&&$realtime>0) begin
//      if (efuse_sm!=SM_SIM_STOP) begin
        if (cs_buf===1'b1) begin
            if (efuse_sm==SM_INACTIVE) begin
//              if (pgm==1'b1) begin
                if (pgm_buf!==1'bx&&sclk_buf!==1'bx&&rw_buf==1'b1&&avdd_buf===1'b1&&dvdd_buf===1'b1) 
                begin
                    if (pgm_all_fused==1'b0) begin // If Efuse hasn't been programmed
                        efuse_sm = SM_PGM_RDY;
//                      #(TDELTA);
                        $display("------------------------------------------------");
                        if (pgm_buf==1'b1) begin
                            $display("Info(@%0.3f ns): Efuse enters program mode.", $realtime);
                            $display("Error!!!(@%0.3f ns): PGM high detected when entering program mode.", $realtime);
                            $display("       It's recommended PGM keeps low when entering program mode.");
                        end 
                        else if (sclk_buf==1'b1) begin
                            $display("Info(@%0.3f ns): Efuse enters program mode.", $realtime);
                            $display("Error!!!(@%0.3f ns): SCLK high detected when entering program mode.", $realtime);
                            $display("       It's recommended SCLK keeps low when entering program mode.");
                        end
                        else begin
                            $display("Info(@%0.3f ns): Efuse enters program mode.", $realtime);
                        end
                    end 
                    adr_cnt  = 0;
                end
//              else if (rd==1'b1) begin
                else if (pgm_buf!==1'bx&&sclk_buf!==1'bx&&rw_buf==1'b0/*&&(avdd_buf===1'b0||avdd_buf===1'bz)*/&&dvdd_buf===1'b1)
                begin
                    efuse_sm = SM_RD_RDY;
//                  #(TDELTA);
                    $display("------------------------------------------------");
                    if (pgm_buf==1'b1) begin
                        $display("Info(@%0.3f ns): Efuse enters read mode.", $realtime);
                        $display("Error!!!(@%0.3f ns): PGM high detected when entering read mode.", $realtime);
                        $display("       It's recommended PGM keeps low when entering read mode.");
                    end 
                    else if (sclk_buf==1'b1) begin
                        $display("Info(@%0.3f ns): Efuse enters read mode.", $realtime);
                        $display("Error!!!(@%0.3f ns): SCLK high detected when entering read mode.", $realtime);
                        $display("       It's recommended SCLK keeps low when entering read mode.");
                    end
                    else begin
                        $display("Info(@%0.3f ns): Efuse enters read mode.", $realtime);
                    end
                    adr_cnt  = 0;
                end
            end
        end
        end // if (efuse_sm!=SM_SIM_STOP)
    end
               
    /* PGM first valid value detection */
    always @(pgm_buf) begin
        if (pgm_buf!==1'bx&&pgm_1st_vld===1'b0)
            pgm_1st_vld = 1'b1;
    end
    /* PGM X/Z detection after simulation */ 
    always @(pgm_buf) begin:PGM_XZ_DETECT 
        if (efuse_sm==SM_SIM_STOP) disable PGM_XZ_DETECT;
        if (pgm_1st_vld==1'b1&&pgm_buf===1'bx) begin
            pgm_xz_err = 1'b1;
            $display("------------------------------------------------");
            case (efuse_sm)
                SM_IN_PGM: begin
                    $display("Error!!!(@%0.3f ns): Unknown PGM when in programming ...", $realtime);
                    if (pgm_max_err==1'b0) begin           // Exclude Max# error in program/read
                        fuse_data[adr_cnt] = 1'bx;
                        $display("    Efuse bit %2d in programing is damaged!!!",adr_cnt);
                    end
                    else begin
                        $display("    Efuse storage bit can be damaged!!!");
                    end
                    pgm_all_fused = 1'b1;
                end
                SM_PGM_RDY: begin
                    $display("Error!!!(@%0.3f ns): Unknown PGM detected when in program mode!!!", $realtime);
                    if (pgm_bit_fused==1'b1) pgm_all_fused=1'b1;
                end
                SM_IN_RD: begin
                    $display("Error!!!(@%0.3f ns): Unknown PGM when in reading mode ...", $realtime);
                    if (rd_max_err==1'b0) begin
                        $display("Error!!!: Efuse bit %2d read is corrupted!!!",adr_cnt);
                        $display("Error!!!: It can leads to uncertain state of Efuse. DOUT become invalid!");
                        dout_rd = 1'bx;
                    end
                end
                default: begin
                    dout_rd = 1'bx;
                    $display("Error!!!(@%0.3f ns): Unknown PGM after simulation ...", $realtime);
                end
            endcase
            $display("Please power off Efuse or go to inactive mode before any Efuse operation!!!");
            efuse_sm=SM_ERR_XZ;
        end
    end
    /* PGM X/Z error flag pgm_xz_err cleanup */
    always @(efuse_sm) begin
        if (efuse_sm==SM_PWROFF||efuse_sm==SM_INACTIVE)
            pgm_xz_err = 1'b0; 
    end
    /* PGM illegal toggle detection, 1->0, 0->1 and excluding X/Z detection */
    always @(negedge pgm_is_1) begin // 1->0
        if (efuse_sm!=SM_SIM_STOP&&$realtime>0) begin
//      if (efuse_sm!=SM_SIM_STOP) begin
        if(($realtime-pgm_pos_time)<(`TS_PGM+`TH_PGM)) begin
            	$display("------------------------------------------------");
            	$display("Error(@%0.3f ns): PGM width must be larger than TS_PGM+TH_PGM.",$realtime);
        end
        if (pgm_buf===1'b0) begin
            case (efuse_sm)
                SM_IN_RD,SM_RD_RDY: begin
                    $display("------------------------------------------------");
                    $display("Error(@%0.3f ns): PGM 1->0 toggle detected in read mode.",$realtime);
                end
                SM_INACTIVE: begin
                    $display("------------------------------------------------");
                    $display("Error(@%0.3f ns): PGM 1->0 toggle detected in inactive mode.",$realtime);
                end
                SM_PWROFF: begin
                    $display("------------------------------------------------");
                    $display("Error(@%0.3f ns): PGM 1->0 toggle detected in power off mode.",$realtime);
                end
            endcase
        end
        end // if (efuse_sm!=SM_SIM_STOP)
    end
    always @(negedge pgm_is_0) begin // 0->1
        if (efuse_sm!=SM_SIM_STOP&&$realtime>0) begin
//      if (efuse_sm!=SM_SIM_STOP) begin
        if (pgm_buf===1'b1) begin
	    pgm_pos_time = $realtime;
            case (efuse_sm)
                SM_IN_RD,SM_RD_RDY: begin
                    $display("------------------------------------------------");
                    $display("Error(@%0.3f ns): PGM 0->1 toggle detected in read mode.",$realtime);
                end
                SM_INACTIVE: begin
                    $display("------------------------------------------------");
                    $display("Error(@%0.3f ns): PGM 0->1 toggle detected in inactive mode.",$realtime);
                end
            endcase
        end
        end // if (efuse_sm!=SM_SIM_STOP)
    end
    /* PGM is 1 when transitioning to SM_RD_RDY or SM_PGM_RDY */
    /* Refer to "CS legal change detection" */

    /* SCLK first valid value detection */
    always @(sclk_buf) begin
        if (sclk_buf!==1'bx&&sclk_1st_vld===1'b0)
            sclk_1st_vld = 1'b1;
    end 
    /* SCLK X/Z detection after simulation */ 
    always @(sclk_buf) begin:SCLK_XZ_DETECT 
        if (efuse_sm==SM_SIM_STOP) disable SCLK_XZ_DETECT;
        if (sclk_1st_vld==1'b1&&sclk_buf===1'bx) begin
            sclk_xz_err = 1'b1;
            $display("------------------------------------------------");
            case (efuse_sm)
                SM_IN_PGM: begin
                    $display("Error!!!(@%0.3f ns): Unknown SCLK when in programming ...", $realtime);
                    if (pgm_buf==1'b1&&pgm_max_err==1'b0) begin // Exclude Max# error in program/read
                        fuse_data[adr_cnt] = 1'bx;
                        $display("    Efuse bit %2d in programing is damaged!!!",adr_cnt);
                    end
                    else begin
                        $display("    Efuse storage bit can be damaged!!!");
                    end
                    pgm_all_fused = 1'b1;
                end
                SM_PGM_RDY: begin
                    $display("Error!!!(@%0.3f ns): Unknown SCLK detected when in program mode!!!", $realtime);
                    if (pgm_bit_fused==1'b1) pgm_all_fused=1'b1;
                end
                SM_IN_RD: begin
                    $display("Error!!!(@%0.3f ns): Unknown SCLK when in reading mode ...", $realtime);
                    if (rd_max_err==1'b0) begin
                        $display("Error!!!: Efuse bit %2d read corrupted!!!",adr_cnt);
                        $display("Error!!!: DOUT become invalid!");
                        dout_rd = 1'bx;
                    end
                end
                default: begin
                    dout_rd = 1'bx;
                    $display("Error!!!(@%0.3f ns): Unknown SCLK after simulation ...", $realtime);
                end
            endcase
            $display("Please power off Efuse or go to inactive mode before any Efuse operation!!!");
            efuse_sm=SM_ERR_XZ;
        end
    end
    /* SCLK X/Z error flag sclk_xz_err cleanup */
    always @(efuse_sm) begin
        if (efuse_sm==SM_PWROFF||efuse_sm==SM_INACTIVE)
            sclk_xz_err = 1'b0; 
    end
    /* SCLK illegal toggle detection, 1->0, 0->1 and excluding X/Z detection */
    always @(negedge sclk_is_1) begin // 1->0
        if (sclk_buf===1'b0&&$realtime>0) begin
//      if (sclk_buf===1'b0) begin
//          if (efuse_sm==SM_INACTIVE) begin
            if (cs_buf==1'b0&&pgm_buf!==1'bx&&sclk_buf!==1'bx&&rw_buf!==1'bx/*&&(avdd_buf===1'b0||avdd_buf===1'bz)*/&&dvdd_buf===1'b1)
            begin
                $display("------------------------------------------------");
                $display("Error(@%0.3f ns): Unnecessary SCLK 1->0 toggle detected when CS=0.", $realtime);
            end
        end
    end
    always @(negedge sclk_is_0) begin // 0->1
        if (efuse_sm!=SM_SIM_STOP&&$realtime>0) begin
//      if (efuse_sm!=SM_SIM_STOP) begin
        if (sclk_buf===1'b1) begin
//          `SM_MON;
            case (efuse_sm)
            SM_RD_RDY,SM_IN_RD: begin
//              if (rd_max_err==1'b1) begin
                if (rd_max_flg==1'b1) begin
                    dout_rd = 1'bx;
                    $display("------------------------------------------------");
                    $display("Error!!!(@%0.3f ns): Read attempt detected after maximum number of read bits (%2d) is reached!!!",
                                       $realtime,  FUSE_SIZE);
                    $display("Errror!!!: No more read is allowed after %2d bits are read already", FUSE_SIZE);
                end
            end
            SM_PGM_RDY,SM_IN_PGM: begin
//              if (pgm_max_err==1'b1) begin
                if (pgm_max_flg==1'b1) begin
//                  if (pgm_bit_pre!=-1) begin
//                      fuse_data[adr_cnt] = 1'bx;
                        SET_FUSE_X;
                        $display("------------------------------------------------");
                        $display("Error!!!(@%0.3f ns): Program attempt detected after maximum number of program bits (%2d) is reached!!!",
                                       $realtime,FUSE_SIZE-1);
                        $display("Error!!!: Program is forbidden when program bit count (%2d) is reached", FUSE_SIZE-1);
//                      $display("Error!!!: Efuse bit number %2d just programmed can be damaged!!!",pgm_bit_pre);
                        $display("Error!!!: Efuse bit number %2d just programmed and other bits can be damaged!!!",pgm_bit_pre);
//                  end
                end
            end
            endcase
        end
        end // efuse_sm!=SM_SIM_STOP
    end
    /* rd_max_err and pgm_max_err flags cleanup */
    /* Indicators rd_exit_en and pgm_exit_en cleanup */
    /* Note: indicator pgm_all_fused never cleaned up */
    always @(efuse_sm) begin
        if (efuse_sm==SM_PWROFF||efuse_sm==SM_INACTIVE) begin
            rd_max_err = 1'b0;
            rd_max_flg = 1'b0;
            rd_exit_en = 1'b0;
            pgm_max_err = 1'b0;
            pgm_max_flg = 1'b0;
            pgm_exit_en = 1'b0;
        end
    end
    /* SCLK is 1 when transitioning to SM_RD_RDY or SM_PGM_RDY */
    /* Refer to "CS legal change detection" */
    
    /* SCLK legal toggle detection, 1->0, 0->1 and excluding X/Z detection */    
    always @(negedge sclk_is_1) begin // 1->0
    #0.01
        if (efuse_sm!=SM_SIM_STOP&&$realtime>0) begin
//      if (efuse_sm!=SM_SIM_STOP) begin
//      `SM_MON;
        if (sclk_buf===1'b0) begin
            case (efuse_sm) 
            SM_IN_PGM: begin
                efuse_sm = SM_PGM_RDY;
//          SM_PGM_RDY: begin
                /* PGM_FUSE task is done and programming is performed */
                #(TDELTA);
                if (fuse_pgm_done==1'b1) begin
                    $display ("Info(@%0.3f ns): Programming Efuse bit number %2d done.",$realtime-TDELTA,adr_cnt);
//                  $display ("Info(@%0.3f ns): Programming Efuse bit number %2d done.",$realtime,adr_cnt);
                    pgm_bit_pre = adr_cnt;
                end
                /* PGM_FUSE task is not done or programming is unable to perform */
                else begin
                    pgm_bit_pre = -1;
                end
                fuse_pgm_done = 1'b0;
                /* Check if next program will cause maximum program bit number error */
                /* Indicate if exiting program mode after current bit program is legal */
                if (adr_cnt==FUSE_SIZE-1) begin
                    pgm_max_flg  = 1'b1;
                    pgm_exit_en  = 1'b1;
                    pgm_all_fused= 1'b1;
                end
                else begin
                    adr_cnt     = adr_cnt+1;
                    pgm_exit_en = 1'b0;
                end
            end
            SM_IN_RD: begin
                /* Check if next read will cause maximum read bit number error */
                /* Indicate if exiting read mode after current bit read is legal */
                if (adr_cnt==FUSE_SIZE-1) begin
                    rd_max_flg = 1'b1;
                    rd_exit_en = 1'b1;
                end
                else begin
                    adr_cnt    = adr_cnt+1;
//                  rd_exit_en = 1'b0;  /////////modify on 2015-10-21
		    rd_exit_en = 1'b1;
                end
                efuse_sm = SM_RD_RDY;
            end
            endcase
        end
        end // if (efuse_sm!=SM_SIM_STOP)
    end
    always @(negedge sclk_is_0) begin // 0->1
    #0.01
        if (efuse_sm!=SM_SIM_STOP&&$realtime>0) begin
//      if (efuse_sm!=SM_SIM_STOP) begin
        if (sclk_buf===1'b1) begin
            case (efuse_sm)
            /* After entry into either SM_RD_RDY or SM_PGM_RDY state (per SCLK 1->0),   */
            /* if CS 1->0, state won't change and stays. In this case, SCLK 0->1 should */
            /* be forbidden and Efuse shall not enter SM_IN_RD or SM_IN_PGM             */
            SM_PGM_RDY: begin
            //  if (cs_buf==1'b1&&adr_cnt<FUSE_SIZE-1) begin
                if (cs_buf==1'b1) begin
                    if (pgm_max_flg==1'b1) pgm_max_err = 1'b1;
                    efuse_sm = SM_IN_PGM;
                end
            end
            SM_RD_RDY: begin
                if (cs_buf==1'b1) begin 
                    if (rd_max_flg==1'b1) rd_max_err = 1'b1;
                    efuse_sm = SM_IN_RD;
                end
            end
            endcase
        end
        end // if (efuse_sm!=SM_SIM_STOP)
    end
    
    /* RW first valid value detection */
    always @(rw_buf) begin
        if (rw_buf!==1'bx&&rw_1st_vld===1'b0)
            rw_1st_vld = 1'b1;
    end 
    /* RW X/Z detection after simulation */ 
    always @(rw_buf) begin:RW_XZ_DETECT 
        if (efuse_sm==SM_SIM_STOP) disable SCLK_XZ_DETECT;
        if (rw_1st_vld==1'b1&&rw_buf===1'bx) begin
            rw_xz_err = 1'b1;
            $display("------------------------------------------------");
            case (efuse_sm)
                SM_IN_PGM: begin
                    $display("Error!!!(@%0.3f ns): Unknown RW when in programming ...", $realtime);
                    if (pgm_buf==1'b1&&pgm_max_err==1'b0) begin // Exclude Max# error in program/read
                        fuse_data[adr_cnt] = 1'bx;
                        $display("Error!!!: Efuse bit %2d in programing is damaged!!!",adr_cnt);
                    end
                    else begin
                        $display("Error!!!: Efuse storage bit can be damaged!!!");
                    end
                end
                SM_PGM_RDY: begin
                    $display("Error!!!(@%0.3f ns): Unknown RW detected when in program mode!!!", $realtime);
                    if (pgm_bit_fused==1'b1) pgm_all_fused=1'b1;
                end
                SM_IN_RD: begin
                    $display("Error!!!(@%0.3f ns): Unknown RW when in reading mode ...", $realtime);
                    if (rd_max_err==1'b0) begin
                        $display("    DOUT become invalid!");
                        dout_rd = 1'bx;
                    end
                end
                default: begin
                    $display("Error!!!(@%0.3f ns): Unknown RW after simulation ...", $realtime);
                end
            endcase
            $display("Please power off Efuse or go to inactive mode before any Efuse operation!!!");
            efuse_sm=SM_ERR_XZ;
        end
    end
    /* RW X/Z error flag rw_xz_err cleanup */
    always @(efuse_sm) begin
        if (efuse_sm==SM_PWROFF||efuse_sm==SM_INACTIVE)
            rw_xz_err = 1'b0; 
    end
    /* RW illegal toggle detection, 1->0, 0->1 and excluding X/Z detection */
    always @(negedge rw_is_1) begin // 1->0
    #0.01
	//if((($realtime-rw_pos_time)<`TPGM_MIN)&&($realtime>0)) begin
        //    $display("------------------------------------------------");
        //    $display("Error!!!(@%0.3f ns): RW width must be larger than TPGM!!!",$realtime);	
	//end	    
        if (efuse_sm!=SM_SIM_STOP&&$realtime>0) begin
//      if (efuse_sm!=SM_SIM_STOP) begin
        if (rw_buf===1'b0) begin
            case (efuse_sm)
            SM_IN_PGM: begin
                if (sclk_buf==1'b1) begin
                    $display("------------------------------------------------");
                    $display("Error!!!(@%0.3f ns): RW toggle 1->0 detected when in programming (SCLK is 1) !!!",$realtime);
                    $display("    Efuse bit %2d in programming is damaged!!!", adr_cnt);
                    rw_tg_inpgm_err = 1'b1;
                    efuse_sm = SM_ERR_TG;
                    pgm_all_fused = 1'b1;
                end
            end
            SM_PGM_RDY: begin
                if (cs_buf==1'b1) begin
                    $display("------------------------------------------------");
                    $display("Error!!!(@%0.3f ns): RW toggle 1->0 detected when in program mode (CS is 1) !!!",$realtime);
                    /* Bit count variable to record the bit just programmed - pending */
                    $display("    Efuse bit %2d just programmed can be damaged!!!", adr_cnt);
                    if (pgm_bit_fused==1'b1) pgm_all_fused=1'b1;
                    rw_tg_pgm_err = 1'b1;
                    efuse_sm = SM_ERR_TG;
                end
                else if (cs_buf==1'b0) begin
                    $display("------------------------------------------------");
                    $display("Error!!!(@%0.3f ns): RW toggle 1->0 detected when in program mode (CS is 0).",$realtime);
                    $display("    To exit program mode, AVDD shall be 0 or floating before RW 1->0"); 
                    /* rw_tg_pgmpre_err = 1'b1;*/
                    efuse_sm = SM_ERR_TG;
                end
            end
            /*SM_INACTIVE: begin
                if (cs_buf==1'b0&&avdd_buf==1'b1) begin
                    $display("------------------------------------------------");
                    $display("Error!!!(@%0.3f ns): RW toggle 1->0 detected when AVDD is high (CS is 0).",$realtime);
                    $display("    To enter program mode, RW should remains to 1 before CS triggers to 1.");
                    efuse_sm = SM_ERR_TG;
                end
            end*/ 
            endcase
        end
        end // if (efuse_sm!=SM_SIM_STOP)
    end
    always @(negedge rw_is_0) begin // 0->1
    #0.01
        rw_pos_time = $realtime;
        if (efuse_sm!=SM_SIM_STOP&&$realtime>0) begin
//      if (efuse_sm!=SM_SIM_STOP) begin
        if (rw_buf===1'b1) begin
            case (efuse_sm)
                SM_IN_RD: begin
                    rw_tg_inrd_err = 1'b1;
                    $display("------------------------------------------------");
                    $display("Error!!!(@%0.3f ns): RW toggle 0->1 detected when in reading !!!",$realtime);
                    $display("    DOUT become invalid!");
                    dout_rd = 1'bx;
                    efuse_sm = SM_ERR_TG;
                end
                SM_RD_RDY: begin
                    $display("------------------------------------------------");
                    $display("Error!!!(@%0.3f ns): RW toggle 0->1 detected when in read mode !!!",$realtime);
                    $display("    CS should be 0 and read mode is exited before RW 0->1 toggle is allowed.");     
                    efuse_sm = SM_ERR_TG;
                end
                /*SM_INACTIVE: begin
                    if (cs_buf==1'b0&&avdd_buf==1'b1) begin
                        rw_tg_pgmpre_err = 1'b1;
                        $display("------------------------------------------------");
                        $display("Error!!!(@%0.3f ns): RW toggle 0->1 detected when AVDD is high (CS is 0).",$realtime); 
                        $display("    To enter program mode, RW toggle 0->1 should be before AVDD is high.");
                    end
                end*/
             endcase
         end
         end // efuse_sm!=SM_SIM_STOP
     end
     /* rw_tg_inpgm_err, rw_tg_pgm_err, rw_tg_inrd_err, rw_tg_pgmpre_err cleanup */
     always @(efuse_sm) begin
        if (efuse_sm==SM_PWROFF||efuse_sm==SM_INACTIVE) begin
            rw_tg_inpgm_err = 1'b0;
            rw_tg_pgm_err   = 1'b0;
            rw_tg_inrd_err  = 1'b0;
            rw_tg_pgmpre_err= 1'b0; 
        end
    end

    /* AVDD first valid value (0/1/Z) detection */
    always @(avdd_buf) begin
        if (avdd_buf!==1'bx&&avdd_1st_vld===1'b0)
            avdd_1st_vld = 1'b1;
    end 
    /* AVDD X detection after simulation */
/*    always @(avdd_buf) begin:AVDD_XZ_DETECT 
        if (efuse_sm==SM_SIM_STOP) disable AVDD_XZ_DETECT;
        if (avdd_1st_vld==1'b1&&avdd_buf===1'bx) begin
            avdd_x_err = 1'b1;
            case (efuse_sm)
            SM_IN_PGM: begin
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): Unknown AVDD detected when in programming!!!",$realtime);
                if (pgm_buf==1'b1&&pgm_max_err==1'b0) begin // Exclude Max# error in program/read
                    fuse_data[adr_cnt] = 1'bx;
                    $display("Error!!!: Efuse bit %2d in programing is damaged!!!",adr_cnt);
                end
                else begin
                    $display("Error!!!: Efuse storage bit can be damaged!!!");
                end
                pgm_all_fused = 1'b1;
            end
            SM_PGM_RDY: begin
                    $display("Error!!!(@%0.3f ns): Unknown AVDD detected when in program mode!!!", $realtime);
                    if (pgm_bit_fused==1'b1) pgm_all_fused=1'b1;
            end
            SM_IN_RD: begin
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): Unknown AVDD detected when in reading mode ...", $realtime);
                if (rd_max_err==1'b0) begin
                    $display("Error!!!: Efuse bit %2d corrupted!!!",adr_cnt);
                    $display("Error!!!: DOUT become invalid and Efuse function can be unpredicable!!!");
                    dout_rd = 1'bx;
                end
                else begin
                    $display("Error!!!: Efuse function can be unpredicable!!!");
                end
            end
            default: begin
                disable FUSE_READ_PROCESS;disable RD_FUSE;disable FUSE_READ_FINISHING_PROCESS;
                dout_rd = 1'bx;
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): Unknown AVDD detected after simulation ...", $realtime);
                $display("Error!!!: It will cause Efuse to function unpredicabally!!!");
            end
            endcase
            $display("          Please power off Efuse or go to inactive mode prior to any Efuse operation!!!");
            efuse_sm = SM_ERR_XZ;
        end
    end*/

    /* AVDD X/Z error flag avdd_x_err cleanup */
    always @(efuse_sm) begin
        if (efuse_sm==SM_PWROFF||efuse_sm==SM_INACTIVE)
            avdd_x_err = 1'b0; 
    end
    /* AVDD illegal toggle detection, 1->0/Z, 0/Z->1 and excluding X detection */
    always @(negedge avdd_is_1) begin // 1->0/Z
    #0.01
        if (efuse_sm!=SM_SIM_STOP&&$realtime>0) begin
//      if (efuse_sm!=SM_SIM_STOP) begin
        if (avdd_buf===1'b0||avdd_buf===1'bz) begin
            case (efuse_sm)
            SM_IN_PGM: begin
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): AVDD powered down when in programming ...", $realtime);    
                if (pgm_buf==1'b1&&pgm_max_err==1'b0) begin // Exclude Max# error in program/read
                    fuse_data[adr_cnt] = 1'bx;
                    $display("    Efuse bit %2d in programing is damaged!!!",adr_cnt);
                end
                else begin
                    $display("    Efuse storage bit can be damaged!!!");
                end
                pgm_all_fused = 1'b1;
                efuse_sm = SM_ERR_AVDD;
            end
            SM_PGM_RDY: begin
                if (cs_buf==1'b1) begin
                    $display("------------------------------------------------");
                    $display("Error!!!(@%0.3f ns): AVDD power-down detected when CS is high in program mode ...",$realtime);
                    $display("    To exit program mode, AVDD should be powered down after CS is set to 0.");
                    if (pgm_bit_fused==1'b1) pgm_all_fused=1'b1;
                    efuse_sm = SM_ERR_AVDD;
                end
            end
            endcase
        end
        end // if (efuse_sm!=SM_SIM_STOP)
    end
    /*always @(negedge avdd_is_0z) begin // 0/Z->1
        if (efuse_sm!=SM_SIM_STOP&&$realtime>0) begin 
//      if (efuse_sm!=SM_SIM_STOP) begin 
        if (avdd_buf==1'b1) begin
            if (dvdd_buf===1'b0||dvdd_buf===1'bz) begin
                avdd1_pwroff_err = 1'b1;
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): AVDD power up detected when DVDD is power down", $realtime);
                $display("    AVDD power up is not allowed except DVDD has been powered up.");
            end
            else if (cs_buf==1'b1) begin
                avdd1_cs1_err = 1'b1;
                case (efuse_sm)
                SM_IN_RD: begin
                    $display("------------------------------------------------");
                    $display("Error!!!(@%0.3f ns): AVDD power up detected when in reading mode!!!",$realtime);
                    if (rd_max_err==1'b0) begin
                        $display("Error!!!: Efuse bit %2d read corrupted!!!",adr_cnt);
                        $display("Error!!!: DOUT become invalid!");
                        dout_rd = 1'bx;
                    end
                end
                SM_RD_RDY: begin
                    $display("------------------------------------------------");
                    $display("Error!!!(@%0.3f ns): AVDD power up detected when in read mode!!!",$realtime);
                    $display("Error!!!: DOUT become invalid!");
                    dout_rd = 1'bx;
                end
                endcase
                $display("          AVDD power-up is not allowed when CS is 1.");
                efuse_sm = SM_ERR_AVDD;
            end
            else if (rw_buf==1'b0) begin
                avdd1_cs1_err = 1'b1;
                dout_rd   = 1'bx;
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): AVDD power up detected when RW is 0 !!!",$realtime);
                $display("          To enter program mode, set RW to 1 first before AVDD can be powered up."); 
                efuse_sm = SM_ERR_AVDD;
            end
            if (efuse_sm==SM_ERR_AVDD) begin // if efuse_sm was set to SM_ERR_AVDD by the above situations
                $display("          Due to AVDD error, please power off Efuse or go to inactive mode before any Efuse operation!!!");
            end
        end 
        end // if (efuse_sm!=SM_SIM_STOP) end 
    end*/
    /* avdd1_pwroff_err, avdd1_cs1_err cleanup */
    always @(efuse_sm) begin
        if (efuse_sm==SM_PWROFF||efuse_sm==SM_INACTIVE) begin
            avdd1_pwroff_err = 1'b0;
            avdd1_cs1_err    = 1'b0;
        end
    end

    /* DVDD first valid value (0/1/Z) detection */
    always @(dvdd_buf) begin
        if (dvdd_buf!==1'bx&&dvdd_1st_vld===1'b0)
            dvdd_1st_vld = 1'b1;
    end 
    /* DVDD X detection after simulation */
    always @(dvdd_buf) begin:DVDD_XZ_DETECT 
        if (efuse_sm==SM_SIM_STOP) disable DVDD_XZ_DETECT;
        if (dvdd_1st_vld==1'b1&&dvdd_buf===1'bx) begin
            case (efuse_sm)
            SM_IN_PGM: begin
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): Unknown DVDD detected when in programming!!!",$realtime);
                if (pgm_buf==1'b1&&pgm_max_err==1'b0) begin // Exclude Max# error in program/read
                    fuse_data[adr_cnt] = 1'bx;
                    $display("    Efuse bit %2d in programing is damaged!!!",adr_cnt);
                end
                else begin
                    $display("    Efuse storage bit can be damaged!!!");
                end
                pgm_all_fused = 1'b1;
            end
            SM_PGM_RDY: begin
                $display("Error!!!(@%0.3f ns): Unknown DVDD detected when in program mode!!!", $realtime);
                if (pgm_bit_fused==1'b1) pgm_all_fused=1'b1;
            end
            SM_IN_RD: begin
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): Unknown DVDD detected when in reading mode ...", $realtime);
                if (rd_max_err==1'b0) begin
                    $display("    DOUT become invalid and Efuse function can be unpredicable!!!");
                    dout_rd = 1'bx;
                end
                else begin
                    $display("    Efuse function can be unpredicable!!!");
                end
            end
            default: begin
                $display("Error!!!(@%0.3f ns): Unknown DVDD detected after simulation ...", $realtime);
                $display("    It will cause Efuse to function unpredicabally!!!", $realtime);
            end
            endcase
            efuse_sm=SM_ERR_DVDD;
            $display("Please power off Efuse and then power on DVDD prior to any Efuse operation!!!");
        end
    end 

    /* DVDD illegal toggle detection, 1->0/Z, 0/X/Z->1 */
    always @(negedge dvdd_is_1) begin: DVDD_BAD_DOWN_DET  // 1->0/Z
    #0.01
//      if (efuse_sm!=SM_SIM_STOP) begin
        if (efuse_sm!=SM_SIM_STOP&&$realtime>0) begin
            /* If it is in error state, disable the detection */
            case (efuse_sm)
                SM_ERR_XZ,SM_ERR_TG,SM_ERR_CSVDD,SM_ERR_AVDD,SM_ERR_AVDDVDD,SM_ERR_DVDD,SM_ERR_PWROFF:
                disable DVDD_BAD_DOWN_DET;
            endcase
        /* Start the detection */
        if (dvdd_buf===1'b0||dvdd_buf===1'bz) begin 
            case (efuse_sm)
            SM_IN_PGM: begin
                efuse_sm = SM_ERR_PWROFF;
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): DVDD powered down when in programming ...", $realtime);    
                if (pgm_buf==1'b1&&pgm_max_err==1'b0) begin // Exclude Max# error in program/read
                    fuse_data[adr_cnt] = 1'bx;
                    $display("    Efuse bit %2d in programing is damaged!!!",adr_cnt);
                end
                else begin
                    $display("    Efuse storage bit can be damaged!!!");
                end
                pgm_all_fused = 1'b1;
            end
            SM_PGM_RDY: begin
                efuse_sm = SM_ERR_PWROFF;
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): DVDD powered down when in programming ...", $realtime);    
                $display("    Efuse storage bit can be damaged!!!");
                if (pgm_bit_fused==1'b1) pgm_all_fused=1'b1;
            end
            SM_IN_RD: begin
                efuse_sm = SM_ERR_PWROFF;
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): DVDD powered down when in reading mode ...", $realtime);
                if (rd_max_err==1'b0) begin
                    $display("    DOUT become invalid!");
                    dout_rd = 1'bx;
                end
                else begin
                    $display("    DOUT are now invalid!");
                end
            end
            SM_RD_RDY: begin
                efuse_sm = SM_ERR_PWROFF;
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): DVDD powered down when in read mode ...", $realtime);
                $display("    DOUT become invalid!");
            end
            default: begin
                /*if (avdd_buf==1'b1) begin
                    $display("Error!!!(@%0.3f ns): DVDD powered down when AVDD is still high!!!",$realtime);
                    $display("    DVDD power-down is only allowed after AVDD is powered down.");
                    efuse_sm = SM_ERR_PWROFF;
                end
//              else if (efuse_sm!=SM_INACTIVE) begin
                else if (!(cs_buf===1'b0&&(avdd_buf===1'b0|avdd_buf===1'bz))) begin
                    $display("Error!!!(@%0.3f ns): DVDD powered down from non inactive mode!!!",$realtime);
//                  `SM_MON;
                    $display("    It can cause Efuse damage!!!");
                    $display("    Inactive mode should be entered before DVDD can be powered down.");
                    efuse_sm = SM_ERR_PWROFF;
                end*/
            end
            endcase
        end
//      end // if (efuse_sm!=SM_SIM_STOP&&$realtime>0)
        end // if (efuse_sm!=SM_SIM_STOP)
    end
    always @(negedge dvdd_is_0z) begin // 0/Z->1
    #0.01
        if (efuse_sm!=SM_SIM_STOP&&$realtime>0) begin 
//      if (efuse_sm!=SM_SIM_STOP) begin 
        if (dvdd_buf==1'b1) begin 
            /*if (avdd_buf==1'b1) begin
                $display("Error!!!(@%0.3f ns): AVDD is up before DVDD is ramping up!!!",$realtime);
                $display("    Please power down DVDD (set DVDD to 0 or Z) and set AVDD down (0/Z) before powering up DVDD again.");
                efuse_sm = SM_ERR_AVDDVDD;
            end
            if (avdd_buf===1'bx) begin
                $display("Error!!!(@%0.3f ns): AVDD is not known when DVDD is ramping up!!!",$realtime);
                $display("    Please power down DVDD (set DVDD to 0 or Z) and set AVDD down (0/Z) before powering up DVDD again.");
                efuse_sm = SM_ERR_AVDDVDD;
            end
            else*/ if (cs_buf===1'b1) begin
                $display("Error!!!(@%0.3f ns): CS is not set to low when DVDD is ramping up!!!",$realtime);
                $display("    Efuse may not be working properly!!!");
                $display("    Please power down DVDD (set DVDD to 0 or Z) and set CS to low before powering up DVDD again.");
                efuse_sm = SM_ERR_CSVDD;
            end
        end
        end // if (efuse_sm!=SM_SIM_STOP) end 
    end
    always @(posedge dvdd_1st_vld) begin // X->1 right after simulation
        if (efuse_sm!=SM_SIM_STOP) begin
        if (dvdd_buf===1'b1) begin
            /*if (avdd_buf===1'b1) begin
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): AVDD is not set down (0/Z) when DVDD is up!!!",$realtime);
                $display("     Please power down DVDD (set DVDD to 0 or Z) and set AVDD down (0/Z) before powering up DVDD again.");
                efuse_sm = SM_ERR_AVDDVDD;
            end
            else if (avdd_buf===1'bx) begin
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): Unknown AVDD when DVDD is up!!!",$realtime);
                $display("     Please power down DVDD (set DVDD to 0 or Z) and set AVDD down (0/Z) before powering up DVDD again.");
                efuse_sm = SM_ERR_AVDDVDD;
            end
            else*/ if (cs_buf===1'b1) begin
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): CS is not set to low when DVDD is up!!!",$realtime);
//              `SM_MON;
                $display("     CS should be set to low before DVDD is set to high!!!");
                $display("     Please power down DVDD (set DVDD to 0 or Z) and set CS to low before powering up DVDD again.");
                efuse_sm = SM_ERR_CSVDD;
//              `SM_MON;
            end
        end
        end // if (efuse_sm!=SM_SIM_STOP)
    end
    
    /* DVDD legal change 1->0/Z, power off */
    always @(negedge dvdd_is_1) begin
        /* If in an error state, go into power off mode */
        case (efuse_sm) 
            SM_ERR_XZ,SM_ERR_TG,SM_ERR_CSVDD,SM_ERR_AVDD,SM_ERR_AVDDVDD,SM_ERR_DVDD,SM_ERR_PWROFF:begin
                if (dvdd_buf!==1'bx) begin // Only if DVDD is 0/Z
                    efuse_sm = SM_PWROFF;
                    $display("------------------------------------------------");
                    $display("Info(@%0.3f ns): DVDD powered down and Efuse is reset from error state.",$realtime);
                end
            end
        endcase
        if (efuse_sm==SM_INACTIVE&&$realtime>0) begin
//      if (efuse_sm==SM_INACTIVE) begin
            if (inactive==1'b1) begin   
            if (dvdd_buf!==1'bx) begin  // Only if DVDD is 0/Z
                efuse_sm = SM_PWROFF;
                $display("------------------------------------------------");
                $display("Info(@%0.3f ns): DVDD power down from inactive mode.",$realtime);
            end
            end
        end
    end

///////////////////////
//  Efuse read process
///////////////////////
    /* When in SM_IN_RD state, start reading */
    always @(efuse_sm) begin
        if (efuse_sm==SM_IN_RD&&rd_max_err!=1'b1) begin:FUSE_READ_PROCESS
            fork
            begin: RD_FUSE_TASK
`ifdef NO_TIMING_OP
`else 
//              #(TDELTA);
`endif
                RD_FUSE;
                disable STOP_RD_FUSE_TASK;
            end
            begin: STOP_RD_FUSE_TASK
//              @(efuse_sm or function_in_err_state or function_in_err_flg);
//              if (efuse_sm==SM_SIM_STOP||efuse_sm==SM_PWROFF||efuse_sm==SM_IN_RD||
//                  function_in_err_state==1'b1||function_in_err_flg==1'b1) begin
                @(efuse_sm==SM_SIM_STOP||efuse_sm==SM_PWROFF||efuse_sm==SM_IN_RD||efuse_sm==SM_IN_PGM||
                    function_in_err_state==1'b1||function_in_err_flg==1'b1);
                disable RD_FUSE;disable RD_FUSE_TASK;
//              end
            end
            join
        end
    end
    /* CS 1->0 in inactive state, last read bit hold time on DOUT */
//  always @(efuse_sm) begin
    always @(negedge cs_is_1) begin
//      if (efuse_sm==SM_INACTIVE) begin: FUSE_READ_FINISHING_PROCESS
//      if (cs_buf===1'b0&&efuse_sm==SM_RD_RDY) begin: FUSE_READ_FINISHING_PROCESS
        if ($realtime>0) begin
//      $display("Negedge CS: now tdqh_en is %b",tdqh_en);
//      if (tdqh_en==1'b1) begin: FUSE_READ_FINISHING_PROCESS
        if ((DVDD===1'b1)&(AVDD===1'b0|AVDD===1'bz)&(CS===1'b0)&(PGM===1'b1|PGM===1'b0)&(SCLK===1'b0)&(RW===1'b0)) 
        begin: FUSE_READ_FINISHING_PROCESS
            fork 
                begin: TDQH_PROCESS
`ifdef NO_TIMING_OP
                    #`TDQH dout_rd = 1'bx;
`else
//                  $display("FUSE_READ_FINISHING_PROCESS is NOT disabled");
                    dout_rd = 1'bx;
                    disable STOP_TDQH_PROCESS;
`endif
                end
                begin: STOP_TDQH_PROCESS
                    @(avdd_buf or notify_tsp_ck or notify_thp_ck or notify_tcklp_p or notify_tpgm_min or
                      notify_ts_pgm or notify_th_pgm or notify_tckhp or notify_tcklp_r or
                      notify_tsr_ck or notify_thr_ck or notify_tsr_rw or notify_thr_rw or 
                      (efuse_sm==SM_SIM_STOP||efuse_sm==SM_PWROFF||efuse_sm==SM_IN_RD||efuse_sm==SM_IN_PGM||
                       function_in_err_state==1'b1||function_in_err_flg==1'b1));
                    disable TDQH_PROCESS;
                end
            join
        end
        end // if ($realtime>0) 
    end
    
////////////////////////////
//  Efuse program process //
////////////////////////////
    always @(efuse_sm) begin
        if (efuse_sm==SM_IN_PGM&&pgm_max_err!=1'b1) begin:FUSE_PGM_PROCESS
`ifdef NO_TIMING_OP
            PGM_FUSE;
`else
            fork
            begin: PGM_FUSE_TASK
                /* #(TDELTA) waiting time is for the timing violation notifier */
                /* being able to propogate and before PGM_FUSE task     */
                #(TDELTA)PGM_FUSE;
                disable  STOP_PGM_FUSE_TASK;
            end
            begin: STOP_PGM_FUSE_TASK
                @(efuse_sm) disable PGM_FUSE_TASK;
            end
            join
`endif
        end // FUSE_PGM_PROCESS
    end         
       
`ifdef NO_TIMING_OP
`else
//////////////////////////////////////
//  Timing check on power supplies
//////////////////////////////////////

    /****************************************************************/
    /* TAVDD_ACC_MAX -- AVDD accumulative high time TMAX_AVDD check */
    /****************************************************************/
/*    always #1000 avdd_max_chk_clk = ~avdd_max_chk_clk & TAVDD_MAX_TEST;
    always @(posedge avdd_max_chk_clk) begin:  TAVDD_MAX_DET
        if (efuse_sm==SM_SIM_STOP)  disable TAVDD_MAX_DET;
        if ((avdd_from_1_time<avdd_to_1_time)&&($realtime-avdd_to_1_time+avdd_1_sum_time>TAVDD_MAX)) begin
            $display("------------------------------------------------");
            $display("Error!!!(@%0.3f ns): Accumulative high time of AVDD exceeds %0.3f ns!!!",
                     $realtime, TAVDD_MAX);
            $display("Error!!!: Efuse damaged!!!");
            SET_FUSE_X;
            efuse_sm = SM_SIM_STOP;
        end
    end
    always @(avdd_is_1) begin
        if (efuse_sm!=SM_SIM_STOP) begin
        if (avdd_is_1==1'b1) avdd_to_1_time  = $realtime; 
        else begin
            avdd_from_1_time  = $realtime;
            if ((avdd_to_1_time!=-1)&&(avdd_from_1_time!=-1)&&(avdd_from_1_time>avdd_to_1_time)) begin
                if(avdd_1_sum_time==-1) avdd_1_sum_time = 0;
                avdd_1_sum_time = avdd_1_sum_time+avdd_from_1_time-avdd_to_1_time;
                if (avdd_1_sum_time>TAVDD_MAX) begin
                    $display("------------------------------------------------");
                    $display("Error!!!(@%0.3f ns): Accumulative high time of AVDD exceeds %0.3f ns!!!",
                              $realtime, TAVDD_MAX);
                    $display("Error!!!: Efuse damaged!!!");
                    SET_FUSE_X;
                    efuse_sm = SM_SIM_STOP;
                end
                else begin
                    avdd_1_sum_time_int = avdd_1_sum_time;
                end
            end
        end
        end // if (efuse_sm!=SM_SIM_STOP)
    end
*/
    /***************************************************************************/
    /* TPGM_MAX -- SCLK high period maximum time (maximum program pulse width) */
    /***************************************************************************/
    always @(efuse_sm) begin: TPGM_MAX_DET
        if (efuse_sm==SM_IN_PGM) begin  
            sclk_to_1_time_tpgm_max_det    = $realtime;
            @(efuse_sm);
            if (efuse_sm!=SM_PGM_RDY||function_in_err_flg==1'b1) disable TPGM_MAX_DET;
//          `SM_MON;$display("@%0.3f ns: adr_cnt = %2d,fuse_pgm_done=%b.",$realtime,adr_cnt,fuse_pgm_done);
//          if ($realtime-sclk_to_1_time_tpgm_max_det>`TPGM_MAX) begin
            if ($realtime-sclk_to_1_time_tpgm_max_det+TDELTA>`TPGM_MAX) begin
                $display("------------------------------------------------");
                if (fuse_pgm_done==1'b0) begin
                    $display("Error!!!(@%0.3f ns): Programming time violation occurs  ...", $realtime);
                    $display("Error!!!(@%0.3f ns): Programming time priod exceeds %0.3fns.",$realtime,`TPGM_MAX);
                    $display("Info: As PGM = 0, bit number %2d is not programmed and not affected by the violation.",adr_cnt);
                end
                else begin
                    $display("Error!!!(@%0.3f ns): Programming time violation occurs  ...", $realtime);
                    $display("Error!!!(@%0.3f ns): Programming time priod exceeds %0.3fns.",$realtime,`TPGM_MAX);
                    $display("Error!!!:  Efuse bit %2d being programmed is damaged!!!",adr_cnt);
                    disable FUSE_PGM_PROCESS; disable PGM_FUSE;
                    fuse_pgm_done = 1'b0;
                    /* Bit address being programmed needs revisit */
//                  fuse_data[adr_cnt] = 1'bx; 
                    SET_FUSE_X;
                    efuse_sm = SM_SIM_STOP;
                end
            end
        end
    end

    /**********************************/
    /* TPS -- DVDD to AVDD setup time */
    /**********************************/

    /* DVDD X->1 right after simulation 
    always @(posedge dvdd_1st_vld) begin: TPS_1RST_DET 
        if (efuse_sm!=SM_SIM_STOP) begin
        if (dvdd_buf!==1'b1)      disable TPS_1RST_DET;              // DVDD being 1
        if (avdd_buf===1'bx||avdd_buf===1'b1)  disable TPS_1RST_DET; // Only if AVDD 0/Z
	dvdd_pwron_time_tps_1rst_det  = $realtime;
        fork
            begin: TPS_1RST_DET_WAIT_FOR_AVDD_H
                @(posedge avdd_is_1);         
                if ($realtime-dvdd_pwron_time_tps_1rst_det<`TPS) begin
                    $display("------------------------------------------------");
                    $display("Error!!!(@%0.3f ns): AVDD powers on too early after DVDD is up!!!",$realtime);
                    $display("    Setup time TPS violation occurs.");
                    $display("    The violation will lead to efuse unstability!");
                    efuse_sm = SM_SIM_STOP;
                end
                disable TPS_1RST_DET_STOP_WAIT_FOR_AVDD_H;
            end
            begin: TPS_1RST_DET_STOP_WAIT_FOR_AVDD_H
                @(dvdd_buf) disable TPS_1RST_DET_WAIT_FOR_AVDD_H;
            end
        join
        end // if (efuse_sm!=SM_SIM_STOP)
    end*/
    /* DVDD 0/Z->1 
    always @(negedge dvdd_is_0z) begin: TPS_DET 
        if (efuse_sm!=SM_SIM_STOP&&$realtime>0) begin
//      if (efuse_sm!=SM_SIM_STOP) begin
        if (avdd_buf===1'bx||avdd_buf===1'b1)  disable TPS_DET; // Only if AVDD 0/Z
        dvdd_pwron_time_tps_det = $realtime;
        fork
            begin: TPS_DET_WAIT_FOR_AVDD_H
                @(posedge avdd_is_1);
                if ($realtime-dvdd_pwron_time_tps_det<`TPS) begin
                    $display("------------------------------------------------");
                    $display("Error!!!(@%0.3f ns): AVDD powers on too early after DVDD is up!!!",$realtime);
                    $display("    Setup time TPS violation occurs.");
                    $display("    The violation will lead to efuse unstability!");
                    efuse_sm = SM_SIM_STOP;
                end
                disable TPS_DET_STOP_WAIT_FOR_AVDD_H;
            end
            begin: TPS_DET_STOP_WAIT_FOR_AVDD_H
                @(dvdd_buf) disable TPS_DET_WAIT_FOR_AVDD_H;
            end
        join
        end // if (efuse_sm!=SM_SIM_STOP)
    end*/

    /*********************************/
    /* TPH -- DVDD to AVDD hold time */
    /********************************
    always @(negedge avdd_is_1) begin:TPH_DET     // 1->0/Z 
        if (efuse_sm!=SM_SIM_STOP&&$realtime>0) begin
//      if (efuse_sm!=SM_SIM_STOP) begin
        if (avdd_buf===1'bx)    disable  TPH_DET; 
        if (dvdd_buf!==1'b1)    disable  TPH_DET; // Only if DVDD is 1
        avdd_pwroff_time_tph_det = $realtime;
        fork
            begin: TPH_DET_WAIT_FOR_DVDD_L 
                @(posedge dvdd_is_0z);
                if ($realtime-avdd_pwroff_time_tph_det<`TPH) begin
                    $display("------------------------------------------------");
                    $display("Error!!!(@%0.3f ns): DVDD shuts down too early after AVDD is down!!!",$realtime);
                    $display("    Hold time TPH violation occurs.");
                    $display("    The violation will lead to Efuse damage!");
                    efuse_sm = SM_SIM_STOP;
                end
                disable TPH_DET_STOP_WAIT_FOR_DVDD_L;
            end
            begin: TPH_DET_STOP_WAIT_FOR_DVDD_L
                @(avdd_buf) disable TPH_DET_WAIT_FOR_DVDD_L;
            end
        join
        end // if (efuse_sm!=SM_SIM_STOP)
    end*/

    /*******************************************************************/
    /* TSP_AVDD_RW -- RW(0->1) to AVDD(0/Z->1) setup time into program mode */
    /*******************************************************************/
    always @(posedge avdd_buf) begin:TSP_RW_DET
    #0.01
//      `SM_MON;
        //if (efuse_sm!=SM_SIM_STOP) begin
        //if (rw_buf===1'bx) disable TSP_RW_DET;                    // Only if RW is 1
        if (avdd_buf!==1'b1) disable TSP_RW_DET; // Only if AVDD is 0/Z 
        //if (efuse_sm!=SM_INACTIVE)            disable TSP_RW_DET; // Only if in inactive mode
        rw_to_1_time_tsp_rw_det     = $realtime;
        fork
            begin: TSP_RW_DET_WAIT_FOR_AVDD_H
                @(posedge rw_buf);
//              if (tsp_rw_en==1'b1) begin
                if ((dvdd_buf===1'b1)&(avdd_buf===1'b1)&(pgm_buf!==1'bx)&(sclk_buf!==1'bx)&(rw_buf===1'b1))
                begin
                    if ($realtime-rw_to_1_time_tsp_rw_det+0.000001<`TSP_AVDD_RW) begin
//                  if ($realtime-rw_to_1_time_tsp_rw_det<`TSP_AVDD_RW) begin
                        $display("------------------------------------------------");
                        $display("Error!!!(@%0.3f ns): RW is up too early after AVDD is 1 !!!",$realtime);
                        $display("    TSP_AVDD_RW setup timing violation occurs.");
                        $display("    The violation can lead to incorrect Efuse program operation and bit damage!!!");
                        efuse_sm = SM_SIM_STOP; 
                    end
                end
                disable TSP_RW_DET_STOP_WAIT_FOR_AVDD_H;
            end
            begin: TSP_RW_DET_STOP_WAIT_FOR_AVDD_H
                @(avdd_buf) disable TSP_RW_DET_WAIT_FOR_AVDD_H;
            end
        join
        //end // if (efuse_sm!=SM_SIM_STOP)
    end
 
    /********************************************************************/
    /* THP_AVDD_RW -- RW(1->0) to AVDD(1->0/Z) hold time out of program mode */
    /********************************************************************/
    always @(negedge rw_buf) begin: THP_RW_DET
    #0.01
        if (efuse_sm!=SM_SIM_STOP&&$realtime>0) begin
//      if (efuse_sm!=SM_SIM_STOP) begin
//      if (thp_rw_en==1'b0) disable THP_RW_DET;
//      if ((DVDD===1'b1)&(AVDD===1'b0|AVDD===1'bz)&(CS===1'b0)&(PGM===1'b0|PGM===1'b1)&(SCLK===1'b1|SCLK===1'b0)&(RW===1'b1)) 
        if (!(dvdd_buf===1'b1&&(avdd_buf===1'b1)&&cs_buf===1'b0&&pgm_buf!==1'bx&&sclk_buf!==1'bx&&rw_buf===1'b0)) 
        disable THP_RW_DET;
//      $display("Monitor(@%0.3f ns): now is checking the first event on THP_AVDD_RW ",$realtime);
        avdd_pwron_time_thp_rw_det = $realtime;
        fork
            begin: THP_RW_DET_WAIT_FOR_RW_L
                @(negedge avdd_buf);
//              if (efuse_sm==SM_INACTIVE) begin
                if (pgm_buf!==1'bx&&sclk_buf!==1'bx&&(avdd_buf===1'b0)&&dvdd_buf===1'b1) begin
//                  $display("Monitor(@%0.3f ns): now is checking second event on THP_AVDD_RW",$realtime);
                    if ($realtime-avdd_pwron_time_thp_rw_det+TDELTA<`THP_AVDD_RW) begin
//                  if ($realtime-avdd_pwron_time_thp_rw_det<`THP_AVDD_RW) begin
                        $display("------------------------------------------------");
                        $display("Error!!!(@%0.3f ns): AVDD becomes 0 too early after RW is 0 !!!",$realtime);
                        $display("Error!!!: THP_AVDD_RW hold timing violation occurs.");
                        $display("          Timing violations relating to power supplies can lead to Efuse malfunction and damage!!!");
                        SET_FUSE_X;
                        efuse_sm = SM_SIM_STOP;
                    end
                end
                disable THP_RW_DET_STOP_WAIT_FOR_RW_L;
            end
            begin: THP_RW_DET_STOP_WAIT_FOR_RW_L
                @(rw_buf);
                disable THP_RW_DET_WAIT_FOR_RW_L;
            end
        join
        end // if (efuse_sm!=SM_SIM_STOP)
    end
    
    /************************************************************************/
    /* TSP_RW_CS -- AVDD(0/Z->1) to CS(0->1) setup time into program mode */
    /************************************************************************/
    always @(posedge rw_buf) begin: TSP_AVDD_CS_DET
    #0.01
        if (avdd_buf!==1'b1)            disable TSP_AVDD_CS_DET;   // Only if AVDD is 1
        if (cs_buf==1'bx||cs_buf==1'b1) disable TSP_AVDD_CS_DET;   // Only if CS is 0
        if (rw_buf!=1'b1)               disable TSP_AVDD_CS_DET;   // Only if RW is 1
        if (efuse_sm!=SM_INACTIVE)      disable TSP_AVDD_CS_DET;   // Only if in inactive mode
        if (efuse_sm!=SM_SIM_STOP&&$realtime>0) begin
//      if (efuse_sm!=SM_SIM_STOP) begin
        avdd_pwron_time_tsp_avdd_cs_det = $realtime;
        fork
            begin: TSP_AVDD_CS_DET_WAIT_FOR_CS_H
                @(posedge cs_is_1);
//              if (tsp_avdd_cs_en==1'b1) begin
                if ((DVDD===1'b1)&(AVDD===1'b1)&(CS===1'b1)&(PGM===1'b1|PGM===1'b0)&(SCLK===1'b1|SCLK===1'b0)&(RW===1'b1))
                begin
                    if ($realtime-avdd_pwron_time_tsp_avdd_cs_det+TDELTA<`TSP_RW_CS) begin
                        $display("------------------------------------------------");
                        $display("Error!!!(@%0.3f ns): CS becomes 1 too early after RW is on !!!",$realtime);
                        $display("Error!!!: TSP_RW_CS setup timing violation occurs.");
                        $display("          Timing violations relating to power supplies can lead to Efuse malfunction and damage!!!");
                        SET_FUSE_X;
                        efuse_sm = SM_SIM_STOP;
                    end
                end
                disable TSP_AVDD_CS_DET_STOP_WAIT_FOR_CS_H;
            end
            begin: TSP_AVDD_CS_DET_STOP_WAIT_FOR_CS_H
                @(rw_buf) disable TSP_AVDD_CS_DET_WAIT_FOR_CS_H;
            end
        join
        end // if (efuse_sm!=SM_SIM_STOP)
    end
    
    /***************************************************************************/
    /* THP_RW_CS -- AVDD (1->0/Z) to CS (1->0) hold time out of program mode */
    /***************************************************************************/
    always @(negedge cs_buf) begin: THP_AVDD_CS_DET
    #0.01
        if (efuse_sm!=SM_SIM_STOP&&$realtime>0) begin
//      if (efuse_sm!=SM_SIM_STOP) begin
//      if (thp_avdd_cs_en==1'b0) disable THP_AVDD_CS_DET;
//      if (!(DVDD===1'b1&AVDD===1'b1&CS===1'b0&(PGM===1'b1|PGM===1'b0)&SCLK===1'b0&RW===1'b1))
        if (!(dvdd_buf===1'b1&avdd_buf===1'b1&cs_buf===1'b0&(pgm_buf===1'b1|pgm_buf===1'b0)&sclk_buf===1'b0&rw_buf===1'b1))
        disable THP_AVDD_CS_DET;
        cs_to_0_time_thp_avdd_cs_det = $realtime;
//      $display("Captured CS 1->0 @%0.3f ns",$realtime);
        fork
            begin: THP_AVDD_CS_DET_WAIT_FOR_AVDD_L
                @(negedge rw_buf);
//              if (efuse_sm==SM_INACTIVE||inactive==1'b1) begin
                if (cs_buf===1'b0&&pgm_buf!==1'bx&&sclk_buf!==1'bx&&rw_buf===1'b0&&(avdd_buf===1'b1)&&dvdd_buf===1'b1) 
                begin
//                  $display("Captured AVDD 1->0 @%0.3f ns",$realtime);
                    if ($realtime-cs_to_0_time_thp_avdd_cs_det+TDELTA<`THP_RW_CS) begin
//                  if ($realtime-cs_to_0_time_thp_avdd_cs_det<`THP_RW_CS) begin
                        $display("------------------------------------------------");
                        $display("Error!!!(@%0.3f ns): RW power down too early after CS become 0 !!!",$realtime);
                        $display("Error!!!: THP_RW_CS hold timing violation occurs.");
                        $display("          Timing violations relating to power supplies can lead to Efuse malfunction and damage!!!");
                        SET_FUSE_X;
                        efuse_sm = SM_SIM_STOP;
                    end
                end
                disable THP_AVDD_CS_DET_STOP_WAIT_FOR_AVDD_L;
            end
            begin: THP_AVDD_CS_DET_STOP_WAIT_FOR_AVDD_L
                @(cs_buf) disable THP_AVDD_CS_DET_WAIT_FOR_AVDD_L;
            end
        join
        end // if (efuse_sm!=SM_SIM_STOP)
    end
`endif // if NO_TIMING_OP not defined

//////////////////////////////////////
// Warning and error process
//////////////////////////////////////

    /* Errors stopping simulation */
    always @(efuse_sm) begin
        if (efuse_sm==SM_SIM_STOP) begin
//      if (efuse_sm==SM_SIM_STOP&&$realtime>0) begin
            $display("------------------------------------------------");
            $display("Info(@%0.3f ns): Simulation will end after %.3fns due to severe errors or violations ...", 
                      $realtime, LOG_TIME);
            #LOG_TIME;  
            $display("------------------------------------------------");
            $display("Simulation ends at %.3f ns.", $realtime);
            $display("------------------------------------------------");
            $finish;
        end
    end

    /****************************/
    /* Functional error process */
    /****************************/

    /* Check if functional error should stop simulation */
    /* SM_ERR_PWROFF->SM_PWROFF if simulation is not set to stop */
    always @(efuse_sm) begin
        #0.01
        case (efuse_sm)
            SM_ERR_XZ,SM_ERR_TG,SM_ERR_CSVDD,SM_ERR_AVDD,SM_ERR_AVDDVDD,SM_ERR_DVDD,SM_ERR_PWROFF: begin
                function_in_err_state = 1'b1;
                if (NO_SIM_STOP==0) begin
                    efuse_sm = SM_SIM_STOP;    
                end
                else if (efuse_sm==SM_ERR_PWROFF) begin
                    if (dvdd_buf===1'bz||dvdd_buf===1'b0) efuse_sm = SM_PWROFF;
                end
            end
            default: function_in_err_state = 1'b0;
        endcase
    end
    always @(cs_xz_err or pgm_xz_err or sclk_xz_err or rd_max_err or pgm_max_err or
             rw_xz_err or rw_tg_inpgm_err or rw_tg_pgm_err or rw_tg_inrd_err or
             rw_tg_pgmpre_err or avdd_x_err or avdd1_pwroff_err or avdd1_cs1_err ) begin
         if (cs_xz_err||pgm_xz_err||sclk_xz_err||rd_max_err||pgm_max_err||
             rw_xz_err||rw_tg_inpgm_err||rw_tg_pgm_err||rw_tg_inrd_err||
             rw_tg_pgmpre_err||avdd_x_err||avdd1_pwroff_err||avdd1_cs1_err) begin
             function_in_err_flg = 1'b1;
             if (NO_SIM_STOP==0) begin
                 efuse_sm = SM_SIM_STOP;
             end
         end
         else function_in_err_flg = 1'b0;
    end
    /* Check if input changes are illegal after functional errors */
    always @(cs_buf or pgm_buf or sclk_buf or rw_buf or avdd_buf or dvdd_buf) begin
        if (efuse_sm!=SM_SIM_STOP) begin
            case (efuse_sm)
            /* SM_ERR_PWROFF is not included */
            SM_ERR_XZ,SM_ERR_TG,SM_ERR_CSVDD,SM_ERR_AVDD,SM_ERR_AVDDVDD,SM_ERR_DVDD: begin
                #(TDELTA);
                if (inactive!=1'b1&&dvdd_buf!==1'bz&&dvdd_buf!==1'b0) begin
                    $display("------------------------------------------------");
                    $display("Info(@%0.3f ns): Input change detected after errors.",$realtime);
                    $display("Warning!!!: Efuse read or program attempt after error can be dangerous!!!");
                    case(efuse_sm)
                        SM_ERR_CSVDD,SM_ERR_AVDDVDD: begin
                        $display("            Power off DVDD and power on DVDD again before any Efuse operation!!!");
                        end
                        default: 
                        $display("            Set Efuse to inactive mode or power down DVDD before any Efuse operation!!!");
                    endcase
                end
            end
            endcase
        end
    end 
    
    /****************************/
    /* Timing error process */
    /****************************/
 
    /* Check if timing error should stop simulation */
    /* TDQH and TCKDQ are excluded */
    always @(notify_tsp_ck or notify_thp_ck or notify_tcklp_p or notify_tpgm_min or
             notify_ts_pgm or notify_th_pgm or notify_tckhp or notify_tcklp_r or
             notify_tsr_ck or notify_thr_ck or notify_tsr_rw or notify_thr_rw) begin
//      if (efuse_sm!=SM_SIM_STOP) begin
        if (efuse_sm!=SM_SIM_STOP&&$realtime>0) begin
            if (NO_SIM_STOP==0) begin
                efuse_sm = SM_SIM_STOP;
            end
        end
    end
    /* Timing errors processing - program mode */
    /* notify_tsp_ck */
    always @(notify_tsp_ck) begin
        if (efuse_sm!=SM_SIM_STOP&&NO_SIM_STOP==1) begin
            /* When notify_tsp_ck flagged, it is already in SM_IN_PGM mode */
            if (efuse_sm==SM_IN_PGM) begin
                disable FUSE_PGM_PROCESS; disable PGM_FUSE;
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): Setup time violation TSP_CK occurs in programming!!!",$realtime);
                $display("    SCLK 0->1 too early after CS is 1 for programming!!!");
                if (pgm_buf==1'b1) begin
                    /* It is at the edge SCLK 0->1, bit address being programmed may have not be updated */
                    /* due to #1 delay */
                    fuse_data[adr_cnt] = 1'bx;
                    $display("    Efuse bit %2d being programmed can be damaged!!!",adr_cnt);
                end
            end
        end
    end
    /* notify_thp_ck */
    always @(notify_thp_ck) begin
        if (efuse_sm!=SM_SIM_STOP&&NO_SIM_STOP==1) begin
            if (efuse_sm==SM_PGM_RDY) begin
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): Hold time violation THP_CK occurs in program mode!!!",$realtime); 
                $display("Error!!!: CS 1->0 too early after SCLK is 0 in program mode!!!");
                if (pgm_bit_pre!=-1) begin
                    fuse_data[pgm_bit_pre] = 1'bx;
                    $display("Error!!!: Efuse bit number %2d just programmed can be damaged!!!",pgm_bit_pre);
                end
            end
        end
    end
    /* notify_tcklp_p */
    always @(notify_tcklp_p) begin
        if (efuse_sm!=SM_SIM_STOP&&NO_SIM_STOP==1) begin
            if (efuse_sm==SM_IN_PGM) begin
                disable FUSE_PGM_PROCESS; disable PGM_FUSE;
                $display("------------------------------------------------");
                $display("Info(@%0.3f ns): Programming Efuse bit number %2d ...",$realtime,adr_cnt);
                if (pgm_buf==1'b1) begin
                    /* It is at the edge SCLK 0->1, bit address being programmed may have not be updated */
                    /* due to #1 delay */
                    /* So bit address is updated on SCLK 1->0 */
                    $display("Error!!!(@%0.3f ns): SCLK low period too shot for programming!!!",$realtime);
                    fuse_data[adr_cnt] = 1'bx;
                    $display("Error!!!: Efuse bit %2d being programmed can be damaged!!!",adr_cnt);
                    fuse_pgm_done      = 1'b0;
                end
                else begin
                    $display("Error!!!(@%0.3f ns): SCLK low period too shot for programming!!!",$realtime);
                    $display("Info: As PGM = 0, bit number %2d will not be programmed.",adr_cnt);
                    fuse_pgm_done      = 1'b0;
                end
            end
        end
    end
    /* notify_tpgm_min */
    always @(notify_tpgm_min) begin
        if (efuse_sm!=SM_SIM_STOP&&NO_SIM_STOP==1) begin
            if (efuse_sm==SM_PGM_RDY) begin
                /* Note though it is at the edge of SCLK 1->0, it is later than */
                /* normal fuse_pgm_done is checked (in PGM_IN_PGM).             */
                /* Thus TDELTA is adopted in the latter, so that the former takes place earlier */
                disable FUSE_PGM_PROCESS;disable PGM_FUSE;
                $display("------------------------------------------------");
                if (fuse_pgm_done==1'b1) begin
                    $display("Error!!!(@%0.3f ns): SCLK high period (program pulse width) too short for programming!!!",$realtime); 
                    fuse_data[adr_cnt] = 1'bx;
                    $display("Error!!!: Efuse just programmed bit %2d can be damaged!!!",adr_cnt);
                end
                else begin
                    $display("Error!!!(@%0.3f ns): SCLK high period (program pulse width) too short for programming!!!",$realtime); 
                    $display("Info: As PGM=0, Efuse bit %2d is not programmed and not impacted by the TPGM_MIN violation.",adr_cnt);
                end
                fuse_pgm_done    = 1'b0;
            end
        end
    end
    /* notify_ts_pgm */
    always @(notify_ts_pgm) begin
        if (efuse_sm!=SM_SIM_STOP&&NO_SIM_STOP==1) begin
            if (efuse_sm==SM_IN_PGM) begin
                disable FUSE_PGM_PROCESS;disable PGM_FUSE;
                $display("------------------------------------------------");
                $display("Info(@%0.3f ns): Programming Efuse bit number %2d ...",$realtime,adr_cnt);
                $display("Error!!!(@%0.3f ns): Set time violation TS_PGM occurs in programming!!!",$realtime);
                $display("Error!!!: SCLK 0->1 too early after PGM is 1 !!!");
                /* It is at the edge SCLK 0->1, bit address being programmed may have not be updated */
                /* due to #1 delay */
                fuse_data[adr_cnt]= 1'bx;
                $display("Error!!!: Efuse bit %2d being programmed can be damaged!!!",adr_cnt);
                fuse_pgm_done      = 1'b0;
            end
        end
    end
    /* notify_th_pgm */
    always @(notify_th_pgm) begin
        if (efuse_sm!=SM_SIM_STOP&&NO_SIM_STOP==1) begin
            /* PGM 1->0 can be before or after SCLK 1->0 */
            /* Damaged bit address can be different      */
            if (efuse_sm==SM_IN_PGM) begin // if PGM 1->0 is before SCLK 1->0 
                disable FUSE_PGM_PROCESS; disable PGM_FUSE;
                $display("------------------------------------------------");
//              $display("Info(@%0.3f ns): Programming Efuse bit number %2d ...",$realtime,adr_cnt);
                $display("Error!!!(@%0.3f ns): Hold time violation TH_PGM occurs in programming!!!",$realtime);
                $display("Error!!!: PGM 1->0 too early after SCLK 1->0 in programming !!!");
                fuse_data[adr_cnt]=1'bx;
                $display("Error!!!: Efuse bit %2d being programmed can be damaged!!!",adr_cnt);
                fuse_pgm_done      = 1'b0;
            end
/*
            if (efuse_sm==SM_PGM_RDY) begin // if PGM 1->0 is after SCLK 1->0 
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): Hold time violation TH_PGM occurs in programming!!!",$realtime);
                $display("    PGM 1->0 too early after SCLK 1->0 in programming !!!");
                if (pgm_bit_pre!=-1) begin
                    fuse_data[pgm_bit_pre]=1'bx;
                    $display("    Efuse bit %2d being programmed can be damaged!!!",pgm_bit_pre);
                end
            end
*/
        end
    end
    /* Timing errors processing - program mode ends */

    /* Timing errors processing - read mode */

    /* notify_tckhp */
    always @(notify_tckhp) begin
        if (efuse_sm!=SM_SIM_STOP&&NO_SIM_STOP==1) begin
            disable FUSE_READ_PROCESS;disable RD_FUSE;
            dout_rd = 1'bx;
            if (efuse_sm==SM_RD_RDY) begin
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): SCLK high period too short for reading !!!", $realtime);
                $display("        (@%0.3f ns): DOUT become invalid!", $realtime);
            end
        end
    end
    /* notify_tcklp_r */
    always @(notify_tcklp_r) begin
        dout_rd = 1'bx;
        if (efuse_sm!=SM_SIM_STOP&&NO_SIM_STOP==1) begin
            disable FUSE_READ_PROCESS;disable RD_FUSE;
            if (efuse_sm==SM_IN_RD) begin
                $display("------------------------------------------------");
                $display("Info(@%0.3f ns): Read Efuse bit %2d ...",$realtime,adr_cnt);
                $display("Error!!!(@%0.3f ns): SCLK low period too short for reading !!!",$realtime);
                $display("Error!!!: Reading Efuse bit %2d fails. DOUT become invalid!!!",adr_cnt);
            end
        end
    end
    /* notify_tsr_ck */
    always @(notify_tsr_ck) begin
        if (efuse_sm!=SM_SIM_STOP&&NO_SIM_STOP==1) begin
            disable FUSE_READ_PROCESS;disable RD_FUSE;
            dout_rd = 1'bx;
            if (efuse_sm==SM_IN_RD) begin
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): When in reading bit %2d, setup time violation TSR_CK occurs!!!",
                          $realtime,adr_cnt);
                $display("Error!!!: SCLK 0->1 too early after CS is 1 for reading !!!");
                $display("          DOUT become invalid!");
            end
        end
    end
    /* notify_thr_ck */
    always @(notify_thr_ck) begin
        if (efuse_sm!=SM_SIM_STOP&&NO_SIM_STOP==1) begin
            disable FUSE_READ_PROCESS;disable RD_FUSE;disable FUSE_READ_FINISHING_PROCESS;
            dout_rd = 1'bx;
            if (efuse_sm==SM_INACTIVE) begin
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): Hold time violation THR_CK occurs when finishing reading!!!",$realtime);
                $display("Error!!!: CS 1->0 too early after SCLK becomes 0 when exiting read mode!!!");
            end
        end
    end
    /* notify_tsr_rw */
    always @(notify_tsr_rw) begin
        if (efuse_sm!=SM_SIM_STOP&&NO_SIM_STOP==1) begin
            disable FUSE_READ_PROCESS;disable RD_FUSE;
            dout_rd = 1'bx; 
            /* The TSR_RW error flag shall be able to block the further read attempt */
            tsr_rw_err = 1'b1; 
            if (efuse_sm==SM_RD_RDY) begin
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): Setup time violation TSR_RW occurs in read mode!!!",$realtime);
                $display("Error!!!: CS 0->1 too early after RW is 0 when entering read mode!!!");
            end
        end
    end
    /* tsr_rw_err clean up */
    always @(efuse_sm) begin
        if (efuse_sm==SM_PWROFF||efuse_sm==SM_INACTIVE||efuse_sm==SM_SIM_STOP) begin
            tsr_rw_err = 1'b0;
        end
    end
    /* TSR_RW error flag block further reads */
    always @(efuse_sm) begin
        if (efuse_sm==SM_IN_RD) begin
            if (tsr_rw_err==1'b1) begin
                disable FUSE_READ_PROCESS;disable RD_FUSE;
                dout_rd = 1'bx;
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): Read attempt detected after setup time violation TSR_RW has occurred!!!",$realtime);
                $display("Error!!!: The read attempt is invalid and DOUT is also invalid !!!");
                $display("          Set Efuse to inactive mode or power off and on again before any read attempt!!!");
            end
        end
   end
   /* notify_thr_rw */
   always @(notify_thr_rw) begin
       if (efuse_sm!=SM_SIM_STOP&&NO_SIM_STOP==1) begin
           disable FUSE_READ_PROCESS;disable RD_FUSE;disable FUSE_READ_FINISHING_PROCESS;
           dout_rd = 1'bx;
           if (efuse_sm==SM_INACTIVE) begin
               $display("------------------------------------------------");
               $display("Error!!!(@%0.3f ns): Hold time violation THR_RW occurs after exiting read mode!!!",$realtime);
               $display("Error!!!: RW 0->1 too early after CS is 0 when out of read mode !!!");
           end
       end
   end
                
////////////////////////////////////////////////////
// Function task declaration
////////////////////////////////////////////////////

    /* Initialize storage values for Efuse */
    task INIT_EFUSE;  
        begin
            for (i=0;i<FUSE_SIZE;i=i+1) 
            fuse_data[i]     = 1'b0;
        end
    endtask
    /* Set all Efuse storage bits to Xs */
    task SET_FUSE_X;   
        begin
            for(i=0;i<FUSE_SIZE;i=i+1) 
            fuse_data[i] = 1'bx;
        end
    endtask
    /* Read Efuse task */
    task RD_FUSE;     
        begin
            if (DOUT === fuse_data[adr_cnt])
                dout_change = 1'b0;
            else
                dout_change = 1'b1;
        `ifdef NO_TIMING_OP
            #(`TCKDQ_H);
            dout_rd = 1'bx;
            #(`TCKDQ-`TCKDQ_H);
        `endif
            dout_rd = fuse_data[adr_cnt]; 
        `ifdef NO_TIMING_OP
            /* Note the NCVerilog and VCS will have different timing to update dout_rd (DOUT) */
            /* Use dout_rd instead of DOUT in $display                                        */
            $display("------------------------------------------------");
            $display("Info(@%0.3f ns): Read Efuse bit %2d, read data=1'b%b;",$realtime,adr_cnt,dout_rd);
//          #(TDELTA);
//          $display("Info(@%0.3f ns): Read Efuse bit %2d, read data=1'b%b;",$realtime,adr_cnt,DOUT);
        `else
            if (dout_change==1'b1) begin
                @(DOUT);
                if (efuse_sm==SM_IN_RD||efuse_sm==SM_RD_RDY) begin
                    $display("------------------------------------------------");
                    $display("Info(@%0.3f ns): Read Efuse bit %2d, read data=1'b%b;",$realtime,adr_cnt,DOUT); 
                end
            end
            else begin
                #(`TCKDQ);
                if (efuse_sm==SM_IN_RD||efuse_sm==SM_RD_RDY) begin
                    $display("------------------------------------------------");
                    $display("Info(@%0.3f ns): Read Efuse bit %2d, read data=1'b%b;",$realtime,adr_cnt,DOUT);
                end
            end
        `endif
        end
    endtask
    /* Program Efuse task */
    task PGM_FUSE;         
        begin
            if (fuse_data[adr_cnt]===1'b0) begin
                if (pgm_buf===1'b1) begin
                    $display("------------------------------------------------");
                    $display("Info(@%0.3f ns): Programming Efuse bit number %2d ...", $realtime, adr_cnt);
                    fuse_data[adr_cnt] = 1'b1;
                    fuse_pgm_done      = 1'b1;
                end
                else begin
                    $display("------------------------------------------------");
                    $display("Info(@%0.3f ns): Programming Efuse bit number %2d ...",$realtime,adr_cnt);
                    $display("Info: As PGM = 0, bit number %2d will not be programmed.",adr_cnt);
                    fuse_pgm_done      = 1'b0;
                end
                pgm_bit_fused = 1'b1;
            end
            else if (fuse_data[adr_cnt]===1'b1) begin
                if (pgm_buf===1'b1) begin
                    $display("------------------------------------------------");
                    $display("Info(@%0.3f ns): Programming Efuse bit number %2d ...",$realtime,adr_cnt);
                    $display("Errors!!!: Efuse bit number %2d has already been programmed!!!",adr_cnt);
                    $display("Errors!!!: Bad attempt to re-program Efuse bit number %2d!!!",adr_cnt);
                    $display("           Bit number %2d can be damaged!!!",adr_cnt);
                    fuse_data[adr_cnt] = 1'bx;
                    fuse_pgm_done      = 1'b0;
                end
                else begin
                    $display("------------------------------------------------");
                    $display("Info(@%0.3f ns): Programming Efuse bit number %2d ...", $realtime, adr_cnt);
                    $display("Info(@%0.3f ns): Efuse Bit number %2d has already been programmed",$realtime,adr_cnt);
                    $display("Info: As PGM = 0, Efuse bit number %2d is not programmed.",adr_cnt);
                    fuse_pgm_done      = 1'b0;
                end
            end
            else if (fuse_data[adr_cnt]===1'bx || fuse_data[adr_cnt]===1'bz) begin
                if (pgm_buf===1'b1) begin
                    $display("------------------------------------------------");
                    $display("Info(@%0.3f ns): Programming Efuse bit number %2d ...", $realtime, adr_cnt);
                    $display("Error!!!: Efuse bit %2d is already damaged or not intitilized.", adr_cnt);
                    $display("Error!!!: Cannot program Efuse bit number %2d where its value is unknown!!!",adr_cnt);
                    fuse_pgm_done      = 1'b0;
                end
                else begin 
                    $display("------------------------------------------------");
                    $display("Info(@%0.3f ns): Programming Efuse bit number %2d ...", $realtime, adr_cnt);
                    $display("Error: Bit number %2d is already damaged or not intitilized.",adr_cnt);
                    $display("Info: As PGM = 0, Efuse bit number %2d is not programmed.", adr_cnt);
                    fuse_pgm_done      = 1'b0;
                end
            end
        end
    endtask

////////////////////////////////////////////  
// Specify timing paths and constraints
////////////////////////////////////////////  
    `ifdef NO_TIMING_OP
        initial begin
            $display("------------------------------------------------");
            $display ("Info(@%0.3f ns): TIMING CHECK is disabled by the user ...",$realtime);
            $display("------------------------------------------------");
        end
    `else

    specify
        /* Program mode check parameters */
        specparam Tsp_ck     =`TSP_CK;  // CS to SCLK鈥檚 rising edge setup time into program mode
        specparam Thp_ck     =`THP_CK;  // CS to SCLK鈥檚 falling edge hold time out of program mode
        specparam Tcklp_p    =`TCKLP_P; // SCLK low period in program mode
        specparam Tpgm_min   =`TPGM_MIN;// Burning minimum time
        specparam Tpgm_max   =`TPGM_MAX;// Burning maximum time
        specparam Ts_pgm     =`TS_PGM;  // PGM to SCLK setup time
        specparam Th_pgm     =`TH_PGM;  // PGM to SCLK hold time
        specparam Tsp_rw     =`TSP_AVDD_RW;  // RW to AVDD setup time into program mode
        specparam Thp_rw     =`THP_AVDD_RW;  // RW to AVDD hold time out of program mode
        specparam Tsp_avdd_cs=`TSP_RW_CS;// AVDD to CS setup time into program mode
        specparam Thp_avdd_cs=`THP_RW_CS;// AVDD to CS hold time out of program mode
        /* Read mode check parameters */
        specparam Tckhp      = `TCKHP;  // SCLK high period in read mode
        specparam Tcklp_r    = `TCKLP_R;// SCLK low period in read mode
        specparam Tsr_ck     = `TSR_CK; // CS to SCLK setup time into read mode
        specparam Thr_ck     = `THR_CK; // CS to SCLK hold time out of read mode
        specparam Tsr_rw     = `TSR_RW; // RW to CS setup time into read mode
        specparam Thr_rw     = `THR_RW; // RW to CS hold time out of read mode
        specparam Tdqh       = `TDQH;   // DOUT to CS hold time out of read mode
        specparam Tckdq      = `TCKDQ;  // DOUT to SCLK rising edge delay time
        specparam Tckdq_h    = `TCKDQ_H;// DOUT to SCLK rising edge hold time
        
        /***************************/
        /* Timing violation checks */ 
        /***************************/

        /* Program mode timing check */
        $setup(posedge CS,posedge SCLK &&& (tsp_ck_en==1),Tsp_ck,notify_tsp_ck); // TSP_CK
        $hold(negedge SCLK &&& (thp_ck_en==1),negedge CS,Thp_ck,notify_thp_ck);  // THP_CK
        $width(negedge SCLK &&& (tcklp_p_en==1),Tcklp_p,0,notify_tcklp_p);       // TCKLP_P
        $width(posedge SCLK &&& (tpgm_min_en==1),Tpgm_min,0,notify_tpgm_min);    // TPGM_MIN
        $setup(posedge PGM,posedge SCLK &&& (ts_pgm_en==1),Ts_pgm,notify_ts_pgm);// TS_PGM
        $hold(posedge SCLK &&& (th_pgm_en==1),negedge PGM,Th_pgm,notify_th_pgm); // TH_PGM
        /* Read mode timing check */
        $width(posedge SCLK &&& (tckhp_en==1),Tckhp,0,notify_tckhp);             // TCKHP 
        $width(negedge SCLK &&& (tcklp_r_en==1),Tcklp_r,0,notify_tcklp_r);       // TCKLP_R
        $setup(posedge CS,posedge SCLK &&& (tsr_ck_en==1),Tsr_ck,notify_tsr_ck); // TSR_CK
        $hold(negedge SCLK &&& (thr_ck_en==1),negedge CS,Thr_ck,notify_thr_ck);  // THR_CK
        $setup(negedge RW,posedge CS &&& (tsr_rw_en==1),Tsr_rw,notify_tsr_rw);   // TSR_RW
        $hold(negedge CS &&& (thr_rw_en==1),posedge RW,Thr_rw,notify_thr_rw);    // THR_RW
        /* CS -> DOUT */
        if (tdqh_en==1) (negedge CS => (DOUT:CS))=(Tdqh,Tdqh);                   // TCKDQ
        /* SCLK -> DOUT */
        /* rise,fall,0->Z,Z->1,1->Z,Z->0 */
        /* 0->X,X->1,1->X,X->0,X->Z,Z->X */
        if (tckdq_en==1) (posedge SCLK=>(DOUT:SCLK))= (Tckdq,Tckdq,Tckdq_h,Tckdq,Tckdq_h,Tckdq, Tckdq_h,Tckdq,Tckdq_h,Tckdq,Tckdq_h,Tckdq_h); // TCKDQ

    endspecify
    `endif

endmodule
`endcelldefine
