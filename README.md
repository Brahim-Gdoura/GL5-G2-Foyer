# GL5-G2-Foyer - Student Housing Management System

A Spring Boot application for managing student housing (foyers) with integrated DevOps practices.

## 🏗️ Tech Stack

- **Backend**: Spring Boot 3.1.3, Java 17
- **Database**: MySQL 8
- **Build Tool**: Maven 3.9.6
- **Containerization**: Docker & Docker Compose
- **CI/CD**: Jenkins
- **Cloud**: AWS (K3s on EC2)
- **IaC**: Terraform
- **Documentation**: SpringDoc OpenAPI (Swagger)

## 📋 Prerequisites

- Java 17 or higher
- Maven 3.6+
- Docker & Docker Compose
- MySQL 8 (or use Docker)

## 🚀 Quick Start

### Local Development

1. **Clone the repository**

   ```bash
   git clone https://github.com/Brahim-Gdoura/GL5-G2-Foyer.git
   cd GL5-G2-Foyer
   ```

2. **Run with Docker Compose** (Recommended)

   ```bash
   docker-compose up -d
   ```

   The application will be available at: http://localhost:8083/tpFoyer17

3. **Or run locally with Maven**
   ```bash
   # Make sure MySQL is running
   ./mvnw spring-boot:run
   ```

### Access Points

- **API**: http://localhost:8083/tpFoyer17
- **Swagger UI**: http://localhost:8083/tpFoyer17/swagger-ui.html
- **API Docs**: http://localhost:8083/tpFoyer17/v3/api-docs

## 🗂️ Project Structure

```
GL5-G2-Foyer/
├── src/
│   ├── main/
│   │   ├── java/tn/esprit/tpfoyer17/
│   │   │   ├── controllers/      # REST controllers
│   │   │   ├── entities/         # JPA entities
│   │   │   ├── repositories/     # Data access layer
│   │   │   ├── services/         # Business logic
│   │   │   └── configurations/   # App configuration
│   │   └── resources/
│   │       └── application.properties
│   └── test/                     # Unit & integration tests
├── aws/terraform/                # Infrastructure as Code
├── docker-compose.yml            # Container orchestration
├── Dockerfile                    # Multi-stage build
├── Jenkinsfile                   # CI/CD pipeline
└── pom.xml                       # Maven configuration
```

## 🧪 Testing

```bash
# Run unit tests
./mvnw test

# Run tests with coverage
./mvnw verify

# View coverage report
open target/site/jacoco/index.html
```

## 📦 Build & Deploy

### Docker Build

```bash
docker build -t foyer-app:latest .
```

### Deploy to AWS K3s

```bash
cd aws/terraform
terraform init
terraform plan
terraform apply
```

## 🔧 Configuration

### Database Configuration

Edit `src/main/resources/application.properties`:

```properties
spring.datasource.url=jdbc:mysql://mysqldb:3306/tpFoyer17
spring.datasource.username=root
spring.datasource.password=root
```

### Docker Environment Variables

Override settings in `docker-compose.yml`:

```yaml
environment:
  SPRING_DATASOURCE_URL: jdbc:mysql://mysqldb:3306/tpFoyer17
  SPRING_DATASOURCE_USERNAME: root
  SPRING_DATASOURCE_PASSWORD: root
```

## 🔐 Nexus Repository

The project is configured to publish artifacts to Nexus:

- Releases: http://nexus:8081/repository/maven-releases/
- Snapshots: http://nexus:8081/repository/maven-snapshots/

Deploy to Nexus:

```bash
./mvnw deploy
```

## 📊 SonarQube Analysis

```bash
./mvnw clean verify sonar:sonar \
  -Dsonar.projectKey=foyer-app \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=your-token
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 API Endpoints

### Bloc Controller

- `GET /tpFoyer17/bloc/retrieve-all-blocs` - Get all blocs
- `GET /tpFoyer17/bloc/retrieve-bloc/{bloc-id}` - Get bloc by ID
- `POST /tpFoyer17/bloc/add-bloc` - Add new bloc
- `PUT /tpFoyer17/bloc/update-bloc` - Update bloc
- `DELETE /tpFoyer17/bloc/remove-bloc/{bloc-id}` - Delete bloc

### Chambre Controller

- `GET /tpFoyer17/chambre/retrieve-all-chambres` - Get all rooms
- `GET /tpFoyer17/chambre/retrieve-chambre/{chambre-id}` - Get room by ID
- `POST /tpFoyer17/chambre/add-chambre` - Add new room
- `PUT /tpFoyer17/chambre/update-chambre` - Update room
- `DELETE /tpFoyer17/chambre/remove-chambre/{chambre-id}` - Delete room

### Etudiant Controller

- `GET /tpFoyer17/etudiant/retrieve-all-etudiants` - Get all students
- `GET /tpFoyer17/etudiant/retrieve-etudiant/{etudiant-id}` - Get student by ID
- `POST /tpFoyer17/etudiant/add-etudiant` - Add new student
- `PUT /tpFoyer17/etudiant/update-etudiant` - Update student
- `DELETE /tpFoyer17/etudiant/remove-etudiant/{etudiant-id}` - Delete student

### Foyer Controller

- `GET /tpFoyer17/foyer/retrieve-all-foyers` - Get all foyers
- `GET /tpFoyer17/foyer/retrieve-foyer/{foyer-id}` - Get foyer by ID
- `POST /tpFoyer17/foyer/add-foyer` - Add new foyer
- `PUT /tpFoyer17/foyer/update-foyer` - Update foyer
- `DELETE /tpFoyer17/foyer/remove-foyer/{foyer-id}` - Delete foyer

### Reservation Controller

- `GET /tpFoyer17/reservation/retrieve-all-reservations` - Get all reservations
- `GET /tpFoyer17/reservation/retrieve-reservation/{reservation-id}` - Get reservation by ID
- `POST /tpFoyer17/reservation/add-reservation` - Add new reservation
- `PUT /tpFoyer17/reservation/update-reservation` - Update reservation
- `DELETE /tpFoyer17/reservation/remove-reservation/{reservation-id}` - Delete reservation

### Universite Controller

- `GET /tpFoyer17/universite/retrieve-all-universites` - Get all universities
- `GET /tpFoyer17/universite/retrieve-universite/{universite-id}` - Get university by ID
- `POST /tpFoyer17/universite/add-universite` - Add new university
- `PUT /tpFoyer17/universite/update-universite` - Update university
- `DELETE /tpFoyer17/universite/remove-universite/{universite-id}` - Delete university

## 📄 License

This project is part of an academic assignment at ESPRIT.

## 👥 Team

GL5-G2 - DevOps Project
