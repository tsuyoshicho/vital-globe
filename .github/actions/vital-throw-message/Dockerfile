FROM golang:1.24@sha256:746a0e918c6fe61aaab1bcc9fd42068ee808e63c052d34ac3c9c36e061abddf6

ENV REVIEWDOG_VERSION=v0.20.3
RUN curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b $(go env GOPATH)/bin ${REVIEWDOG_VERSION}

ADD  scripts/ /scripts/

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
