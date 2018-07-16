#!/bin/bash
source /etc/profile
cd /home/master/airflow_docker/airflow-onions-dockerhub/
docker-compose -f docker-compose-CeleryExecutor.yml run --rm postgres psql "user=airflow password=airflow host=postgres" < ./pg_stat.sql
