FROM ubuntu:20.04 AS builder

# ===================================================================================================================================
# install wget and tar
RUN apt-get update && apt-get upgrade -y
RUN apt-get install wget tar -y

# ===================================================================================================================================
# install jdk-20
RUN wget https://download.java.net/openjdk/jdk20/ri/openjdk-20+36_linux-x64_bin.tar.gz
RUN tar -xvf /openjdk-20+36_linux-x64_bin.tar.gz
RUN mv jdk-20 /opt/

ENV JAVA_HOME="/opt/jdk-20"
ENV PATH="$JAVA_HOME/bin:$PATH"

RUN java --version

# ===================================================================================================================================
# install maven 3.6.3
RUN wget https://mirrors.estointernet.in/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
RUN tar -xvf apache-maven-3.6.3-bin.tar.gz
RUN mv apache-maven-3.6.3 /opt/

ENV M2_HOME="/opt/apache-maven-3.6.3"
ENV PATH="$M2_HOME/bin:$PATH"

RUN mvn --version

# ===================================================================================================================================
# install application
COPY . /techmaster-obo-web

WORKDIR /techmaster-obo-web

# env to connect mysql database
ENV DB_HOST: localhost
ENV DB_PORT: 3306
ENV DB_NAME: obo
ENV DB_USER: root
ENV DB_PASSWORD: 123

RUN mvn install

# ===================================================================================================================================
# multi-stage build
FROM ubuntu:20.04 AS artifact

# ===================================================================================================================================
# setting up jdk on artifact container
COPY --from=builder /opt/jdk-20/ /opt/jdk-20/

ENV JAVA_HOME="/opt/jdk-20"
ENV PATH="$JAVA_HOME/bin:$PATH"

# ===================================================================================================================================
# copy java artifact artifact container
COPY --from=builder /techmaster-obo-web/src/main/resources/ techmaster-obo-web/src/main/resources/
COPY --from=builder /techmaster-obo-web/target/obo-0.0.1-SNAPSHOT.jar techmaster-obo-web/target/obo-0.0.1-SNAPSHOT.jar

WORKDIR /techmaster-obo-web

# ===================================================================================================================================
# setup entrypoint
ENTRYPOINT ["java", "-jar", "target/obo-0.0.1-SNAPSHOT.jar"]
