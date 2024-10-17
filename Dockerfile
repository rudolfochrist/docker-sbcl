FROM debian:stable-slim as build

RUN apt update \
    && apt install -y \
    ca-certificates \
    curl \
    gpg \
    bzip2 \
    build-essential

# install SBCL
ENV SBCL_VERSION 2.4.9
ENV SBCL_SIGN_KEY D6839CA0A67F74D9DFB70922EBD595A9100D63CD

RUN mkdir -p /usr/local/src/sbcl \
    && cd /usr/local/src/sbcl \
    && curl -fsSLO "https://download.sourceforge.net/project/sbcl/sbcl/${SBCL_VERSION}/sbcl-${SBCL_VERSION}-crhodes.asc" \
    && curl -fsSLO "https://download.sourceforge.net/project/sbcl/sbcl/${SBCL_VERSION}/sbcl-${SBCL_VERSION}-x86-64-linux-binary.tar.bz2"\
    && bunzip2 sbcl-${SBCL_VERSION}-x86-64-linux-binary.tar.bz2 \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys ${SBCL_SIGN_KEY} \
    && gpg --batch --verify sbcl-${SBCL_VERSION}-crhodes.asc \
    && gpg --batch --decrypt sbcl-${SBCL_VERSION}-crhodes.asc > sbcl-checksum \
    && (grep sbcl-${SBCL_VERSION}-x86-64-linux-binary.tar sbcl-checksum | sha256sum -c) \
    && tar xf sbcl-${SBCL_VERSION}-x86-64-linux-binary.tar \
    && cd sbcl-${SBCL_VERSION}-x86-64-linux \
    && INSTALL_ROOT=/usr/local sh install.sh

FROM debian:stable-slim
LABEL "maintainer"="Sebastian Christ"
LABEL "version"="2.4.9-b1"

COPY --from=build /usr/local/bin/sbcl /usr/local/bin/sbcl
COPY --from=build /usr/local/lib/sbcl /usr/local/lib/sbcl
COPY image /

CMD ["/usr/local/bin/sbcl"]
