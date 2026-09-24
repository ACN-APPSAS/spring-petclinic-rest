# ---- Build stage ----
FROM eclipse-temurin:17-jdk AS build
WORKDIR /workspace

# Cache dependency resolution separately from source compilation
COPY mvnw pom.xml ./
COPY .mvn .mvn
RUN ./mvnw -B dependency:go-offline -q

# Build the fat JAR
COPY src src
RUN ./mvnw -B package -DskipTests -q

# ---- Runtime stage ----
FROM eclipse-temurin:17-jre
WORKDIR /app

# Run as non-root
RUN groupadd --system petclinic && useradd --system --gid petclinic petclinic
USER petclinic

COPY --from=build /workspace/target/spring-petclinic-rest-*.jar app.jar

EXPOSE 9966
ENTRYPOINT ["java", "-jar", "app.jar"]
