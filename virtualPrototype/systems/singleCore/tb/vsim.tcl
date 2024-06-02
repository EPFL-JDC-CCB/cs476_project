# Read the file containing Verilog file paths
set file_list [open "../config/project.files" r]
set verilog_files [read $file_list]
close $file_list

# Split the file paths into a list
set verilog_file_list [split $verilog_files "\n"]

# Get the number of files
set num_files [llength $verilog_file_list]

# Exclude the last two files
if {$num_files > 2} {
    set verilog_file_list [lrange $verilog_file_list 0 [expr {$num_files - 3}]]
}
lappend verilog_file_list "simpleMemSlave.v"
lappend verilog_file_list "simplePrintSlave.v"
lappend verilog_file_list "tb_harness.v"
lappend verilog_file_list "vsim_top.v"

# Create a new project
project new virtualprototype

# Add the Verilog files to the project
foreach verilog_file $verilog_file_list {
    if {[string length $verilog_file] > 0} {
        project addfile $verilog_file
    }
}

# Compile the project
project compile

# Simulate the testbench
# Assuming 'testbench' is the top-level module
vsim -c -do "run -all; quit" vsim_top