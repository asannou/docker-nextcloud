FROM nginx:stable

COPY nginx/default.conf nginx/sharing-only.conf /etc/nginx/conf.d/
RUN touch /var/log/nginx/sharing-only.log

EXPOSE 80 8000

CMD ["sh", "-c", "nginx -g 'daemon off;'"]

