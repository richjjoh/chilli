FROM alpine:latest AS builder
RUN apk update --no-cache
RUN apk add rhash
RUN mkdir /tools
COPY ./filestohash/*.* /www/files/
COPY ./src/*.sh /tools/
RUN rhash --simple -M -H --sha256 /www/files/*.* >>/www/md5sum_results.txt
RUN chmod +x ./tools/create_html.sh
RUN chmod +x ./tools/remove_paths.sh
RUN ./tools/create_html.sh
RUN ./tools/remove_paths.sh

FROM alpine:latest
RUN apk update --no-cache
RUN apk add nginx
RUN adduser -D -g 'www' www
RUN mkdir /www
COPY --from=builder /www/index3.html /www/index.html
COPY --from=builder /www/files/*.* /www/files/
COPY /src/nginx.conf /etc/nginx/nginx.conf
RUN chown -R www:www /var/lib/nginx
RUN chown -R www:www /www
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
