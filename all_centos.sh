rm -rf build_*
rm -rf whl_package
rm -rf bin_package
rm -rf *.log
git pull origin v0.5.0
bash cpu_centos.sh  > cpu.log 2>&1 
bash cuda102_centos.sh >cu102.log 2>&1
bash client_centos.sh >client.log 2>&1
bash cuda101_centos.sh > cu101.log 2>&1
bash cuda9_centos.sh > cu9.log 2>&1
bash cuda10_centos.sh > cu10.log 2>&1
bash cuda11_centos.sh > cu11.log 2>&1
