# Read the file containing Verilog file paths
set file_list [open "../config/project.files" r]
set verilog_files [read $file_list]
close $file_list

# Split the file paths into a list
set project_file_list [split $verilog_files "\n"]

# Get the number of files
set num_files [llength $project_file_list]

# Exclude the last two files
if {$num_files > 2} {
    set project_file_list [lrange $project_file_list 0 [expr {$num_files - 3}]]
}
lappend project_file_list "simpleMemSlave.v"
lappend project_file_list "simplePrintSlave.v"
lappend project_file_list "tb_harness.v"
lappend project_file_list "vsim_top.v"
lappend project_file_list "uartprint.sv"

# Create a new project
project new proj .


# Add the Verilog files to the project
foreach project_file $project_file_list {
    if {[string length $project_file] > 0} {
        project addfile ../$project_file
    }
}

# Compile the project
project compileall

#vlog -work work -dpiheader ../uartdpi.h ../uartdpi.sv ../uartdpi.c

# Simulate the testbench
# Assuming 'testbench' is the top-level module
vsim -voptargs=+acc   -c -do "vcd file dump.vcd; vcd add -r vsim_top/*; run -all; quit" vsim_top
