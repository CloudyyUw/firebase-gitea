# Let's use arch btw
FROM archlinux:latest

# Setting up the keys for installing packages
RUN pacman-key --init 
RUN yes | pacman -Syy archlinux-keyring

# I will install yarn, but you can just install npm
# git and go are gitea dependencies
# and nodejs we will use to make our backup API
RUN yes | pacman -S  git go nodejs npm yarn gitea

# We clone the gist with the code to upload only one file to firebase hosting
RUN git clone https://gist.github.com/e2954fd382c63cd589b260cea6cf6b6c.git gist-files

# Creating a folder to organize the files we are going to download and copy
RUN mkdir work

# Copying Files
COPY . work/

# This is the structure I will use
# work/src/js work/src/scripts
# in the js folder will be the server files
# in the scripts folder will be the shell scripts that we will use to make things easier
RUN mkdir work/tempdir

# We just move the file we need from the repository
RUN mv gist-files/deployFileModule.js work/src/js

# Now all commands will be executed inside the work/ folder
WORKDIR work

# Installing Packages
# if you are using npm, change to npm i
RUN yarn

# Your gitea server port
ENV PORT=8080
# Node server port
ENV NODE_PORT=3152
# The key to the backup API we are going to do
ENV AUTH_KEY="test_key"
# Your firebase account token
ENV FIREBASE_TOKEN="firebase login:ci token"
# The name of your project on firebase hosting
ENV SITE="project name"
# Temporary folder for gitea backups
ENV TMPDIR=/work/tempdir 

#                   .--------.
#                   | Backup |
#                   '--------'
# Uncomment this session if you want to restore a previous backup
#ENV BACKUP_ID=1610949662

# Uncomment according to the database you are using
# Mysql & postgres
#ENV USER=""
#ENV PASS=""
#ENV DATABASE=""
# sqlite3
#ENV DATABASE_PATH="path"

#RUN pacman -S wget unzip

#RUN wget https://${SITE}.web.app/backups/gitea-dump-${BACKUP_ID}.zip

#RUN unzip gitea-dump-${BACKUP_ID}

#WORKDIR gitea-dump-${BACKUP_ID}

#RUN mv data/conf/app.ini /etc/gitea/conf/app.ini

#RUN mv data/* /var/lib/gitea/data/

#RUN mv log/* /var/lib/gitea/log/

#RUN mv repos/* /var/lib/gitea/repositories/

#RUN chown -R git:git /etc/gitea/conf/app.ini /var/lib/gitea


# Uncomment according to the database you are using
# mysql
# RUN mysql --default-character-set=utf8mb4 -u$USER -p$PASS $DATABASE <gitea-db.sql

# sqlite3
# RUN sqlite3 $DATABASE_PATH <gitea-db.sql

# postgres
# RUN psql -U $USER -d $DATABASE < gitea-db.sql

# API path for backup: /api/node/backup?key=$AUTH_KEY&upload=true
# Use the parameter upload=false if you do not want to upload

# The path to download files: /api/node/download?key=$AUTH_KEY&id=gitea-backup-id


ENTRYPOINT [ "bash", "src/scripts/start.sh" ]