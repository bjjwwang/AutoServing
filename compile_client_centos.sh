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
export LD_LIBRARY_PATH=/opt/_internal/cpython-2.7.15-ucs4/lib/:/opt/_internal/cpython-3.6.0/lib/:/opt/_internal/cpython-3.5.1/lib/:/opt/_internal/cpython-3.8.0/lib/:/opt/_internal/cpython-3.7.0/lib/:/usr/lib64:$LD_LIBRARY_PATH
export GOROOT=/usr/local/go
export GOPATH=/root/gopath
export PATH=$PATH:$GOPATH/bin:$GOROOT/bin

PYTHONROOT=/opt/_internal/cpython-2.7.15-ucs4/
PYTHON_INCLUDE_DIR_2=$PYTHONROOT/include/python2.7/
PYTHON_LIBRARY_2=$PYTHONROOT/lib/libpython2.7.so
PYTHON_EXECUTABLE_2=$PYTHONROOT/bin/python2.7

PYTHONROOT35=/opt/_internal/cpython-3.5.1/
PYTHON_INCLUDE_DIR_35=$PYTHONROOT35/include/python3.5m/
PYTHON_LIBRARY_35=$PYTHONROOT35/lib/libpython3.5m.so
PYTHON_EXECUTABLE_35=$PYTHONROOT35/bin/python3.5m

PYTHONROOT37=/opt/_internal/cpython-3.7.0/
PYTHON_INCLUDE_DIR_37=$PYTHONROOT37/include/python3.7m/
PYTHON_LIBRARY_37=$PYTHONROOT37/lib/libpython3.7m.so
PYTHON_EXECUTABLE_37=$PYTHONROOT37/bin/python3.7m

PYTHONROOT38=/opt/_internal/cpython-3.8.0/
PYTHON_INCLUDE_DIR_38=$PYTHONROOT38/include/python3.8/
PYTHON_LIBRARY_38=$PYTHONROOT38/lib/libpython3.8.so
PYTHON_EXECUTABLE_38=$PYTHONROOT38/bin/python3.8

PYTHONROOT36=/opt/_internal/cpython-3.6.0/
PYTHON_INCLUDE_DIR_36=$PYTHONROOT36/include/python3.6m/
PYTHON_LIBRARY_36=$PYTHONROOT36/lib/libpython3.6m.so
PYTHON_EXECUTABLE_36=$PYTHONROOT36/bin/python3.6m

$PYTHON_EXECUTABLE_2 -m pip install --upgrade pip
$PYTHON_EXECUTABLE_2 -m pip install grpcio==1.33.2 grpcio-tools==1.33.2 numpy bce-python-sdk  pycrypto wheel==0.34.2
$PYTHON_EXECUTABLE_2 -m pip install --upgrade pip
$PYTHON_EXECUTABLE_35 -m pip install setuptools -U
$PYTHON_EXECUTABLE_35 -m pip install grpcio grpcio-tools numpy wheel requests wheel==0.34.2

$PYTHON_EXECUTABLE_36 -m pip install setuptools -U
$PYTHON_EXECUTABLE_36 -m pip install grpcio grpcio-tools numpy wheel requests wheel==0.34.2

$PYTHON_EXECUTABLE_37 -m pip install setuptools -U
$PYTHON_EXECUTABLE_37 -m pip install grpcio grpcio-tools numpy wheel requests wheel==0.34.2

$PYTHON_EXECUTABLE_38 -m pip install setuptools -U
$PYTHON_EXECUTABLE_38 -m pip install grpcio grpcio-tools numpy wheel requests wheel==0.34.2

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

function compile_client(){
mkdir -p build_client
cd build_client
clean_whl
cmake -DPYTHON_INCLUDE_DIR=$PYTHON_INCLUDE_DIR_2  \
        -DPYTHON_LIBRARY=$PYTHON_LIBRARY_2 \
            -DPYTHON_EXECUTABLE=$PYTHON_EXECUTABLE_2 \
                -DCLIENT=ON \
                    -DPACK=ON .. > compile_log
make -j$cpu_num >> compile_log
#make install >> compile_log
cp_whl
cd ..
}

function compile_client_py35(){
mkdir -p build_client_py35
cd build_client_py35
clean_whl
cmake -DPYTHON_INCLUDE_DIR=$PYTHON_INCLUDE_DIR_35 \
        -DPYTHON_LIBRARY=$PYTHON_LIBRARY_35 \
            -DPYTHON_EXECUTABLE=$PYTHON_EXECUTABLE_35 \
                -DCLIENT=ON \
                    -DPACK=ON .. > compile_log
make -j$cpu_num >> compile_log
#make install >> compile_log
cp_whl
cd ..
}

function compile_client_py36(){
mkdir -p build_client_py36
cd build_client_py36
clean_whl
cmake -DPYTHON_INCLUDE_DIR=$PYTHON_INCLUDE_DIR_36 \
        -DPYTHON_LIBRARY=$PYTHON_LIBRARY_36 \
            -DPYTHON_EXECUTABLE=$PYTHON_EXECUTABLE_36 \
                -DCLIENT=ON \
                    -DPACK=ON .. > compile_log
make -j$cpu_num >> compile_log
#make install >> compile_log
cp_whl
cd ..
}
function compile_client_py37(){
mkdir -p build_client_py37
cd build_client_py37
clean_whl
cmake -DPYTHON_INCLUDE_DIR=$PYTHON_INCLUDE_DIR_37 \
        -DPYTHON_LIBRARY=$PYTHON_LIBRARY_37 \
            -DPYTHON_EXECUTABLE=$PYTHON_EXECUTABLE_37 \
                -DCLIENT=ON \
                    -DPACK=ON .. > compile_log
make -j$cpu_num >> compile_log
#make install >> compile_log
cp_whl
cd ..
}
function compile_client_py38(){
mkdir -p build_client_py38
cd build_client_py38
clean_whl
cmake -DPYTHON_INCLUDE_DIR=$PYTHON_INCLUDE_DIR_38 \
        -DPYTHON_LIBRARY=$PYTHON_LIBRARY_38 \
            -DPYTHON_EXECUTABLE=$PYTHON_EXECUTABLE_38 \
                -DCLIENT=ON \
                    -DPACK=ON .. > compile_log
make -j$cpu_num >> compile_log
#make install >> compile_log
cp_whl
cd ..
}

function compile_app(){
mkdir -p build_app
cd build_app
clean_whl
cmake -DPYTHON_INCLUDE_DIR=$PYTHON_INCLUDE_DIR_2  \
        -DPYTHON_LIBRARY=$PYTHON_LIBRARY_2 \
            -DPYTHON_EXECUTABLE=$PYTHON_EXECUTABLE_2 \
                -DAPP=ON .. > compile_log
make -j$cpu_num >> compile_log
#make install >> compile_log
cp_whl
cd ..
}

function compile_app_py3(){
mkdir -p build_app_py3
cd build_app_py3
clean_whl
cmake -DPYTHON_INCLUDE_DIR=$PYTHON_INCLUDE_DIR_36 \
        -DPYTHON_LIBRARY=$PYTHON_LIBRARY_36 \
            -DPYTHON_EXECUTABLE=$PYTHON_EXECUTABLE_36 \
                -DAPP=ON ..> compile_log
make -j$cpu_num >> compile_log
#make install >> compile_log
cp_whl
cd ..
}

function upload_whl(){
    cd whl_package
    python ../bos_conf/upload.py whl paddle_serving_client-$version-cp27-*
    python ../bos_conf/upload.py whl paddle_serving_client-$version-cp35-*
    python ../bos_conf/upload.py whl paddle_serving_client-$version-cp36-*
    python ../bos_conf/upload.py whl paddle_serving_client-$version-cp37-*
    python ../bos_conf/upload.py whl paddle_serving_client-$version-cp38-*
    python ../bos_conf/upload.py whl paddle_serving_app-$app_version-py2-none-any.whl
    python ../bos_conf/upload.py whl paddle_serving_app-$app_version-py3-none-any.whl
    cd ..
}

function compile(){
    compile_client
    compile_client_py35
    compile_client_py36
    compile_client_py37
    compile_client_py38
    compile_app   
    compile_app_py3
}

#compile
compile

#upload bin

#upload whl
upload_whl

