# ============================================

# fm_dc_common.tcl

# Formal Verification STAGE 1: RTL vs Netlist sau Synthesis (DC)

# Cac bien can duoc set truoc:

#   project_root, top_design, rtl_files, lib_db_path

# ============================================



set LinkSource   "${project_root}/rtl"

set LinkNetlist  "${project_root}/netlist"

set LinkReport   "${project_root}/dc/dc_report"

set LinkFmReport "${project_root}/dc/fm_dc"



file mkdir ${LinkFmReport}



# --- Load thu vien TRUOC (bat buoc, de resolve duoc cell trong netlist) ---

read_db [list ${lib_db_path}/saed90nm_min.db \

    ${lib_db_path}/saed90nm_typ.db \

    ${lib_db_path}/saed90nm_max.db]



# --- Load SVF TRUOC KHI doc bat ky design nao (bat buoc theo FM-256) ---

if {[file exists "${LinkReport}/${top_design}.svf"]} {

    if {[catch {set_svf "${LinkReport}/${top_design}.svf"} err]} {

        puts "Warning: set_svf failed: $err"

    } else {

        puts "SVF file registered for guided matching."

    }

} else {

    puts "Warning: No SVF file found, Formality will match without DC guidance."

}



# --- Reference design (RTL gốc) ---

foreach f $rtl_files {

    read_verilog -r "${LinkSource}/${f}"

}

set_top r:/WORK/${top_design}



# --- Implementation design (netlist sau synthesis) ---

read_verilog -i ${LinkNetlist}/${top_design}_NL.v

set_top i:/WORK/${top_design}



match

verify



report_failing_points > ${LinkFmReport}/${top_design}_failing.rpt

diagnose > ${LinkFmReport}/${top_design}_diagnose.rpt



report_matched_points > ${LinkFmReport}/${top_design}_matched.rpt

report_unmatched_points > ${LinkFmReport}/${top_design}_unmatched.rpt



puts "=========================================="

puts "DONE: Formal verification (DC stage) for ${top_design}"

puts "RTL vs Post-Synthesis Netlist"

puts "Reports: ${LinkFmReport}/"

puts "=========================================="