FROM golang:1.26@sha256:b75179794e029c128d4496f695325a4c23b29986574ad13dd52a0d3ee9f72a6f

ENV REVIEWDOG_VERSION=v0.21.0
RUN curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b $(go env GOPATH)/bin ${REVIEWDOG_VERSION}

ADD  scripts/ /scripts/

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
