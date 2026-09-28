
set project_root  "/home/ltk/pd_mips"
set lib_db_path   "/home/ltk/ASIC_LIB/Lib/syn_lib/syn_lib"

set top_design    "mips_cpu_top"
set rtl_files      {mips_alu.v shifter.v reg_file.v alu_ctrl.v mips_datapath.v mips_controller.v mips_cpu_top.v}

source /home/ltk/eda_scripts/fm_dc_common.tcl
