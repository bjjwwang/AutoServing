set -e
set -v
export http_proxy=http://172.19.57.45:3128/
export https_proxy=http://172.19.57.45:3128/
version=0.0.0
app_version=0.0.0
cd ./python
#python change_version.py $version
cd ..

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/python3.7/lib
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

cpu_num=10

PYTHONROOT=/usr/local/python2.7
PYTHON_INCLUDE_DIR_2=$PYTHONROOT/include/python2.7
PYTHON_LIBRARY_2=$PYTHONROOT/lib/libpython2.7.so
PYTHON_EXECUTABLE_2=$PYTHONROOT/bin/python2.7

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

function compile_client_py3(){
mkdir -p build_client_py3
cd build_client_py3
clean_whl
cmake -DPYTHON_INCLUDE_DIR=$PYTHON_INCLUDE_DIR_3 \
        -DPYTHON_LIBRARY=$PYTHON_LIBRARY_3 \
            -DPYTHON_EXECUTABLE=$PYTHON_EXECUTABLE_3 \
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
cmake -DPYTHON_INCLUDE_DIR=$PYTHON_INCLUDE_DIR_3 \
        -DPYTHON_LIBRARY=$PYTHON_LIBRARY_3 \
            -DPYTHON_EXECUTABLE=$PYTHON_EXECUTABLE_3 \
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
    python ../bos_conf/upload.py whl paddle_serving_app-$app_version-py2-none-any.whl
    python ../bos_conf/upload.py whl paddle_serving_app-$app_version-py3-none-any.whl
    cd ..
}

function compile(){
    #client
    compile_client
    change_py_version 35 && compile_client_py3
    change_py_version 36 && compile_client_py3
    change_py_version 37 && compile_client_py3

    #app
    compile_app
    change_py_version 36 && compile_app_py3
}

#compile
compile

#upload bin
upload_bin

