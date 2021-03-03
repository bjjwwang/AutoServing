PLATFORM=cpu
IMAGE_TAG=0.5.0-cuda10.1-cudnn7-centos-devel
docker rm --force compile_$PLATFORM
docker run --rm --name compile_$PLATFORM -dit \
  -v $PWD:/Serving \
  -e http_proxy=http://172.19.57.45:3128 \
  -e https_proxy=http://172.19.57.45:3128 \
  -e PYTHONROOT=/usr \
  -e TENSORRT_ROOT=/usr \
  registry.baidubce.com/paddlepaddle/serving:$IMAGE_TAG bash
docker exec compile_$PLATFORM  /bin/bash -c "cd /Serving && bash compile_cpu_centos.sh" 
