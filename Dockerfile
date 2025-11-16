FROM eclipse-temurin:8-jdk-alpine
EXPOSE 8083
ADD target/foyer.jar
ENTRYPOINT ["java","-jar","foyer.jar"]