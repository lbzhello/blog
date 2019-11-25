## 清华镜像

[Anaconda 镜像使用帮助](https://mirrors.tuna.tsinghua.edu.cn/help/anaconda/)

## 常用命令

```sh
# 创建 dev 虚拟环境, 后面 python=3.8 可选
conda create -n dev python=3.8

# 查看虚拟环境
conda info -e
conda info --envs
conda env list

# 激活虚拟环境
conda activate dev

# 退出虚拟环境
conda deactivate

# 删除包
conda remove -n dev --all

# 查看已安装包（当前虚拟环境下）
conda list

# 查找包
conda search PACKAGENAME

# 安装包， -y 表示同意安装，不加后面会询问一下
conda install -y pandas

# 安装包， -c 表示使用 conda-forge 通道（更新的软件）
conda install -c conda-forge jupyterlab

# 更新包, -n 可以指定环境
conda update -n dev pandas

# 升级 conda
conda upgrade conda
```