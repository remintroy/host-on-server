# host-on-server
This is a simple solution for saving time while hosting the MERN app on AWS or any other ubuntu22.04 instance

### Working
* Update and upgrade apt
* Install npm
* Install and update node
* Install pnpm
* Install nginx
* Install MongoDB
* Yay your server is all set for further hosting configurations

### How to use it?
```bash
git clone https://github.com/remintroy/host-on-server.git
```
```bash
cd host-on-server
```
```bash
sudo ./setup_server.sh
```

Switches
* `-y` : all yes
```bash
sudo ./setup_server.sh -y
```
Thats it! Good luck and stay creative
