# Utiliser une image Java officielle
FROM openjdk:17-jdk-slim

# Créer un répertoire pour l'application
WORKDIR /app

# Copier le JAR généré dans le conteneur
COPY target/*.jar app.jar

# Exposer le port sur lequel tourne l'application
EXPOSE 9096

# Démarrer l'application
ENTRYPOINT ["java", "-jar", "app.jar"]
