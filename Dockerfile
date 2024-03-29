FROM golang:latest AS builder

RUN git clone https://github.com/xteve-project/xTeVe.git /go/src/github.com/xteve-project/xteve && \
    cd /go/src/github.com/xteve-project/xteve && \
    go get github.com/koron/go-ssdp && go get github.com/gorilla/websocket && go get github.com/kardianos/osext && \
    git checkout 2.2.0.200 && \
    go build xteve.go


# Actual container
FROM alpine:latest

# Based on https://stackoverflow.com/a/49955098/2378368 and https://stackoverflow.com/a/63110882/2378368
RUN addgroup -g 2001 -S xteve && adduser -u 1001 -S xteve -G xteve

# Partially based on https://github.com/alturismo/xteve/blob/master/Dockerfile
VOLUME /home/xteve/.xteve
VOLUME /tmp/xteve
COPY --from=builder /go/src/github.com/xteve-project/xteve/xteve /usr/local/bin/xteve
RUN chmod +x /usr/local/bin/xteve

# Set timezone & install compatibility libraries according to https://stackoverflow.com/questions/51508150/standard-init-linux-go190-exec-user-process-caused-no-such-file-or-directory#comment117747592_62123648
RUN apk add --no-cache tzdata libc6-compat gcompat
ENV TZ=Europe/Amsterdam
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Instal ffmpeg
RUN apk add --no-cache ffmpeg

# Install VLC, but do not fail if the package does not exist
RUN apk add --no-cache vlc || true

# xTeVe runs on port 34400
EXPOSE 34400

# Set user, based on https://stackoverflow.com/a/49955098/2378368
USER xteve

# Define executable with parameters
CMD [ "/usr/local/bin/xteve","-config=/home/xteve/.xteve/" ]
