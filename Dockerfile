# Firebase App Hosting build for GradeGlow (Flutter web).
# App Hosting's Node buildpack cannot compile Flutter, so we Docker-build
# the website and serve it on Cloud Run port 8080.

FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app
COPY . .
RUN flutter config --enable-web && flutter pub get && flutter build web --release

FROM nginx:1.27-alpine
COPY nginx.app_hosting.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
