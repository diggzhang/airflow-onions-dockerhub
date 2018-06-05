# VERSION 1.9.0-3
# AUTHOR: Matthieu "Puckel_" Roisil
# DESCRIPTION: Basic Airflow container
# BUILD: docker build --rm -t puckel/docker-airflow .
# SOURCE: https://github.com/puckel/docker-airflow

FROM python:3.6-slim
MAINTAINER Puckel_

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# Airflow
ARG AIRFLOW_VERSION=1.9.0-yc
ARG AIRFLOW_HOME=/usr/local/airflow

RUN set -ex \
    && buildDeps=' \
        python3-dev \
        libkrb5-dev \
        libsasl2-dev \
        libssl-dev \
        libffi-dev \
        build-essential \
        libblas-dev \
        liblapack-dev \
        libpq-dev \
        git \
    ' \
    && apt-get update -yqq \
    && apt-get upgrade -yqq \
    && apt-get install -yqq --no-install-recommends \
        $buildDeps \
        python3-pip \
        python3-requests \
        mysql-client \
        mysql-server \
        libmysqlclient-dev \
        apt-utils \
        curl \
        rsync \
        netcat \
        locales \
        locales-all \
    # && sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
    # && locale-gen \
    # && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && useradd -ms /bin/bash -d ${AIRFLOW_HOME} airflow \
    && pip install -U pip setuptools wheel \
    && pip install Cython \
    && pip install pytz \
    && pip install pyOpenSSL \
    && pip install ndg-httpsclient \
    && pip install cryptography \
    && pip install paramiko \
    && pip install flask_bcrypt \
    && pip install pyasn1 \
    && pip install kombu==4.1.0 \
    && pip install celery[redis]==4.0.2 \
    && pip install -e git+https://github.com/diggzhang/airflow-dingding.git\#egg\=apache-airflow[crypto,celery,postgres,hive,jdbc,mysql] \
    && pip install celery[redis]==4.0.2 \
    && apt-get purge --auto-remove -yqq $buildDeps \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base

# Define en_US.
ENV LC_ALL zh_CN.UTF-8
ENV LANG zh_CN.UTF-8
RUN echo "export LC_ALL=zh_CN.UTF-8"  >>  /etc/profile &&  echo "export LC_ALL=zh_CN.UTF-8" >>/root/.bashrc
RUN localedef -c -f UTF-8 -i zh_CN zh_CN.utf8

COPY script/entrypoint.sh /entrypoint.sh
COPY config/airflow.cfg ${AIRFLOW_HOME}/airflow.cfg

RUN chown -R airflow: ${AIRFLOW_HOME}

EXPOSE 8080 5555 8793

USER airflow
WORKDIR ${AIRFLOW_HOME}
ENTRYPOINT ["/entrypoint.sh"]
