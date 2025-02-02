
Why to use a reverse proxy?
- if you have multiple services on the one computer you cannot create the subhost for them, they need to be hosted on some port (localhost:80, localhost:81 etc). This means that in the internet you also have your service under specific port like productivitytools.top:81. You can add the subhost, but still port is needed
- above also means that you cannot have two pages on the standard 80 port. 
- if you have multiple services (localhost:80, localhost:81 etc) for each of them you need to have different ssl certificate 


Tutorial:
docker run -d --name nginx-base -p:81:80 nginx:latest
edit config
docker cp ./default.conf nginx-base:/etc/nginx/conf.d/
docker exec nginx-base nginx -t
docker exec nginx-base nginx -s reload


Remarks:
- remember to open port on the ubuntu, that your docker image operates.
```
sudo ufw status verbose sudo ufw allow 81/tcp
```
![](2025-01-14-23-12-41.png)

In dns provider remember to create subdomain or to point all subdomains  to your server *.productivitytools.top

## Reverse Proxy and https termination

### Create VM for tests

```
gcloud compute instances create "reverseproxy" --machine-type "e2-standard-2" --image-project "ubuntu-os-cloud" --image-family "ubuntu-2204-lts" --subnet "default"
gcloud compute instsances delete reverseproxy
gcloud compute instances stop reverseproxy
gcloud compute instances start reverseproxy
```

### Install nginx

```
sudo apt-get update
sudo apt install nginx -y
curl localhost
```

### Install docker

```
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo docker run hello-world
sudo docker run --rm -d -p 81:80 --name my-nginx nginx
```
Change Nginx so you know from where it was hosted

```
sudo nano /var/www/html/index.nginx-debian.html
```

### certbot 

```
sudo apt-get update
sudo apt-get install certbot
sudo apt-get install python3-certbot-nginx
sudo certbot certonly --nginx -d testrp.productivitytools.top
```