FROM openjdk:8-jdk
MAINTAINER Yamel Senih "ysenih@erpya.com"

ARG ADEMPIERE_DB_HOST=localhost
ARG ADEMPIERE_DB_PORT=5432
ARG ADEMPIERE_DB_NAME=ADempiereSeed
ARG ADEMPIERE_DB_USER=adempiere
ARG ADEMPIERE_DB_PASSWORD=adempiere
ARG ADEMPIERE_DB_ADMIN_PASSWORD=postgres
ARG ADEMPIERE_WEB_PORT=8888

ENV ADEMPIERE_DB_HOST $ADEMPIERE_DB_HOST
ENV ADEMPIERE_DB_PORT $ADEMPIERE_DB_PORT
ENV ADEMPIERE_DB_NAME $ADEMPIERE_DB_NAME
ENV ADEMPIERE_DB_USER $ADEMPIERE_DB_USER
ENV ADEMPIERE_DB_PASSWORD $ADEMPIERE_DB_PASSWORD
ENV ADEMPIERE_DB_ADMIN_PASSWORD $ADEMPIERE_DB_ADMIN_PASSWORD
ENV ADEMPIERE_WEB_PORT $ADEMPIERE_WEB_PORT
ENV OPT_DIR /opt
ENV ADEMPIERE_HOME /opt/Adempiere
ENV ADEMPIERE_RELEASE_URL https://github.com/erpcya/adempiere/releases/download
ENV ADEMPIERE_RELEASE_NAME 3.9.3-rs-1.3
ENV ADEMPIERE_BINARY_NAME Adempiere_393LTS.tar.gz

RUN cd $OPT_DIR && \
wget -c $ADEMPIERE_RELEASE_URL/$ADEMPIERE_RELEASE_NAME/$ADEMPIERE_BINARY_NAME

RUN cd $OPT_DIR && \
tar -C $OPT_DIR -zxvf $ADEMPIERE_BINARY_NAME

RUN chmod -Rf 755 $ADEMPIERE_HOME/*.sh
RUN chmod -Rf 755 $ADEMPIERE_HOME/utils/*.sh

RUN sed -i "s/ADEMPIERE_HOME=C.*/ADEMPIERE_HOME=\/opt\/Adempiere/g" /opt/Adempiere/AdempiereEnvTemplate.properties
RUN sed -i "s/JAVA_HOME=C.*/JAVA_HOME=\/usr\/lib\/jvm\/java-8-openjdk-amd64/g" /opt/Adempiere/AdempiereEnvTemplate.properties
RUN sed -i "s/ADEMPIERE_JAVA_OPTIONS=-Xms64M -Xmx512M/ADEMPIERE_JAVA_OPTIONS=-Xms1024M -Xmx4096M/g" /opt/Adempiere/AdempiereEnvTemplate.properties
RUN sed -i "s/ADEMPIERE_DB_SERVER=localhost/ADEMPIERE_DB_SERVER=$ADEMPIERE_DB_HOST/g" /opt/Adempiere/AdempiereEnvTemplate.properties
RUN sed -i "s/ADEMPIERE_DB_PORT=5432/ADEMPIERE_DB_PORT=$ADEMPIERE_DB_PORT/g" /opt/Adempiere/AdempiereEnvTemplate.properties
RUN sed -i "s/ADEMPIERE_DB_NAME=adempiere/ADEMPIERE_DB_NAME=$ADEMPIERE_DB_NAME/g" /opt/Adempiere/AdempiereEnvTemplate.properties
RUN sed -i "s/ADEMPIERE_DB_USER=adempiere/ADEMPIERE_DB_USER=$ADEMPIERE_DB_USER/g" /opt/Adempiere/AdempiereEnvTemplate.properties
RUN sed -i "s/ADEMPIERE_DB_PASSWORD=adempiere/ADEMPIERE_DB_PASSWORD=$ADEMPIERE_DB_PASSWORD/g" /opt/Adempiere/AdempiereEnvTemplate.properties
RUN sed -i "s/ADEMPIERE_DB_SYSTEM=postgres/ADEMPIERE_DB_SYSTEM=$ADEMPIERE_DB_ADMIN_PASSWORD/g" /opt/Adempiere/AdempiereEnvTemplate.properties
RUN sed -i "s/ADEMPIERE_KEYSTORE=C*/ADEMPIERE_KEYSTORE=\/data\/app\/Adempiere\/keystore\/myKeystore/g" /opt/Adempiere/AdempiereEnvTemplate.properties
RUN sed -i "s/ADEMPIERE_WEB_ALIAS=localhost/ADEMPIERE_DB_SYSTEM=$(hostname)/g" /opt/Adempiere/AdempiereEnvTemplate.properties
RUN sed -i "s/ADEMPIERE_APPS_TYPE=tomcat/ADEMPIERE_APPS_TYPE=jboss/g" /opt/Adempiere/AdempiereEnvTemplate.properties
RUN sed -i "s/ADEMPIERE_APPS_DEPLOY=\/opt\/Adempiere\/tomcat\/webapps/ADEMPIERE_APPS_DEPLOY=\/opt\/Adempiere\/jboss\/server\/adempiere\/deploy/g" /opt/Adempiere/AdempiereEnvTemplate.properties && \
JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64" && \
cd /opt/Adempiere && \
cp AdempiereEnvTemplate.properties AdempiereEnv.properties && \
cp utils/myEnvironmentTemplate.sh utils/myEnvironment.sh
