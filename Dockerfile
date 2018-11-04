FROM debian

ARG APT_PROXY
RUN set -x && \
    [ -z "$APT_PROXY" ] || \
        /bin/echo -e "Acquire::HTTP::Proxy \"$APT_PROXY\";\nAcquire::HTTPS::Proxy \"$APT_PROXY\";\nAcquire::http::Pipeline-Depth \"23\";" > \
            /etc/apt/apt.conf.d/01proxy

RUN set -x && \
    apt-get update -qq && \
    apt-get -yq install  \
        shellcheck \
    && \
    rm -rf /var/lib/apt/lists/*

RUN set -x && \
    mkdir -p /data

WORKDIR /data

VOLUME [ "/data" ]

ENTRYPOINT [ "" ]
