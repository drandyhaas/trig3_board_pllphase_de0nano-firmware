// megafunction wizard: %ALTDDIO_IN%VBB%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: ALTDDIO_IN 

// ============================================================
// File Name: ddio_in_mhg.v
// Megafunction Name(s):
// 			ALTDDIO_IN
//
// Simulation Library Files(s):
// 			altera_mf
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 18.1.0 Build 625 09/12/2018 SJ Lite Edition
// ************************************************************

//Copyright (C) 2018  Intel Corporation. All rights reserved.
//Your use of Intel Corporation's design tools, logic functions 
//and other software and tools, and its AMPP partner logic 
//functions, and any output files from any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Intel Program License 
//Subscription Agreement, the Intel Quartus Prime License Agreement,
//the Intel FPGA IP License Agreement, or other applicable license
//agreement, including, without limitation, that your use is for
//the sole purpose of programming logic devices manufactured by
//Intel and sold by Intel or its authorized distributors.  Please
//refer to the applicable agreement for further details.

module ddio_in_mhg (
	datain,
	inclock,
	dataout_h,
	dataout_l);

	input	[0:0]  datain;
	input	  inclock;
	output	[0:0]  dataout_h;
	output	[0:0]  dataout_l;

endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: LIBRARY: altera_mf altera_mf.altera_mf_components.all
// Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Cyclone IV E"
// Retrieval info: CONSTANT: INTENDED_DEVICE_FAMILY STRING "Cyclone IV E"
// Retrieval info: CONSTANT: INVERT_INPUT_CLOCKS STRING "OFF"
// Retrieval info: CONSTANT: LPM_HINT STRING "UNUSED"
// Retrieval info: CONSTANT: LPM_TYPE STRING "altddio_in"
// Retrieval info: CONSTANT: POWER_UP_HIGH STRING "OFF"
// Retrieval info: CONSTANT: WIDTH NUMERIC "1"
// Retrieval info: USED_PORT: datain 0 0 1 0 INPUT NODEFVAL "datain[0..0]"
// Retrieval info: CONNECT: @datain 0 0 1 0 datain 0 0 1 0
// Retrieval info: USED_PORT: dataout_h 0 0 1 0 OUTPUT NODEFVAL "dataout_h[0..0]"
// Retrieval info: CONNECT: dataout_h 0 0 1 0 @dataout_h 0 0 1 0
// Retrieval info: USED_PORT: dataout_l 0 0 1 0 OUTPUT NODEFVAL "dataout_l[0..0]"
// Retrieval info: CONNECT: dataout_l 0 0 1 0 @dataout_l 0 0 1 0
// Retrieval info: USED_PORT: inclock 0 0 0 0 INPUT_CLK_EXT NODEFVAL "inclock"
// Retrieval info: CONNECT: @inclock 0 0 0 0 inclock 0 0 0 0
// Retrieval info: GEN_FILE: TYPE_NORMAL ddio_in_mhg.v TRUE FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL ddio_in_mhg.qip TRUE FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL ddio_in_mhg.bsf TRUE TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL ddio_in_mhg_inst.v TRUE TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL ddio_in_mhg_bb.v TRUE TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL ddio_in_mhg.inc TRUE TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL ddio_in_mhg.cmp TRUE TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL ddio_in_mhg.ppf TRUE FALSE
// Retrieval info: LIB_FILE: altera_mf
