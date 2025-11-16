FROM eclipse-temurin:8-jdk-alpine
EXPOSE 8083
ADD target/foyer.jar /app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
