FROM nginx

RUN apt-get update && apt-get install -y fail2ban

COPY default.conf sharing-only.conf /etc/nginx/conf.d/
COPY nginx-nextcloud-sharing-auth.conf /etc/fail2ban/filter.d/
COPY iptables-proxy.conf /etc/fail2ban/action.d/
COPY jail.conf /etc/fail2ban/

EXPOSE 80 8000

