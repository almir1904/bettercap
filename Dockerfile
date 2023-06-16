# build stage
FROM golang:latest AS build-env

ENV SRC_DIR $GOPATH/src/github.com/bettercap/bettercap
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get install -y --no-install-recommends build-essential libpcap-dev libusb-1.0-0-dev libnetfilter-queue-dev wireless-tools

WORKDIR $SRC_DIR
ADD . $SRC_DIR
RUN make

# get caplets
RUN mkdir -p /usr/local/share/bettercap
RUN git clone https://github.com/bettercap/caplets /usr/local/share/bettercap/caplets

# final stage
FROM golang:latest
RUN apt update && apt install -y build-essential libpcap-dev libusb-1.0-0-dev libnetfilter-queue-dev wireless-tools
COPY --from=build-env /go/src/github.com/bettercap/bettercap/bettercap /app/
COPY --from=build-env /usr/local/share/bettercap/caplets /app/
WORKDIR /app

EXPOSE 80 443 53 5300 8080 8081 8082 8083 8000
ENTRYPOINT ["/app/bettercap"]
