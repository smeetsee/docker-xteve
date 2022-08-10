FROM golang:latest AS builder

# Clone source code
RUN git clone https://github.com/xteve-project/xTeVe.git xteve && cd xteve
# Install dependencies
RUN go get github.com/koron/go-ssdp && go get github.com/gorilla/websocket && go get github.com/kardianos/osext
# Checkout latest version
RUN git checkout 2.2.0.200
# Build xTeVe
RUN go build xteve.go



# Actual container
FROM alpine:latest

# Partially based on https://github.com/alturismo/xteve/blob/master/Dockerfile
VOLUME /root/.xteve
VOLUME /tmp/xteve
COPY --from=builder xteve/xteve /usr/local/bin/xteve
RUN chmod +x /usr/bin/xteve

# Set timezone
RUN apk update && apk add --no-cache tzdata
ENV TZ=Europe/Amsterdam
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Instal ffmpeg
RUN apk add --no-cache ffmpeg

# xTeVe runs on port 34400
EXPOSE 34400

# Define executable with parameters
ENTRYPOINT [ "/usr/local/bin/xteve","-config=/root/.xteve/" ]