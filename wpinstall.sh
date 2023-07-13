#!/bin/bash
echo "================================================================="
echo "WordPress Installer!!"
echo "By: Bappi"
echo "v1.0.0"
echo "================================================================="
DB_USER="root"
DB_PASS="root"
DB_HOST="127.0.0.1"
​
# Check if user passed a project name, if not then ask for one
if [ -z "$1" ]; then
    read -p "Enter site name: " SITE
else
    SITE=$1
fi
​
# Cleanup project name
SITE=$(echo $SITE | tr -cd '[:alnum:]' | tr '[:upper:]' '[:lower:]' | sed 's/test$//g')
# Check if project name is empty
if [ -z "$SITE" ]; then
    echo "Site name is empty"
    exit 1
fi
​
​
DOMAIN=$SITE.test
SITE_PATH=$HOME/Sites/$SITE
echo "➤ Site name: $SITE"
echo "➤ Domain: $DOMAIN"
echo "➤ Path: $SITE_PATH"
​
# Check the flag to see if we should install WordPress
if [[ $* == *--remove ]]; then
    echo "➤ Checking if site exists..."
    # Check if site directory exists if so delete it
    if [ -d $SITE_PATH ]; then
        echo "➤ Site exists, deleting the site..."
        echo "➤ Deleting database..."
        wp db drop --yes --path=$SITE_PATH > /dev/null 2>&1
        echo "➤ Deleting site directory..."
        rm -rf $SITE_PATH
        echo "➤ Site deleted"
    else
        echo "x Site does not exist"
    fi
​
    exit
fi
​
# Check if the site exists
echo "➤ Creating site..."
if [ -d "$SITE_PATH" ]; then
    echo "x Site directory exists"
    exit 1
else
    echo "➤ Site directory does not exist, creating site directory..."
    mkdir -p "$SITE_PATH"
    echo "✓ Site directory created"
fi
​
# Check if wp-config.php exists if not install WordPress
echo "➤ Installing WordPress..."
if [ -f "$SITE_PATH/wp-config.php" ]; then
    echo "✓ WordPress is already installed"
    exit 1
else
    # Download WordPress
    echo "➤ Downloading WordPress..."
    wp core download --path="$SITE_PATH" --locale=en_US --force > /dev/null 2>&1
    echo "✓ WordPress downloaded"
​
    # Create wp-config.php
    echo "➤ Creating wp-config.php..."
    wp core config --path="$SITE_PATH" --dbname="$SITE" --dbuser="$DB_USER" --dbpass="$DB_PASS" --dbhost="$DB_HOST" --force > /dev/null 2>&1
    echo "✓ wp-config.php created"
​
    echo "➤ Creating database..."
    wp db create --path="$SITE_PATH" > /dev/null 2>&1
    echo "✓ Database created"
​
    # Install WordPress
    echo "➤ Installing WordPress..."
    wp core install --path="$SITE_PATH" --url="$DOMAIN" --title="$SITE" --admin_user="admin" --admin_password="password" --admin_email="admin@$DOMAIN" --skip-email > /dev/null 2>&1
    echo "✓ WordPress installed"
fi
​
# Configure WordPress
echo "➤ Configuring WordPress..."
wp option update timezone_string  Asia/Dhaka --path="$SITE_PATH" > /dev/null 2>&1
wp rewrite structure '/%postname%/' --hard --path="$SITE_PATH" > /dev/null 2>&1
wp rewrite flush --hard --path="$SITE_PATH" > /dev/null 2>&1
wp config set WP_DEBUG true --raw --path="$SITE_PATH" > /dev/null 2>&1
wp config set WP_DEBUG_LOG true --raw --path="$SITE_PATH" > /dev/null 2>&1
wp config set WP_DEBUG_DISPLAY false --raw --path="$SITE_PATH" > /dev/null 2>&1
wp config set SCRIPT_DEBUG true --raw --path="$SITE_PATH" > /dev/null 2>&1
echo "✓ WordPress configured"
​
# Remove default themes and plugins
echo "➤ Removing default themes and plugins..."
# Get installed themes
THEMES=$(wp theme list --field=name --path="$SITE_PATH")
# Get the last theme
THEME=$(echo "$THEMES" | tail -n 1)
# Loop through the themes and delete them keep the last one
for theme in $THEMES; do
    if [ "$theme" != "$THEME" ]; then
        wp theme delete "$theme" --path="$SITE_PATH" > /dev/null 2>&1
    fi
done
​
wp plugin delete akismet hello --path="$SITE_PATH" > /dev/null 2>&1
echo "✓ Default themes and plugins removed"
​
​
# Install plugins
echo "➤ Installing plugins..."
wp plugin install --activate --path="$SITE_PATH" debug-bar query-monitor user-switching wp-mail-catcher > /dev/null 2>&1
​
​
if [[ $* == *--wc ]]; then
    echo "➤ Installing WooCommerce..."
    wp plugin install --activate --path="$SITE_PATH" woocommerce > /dev/null 2>&1
    echo "✓ WooCommerce installed"
    echo "➤ Configuring WooCommerce..."
    wp option update woocommerce_store_address 'Level#3, House# 1139, Avenue#8' --path="$SITE_PATH" > /dev/null 2>&1
    wp option update woocommerce_store_address_2 'Dhaka' --path="$SITE_PATH" > /dev/null 2>&1
    wp option update woocommerce_store_city 'Dhaka' --path="$SITE_PATH" > /dev/null 2>&1
    wp option update woocommerce_default_country 'BD:BD-13' --path="$SITE_PATH" > /dev/null 2>&1
    wp option update woocommerce_store_postcode '1216' --path="$SITE_PATH" > /dev/null 2>&1
    wp option update woocommerce_calc_taxes 'yes' --path="$SITE_PATH" > /dev/null 2>&1
    wp option update woocommerce_currency 'USD' --path="$SITE_PATH" > /dev/null 2>&1
    wp option update woocommerce_currency_pos 'left' --path="$SITE_PATH" > /dev/null 2>&1
    wp option update woocommerce_task_list_prompt_shown '1' --path="$SITE_PATH" > /dev/null 2>&1
    wp option update woocommerce_cod_settings 'a:6:{s:7:\"enabled\";s:3:\"yes\";s:5:\"title\";s:16:\"Cash on delivery\";s:11:\"description\";s:28:\"Pay with cash upon delivery.\";s:12:\"instructions\";s:28:\"Pay with cash upon delivery.\";s:18:\"enable_for_methods\";a:0:{}s:18:\"enable_for_virtual\";s:3:\"yes\";}' --path="$SITE_PATH" > /dev/null 2>&1
    wp option update woocommerce_task_list_tracked_completed_tasks 'a:6:{i:0;s:8:\"purchase\";i:1;s:8:\"products\";i:2;s:13:\"store_details\";i:3;s:8:\"shipping\";i:4;s:8:\"payments\";i:5;s:3:\"tax\";}' --path="$SITE_PATH" > /dev/null 2>&1
    wp wc tool run install_pages --user=admin --path="$SITE_PATH" > /dev/null 2>&1
    #bypass woocomerce setup wizard
    echo "✓ WooCommerce configured"
​
    # Import demo products.
    echo "➤ Importing demo products..."
    wp plugin install wordpress-importer --activate --path="$SITE_PATH" > /dev/null 2>&1
    wp import "$SITE_PATH/wp-content/plugins/woocommerce/sample-data/sample_products.xml" --authors=create --path="$SITE_PATH" > /dev/null 2>&1
    wp plugin deactivate wordpress-importer --path="$SITE_PATH" > /dev/null 2>&1
    wp plugin uninstall wordpress-importer --path="$SITE_PATH" > /dev/null 2>&1
    echo "✓ Demo products imported"
​
    # Install storefront theme and activate it
    echo "➤ Installing Storefront theme..."
    wp theme install storefront --activate --path="$SITE_PATH" > /dev/null 2>&1
    echo "✓ Storefront theme installed"
fi
echo "✓ Plugins installed"
​
# Check if dump.sql file exists, if not create it
if [ ! -f "$SITE_PATH/dump.sql" ]; then
    echo "➤ Creating dump.sql..."
    wp db export "$SITE_PATH/dump.sql" --path="$SITE_PATH" > /dev/null 2>&1
    echo "✓ dump.sql created"
fi
​
# Show a nice confirmation message
echo "✓ Site created successfully"
echo ""
echo "----------------------------------------"
echo "➤ Site URL: http://$DOMAIN"
echo "➤ Site path: $SITE_PATH"
echo "➤ Database name: $SITE"
echo "➤ Database user: $DB_USER"
echo "➤ Database password: $DB_PASS"
echo "➤ Database host: $DB_HOST"
/usr/bin/open -a "/Applications/Google Chrome.app" "http://${DOMAIN}"
/usr/bin/open -a "/Applications/Google Chrome.app" "http://${DOMAIN}/wp-admin"
cd "$SITE_PATH"
echo "----------------------------------------"
