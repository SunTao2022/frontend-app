



# =========================
# 1. Build stage
# =========================
FROM node:22-alpine AS builder

WORKDIR /app

# 先复制依赖文件，利用 Docker cache
COPY package*.json ./

RUN npm ci

# 复制源代码
COPY . .

# 构建 Vite
RUN npm run build


# =========================
# 2. Production stage
# =========================
FROM nginx:alpine

# 删除默认 nginx 页面
RUN rm -rf /usr/share/nginx/html/*

# 把 Vite 构建结果复制到 nginx
COPY --from=builder /app/dist /usr/share/nginx/html

# SPA 路由支持
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]