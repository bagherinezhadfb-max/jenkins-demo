FROM nginx:alpine

RUN echo "Jenkins CI/CD Application" > /usr/share/nginx/html/index.html
