#!/usr/bin/bash

if [ ! -f "$PATH/s_php" ]; then
        cp /usr/local/bin/php /usr/local/bin/s_php
fi


if [ "$MODE" == "polyscripted" ] || [ -e /polyscripted ]; then
	
	if [ -f /wordpress ]; then
		cp /wordpress /usr/src/wordpress/
	fi

	echo "Starting polyscripted WordPress"
	cd $POLYSCRIPT_PATH
	sed -i "/#mod_allow/a \define( 'DISALLOW_FILE_MODS', true );" /usr/src/wordpress/wp-config.php
    	./build-scrambled.sh
	if [ -f scrambled.json ] && s_php tok-php-transformer.php -p /usr/src/wordpress --replace; then
		echo "Polyscripting enabled."
		echo "done"
	else
		echo "Polyscripting failed."
		cp /usr/local/bin/s_php /usr/local/bin/php
		exit 1
	fi
else
    echo "Polyscripted mode is off. To enable it, either:"
    echo "  1. Set the environment variable: MODE=polyscripted"
    echo "  2. OR create a file at path: /polyscripted"

    # Symlink the mount so it's editable
    ln -s /wordpress /usr/src/wordpress
fi
