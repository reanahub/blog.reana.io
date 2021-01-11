FROM klakegg/hugo:0.80.0-onbuild AS hugo

FROM nginx:1.19.4
EXPOSE 8080
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=hugo /target /usr/share/nginx/html
RUN chmod -R a+rwx /var/run && \
    chmod -R a+rwx /var/cache/nginx
USER 1001
