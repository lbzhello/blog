Git 设置用户名，密码，密钥，以后不用每次 push 是都输入用户名和密码

## 设置 username, email
```
git config --global user.name "foo"

git config --global user.email "foo@example.com"

# 设置保存密码
git config --global credential.helper store
```

## 生成 SSH 密钥

密钥存储在 ~/.ssh 目录下

1. 生存密钥和公钥。命令执行完后，在 ~/.ssh 目录下会看到 id_rsa（私钥）、id_rsa.pub（公钥） 文件。
```sh
ssh-keygen -t rsa -C "foo@example.com"
```
2. 复制 id_rsa.pub 里的内容到 Github -> Settings -> SSH and GPG Keys
