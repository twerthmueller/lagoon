#!/usr/bin/env bash

set -e
set -x

if [ ! -d "/run/mysqld" ]; then
	mkdir -p /run/mysqld
	chown -R mysql:mysql /run/mysqld
fi

find /var/lib/mysql

if [ -d /var/lib/mysql/mysql ]; then
	echo "[i] MySQL directory already present, skipping creation"
else
	echo "[i] MySQL data directory not found, creating initial DBs"

	mysql_install_db --skip-name-resolve

	if [ "$MARIADB_ROOT_PASSWORD" = "" ]; then
		MARIADB_ROOT_PASSWORD=`pwgen 16 1`
		echo "[i] MySQL root Password: $MARIADB_ROOT_PASSWORD"
	fi

	MARIADB_DATABASE=${MARIADB_DATABASE:-""}
	MARIADB_USER=${MARIADB_USER:-""}
	MARIADB_PASSWORD=${MARIADB_PASSWORD:-""}

	tfile=`mktemp`
	if [ ! -f "$tfile" ]; then
	    return 1
	fi

	cat << EOF > $tfile
USE mysql;

UPDATE user SET PASSWORD=PASSWORD("$MARIADB_ROOT_PASSWORD") WHERE user="root";
FLUSH PRIVILEGES;

EOF

	if [ "$MARIADB_DATABASE" != "" ]; then
	  echo "[i] Creating database: $MARIADB_DATABASE"
	  echo "CREATE DATABASE IF NOT EXISTS \`$MARIADB_DATABASE\` CHARACTER SET utf8 COLLATE utf8_general_ci;" >> $tfile
	  if [ "$MARIADB_USER" != "" ]; then
	    echo "[i] Creating user: $MARIADB_USER with password $MARIADB_PASSWORD"
		  echo "GRANT ALL ON \`$MARIADB_DATABASE\`.* to '$MARIADB_USER'@'%' IDENTIFIED BY '$MARIADB_PASSWORD';" >> $tfile
	  fi
		echo "FLUSH PRIVILEGES;" >> $tfile
	fi

	/usr/bin/mysqld --bootstrap --verbose=0 < $tfile
	rm -v -f $tfile

	echo "[client]" >> /var/lib/mysql/.my.cnf
	echo "user=root" >> /var/lib/mysql/.my.cnf
	echo "password=$MARIADB_ROOT_PASSWORD"  >> /var/lib/mysql/.my.cnf

fi

# execute any pre-exec scripts, useful for images
# based on this image
for i in /scripts/pre-exec.d/*sh
do
	if [ -e "${i}" ]; then
		echo "[i] pre-exec.d - processing $i"
		. ${i}
	fi
done

exec /usr/bin/mysqld --console