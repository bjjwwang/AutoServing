PLATFORM=cuda102
IMAGE_TAG=0.4.1-cuda10.2-cudnn8-trt7-devel
docker rm --force compile_$PLATFORM
docker run --rm --name compile_$PLATFORM -dit \
  -v $PWD:/Serving \
  -e http_proxy=http://172.19.57.45:3128 \
  -e https_proxy=http://172.19.57.45:3128 \
  -e PYTHONROOT=/usr \
  -e TENSORRT_ROOT=/usr \
  -e GOROOT=/usr/local/go \
  -e GOPATH=/root/go \
  -e PATH=/home/cmake-3.16.0-Linux-x86_64/bin:/usr/local/go/bin:/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:/root/go/bin:$PATH \
  hub.baidubce.com/paddlepaddle/serving:$IMAGE_TAG bash
docker exec compile_$PLATFORM  /bin/bash -c "cd /Serving && bash compile_cuda102.sh" 
