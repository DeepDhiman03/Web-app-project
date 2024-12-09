#!/bin/bash
sudo apt-get update 
sudo apt-get install nodejs -y
sudo apt-get install npm -y
git clone https://github.com/DeepDhiman03/backend-app.git
cd backend-app
npm init -y
npm install express
sudo node app.js &