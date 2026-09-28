# ============================================
# fm_icc_common.tcl
# Formal Verification STAGE 2: Netlist sau Synthesis (DC) vs Netlist sau P&R (ICC)
# Cac bien can duoc set truoc:
#   project_root, top_design, lib_db_path
# ============================================

set LinkNetlistDc  "${project_root}/netlist"
set LinkNetlistPr  "${project_root}/icc/netlist_pr"
set LinkFmReport   "${project_root}/icc/fm_icc"

file mkdir ${LinkFmReport}

# --- Load thu vien TRUOC (bat buoc, de resolve duoc cell) ---
read_db [list ${lib_db_path}/saed90nm_min.db \
    ${lib_db_path}/saed90nm_typ.db \
    ${lib_db_path}/saed90nm_max.db]

# --- Reference design: netlist sau SYNTHESIS (DC) ---
read_verilog -r ${LinkNetlistDc}/${top_design}_NL.v
set_top r:/WORK/${top_design}

# --- Implementation design: netlist sau P&R (ICC) ---
read_verilog -i ${LinkNetlistPr}/${top_design}_PR.v
set_top i:/WORK/${top_design}

match
verify

report_matched_points   > ${LinkFmReport}/${top_design}_matched.rpt
report_unmatched_points > ${LinkFmReport}/${top_design}_unmatched.rpt

puts "=========================================="
puts "DONE: Formal verification (ICC stage) for ${top_design}"
puts "Post-Synthesis Netlist vs Post-P&R Netlist"
puts "Reports: ${LinkFmReport}/"
puts "=========================================="