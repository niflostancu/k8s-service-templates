ARG BASE_IMAGE
FROM ${BASE_IMAGE}

RUN apt-get update && apt-get install -y \
        supervisor vim-tiny less \
    && rm -rf /var/lib/apt/lists/* && \
    mkdir /var/log/supervisord /var/run/supervisord

ADD --chmod=755 entrypoint2.sh /entrypoint2.sh
COPY supervisord.conf /etc

ENV NEXTCLOUD_UPDATE=1

ENTRYPOINT ["/entrypoint2.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
