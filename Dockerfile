FROM amazoncorretto:17-alpine

WORKDIR /app

COPY target/tpFoyer-17-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8082

ENTRYPOINT ["java", "-jar", "app.jar"]
