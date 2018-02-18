# simple-backup-dropbox
A very simple no cost recipe to store a backup on Dropbox using Git and Unix shell scripts.

* Create an account on Dropbox. Go to Dropbox Developers and create an App. Provide an App's name and select 'App folder' for Permission type. Last press Generate button to create a Generated access token and copy the generated token.

* Suppose you'd like to keep a backup of folder **/var/www/my-site**

* Create a folder under /var, which will hold a bare Git repository which will serve as a stage.
```Bash
mkdir -p /var/repos
cd /var/respos
git init --bare /var/repos/my-site.git
```
* Initialize a Git repository on **/var/www/my-site** and add a remote to **/var/repos/my-site.git**
```Bash
cd /var/www/my-site
git init
git remote add stage /var/repos/my-site.git
git add . -A
git commit -am 'Init commit'
git push stage master
```

* Create a Shell script. 
```Bash
cd ~ && echo > backup.sh && chmod +x backup.sh
```
* Edit the shell script with your favourite editor. The script creates a tar from the bare Git repo, makes splits of 50Mbytes and push them on Dropbox along with a log.
```Bash
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
```

* Run your script! You may set up Cron to run this script any time of the day, weekday, etc..

* You may recover from backup from 2 sources. Either from the bare Git repo
```Bash
cd /var/www
git clone /var/repos/my-site.git
```
or from Dropbox
```Bash
cat my-site.tar.* > my-site.tar
cd /var/repos
tar xvf my-site.tar
cd /var/www
git clone /var/repos/my-site.git
```
