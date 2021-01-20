PLATFORM=client
IMAGE_TAG=all-python-devel
docker rm --force compile_$PLATFORM
docker run --rm --name compile_$PLATFORM -dit \
  -v $PWD:/Serving \
  -e http_proxy=http://172.19.57.45:3128 \
  -e https_proxy=http://172.19.57.45:3128 \
  -e PYTHONROOT=/usr \
  -e GOROOT=/usr/local/go \
  -e GOPATH=/root/go \
  -e LD_LIBRARY_PATH=/usr/local/python3.7/lib:/usr/local/python3.5/lib:/usr/local/python3.6/lib:/usr/local/python2.7/lib:/opt/rh/devtoolset-2/root/usr/lib64:/opt/rh/devtoolset-2/root/usr/lib:/usr/local/nvidia/lib:/usr/local/nvidia/lib64 \
  -e PATH=/opt/rh/devtoolset-2/root/usr/bin/:/usr/local/python3.7/bin:/usr/local/python3.5/bin:/usr/local/python3.6/bin:/usr/local/python2.7/bin:/usr/local/go/bin:/usr/local/cmake3.2.0/bin:/opt/rh/devtoolset-2/root/usr/bin:/usr/local/go/bin:/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:/root/go/bin:/usr/local/cmake3.2.0/bin/:/usr/local/go/bin:/usr/local/go/bin:/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/opt/bin:/home/opt/bin:/opt/bin:/home/opt/bin:/root/bin:/root/go/bin \
  -e PYTHONPATH=/opt/rh/devtoolset-2/root/usr/lib64/python2.6/site-packages:/opt/rh/devtoolset-2/root/usr/lib/python2.6/site-packages \
  -e GOPATH=/root/go \
  -e INFOPATH=/opt/rh/devtoolset-2/root/usr/share/info \
  hub.baidubce.com/paddlepaddle/serving:$IMAGE_TAG bash
docker exec compile_$PLATFORM  /bin/bash -c "cd /Serving && bash compile_client.sh" 
