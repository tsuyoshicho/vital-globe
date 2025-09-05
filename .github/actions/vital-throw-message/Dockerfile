FROM golang:1.25@sha256:a5e935dbd8bc3a5ea24388e376388c9a69b40628b6788a81658a801abbec8f2e

ENV REVIEWDOG_VERSION=v0.20.3
RUN curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b $(go env GOPATH)/bin ${REVIEWDOG_VERSION}

ADD  scripts/ /scripts/

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
