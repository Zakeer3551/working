#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script stareted executing at $TIMESTAMP" &>> $LOGFILE

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
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 # you can give other than 0
else
    echo "You are root user"
fi # fi means reverse of if, indicating condition end


dnf install maven mysql -y

VALIDATE $? " Installing maven and mysql "

rm -rf /app

VALIDATE $? " Installing maven and mysql "

mkdir -p /app

VALIDATE $? " Installing maven and mysql "

id roboshop #if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

cp -f shipping.service /etc/systemd/system/shipping.service

VALIDATE $? "Copying shipping.service "

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip

VALIDATE $? "downloading shipping"

cd /app

VALIDATE $? "moving to app directory"

unzip /tmp/shipping.zip

VALIDATE $? "unzipping shipping"

mvn clean package

VALIDATE $? "Installing dependencies"

mv target/shipping*.jar shipping.jar

VALIDATE $? "renaming jar file"

systemctl daemon-reload

VALIDATE $? "deamon reload"

systemctl enable shipping

VALIDATE $? "enable shipping"

systemctl restart shipping

VALIDATE $? " start shipping "