# -------------------- 最终解决方案 Dockerfile --------------------
# 阶段1: 构建阶段 - 使用 Maven 镜像
FROM maven:3.8.5-openjdk-8-slim AS build
# 设置工作目录
WORKDIR /app
# 关键改动：一次性复制所有文件，避免路径问题
COPY . .
# 运行 Maven 打包命令
RUN mvn -f pom.xml clean package -DskipTests

# 阶段2: 运行阶段 - 使用轻量级 Java 运行环境
FROM openjdk:8-jre-alpine
# 设置工作目录
WORKDIR /app
# 从构建阶段(build)复制最终生成的 JAR 文件
COPY --from=build /app/target/lottery-0.0.1-SNAPSHOT.jar app.jar
# 暴露端口
EXPOSE 8080
# 定义容器启动命令
ENTRYPOINT ["java", "-jar", "app.jar"]
# -------------------------------------------------------------------
