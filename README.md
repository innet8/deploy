# 安装
*必须将本项目部署在 /www/deploy 文件*
## 运行 ./install 安装配置工具
## 运行 docker-compose up -d 运行本项目

# 添加远程主机
1、管理员登录系统后台->系统设置->主机管理，根据表单提示录入主机信息  
2、记录该主机自增ID号（后续配置证书用）

# 生成证书
登录将要部署远程桌面容器的主机，安装 docker 和 docker-compose 后，按以下步骤制作证书：
1. 创建certs文件夹，用来存放CA私钥和公钥
```shell
mkdir -pv /etc/docker/certs
cd /etc/docker/certs
```   
2. 创建密钥
```shell
openssl genrsa -aes256 -out ca-key.pem 4096
```
3. 依次输入密码、国家、省、市、组织名称等。过期时间可根据实际需要填写，当前示例为"一年"
```shell
openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem
```
4. 生成server-key.pem 
```shell
openssl genrsa -out server-key.pem 4096
```
5. 生成server.csr（把下面的IP换成你自己服务器外网的IP或者域名，示例中使用笔者虚拟机IP地址）
```
openssl req -subj "/CN=192.168.0.123" -sha256 -new -key server-key.pem -out server.csr
```
6. 配置白名单
0.0.0.0表示所有ip都可以连接。（这里需要注意，虽然0.0.0.0可以匹配任意，但是仍需要配置你的外网ip和127.0.0.1，否则客户端会连接不上）
```
echo subjectAltName = IP:0.0.0.0,IP:192.168.0.123,IP:127.0.0.1 >> extfile.cnf
```
也可以设置成域名

```
echo subjectAltName = DNS:www.example.com,IP:192.168.0.123,IP:127.0.0.1 >> extfile.cnf
```
7. 将Docker守护程序密钥的扩展使用属性设置为仅用于服务器身份验证
```
echo extendedKeyUsage = serverAuth >> extfile.cnf
```
8.输入之前设置的密码，生成签名证书
```
openssl x509 -req -days 365 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem \
-CAcreateserial -out server-cert.pem -extfile extfile.cnf
```
9、生成供客户端发起远程访问时使用的key.pem 
```
openssl genrsa -out key.pem 4096
```
10. 生成client.csr（把下面的IP换成你自己服务器外网的IP或者域名）
```
openssl req -subj "/CN=192.168.0.123" -new -key key.pem -out client.csr
```
11. 创建扩展配置文件，把密钥设置为客户端身份验证用
```
echo extendedKeyUsage = clientAuth > extfile-client.cnf
```
12. 生成cert.pem，输入前面设置的密码，生成签名证书
```
openssl x509 -req -days 365 -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem \
    -CAcreateserial -out cert.pem -extfile extfile-client.cnf
```
13. 删除不需要的配置文件和两个证书的签名请求
```
rm -v client.csr server.csr extfile.cnf extfile-client.cnf
```
14. 为了防止私钥文件被更改以及被其他用户查看，修改其权限为所有者只读
```
chmod -v 0400 ca-key.pem key.pem server-key.pem
```
15. 为了防止##### 公钥文件被更改，修改其权限为只读
```
chmod -v 0444 ca.pem server-cert.pem cert.pem
```
16. 修改Docker配置，使Docker守护程序仅接受来自提供CA信任的证书的客户端的连接，拷贝安装包单元文件到/etc，这样就不会因为docker升级而被覆盖
```
cp /lib/systemd/system/docker.service /etc/systemd/system/docker.service
```
在ExecStart=/usr/bin/dockerd-current \下面增加
```
--tlsverify \
--tlscacert=/etc/docker/certs/ca.pem \
--tlscert=/etc/docker/certs/server-cert.pem \
--tlskey=/etc/docker/certs/server-key.pem \
-H tcp://0.0.0.0:2376 \
-H unix:///var/run/docker.sock 
```
17. 重新加载daemon并重启docker
```
systemctl daemon-reload
systemctl restart docker
```
### 客户端配置
1. 创建证书目录
```
#进入任务系统项目根目录
cd $MissionSystem
mkdir -pv ./docker/desktop/cert/${远程主机自增ID}
cd ./docker/desktop/cert/${远程主机自增ID}
```
2. 将之前生成的ca.pem cert.pem key.pem这3个文件拷贝到当前目录。注意正确设置证书文件权限。
3. 使用docker客户端测试（注意修改证书路径为绝对路径）
```
docker --tlsverify \
   --tlscacert=./docker/desktop/cert/${远程主机自增ID}/ca.pem \
   --tlscert=./docker/desktop/cert/${远程主机自增ID}/cert.pem \
   --tlskey=./docker/desktop/cert/${远程主机自增ID}/key.pem \
   -H=192.168.0.123:2376 version
```
4. 使用curl测试Docker API
```
curl https://192.168.0.123:2376/images/json \
   --cert ./docker/desktop/cert/${远程主机自增ID}/cert.pem \
   --key ./docker/desktop/cert/${远程主机自增ID}/key.pem \
   --cacert ./docker/desktop/cert/${远程主机自增ID}/ca.pem
```
5. 配置默认远程调用服务器docker服务
#### 配置~/.zshrc（或者~/.bashrc，根据你的客户端环境而定），在末尾添加以下
```
export DOCKER_HOST=tcp://192.168.0.123:2376 DOCKER_TLS_VERIFY=1
export DOCKER_CERT_PATH=~/.docker/certs/
```
#### 加载到当前会话
```
source .zshrc
```
#### 测试
```
docker ps
```
*务必非常小心保管这些key*

