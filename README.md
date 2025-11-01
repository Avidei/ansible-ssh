## Description 
Personal Ansible build based on Debian 13 with preinstalled packages: <br>
<br>
`curl`<br> 
`git`<br>
`nano`<br>
`python3` <br>
`ansible`<br>
`openssh-server`<br>
`openssh-client`<br>
`rsyslog`
## ansible-ssh
Debian + SSH + Ansible container with opened 22/tcp port for SSH-connections<br>
The container starts and runs as root
## Сredentials for SSH connection
`username` : avidei<br>
`password` : avidei
## Install
```bash
git clone https://github.com/Avidei/ansible-ssh.git
cd ansible-ssh
```

```bash
docker build -t avidei/ansible-ssh:latest . && \
docker run -d -p 2222:22 --name ansible-ssh avidei/ansible-ssh:latest
```

