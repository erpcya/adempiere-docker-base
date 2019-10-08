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
ENV ADEMPIERE_RELEASE_NAME 3.9.2-rc-1.0
ENV ADEMPIERE_BINARY_NAME Adempiere_392LTS.tar.gz

RUN cd $OPT_DIR && \
wget -c $ADEMPIERE_RELEASE_URL/$ADEMPIERE_RELEASE_NAME/$ADEMPIERE_BINARY_NAME

RUN cd $OPT_DIR && \
tar -C $OPT_DIR -zxvf $ADEMPIERE_BINARY_NAME

RUN cd $ADEMPIERE_HOME &&\
	chmod -Rf 755 *.sh &&\
	chmod -Rf 755 utils/*.sh &&\
	cp AdempiereEnvTemplate.properties AdempiereEnv.properties &&\
	sed -i "s@ADEMPIERE_HOME=C.*@ADEMPIERE_HOME=$ADEMPIERE_HOME@" AdempiereEnv.properties &&\
	sed -i "s@JAVA_HOME=C.*@JAVA_HOME=$JAVA_HOME@" AdempiereEnv.properties &&\
	sed -i "s/ADEMPIERE_JAVA_OPTIONS=-Xms64M -Xmx512M/ADEMPIERE_JAVA_OPTIONS=-Xms1024M -Xmx4096M/g" AdempiereEnv.properties &&\
	sed -i "s/ADEMPIERE_DB_SERVER=localhost/ADEMPIERE_DB_SERVER=$ADEMPIERE_DB_HOST/g" AdempiereEnv.properties &&\
	sed -i "s/ADEMPIERE_DB_PORT=5432/ADEMPIERE_DB_PORT=$ADEMPIERE_DB_PORT/g" AdempiereEnv.properties &&\
	sed -i "s/ADEMPIERE_DB_NAME=adempiere/ADEMPIERE_DB_NAME=$ADEMPIERE_DB_NAME/g" AdempiereEnv.properties &&\
	sed -i "s/ADEMPIERE_DB_USER=adempiere/ADEMPIERE_DB_USER=$ADEMPIERE_DB_USER/g" AdempiereEnv.properties &&\
	sed -i "s/ADEMPIERE_DB_PASSWORD=adempiere/ADEMPIERE_DB_PASSWORD=$ADEMPIERE_DB_PASSWORD/g" AdempiereEnv.properties &&\
	sed -i "s/ADEMPIERE_DB_SYSTEM=postgres/ADEMPIERE_DB_SYSTEM=$ADEMPIERE_DB_ADMIN_PASSWORD/g" AdempiereEnv.properties &&\
	sed -i "s/ADEMPIERE_KEYSTORE=C*/ADEMPIERE_KEYSTORE=\/data\/app\/Adempiere\/keystore\/myKeystore/g" AdempiereEnv.properties &&\
	sed -i "s/ADEMPIERE_WEB_ALIAS=localhost/ADEMPIERE_DB_SYSTEM=$(hostname)/g" AdempiereEnv.properties 

RUN rm $OPT_DIR/$ADEMPIERE_BINARY_NAME

RUN cd $OPT_DIR && \
	echo "ADEMPIERE_HOME=$ADEMPIERE_HOME" >> /root/.bashrc  && \
	echo "JAVA_HOME=$JAVA_HOME" >> /root/.bashrc  && \
	echo "export JAVA_HOME" >> /root/.bashrc  && \
	echo "export ADEMPIERE_HOME" >> /root/.bashrc  

RUN cd $ADEMPIERE_HOME && \
	sh RUN_silentsetup.sh

RUN cd $ADEMPIERE_HOME && \
	cp utils/unix/adempiere_Debian.sh utils/unix/adempiere && \
	sed -i "s@EXECDIR=\/opt.*@EXECDIR=$ADEMPIERE_HOME@" utils/unix/adempiere && \
	sed -i "s/ADEMPIEREUSER=adempiere/ADEMPIEREUSER=root/g" utils/unix/adempiere && \
	sed -i "s/ENVFILE=\/home\/adempiere\/.bashrc/ENVFILE=\/root\/.bashrc/g" utils/unix/adempiere && \
	mv utils/unix/adempiere /etc/init.d/ && \
	cd /etc/init.d/ && \
	update-rc.d adempiere defaults 99

CMD service adempiere start && tail -f /dev/null