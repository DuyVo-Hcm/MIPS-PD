# ============================================
# icc_common.tcl
# Script CHUNG cho moi project - KHONG sua file nay
# Cac bien can duoc set truoc khi source file nay,
# thong qua file config rieng cua tung project
#
# PHIEN BAN NAY CHI CHAY DEN HET IMPORT NETLIST + SDC.
# Moi buoc TU floorplan tro di se duoc go TAY tung lenh
# trong icc_shell, khong nam trong script nay.
# ============================================

# Bien BAT BUOC phai duoc set truoc (trong file config):
#   project_root   - duong dan goc project
#   top_design     - ten module top-level
#   lib_db_path    - duong dan thu vien .db (Liberty, dung cho optimize)
#   lib_mk_path    - duong dan goc thu vien process (tech file, TLU+, fram)

set my_mw_lib      "${top_design}_Lib"
set LinkNetlist    "${project_root}/netlist"
set LinkSdc        "${project_root}/sdc"
set LinkIccReport  "${project_root}/icc/icc_report"

file mkdir ${LinkIccReport}

# --- Duong dan tech/PDK (co dinh, dung chung SAED90nm cho moi project) ---
set Techfile "${lib_mk_path}/astro/tech/astroTechFile.tf"
set Ref_lib  "${lib_mk_path}/astro/fram/saed90nm_fr"
set Tlupmax  "${lib_mk_path}/star_rcxt/tluplus/saed90nm_1p9m_1t_Cmax.tluplus"
set Tlupmin  "${lib_mk_path}/star_rcxt/tluplus/saed90nm_1p9m_1t_Cmin.tluplus"
set Tech2itf "${lib_mk_path}/astro/tech/tech2itf.map"

set target_library [list ${lib_db_path}/saed90nm_min.db \
    ${lib_db_path}/saed90nm_typ.db \
    ${lib_db_path}/saed90nm_max.db]
set link_library [list * ${lib_db_path}/saed90nm_min.db \
    ${lib_db_path}/saed90nm_typ.db \
    ${lib_db_path}/saed90nm_max.db]

# --- Tao Milkyway library ---
create_mw_lib -technology $Techfile -mw_reference_library $Ref_lib $my_mw_lib
set_tlu_plus_files -max_tluplus $Tlupmax -min_tluplus $Tlupmin -tech2itf_map $Tech2itf
open_mw_lib "$my_mw_lib"

# --- Import netlist + constraint ---
import_designs -format verilog -top $top_design -cel $top_design ${LinkNetlist}/${top_design}_NL.v
uniquify
link
uniquify_fp_mw_cel

read_sdc "${LinkSdc}/${top_design}_SDC.sdc"
save_mw_cel -as "mw_${top_design}"

puts "=========================================="
puts "DONE: netlist + sdc imported for ${top_design}"
puts "Checkpoint saved: mw_${top_design}"
puts "Ban gio co the tu go tung lenh floorplan"
puts "bat dau tu: open_mw_cel \"mw_${top_design}\""
puts "=========================================="