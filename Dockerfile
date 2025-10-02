# 多阶段构建：用 Maven 构建可执行 jar，然后用轻量 JRE 运行
FROM maven:3.8.8-openjdk-11 AS build
WORKDIR /app

# 利用缓存先复制 pom 文件，预拉依赖
COPY pom.xml ./
# 若仓库有 mvnw/.mvn，请取消下一行注释
# COPY mvnw .mvn/ .mvn

# 预先拉依赖（可提高后续构建缓存命中）
RUN mvn -B -q dependency:go-offline || true

# 复制源码并打包
COPY src ./src
RUN mvn -B -DskipTests package

# 运行镜像
FROM eclipse-temurin:11-jre
WORKDIR /app

ARG JAR_FILE=target/*.jar
COPY --from=build /app/target/*.jar /app/app.jar

# 根据需要调整 JVM 内存设置
ENV TZ=UTC

# Zeabur 会把容器端口映射出来，一般 Spring Boot 默认 8080
EXPOSE 8080

# 使用平台提供的 PORT 环境变量（如果没有则默认 8080）
ENTRYPOINT ["sh", "-c", "java -Dserver.port=${PORT:-8080} -Xms256m -Xmx512m -jar /app/app.jar"]