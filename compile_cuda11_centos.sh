set -e
set -v
export http_proxy=http://172.19.57.45:3128/
export https_proxy=http://172.19.57.45:3128/
export http_proxy=http://172.19.56.199:3128
export https_proxy=http://172.19.56.199:3128
version=0.0.0
app_version=0.0.0
#version=0.5.0
#app_version=0.3.0
yum install -y bzip2-devel
cd ./python
#python change_version.py $version
cd ..
rm -rf /usr/local/bin/protoc /usr/local/include/protobuf
ln -sf /usr/lib64/libcrypto.so.10 /usr/lib64/libcrypto.so
ln -sf /usr/lib64/libssl.so.10 /usr/lib64/libssl.so
export LIBRARY_PATH=/usr/lib64:/usr/local/cuda/lib64/stubs
export LD_LIBRARY_PATH=/opt/_internal/cpython-2.7.15-ucs4/lib/:/opt/_internal/cpython-3.6.0/lib/:/usr/lib64:$LD_LIBRARY_PATH
export GOROOT=/usr/local/go
export GOPATH=/root/gopath
export PATH=$PATH:$GOPATH/bin:$GOROOT/bin

PYTHONROOT=/opt/_internal/cpython-2.7.15-ucs4/
PYTHON_INCLUDE_DIR_2=$PYTHONROOT/include/python2.7/
PYTHON_LIBRARY_2=$PYTHONROOT/lib/libpython2.7.so
PYTHON_EXECUTABLE_2=$PYTHONROOT/bin/python2.7

PYTHONROOT3=/opt/_internal/cpython-3.6.0/
PYTHON_INCLUDE_DIR_3=$PYTHONROOT3/include/python3.6m/
PYTHON_LIBRARY_3=$PYTHONROOT3/lib64/libpython3.6m.so
PYTHON_EXECUTABLE_3=$PYTHONROOT3/bin/python3.6m
$PYTHON_EXECUTABLE_2 -m pip install --upgrade pip
$PYTHON_EXECUTABLE_2 -m pip install grpcio==1.33.2 grpcio-tools==1.33.2 numpy bce-python-sdk  pycrypto wheel
$PYTHON_EXECUTABLE_2 -m pip install --upgrade pip
$PYTHON_EXECUTABLE_3 -m pip install setuptools -U
$PYTHON_EXECUTABLE_3 -m pip install grpcio grpcio-tools numpy wheel

go env -w GO111MODULE=on
go env -w GOPROXY=https://goproxy.cn,direct
go get -u github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway@v1.15.2
go get -u github.com/grpc-ecosystem/grpc-gateway/protoc-gen-swagger@v1.15.2
go get -u github.com/golang/protobuf/protoc-gen-go@v1.4.3
go get -u google.golang.org/grpc@v1.33.0

#git fetch upstream
#git merge upstream/develop

git submodule init
git submodule update

function cp_lib(){
cp /usr/lib64/libcrypto.so.10 $1
cp /usr/lib64/libssl.so.10 $1
}

function pack_gpu(){
mkdir -p bin_package
cd bin_package
CUDA_version=$1
mkdir -p serving-gpu-$CUDA_version-$version
cp ../build_gpu_server_$CUDA_version/output/demo/serving/bin/* serving-gpu-$CUDA_version-$version
cp ../build_gpu_server_$CUDA_version/third_party/install/Paddle//third_party/install/mklml/lib/* serving-gpu-$CUDA_version-$version
cp ../build_gpu_server_$CUDA_version/third_party/Paddle/src/extern_paddle/paddle/lib/libpaddle_fluid.so serving-gpu-$CUDA_version-$version
if [ $1 != trt6 ]
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

function compile_gpu_11(){
mkdir -p build_gpu_server_cuda11
cd build_gpu_server_cuda11
clean_whl
cmake -DPYTHON_INCLUDE_DIR=$PYTHON_INCLUDE_DIR_2 \
    -DPYTHON_LIBRARY=$PYTHON_LIBRARY_2 \
    -DPYTHON_EXECUTABLE=$PYTHON_EXECUTABLE_2 \
    -DWITH_GPU=ON \
    -DSERVER=ON .. > compile_log
make -j$cpu_num >> compile_log
make -j$cpu_num >> compile_log
make install >> compile_log
cp_whl
cd ..
pack_gpu cuda11
}

function compile_gpu_113(){
mkdir -p build_gpu_server_cuda113
cd build_gpu_server_cuda113
clean_whl
cmake -DPYTHON_INCLUDE_DIR=$PYTHON_INCLUDE_DIR_3 \
    -DPYTHON_LIBRARY=$PYTHON_LIBRARY_3 \
    -DPYTHON_EXECUTABLE=$PYTHON_EXECUTABLE_3 \
    -DWITH_GPU=ON \
    -DSERVER=ON .. > compile_log
make -j$cpu_num >> compile_log
make -j$cpu_num >> compile_log
make install >> compile_log
cp_whl
cd ..
#pack_gpu
}

function upload_bin(){
    cd bin_package
    python ../bos_conf/upload.py bin serving-gpu-cuda11-$version.tar.gz
    cd ..
}

function upload_whl(){
    cd whl_package
    python ../bos_conf/upload.py whl paddle_serving_server_gpu-$version.post11-py2-none-any.whl
    python ../bos_conf/upload.py whl paddle_serving_server_gpu-$version.post11-py3-none-any.whl
    cd ..
}

function compile(){
    #gpu
    compile_gpu_11
    compile_gpu_113
}

#compile
compile

#upload bin
upload_bin

#upload whl
upload_whl

