#!/bin/bash

# Variables
NEW_USER="new_user"
MYSQL_ROOT_PASSWORD="mysql_Password"
ADMIN_PASSWORD="Admin_password"
SITE_NAME="brewhq.local"
BENCH_DIR="/home/$NEW_USER/frappe-bench"

# Create a new user
adduser --disabled-password --gecos "" $NEW_USER
usermod -aG sudo $NEW_USER

# Update system
apt-get update && apt-get upgrade -y

# Install essential packages
apt-get install -y fail2ban supervisor git curl \
  python3-dev python3.10-dev python3-setuptools \
  python3-pip python3-distutils python3.10-venv \
  mariadb-server mariadb-client redis-server \
  software-properties-common libmysqlclient-dev \
  xvfb libfontconfig wkhtmltopdf

# Setup Node.js v20 and Yarn
curl -fsSL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh
bash nodesource_setup.sh
apt-get install -y nodejs
npm install -g yarn

# Start necessary services
systemctl start fail2ban
systemctl start redis-server
systemctl start mysql

# Secure MySQL root user (non-interactive)
mysql -u root <<MYSQL_SCRIPT
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# Update MySQL config for utf8mb4
cat <<EOF >> /etc/mysql/my.cnf

[mysqld]
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

[mysql]
default-character-set = utf8mb4
EOF

# Restart MySQL to apply changes
service mysql restart

# Install Frappe Bench globally
pip3 install frappe-bench

# Set permissions
chmod -R o+rx /home/$NEW_USER

# Switch to new user for all bench-related commands
sudo -i -u $NEW_USER bash <<EOF
cd ~

# Initialize bench
bench init --frappe-branch version-15 frappe-bench
cd frappe-bench

# Create new site
bench new-site $SITE_NAME --mariadb-root-password $MYSQL_ROOT_PASSWORD --admin-password $ADMIN_PASSWORD

# Get ERPNext and other apps
bench get-app payments
bench get-app --branch version-15 erpnext
bench get-app hrms

# Install apps
bench --site $SITE_NAME install-app erpnext
bench --site $SITE_NAME install-app hrms

# Enable background jobs & turn off maintenance
bench --site $SITE_NAME enable-scheduler
bench --site $SITE_NAME set-maintenance-mode off

# Setup nginx and production
bench setup nginx
bench setup production $NEW_USER
EOF

# Fix deprecated Ansible syntax
sed -i '1s/- include/- include_tasks/' /usr/local/lib/python3.10/dist-packages/bench/playbooks/roles/mariadb/tasks/main.yml
sed -i '4s/- include/- include_tasks/' /usr/local/lib/python3.10/dist-packages/bench/playbooks/roles/mariadb/tasks/main.yml
sed -i '7s/- include/- include_tasks/' /usr/local/lib/python3.10/dist-packages/bench/playbooks/roles/mariadb/tasks/main.yml

# Restart supervisor to apply changes
supervisorctl restart all

echo -e "\n✅ ERPNext setup completed successfully! Visit: http://$SITE_NAME\n"
