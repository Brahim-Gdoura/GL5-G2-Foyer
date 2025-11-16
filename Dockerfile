FROM eclipse-temurin:8-jdk-alpine
EXPOSE 8083
ADD target/app.war /app.war
ENTRYPOINT ["java","-jar","/app.war"]

