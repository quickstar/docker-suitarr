FROM debian:stretch-slim
LABEL maintainer="quickstar"

ARG DEBIAN_FRONTEND=noninteractive
ENV XDG_CONFIG_HOME="/config" XDG_DATA_HOME="/config"
ENV LANG='C.UTF-8' LANGUAGE='C.UTF-8' LC_ALL='C.UTF-8'

# install packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends --no-install-suggests \
        ca-certificates-mono gnupg dirmngr apt-transport-https libcurl4-openssl-dev && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && echo "deb https://download.mono-project.com/repo/debian stable-stretch main" | tee /etc/apt/sources.list.d/mono-official-stable.list && \
# debian:strecht-slim is missing the man directories, mono and openjdk fails during install if not present
        mkdir -p /usr/share/man/man1 && \
    apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
        jq \
        unzip \
        curl \
        mono-devel \
        sqlite3 \
        python \
        openjdk-8-jre-headless \
        mediainfo && \
# install s6-overlay
    curl -s -o - -L "https://github.com/just-containers/s6-overlay/releases/download/v1.21.4.0/s6-overlay-amd64.tar.gz" | tar xzf - -C / && \
# make folders
    mkdir -p /app /config && \
# create user
    useradd -u 1000 -U -d /config -s /bin/false hotio && \
    usermod -G users hotio && \
# clean up
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* /usr/share/man1/*

COPY root/ /
VOLUME ["/config"]
ENTRYPOINT ["/init"]
