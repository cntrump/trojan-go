FROM golang:alpine AS builder
WORKDIR /
ARG REF
RUN apk add git make curl gcc g++
RUN git clone https://github.com/cntrump/trojan-go.git
RUN if [[ -z "${REF}" ]]; then \
        echo "No specific commit provided, use the latest one." \
    ;else \
        echo "Use commit ${REF}" &&\
        cd trojan-go &&\
        git checkout ${REF} \
    ;fi
RUN cd trojan-go && \
    make && \
    curl -L https://github.com/v2fly/domain-list-community/raw/release/dlc.dat > build/geosite.dat && \
    curl -L https://github.com/v2fly/geoip/raw/release/geoip.dat > build/geoip.dat

FROM alpine
WORKDIR /
COPY --from=builder /trojan-go/build /usr/local/bin/
COPY --from=builder /trojan-go/example/server.json /etc/trojan-go/config.json

ENTRYPOINT ["/usr/local/bin/trojan-go", "-config"]
CMD ["/etc/trojan-go/config.json"]
