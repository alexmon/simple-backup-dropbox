ACCESS_TOKEN="DROPBOX_GENERATED_ACCESS_TOKEN"

# commit changes on source folder, push to stage repo
cd /var/www/my-site
git add . -A
git commit -am "`date +'%Y-%m-%d %H:%M'`"
git push stage master

# create temp folder
mkdir -p /tmp/my-site/splits
cd /tmp/my-site
echo > log.txt
rm my-site.tar
rm ./splits/my-site.tar.*

# create archive of stage repo, make splits
tar -cvf my-site.tar  /var/repos/my-site.git
split --bytes=50M my-site.tar ./splits/my-site.tar.

# push splits to Dropbox
cd /tmp/my-site/splits

for f in my-site.tar.*; do
  CMD=$(curl -X POST https://content.dropboxapi.com/2/files/upload \
    --header "Authorization: Bearer $ACCESS_TOKEN" \
    --header "Dropbox-API-Arg: {\"path\": \"/splits/$f\",\"mode\": \"overwrite\",\"autorename\": false,\"mute\": true}" \
    --header "Content-Type: application/octet-stream" \
    --data-binary @$f 2>&1)
  echo $CMD >> /tmp/my-site/log.txt
done

curl -X POST https://content.dropboxapi.com/2/files/upload \
    --header "Authorization: Bearer $ACCESS_TOKEN" \
    --header "Dropbox-API-Arg: {\"path\": \"/log.txt\",\"mode\": \"overwrite\",\"autorename\": false,\"mute\": true}" \
    --header "Content-Type: application/octet-stream" \
    --data-binary @/tmp/my-site/log.txt 2>&1
