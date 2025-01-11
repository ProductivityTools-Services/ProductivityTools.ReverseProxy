
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

In dns provider remember to create subdomain or to point all subdomains  to your server *.productivitytools.top



