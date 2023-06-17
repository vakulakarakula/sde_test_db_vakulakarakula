#!/bin/bash
docker pull postgres:latest
docker run --name postgres-db-vakula -p 5432:5432 -e POSTGRES_PASSWORD="@sde_password012" -e POSTGRES_USER="test_sde" -e POSTGRES_DB="demo" -v $HOME/sde_test_db:/mnt -d postgres
echo "shushut waiting, bro!"
sleep 15s
docker exec postgres-db-vakula psql -U test_sde -d demo -f /mnt/sql/init_db/demo.sql
docker ps
