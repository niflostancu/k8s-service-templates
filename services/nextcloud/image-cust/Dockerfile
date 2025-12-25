ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG NEXTCLOUD_USER=www-data
ARG NEXTCLOUD_UID=1000
ARG NEXTCLOUD_GID=1000

RUN apt-get update && apt-get install -y \
        supervisor vim-tiny less inotify-tools wget \
    && rm -rf /var/lib/apt/lists/* && \
    mkdir /var/log/supervisord /var/run/supervisord && \
    pecl install inotify && docker-php-ext-enable inotify

ADD --chmod=755 entrypoint2.sh /entrypoint2.sh
COPY supervisord.conf /etc

RUN usermod -u "${NEXTCLOUD_UID}" "${NEXTCLOUD_USER}" && \
    groupmod -g "${NEXTCLOUD_GID}" "${NEXTCLOUD_USER}"

ENV NEXTCLOUD_UPDATE=1

ENTRYPOINT ["/entrypoint2.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
