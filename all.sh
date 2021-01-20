git  pull origin v0.4.1
rm -rf build_*
rm -rf whl_package
rm -rf bin_package
bash cpu.sh >cpu.log 2>&1
bash cuda9.sh >cuda9.log 2>&1
bash cuda10.sh >cuda10.log 2>&1
bash cuda101.sh >cuda101.log 2>&1
bash cuda102.sh >cuda102.log 2>&1
bash client.sh >client.log 2>&1
