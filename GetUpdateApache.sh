#!/bin/sh

# Execute this in your virtualenv!
#
# Version
read -p "Enter version number: " NEW_RELEASE
mkdir -p /root/repository/$NEW_RELEASE
# Checkout to repository and set PRODUCTION = True
git clone https://github.com/<username>/mysite.git /root/repository/$NEW_RELEASE/mysite && sed -i 's/PRODUCTION = False/PRODUCTION = True/g' /root/repository/$NEW_RELEASE/mysite/mysite/settings.py && sed -i 's/PRODUCTION = False/PRODUCTION = True/g' /root/repository/$NEW_RELEASE/mysite/tasks/tasks.py
# Install cronjobs
mv /root/repository/$NEW_RELEASE/mysite/tasks/crontab /etc/crontab
# Install Django project
rm -rf /var/www/mysite/myenv/mysite/ && cp -r /root/repository/$NEW_RELEASE/mysite/ /var/www/mysite/myenv
chown -R www-data /var/www/mysite/myenv/mysite
python3 /var/www/mysite/myenv/mysite/manage.py migrate
python3 /var/www/mysite/myenv/mysite/manage.py collectstatic
# Serve Django website
systemctl restart apache2