FROM nginx

RUN apt-get update \
	&& apt-get install curl sudo git -y \
	&& rm -rf /var/log/nginx/*.log \
	&& touch /var/log/nginx/access.log \
	&& touch /var/log/nginx/error.log \
    && touch /var/log/vector.log \
	&& git clone https://github.com/sbilly/joli-admin \
	&& mv joli-admin/joli/* /usr/share/nginx/html/

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.vector.dev | sh -s -- -y

ADD ./vector.toml /etc/vector/vector.toml

ADD ./start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh
CMD [ "/usr/local/bin/start.sh" ]
