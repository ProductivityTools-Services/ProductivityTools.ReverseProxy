Reverse proxy service full tutorial is place in the [articles](https://github.com/pwujczyk/ProductivityTools.Articles/tree/main/2025.03.23%20-%20Reverse%20Proxy)


To setup reverse proxy. Execute script
```
chmod +x CopySites-Availiable.sh
.CopySites-Availiable.sh
```

ADDED to the script

Add ssl if required (maybe it should be added to the script)
```
sudo certbot --nginx -d feedback-api.productivitytools.top
sudo nginx -t
sudo nginx -s reload
```


Debug:
```
ls /etc/nginx/sites-enabled/

```


```
./CopySites-Availiable.sh is equal to ./CopySites-Availiable.sh 1
./CopySites-Availiable.sh 2 gives more details
```

If you want to execute script only for one file then:
```
sudo ./CopySites-Availiable.sh 2 transfers-api-t460.productivitytools.top

```
