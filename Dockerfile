FROM quay.io/projectquay/golang:1.20 as builder

WORKDIR /go/src/app
COPY . .
ARG TARGETARCH
RUN make build TARGETARCH=${TARGETARCH}

FROM scratch
WORKDIR /
COPY --from=builder /go/src/app/kbot .
# Додано етап для alpine для отримання сертифікатів, як обговорювалося
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["./kbot", "start"]
