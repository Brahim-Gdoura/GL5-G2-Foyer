FROM eclipse-temurin:17-jdk-alpine
EXPOSE 8083
ADD target/app.jar /app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
