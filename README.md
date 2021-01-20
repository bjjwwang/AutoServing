# Paddle Serving自动编包工具

# 介绍

本工具用于发版本和更新Paddle Serving pip wheel包。

| 入口脚本          | 编译脚本                  | 所属平台                         |
|---------------|-----------------------|------------------------------|
| cpu.sh        | compile_cpu.sh        | x86 cpu                      |
| cuda9.sh      | compile_cuda9.sh      | x86 gpu cuda 9.0             |
| cuda10.sh     | compile_cuda10.sh     | x86 gpu cuda 10.0            |
| cuda101.sh    | compile_cuda101.sh    | x86 gpu cuda 10.1 TensorRT 6 |
| cuda102.sh    | compile_cuda102.sh    | x86 gpu cuda 10.2 TensorRT 7 |
| client.sh     | compile_client.sh     | x86 client app               |
| xpu.sh        | compile_xpu.sh        | arm xpu                      |
| xpu_client.sh | compile_xpu_client.sh | arm xpu client app           |

# 用法

```
bash all.sh
```


