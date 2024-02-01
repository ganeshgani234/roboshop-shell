#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST=mongodb.daws76s1.online

TIMESTAMP=$(date +%F-%H-%M_%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2 ... $R FAILED $N"
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then 
    echo -e "$R ERROR:: please run this script with root access $N"
    exit 1 # you can give other than 0
else 
    echo "you are root user"
fi

dnf module disable nodejs -y

VALIDATE $? "Disabiling current nodeJS" &>> $LOGFILE

dnf module enable nodejs:18 -y

VALIDATE $? "Enable nodejs:18" &>> $LOGFILE

dnf install nodejs -y

VALIDATE $? "Installing nodejs:18" &>> $LOGFILE

useradd roboshop

VALIDATE $? "Creating roboshop user" &>> $LOGFILE

mkdir /app

VALIDATE $? "Creating app directory" &>> $LOGFILE

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

VALIDATE $? "CrDownloding catalogue apllication" &>> $LOGFILE

cd /app 

unzip /tmp/catalogue.zip

VALIDATE $? "unzipping catalogue" &>> $LOGFILE

npm install 

VALIDATE $? "Installing dependencies" &>> $LOGFILE

# use absolute, because catalogue.service exists there
cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "copying catalogue service file"

systemctl daemon-reload

VALIDATE $? "catalogue deamon reload" &>> $LOGFILE

systemctl enable catalogue

VALIDATE $? "Enable catalogue" &>> $LOGFILE

systemctl start catalogue

VALIDATE $? "Starting catalogue" &>> $LOGFILE

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "copying mongodb repo" &>> $LOGFILE

dnf install mongodb-org-shell -y

VALIDATE $? "Installing mongodb client" &>> $LOGFILE

mongo --host $MONGODB_HOST </app/schema/catalogue.js

VALIDATE " Loading catalogue data in to mongodb"