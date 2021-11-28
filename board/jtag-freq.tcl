connect -url $::env(HW_SERVER_URL)

# FPGA programming can fail when JTAG clock frequency is too high

jtag targets -set -filter {level == 0 && is_open}
set freq [jtag freq]
if { $freq > 20000000 } {
  jtag freq 20000000
}
