FROM golang:1.25@sha256:e5ab8640ed89da51a95d687efdcef75bf1bf7f66368af2818ff7fd34b0bc6539

ENV REVIEWDOG_VERSION=v0.20.3
RUN curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b $(go env GOPATH)/bin ${REVIEWDOG_VERSION}

ADD  scripts/ /scripts/

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
