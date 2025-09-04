FROM golang:1.25@sha256:5e856b892fff06368bd92fe3ac00c457ede6d399e7152575b57f9a14312ab713

ENV REVIEWDOG_VERSION=v0.20.3
RUN curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b $(go env GOPATH)/bin ${REVIEWDOG_VERSION}

ADD  scripts/ /scripts/

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
