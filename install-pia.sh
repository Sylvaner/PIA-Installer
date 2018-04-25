#!/bin/sh

# Vérification que le script est lancé en root
if [[ $EUID -ne 0 ]]; then
   echo "/!\ Le script doit être lancé en root"
   exit 1
fi

echo "Utilisateur de la base de données (PostgreSQL): pia_db_user"
echo -n "Mot de passe pour cet utilisateur : "
read postgres_user_password

echo "**************************"
echo "* Mise à jour du système *"
echo "**************************"
apt-get update
apt-get upgrade -y

echo "*****************************************"
echo "* Installation des packages nécessaires *"
echo "*****************************************"
apt-get install -y git sudo build-essential zlib1g-dev libsqlite3-dev curl nodejs dirmngr

echo "******************************"
echo "* Installation de PostgreSQL *"
echo "******************************"
apt-get install -y postgresql libpq-dev

echo "****************************************"
echo "* Création de l'utilisateur PostgreSQL *"
echo "****************************************"
#sudo -u postgres psql -c "CREATE DATABASE pia_production"
sudo -u postgres psql -c "CREATE USER pia_db_user WITH PASSWORD '$postgres_user_password'"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE pia_production TO pia_db_user"
sudo -u postgres psql -c "ALTER USER pia_db_user WITH CREATEDB"

echo "*****************************"
echo "* Création d'un utilisateur *"
echo "*****************************"
useradd -m pia
cd /home/pia

echo "*********************************"
echo "* Installation de Ruby on Rails *"
echo "*********************************"
apt-get install -y ruby-dev
gem install rails -v 5.0

echo "***********************"
echo "* Installation de PIA *"
echo "***********************"

su pia -c "git clone https://github.com/atnos/pia-back.git"
cd pia-back
su pia -c "cp config/database.example.yml config/database.yml"
sed -i "s/username:/username: pia_db_user/g" config/database.yml
sed -i "s/password:/password: $postgres_user_password/g" config/database.yml

echo "*************************************"
echo "* Installation des dépendances Ruby *"
echo "*************************************"
su pia -c "bundle install --path vendor/bundle"
gem pristine --all

echo "************************"
echo "* Configuration finale *"
echo "************************"
echo "pia ALL=(ALL) NOPASSWD: /home/pia/pia-back/bin/rails" >> /etc/sudoers.d/pia
SECRET_KEY_BASE=`RAILS_ENV=production rake secret`
sudo -u pia sed -i "s/<%= ENV\[\"SECRET_KEY_BASE\"\] %>/$SECRET_KEY_BASE/g" config/secrets.yml
sudo -u pia RAILS_ENV=production bin/rake db:create
sudo -u pia RAILS_ENV=production bin/rake db:migrate

echo "****************************"
echo "* Configuration de systemd *"
echo "****************************"
cat << START_SERVER_EOF >> start.sh
#!/bin/sh
cd /home/pia/pia-back
RAILS_ENV=production bin/rails s
START_SERVER_EOF
chmod +x start.sh

cat << PIA_SERVICE_EOF >> /etc/systemd/system/pia.service
[Unit]
Description=Serveur PIA
After=network-online.target

[Service]
Type=simple
User=pia
Group=pia
ExecStart=/home/pia/pia-back/start.sh

[Install]
WantedBy=multi-user.target
PIA_SERVICE_EOF
systemctl enable pia
systemctl start pia
