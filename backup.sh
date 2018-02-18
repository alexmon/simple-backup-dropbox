ACCESS_TOKEN="DROPBOX_GENERATED_ACCESS_TOKEN"

mkdir -p /tmp/my-site/splits

cd /tmp/my-site

echo > log.txt

rm my-site.tar

rm ./splits/my-site.tar.*

tar -cvf my-site.tar  /var/repos/my-site.git

split --bytes=50M my-site.tar ./splits/my-site.tar.

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
