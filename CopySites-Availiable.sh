#!/bin/bash

FILES="./sites-available/*"
echo "$FILES"

for fullpath in $FILES;
do
 echo "$fullpath"
 echo "copy $fullpath to sites-available"
 cp $fullpath /etc/nginx/sites-available/
 FILENAME=$(basename $fullpath)
 echo $FILENAME
 echo "creating ln for $FILENAME"
 ln -s "/etc/nginx/sites-available/$FILENAME" /etc/nginx/sites-enabled
done



#cp -R ./sites-available/.  /etc/nginx/sites-available/


