FROM nginx:alpine

#RUN mkdir -p /etc/nginx/external
RUN mkdir -p /etc/ssl/certs/

COPY  ca.crt  /etc/ssl/certs/ca.crt

COPY  registry-key.key /etc/ssl/certs/registry-key.key

COPY nginx.conf /etc/nginx/nginx.conf
