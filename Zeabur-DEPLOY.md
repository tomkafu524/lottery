# 在 Zeabur 上部署说明（自动化部署模板）

说明：把本分支（zeabur-deploy）合并后，Zeabur 直接从该仓库读取 Dockerfile 构建并部署。

必备环境变量（需在 Zeabur Service 的 Settings -> Environment Variables 中配置）
- SPRING_PROFILES_ACTIVE: production  （可选）
- SPRING_DATASOURCE_URL: jdbc:mysql://<HOST>:<PORT>/<DB>?useSSL=false&serverTimezone=UTC
- SPRING_DATASOURCE_USERNAME: your_db_user
- SPRING_DATASOURCE_PASSWORD: your_db_password
- JWT_SECRET: <your-jwt-secret>                 （如果项目使用 JWT）
- OTHER_API_KEY: <第三方服务密钥>               （按需添加）

推荐 Zeabur 配置
1. 在 Zeabur 创建 Project（或使用已有 Project）。
2. Create Service -> Deploy from Git -> 选择你的仓库和分支（推荐选择 zeabur-deploy 或 main）。
3. 平台会使用仓库根目录下的 Dockerfile 构建镜像。端口填写 8080（镜像内已 EXPOSE 8080），Zeabur 会设置环境变量 PORT 给容器。
4. 如果需要数据库，可以在 Zeabur 中创建一个 MySQL/Postgres 服务，并把连接信息填入上面的 SPRING_DATASOURCE_* 变量。
5. 配置 Secrets / Environment Variables 后，点击 Deploy（或启用自动部署）。

本地测试
- 本地构建镜像：
  docker build -t lottery:dev .
- 运行容器并映射端口：
  docker run -e PORT=8080 -p 8080:8080 lottery:dev
- 或直接用 Maven 运行：
  mvn -DskipTests spring-boot:run

注意事项
- 若仓库包含前端（例如 Vue）且前端不是在 Maven 生命周期中构建，需要额外在 Dockerfile 中加入前端构建步骤（npm install && npm run build），或先把前端构建产物放入 Spring Boot 的 static 目录。
- 请务必在 Zeabur 上配置好所有敏感信息（数据库密码、第三方 API Key），不要将它们写入仓库。
- 本仓库为博彩类项目，请确认在你目标部署区域与 Zeabur 平台的服务条款允许此类服务部署。