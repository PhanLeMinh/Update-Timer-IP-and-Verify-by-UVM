+incdir+./../regmodel
+incdir+./../regmodel/register
+incdir+./../sequences
+incdir+./../testcases
+incdir+./../tb

+define+APB_ADDR_WIDTH=12
+define+APB_DATA_WIDTH=32

// Compile VIP design (agent)
-f ./../vip/apb_vip.f

// Compile Envrionment
../regmodel/register/timer_register_pkg.sv
../regmodel/timer_regmodel_pkg.sv
../tb/env_pkg.sv
../sequences/seq_pkg.sv
../testcases/test_pkg.sv
../tb/test_bench.sv
