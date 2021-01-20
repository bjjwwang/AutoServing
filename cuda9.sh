PLATFORM=cuda9
IMAGE_TAG=0.4.1-cuda9-cudnn7-devel
docker rm --force compile_$PLATFORM
docker run --rm --name compile_$PLATFORM -dit \
  -v $PWD:/Serving \
  -e http_proxy=http://172.19.57.45:3128 \
  -e https_proxy=http://172.19.57.45:3128 \
  -e PYTHONROOT=/usr \
  -e GOROOT=/usr/local/go \
  -e GOPATH=/root/go \
  -e PATH=/usr/local/go/bin:/usr/local/cmake3.2.0/bin:/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:/root/go/bin:$PATH \
  hub.baidubce.com/paddlepaddle/serving:$IMAGE_TAG bash
docker exec compile_$PLATFORM  /bin/bash -c "cd /Serving && bash compile_cuda9.sh" 
