FROM openjdk:17.0.2-oraclelinux8

COPY target/obo-0.0.1-SNAPSHOT.jar obo-0.0.1-SNAPSHOT.jar

ENTRYPOINT ["java","-jar","/obo-0.0.1-SNAPSHOT.jar"]