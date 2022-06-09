#!/bin/sh

# Execute this in your virtualenv!
#
# Version
read -p "Enter version number: " NEW_RELEASE
read -p "Enter repository name: " REPO_NAME
# If repo is private, enter the username and password
read -p "Enter Username: " USERNAME
mkdir -p /root/repository/$NEW_RELEASE
# Checkout to repository and set PRODUCTION = True
git clone https://github.com/$USERNAME/$REPO_NAME.git /root/repo/$NEW_RELEASE/$REPO_NAME && sed -i 's/PRODUCTION = False/PRODUCTION = True/g' /root/repo/$NEW_RELEASE/$REPO_NAME/$REPO_NAME/settings.py && sed -i 's/PRODUCTION = False/PRODUCTION = True/g' /root/repo/$NEW_RELEASE/$REPO_NAME/tasks/tasks.py
# Install cronjobs
mv /root/repo/$NEW_RELEASE/$REPO_NAME/tasks/crontab /etc/crontab
# Install Django project
rm -rf /var/www/$REPO_NAME/myenv/$REPO_NAME/ && cp -r /root/repo/$NEW_RELEASE/$REPO_NAME/ /var/www/$REPO_NAME/myenv
chown -R www-data /var/www/$REPO_NAME/myenv/$REPO_NAME
python3 /var/www/$REPO_NAME/myenv/$REPO_NAME/manage.py makemigrations
python3 /var/www/$REPO_NAME/myenv/$REPO_NAME/manage.py migrate
python3 /var/www/$REPO_NAME/myenv/$REPO_NAME/manage.py collectstatic
# Serve Django website
systemctl restart apache2
