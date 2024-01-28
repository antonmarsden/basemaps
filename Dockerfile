FROM amazoncorretto:21

RUN yum update -y && \
    yum install -y wget osmium-tool make && \
    wget https://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo && \
    sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo && \
    yum install -y apache-maven

COPY tiles /opt/tiles
WORKDIR /opt/tiles
RUN mvn clean package

RUN yum install -y aws-cli

RUN mkdir -p /opt/builder
RUN mkdir -p /opt/builder/data
RUN mkdir -p /opt/builder/output
WORKDIR /opt/builder

RUN cp /opt/tiles/target/protomaps-basemap-HEAD-with-deps.jar /opt/builder/protomaps.jar

RUN cp /opt/tiles/Makefile .
RUN sed -i 's/target\/\*-with-deps\.jar/\/opt\/builder\/protomaps.jar/g' ./Makefile
RUN sed -i 's/=planet\.pmtiles/=output\/planet\.pmtiles/g' ./Makefile
RUN sed -i -E 's/--area=(\S+)/--area=\1 --output=output\/\1\.pmtiles/g' ./Makefile

#ENTRYPOINT ["java", "-jar", "/opt/protomaps.jar", "--download", "--force", "--area=monaco"]
ENTRYPOINT ["/bin/sh"]
