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
        exit 1
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

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disabiling current nodeJS"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enable nodejs:18" 

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing nodejs:18" 

id roboshop
if [ $? -ne 0 ]
then 
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else 
    echo -e " roboshop user alredy exist $Y SKIPPING $N"
fi

mkdir -p /app 

VALIDATE $? "Creating app directory" 

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "Downloding catalogue apllication" 

cd /app 

unzip -o /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "unzipping catalogue" 

npm install &>> $LOGFILE

VALIDATE $? "Installing dependencies"

# use absolute, because catalogue.service exists there
cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "copying catalogue service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "daemon reload"

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "enable catalogue"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "starting catalogue"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "coppying mongodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "installing mongoDB client"

mongo --host $MONGODB_HOST </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "loading catalog data into mongoDB"