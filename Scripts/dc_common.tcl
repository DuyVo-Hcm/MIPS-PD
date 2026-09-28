# ============================================
# dc_common.tcl
# Script CHUNG cho moi project - KHONG sua file nay
# Cac bien can duoc set truoc khi source file nay,
# thong qua file config rieng cua tung project
# ============================================

# Bien BAT BUOC phai duoc set truoc (trong file config):
#   project_root   - duong dan goc project
#   top_design     - ten module top-level
#   rtl_files      - list cac file .v (co the nhieu file)
#   clock_port     - ten port clock
#   clock_period   - chu ky clock (ns)
#   lib_db_path    - duong dan thu vien .db

set LinkSource  "${project_root}/rtl"
set LinkReport  "${project_root}/dc/dc_report"
set LinkNetlist "${project_root}/netlist"
set LinkSdc     "${project_root}/sdc"

file mkdir ${LinkReport}
file mkdir ${LinkNetlist}
file mkdir ${LinkSdc}
file mkdir "${project_root}/dc/work"

define_design_lib WORK -path "${project_root}/dc/work"

set target_library [list ${lib_db_path}/saed90nm_min.db \
    ${lib_db_path}/saed90nm_typ.db \
    ${lib_db_path}/saed90nm_max.db]
set link_library [list * ${lib_db_path}/saed90nm_min.db \
    ${lib_db_path}/saed90nm_typ.db \
    ${lib_db_path}/saed90nm_max.db]

# Doc tat ca file RTL trong list (ho tro nhieu file .v)
foreach f $rtl_files {
    read_verilog -rtl "${LinkSource}/${f}"
}

uniquify
check_design > ${LinkReport}/synth_check_design.rpt

set_min_library ${lib_db_path}/saed90nm_max.db -min_version ${lib_db_path}/saed90nm_min.db
set_operating_conditions -min BEST -max WORST

current_design $top_design

set time_scale $clock_period
set tran      [expr (0.05*$time_scale)]
set delay_in  [expr (0.7*$time_scale)]
set delay_out [expr (0.7*$time_scale)]

create_clock -period $clock_period -waveform [list 0 [expr $clock_period/2]] $clock_port

set_clock_uncertainty $tran $clock_port
set_clock_latency     $tran $clock_port
set_clock_transition  $tran $clock_port
set_input_delay  $delay_in  [remove_from_collection [all_inputs] $clock_port] -clock $clock_port
set_output_delay $delay_out [all_outputs] -clock $clock_port

current_design $top_design
set_ungroup [get_designs *] false

set_svf ${LinkReport}/${top_design}.svf
compile_ultra

report_area      > ${LinkReport}/${top_design}_synth_area.rpt
report_cell      > ${LinkReport}/${top_design}_synth_cells.rpt
report_qor       > ${LinkReport}/${top_design}_synth_qor.rpt
report_resources > ${LinkReport}/${top_design}_synth_resources.rpt
report_timing -max_paths 20 -delay max > ${LinkReport}/${top_design}_setup.rpt
report_timing -max_paths 20 -delay min > ${LinkReport}/${top_design}_hold.rpt

write_sdc ${LinkSdc}/${top_design}_SDC.sdc
write -hierarchy -format verilog -output ${LinkNetlist}/${top_design}_NL.v

puts "=========================================="
puts "DONE: ${top_design} synthesis complete"
puts "Netlist: ${LinkNetlist}/${top_design}_NL.v"
puts "SDC    : ${LinkSdc}/${top_design}_SDC.sdc"
puts "Reports: ${LinkReport}/"
puts "=========================================="