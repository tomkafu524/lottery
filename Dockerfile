# 阶段1: 使用 Maven 镜像进行构建
FROM maven:3.8.5-openjdk-8-slim AS build

# 将工作目录设置为 /app
WORKDIR /app

# 复制 pom.xml 文件并下载依赖，利用 Docker 缓存机制
COPY pom.xml .
RUN mvn dependency:go-offline

# 复制所有源代码
COPY src ./src

# 执行打包命令
RUN mvn package -DskipTests


# 阶段2: 使用一个轻量的 Java 运行环境
FROM openjdk:8-jre-alpine

# 将工作目录设置为 /app
WORKDIR /app

# 从构建阶段(build)复制打包好的 JAR 文件到当前阶段，并重命名为 app.jar
# 这是最关键的一步，它确保了我们能找到 JAR 文件
COPY --from=build /app/target/lottery-0.0.1-SNAPSHOT.jar app.jar

# 暴露后端服务端口
EXPOSE 8080

# 容器启动时执行的命令，使用绝对路径，万无一失
ENTRYPOINT ["java", "-jar", "app.jar"]