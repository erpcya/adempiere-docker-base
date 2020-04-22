FROM openjdk:8-jdk-alpine
MAINTAINER Yamel Senih "ysenih@erpya.com"
COPY start-adempiere.sh /opt/

ENV ADEMPIERE_DB_HOST localhost
ENV ADEMPIERE_DB_PORT 5432
ENV ADEMPIERE_DB_NAME ADempiereSeed
ENV ADEMPIERE_DB_USER adempiere
ENV ADEMPIERE_DB_PASSWORD adempiere
ENV ADEMPIERE_DB_ADMIN_PASSWORD postgres
ENV ADEMPIERE_WEB_PORT 8888
ENV ADEMPIERE_SSL_PORT 4443
ENV OPT_DIR /opt
ENV ADEMPIERE_HOME /opt/Adempiere
ENV ADEMPIERE_RELEASE_URL https://github.com/erpcya/adempiere/releases/download
ENV ADEMPIERE_RELEASE_NAME 3.9.3-rs-1.6
ENV ADEMPIERE_BINARY_NAME Adempiere_393LTS.tar.gz

#Expose Ports
EXPOSE $ADEMPIERE_WEB_PORT
EXPOSE $ADEMPIERE_SSL_PORT

#Health Check
HEALTHCHECK --interval=3m --timeout=3s --retries=3 \
  CMD curl -f http://$(hostname):$ADEMPIERE_WEB_PORT/ || exit 1

#Set Workdir
WORKDIR $ADEMPIERE_HOME

#Install needed packages
RUN apk --no-cache add wget
RUN apk --no-cache add unzip
RUN apk --no-cache add sed

#Get ADempiere Binary
RUN cd $OPT_DIR && \
	wget -c $ADEMPIERE_RELEASE_URL/$ADEMPIERE_RELEASE_NAME/$ADEMPIERE_BINARY_NAME

#De-compress ADempiere Binary
RUN cd $OPT_DIR && \
tar -C $OPT_DIR -zxvf $ADEMPIERE_BINARY_NAME

#Setting Directories and access
RUN cd $ADEMPIERE_HOME && \
	chmod -Rf 755 *.sh && \
	chmod -Rf 755 utils/*.sh && \
	chmod +x $OPT_DIR/start-adempiere.sh && \
	cp AdempiereEnvTemplate.properties AdempiereEnv.properties && \
	sed -i "s@ADEMPIERE_HOME=C.*@ADEMPIERE_HOME=$ADEMPIERE_HOME@" AdempiereEnv.properties && \
	sed -i "s@JAVA_HOME=C.*@JAVA_HOME=$JAVA_HOME@" AdempiereEnv.properties && \
	sed -i "s/ADEMPIERE_JAVA_OPTIONS=-Xms64M -Xmx512M/ADEMPIERE_JAVA_OPTIONS=-Xms1024M -Xmx4096M/g" AdempiereEnv.properties && \
	sed -i "s/ADEMPIERE_KEYSTORE=C*/ADEMPIERE_KEYSTORE=\/data\/app\/Adempiere\/keystore\/myKeystore/g" AdempiereEnv.properties && \
	sed -i "s/ADEMPIERE_APPS_TYPE=tomcat/ADEMPIERE_APPS_TYPE=jboss/g" /opt/Adempiere/AdempiereEnv.properties && \
	sed -i "s/ADEMPIERE_APPS_DEPLOY=\/opt\/Adempiere\/tomcat\/webapps/ADEMPIERE_APPS_DEPLOY=\/opt\/Adempiere\/jboss\/server\/adempiere\/deploy/g" /opt/Adempiere/AdempiereEnv.properties

#Remove Compress Binary
RUN rm $OPT_DIR/$ADEMPIERE_BINARY_NAME

#Setting Environment
RUN cd $OPT_DIR && \
	echo "ADEMPIERE_HOME=$ADEMPIERE_HOME" >> /root/.bashrc  && \
	echo "JAVA_HOME=$JAVA_HOME" >> /root/.bashrc  && \
	echo "export JAVA_HOME" >> /root/.bashrc  && \
	echo "export ADEMPIERE_HOME" >> /root/.bashrc

#Start Adempiere
CMD $OPT_DIR/start-adempiere.sh
