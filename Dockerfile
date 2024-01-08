FROM golang:1.21-bookworm as builder

RUN apt update && apt install -y build-essential

COPY hockeypuck/Makefile /hockeypuck/
COPY hockeypuck/src /hockeypuck/src
ENV GOPATH=/hockeypuck
ENV CGO_ENABLED=0

WORKDIR /hockeypuck
RUN make build


FROM gcr.io/distroless/static-debian12 as runner

USER nobody
WORKDIR /hockeypuck

COPY --from=builder --chown=nobody:nogroup /hockeypuck/bin /hockeypuck/bin
COPY --chown=nobody:nogroup hockeypuck/contrib/templates /hockeypuck/lib/templates
COPY --chown=nobody:nogroup hockeypuck/contrib/webroot /hockeypuck/lib/www
WORKDIR /hockeypuck/etc
WORKDIR /hockeypuck/data/ptree

WORKDIR /hockeypuck

CMD ["/hockeypuck/bin/hockeypuck", "-config", "/hockeypuck/etc/hockeypuck.conf"]
