#!/usr/bin/bash

# NOTE: This script is currently only tested and developing for running in ubuntu 22.04
# Using this script you can install nessory dependcies to run your project;
# This script is for projects with nodejs, mongodb,

getopts ":y" ops

permission_all_yes=""
default_permission="y"
permission=$default_permission

if [ "$ops" == "y" ]; then permission_all_yes="y"; fi

ask_permission() {
    if [ "$permission_all_yes" ]; then
        permission="y"
        return
    fi

    # get permmission string as agrument
    local permission_string=$1
    local default_permission_local=$2
    local default_y="[Y/n]"
    local default_n="[y/N]"
    local default_selected=""

    if [[ "$default_permission_local" != "n" && "$default_permission_local" != "y" ]]; then
        default_permission_local=$default_permission
    fi

    # settings default selection indicatior dialog propt string
    if [ "$default_permission_local" == "y" ]; then default_selected=$default_y; else default_selected=$default_n; fi

    # getting permission from user
    read -p "> $permission_string $default_selected : " permission

    # if there is noting then sets to default permission
    if [ "$permission" == "" ]; then permission=$default_permission_local; fi

    # set permission curresponding to user input
    if [[ "$permission" == "y" || "$permission" == "yes" ]]; then
        permission="y"
    else
        permission=""
    fi
}

new_task() {
    local message_title=$1
    clear
    if [ "$message_title" ]; then echo $message_title; fi
}

install_npm() {
    if [ $(which npm) ]; then echo "> npm version $(npm -v)"; else
        ask_permission "Npm is not installed do you want to install npm"
        if [ "$permission" ]; then
            if [ "$(which curl)" == "" ]; then
                new_task "> curl is not installed - Installing curl..."
                apt install -y curl
            fi
            new_task "> Installing npm..."
            # 1
            apt install -y npm
            # 2
            npm install -g n
            # 3
            n stable
        fi
    fi
}

install_node() {
    if [ $(which node) ]; then echo "> node version $(node -v)"; else
        ask_permission "Node is not installed do you want to install node"
        if [ "$permission" ]; then
            new_task "> Installing node..."
            # 1
            apt install nodejs -y
        fi
    fi
}

install_pnpm() {
    if [ $(which pnpm) ]; then echo "> pnpm version $(pnpm -v)"; else
        if [ $(which npm) ]; then
            ask_permission "Pnpm is not installed do you want to install pnpm"
            if [ "$permission" ]; then
                new_task "> Installing pnpm..."
                # 1
                $(which npm) cache clean --force
                # 2
                $(which npm) install pnpm -g -y
            fi
        fi
    fi
}

install_pm2() {
    if [ $(which pm2) ]; then echo "> pm2 version $(pm2 -v)"; else
        ask_permission  "pm2 is not installed do you want to install pm2"
        if [ $(which npm) ]; then 
            if [ "$permission" ]; then
                new_task "> Installing pm2..."
                # 1
                $(which npm) install pm2 -g
            fi
        else
           install_npm
           if [ $(which npm) ]; then  $(which npm) install pm2 -g; fi
        fi
    fi
}

install_nginx() {
    if [ $(which nginx) ]; then echo "> nginx version ^ $(nginx -v)"; else
        ask_permission "Nginx is not installed do you want to install nginx"
        if [ "$permission" ]; then
            new_task "> Installing nginx..."
            # 1
            apt install nginx -y
        fi
    fi
}

install_redis() {
    if [ $(which redis-server) ]; then echo "> redis version $(redis-server -v)"; else
        ask_permission "Redis is not installed do you want to install redis"
        if [ "$permission" ]; then
            new_task "> Installing redis..."
            # 1
            apt install redis-server -y
        fi
    fi 
}

install_mongodb() {
    if [ $(which mongod) ]; then echo "> mongodb version $(mongod --version)"; else
        ask_permission "Mongodb is not installed do you want to install mongodb"
        if [ "$permission" ]; then
            if [ "$(which curl)" == "" ]; then
                new_task "> curl is not installed - Installing curl..."
                apt install -y curl
            fi
            new_task "> Installing mongodb..."
            # 1
            curl -fsSL https://pgp.mongodb.com/server-6.0.asc |
                gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg \
                    --dearmor
            # 2
            echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list
            # 3
            apt update
            # 4
            apt install -y mongodb-org
            #
            new_task "> Starting and enabling mongodb..."
            if [ "$(ps -p 1 -o comm=)" == "systemd" ]; then
                # 5
                systemctl enable mongod
                # 6
                systemctl start mongod
            else
                # 5
                $(mongod --config /etc/mongod.conf) &
            fi
        fi
    fi
}

update_and_upgrade_packages() {
    ask_permission "Do you want to update and upgrade packages"

    if [ "$permission" ]; then
        apt update -y && apt upgrade -y && apt dist-upgrade -y
    fi
}

# Real execution starts below
new_task
update_and_upgrade_packages
install_npm
install_node
install_pm2
install_pnpm
install_nginx
install_mongodb
install_redis

echo "> You are all set !"
