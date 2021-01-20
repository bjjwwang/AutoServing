set -e
set -v
export http_proxy=http://172.19.57.45:3128/
export https_proxy=http://172.19.57.45:3128/
version=0.0.0
app_version=0.0.0
apt install -y libcurl4-openssl-dev
cd ./python
#python change_version.py $version
cd ..

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/python3.7/lib
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

cpu_num=10

PYTHONROOT=/usr/local/python2.7.15
PYTHON_INCLUDE_DIR_2=$PYTHONROOT/include/python2.7/
PYTHON_LIBRARY_2=$PYTHONROOT/lib/libpython2.7.so
PYTHON_EXECUTABLE_2=$PYTHONROOT/bin/python2.7

PYTHONROOT3=/usr/local
PYTHON_INCLUDE_DIR_3=$PYTHONROOT3/include/python3.6m/
PYTHON_LIBRARY_3=$PYTHONROOT3/lib64/libpython3.6m.so
PYTHON_EXECUTABLE_3=$PYTHONROOT3/bin/python3.6m
/usr/local/python2.7.15/bin/python2.7 -m pip install grpcio==1.33.2 grpcio-tools==1.33.2 numpy bce-python-sdk  pycrypto wheel
/usr/local/bin/python3.6m -m pip install setuptools -U
/usr/local/bin/python3.6m -m pip install grpcio grpcio-tools numpy wheel

go env -w GO111MODULE=on
go env -w GOPROXY=https://goproxy.cn,direct
go get -u github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway@v1.15.2
go get -u github.com/grpc-ecosystem/grpc-gateway/protoc-gen-swagger@v1.15.2
go get -u github.com/golang/protobuf/protoc-gen-go@v1.4.3
go get -u google.golang.org/grpc@v1.33.0

function change_py_version(){
py3_version=$1
case $py3_version in
    35)
        PYTHONROOT3=/usr/local/python3.5
        PYTHON_INCLUDE_DIR_3=$PYTHONROOT3/include/python3.5m
        PYTHON_LIBRARY_3=$PYTHONROOT3/lib/libpython3.5m.so
        PYTHON_EXECUTABLE_3=$PYTHONROOT3/bin/python3.5m
        ;;
    36)
        PYTHONROOT3=/usr/local/python3.6
        PYTHON_INCLUDE_DIR_3=$PYTHONROOT3/include/python3.6m/
        PYTHON_LIBRARY_3=$PYTHONROOT3/lib/libpython3.6m.so
        PYTHON_EXECUTABLE_3=$PYTHONROOT3/bin/python3.6m
        ;;
    37)
        PYTHONROOT3=/usr/local/python3.7
        PYTHON_INCLUDE_DIR_3=$PYTHONROOT3/include/python3.7m/
        PYTHON_LIBRARY_3=$PYTHONROOT3/lib/libpython3.7m.so
        PYTHON_EXECUTABLE_3=$PYTHONROOT3/bin/python3.7m
        ;;
esac
}
#git fetch upstream
#git merge upstream/develop

git submodule init
git submodule update

function cp_lib(){
cp /usr/lib/libcrypto.so.10 $1
cp /usr/lib/libssl.so.10 $1
}

function pack_gpu(){
mkdir -p bin_package
cd bin_package
CUDA_version=$1
mkdir -p serving-gpu-$CUDA_version-$version
cp ../build_gpu_server_$CUDA_version/output/demo/serving/bin/* serving-gpu-$CUDA_version-$version
cp ../build_gpu_server_$CUDA_version/third_party/install/Paddle//third_party/install/mklml/lib/* serving-gpu-$CUDA_version-$version
cp ../build_gpu_server_$CUDA_version/third_party/Paddle/src/extern_paddle/paddle/lib/libpaddle_fluid.so serving-gpu-$CUDA_version-$version
if [ $1 != 101 ]
then
cp ../build_gpu_server_$CUDA_version/third_party/install/Paddle//third_party/install/mkldnn/lib/libdnnl.so.1 serving-gpu-$CUDA_version-$version
fi
cp_lib serving-gpu-$CUDA_version-$version
tar -czvf serving-gpu-$CUDA_version-$version.tar.gz serving-gpu-$CUDA_version-$version/
cd ..
}

function cp_whl(){
cd ..
mkdir -p whl_package
cd -
cp ./python/dist/paddle_serving_*-$version* ../whl_package \
|| cp ./python/dist/paddle_serving_app*-$app_version* ../whl_package
}

function clean_whl(){
if [ -d "python" ];then
rm -r python
fi
}

function compile_101(){
mkdir -p build_gpu_server_101
cd build_gpu_server_101
clean_whl
echo "compile start"
cmake -DPYTHON_INCLUDE_DIR=$PYTHON_INCLUDE_DIR_2 \
    -DPYTHON_LIBRARY=$PYTHON_LIBRARY_2 \
    -DPYTHON_EXECUTABLE=$PYTHON_EXECUTABLE_2 \
    -DWITH_GPU=ON \
    -DSERVER=ON \
    -DWITH_TRT=ON \
    -DTENSORRT_ROOT=/usr/ .. 
make -j$cpu_num >> compile_log
make -j$cpu_num >> compile_log
make install >> compile_log
cp_whl
cd ..
pack_gpu 101
}

function compile_101_py3(){
mkdir -p build_gpu_server_1013
cd build_gpu_server_1013
clean_whl
export CUDA_PATH='/usr/local'
export CUDNN_LIBRARY='/usr/local/cuda/lib64/'
export CUDA_CUDART_LIBRARY="/usr/local/cuda/lib64/"
cmake -DPYTHON_INCLUDE_DIR=$PYTHON_INCLUDE_DIR_3 \
    -DPYTHON_LIBRARY=$PYTHON_LIBRARY_3 \
    -DPYTHON_EXECUTABLE=$PYTHON_EXECUTABLE_3 \
    -DWITH_GPU=ON \
    -DSERVER=ON \
    -DWITH_TRT=ON \
    -DTENSORRT_ROOT=/usr .. 
make -j$cpu_num >> compile_log
make -j$cpu_num >> compile_log
make install >> compile_log
cp_whl
cd ..
pack_gpu 101
}

function upload_bin(){
    cd bin_package
    python ../bos_conf/upload.py bin serving-gpu-101-$version.tar.gz
    cd ..
}

function upload_whl(){
    cd whl_package
    python ../bos_conf/upload.py whl paddle_serving_server_gpu-$version.post101-py2-none-any.whl
    python ../bos_conf/upload.py whl paddle_serving_server_gpu-$version.post101-py3-none-any.whl
    cd ..
}

function compile(){
    compile_101
    compile_101_py3
}

#compile
compile

#upload bin
upload_bin

#upload whl
upload_whl
