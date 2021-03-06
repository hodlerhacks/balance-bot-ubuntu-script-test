##################################################################################
#!/bin/bash
# to use : wget -P /tmp -L https://raw.githubusercontent.com/hodlerhacks/balance-bot-ubuntu-script/master/bb_migrate.sh bb_migrate.sh;bash /tmp/bb_migrate.sh
# Balance Bot UBUNTU/DEBIAN Migration tool
##################################################################################
SCRIPTVERSION="1.0.1"
BBPATH=/var/opt
BBFOLDER=balance-botv2
BBSCRIPTFOLDER=balance-bot-ubuntu-script
BBINSTALLERREPOSITORY=https://github.com/hodlerhacks/balance.git
BBSCRIPTREPOSITORY=https://github.com/hodlerhacks/balance-bot-ubuntu-script.git
PM2FILE=bb.js

############################## Functions #########################################

press_enter() {
	echo ""
  	echo -n "	Press Enter to continue "
  	read
}

bbscript_update() {
	if [ -d "$BBPATH"/"$BBSCRIPTFOLDER" ]; then
	# If local repository exists check for updates		
		cd "$BBPATH"/"$BBSCRIPTFOLDER"
			git pull --ff-only origin master
	else
		git clone "$BBSCRIPTREPOSITORY" "$BBPATH"/"$BBSCRIPTFOLDER"
	fi
}

migrate_bot() {
	pm2 delete all
	cd

	## Save config files
	if [ -d "$BBPATH"/"$BBFOLDER"/config/ ]; then
		mkdir /tmp/config/
		cp "$BBPATH"/"$BBFOLDER"/config/* /tmp/config/
    fi

	rm -r "$BBPATH"/"$BBFOLDER"

	## Creating local repository ##
	echo "### Downloading Balance Bot ###"
	
	git clone "$BBINSTALLERREPOSITORY" "$BBPATH"/"$BBFOLDER"

    ## Run install.js to do a clean install
    CWD="$PWD"
    cd "$BBPATH"/"$BBFOLDER"
    node install.js "$INSTALLOPTION"
	cd

    press_enter

	## Recover config files
	mkdir "$BBPATH"/"$BBFOLDER"/bb/config/
	cp /tmp/config/* "$BBPATH"/"$BBFOLDER"/bb/config/

	# Check if migration was successful
	if [ -d "$BBPATH"/"$BBFOLDER"/bb/config/ ]; then
		rm -r /tmp/config/
	fi

    bbscript_update

	## Start bot ##
	echo "### Starting Balance Bot ###"
	pm2_install
	pm2 startup
	pm2 restart BalanceBot

    exit
}

pm2_install () { 
	cd "$BBPATH"/"$BBFOLDER";pm2 start "$PM2FILE" --name=BalanceBot
	pm2 save
}

print_header () {
    clear
    echo "---------------------------------------------------------"
    echo ""
    echo "                  Balance Bot Migration"
    echo "                         v"$SCRIPTVERSION
    echo ""
    echo "---------------------------------------------------------"
    echo ""
}

if [ -d "$BBPATH"/"$BBFOLDER"/bb/config/ ]; then
    print_header
    echo "           Balance Bot has already been migrated"
	echo "" 
	echo "---------------------------------------------------------"
	echo "" 
    exit
fi

until [ "$selection" = "0" ]; do
    print_header
	echo "      1  -  Migrate Balance Bot"
	echo "      0  -  Exit"
	echo ""
	echo "---------------------------------------------------------"
	echo "" 
	echo -n "  Enter selection: "
	read selection
	echo ""
	case $selection in
		1 ) clear ; INSTALLOPTION=1 ; migrate_bot ;;
		1s ) clear ; INSTALLOPTION=1s ; migrate_bot ;;
	esac
done