# Етап для витягування сертифікатів
FROM alpine:latest as certs
RUN apk --update add ca-certificates

# Етап збірки програми
FROM quay.io/projectquay/golang:1.20 as builder
WORKDIR /go/src/app
COPY . .
# Запускаємо збірку та тестування в одному RUN, щоб зменшити кількість шарів
RUN make build && make test

# Фінальний етап для створення мінімального образу
FROM scratch
WORKDIR /
# Копіюємо скомпільовану програму
COPY --from=builder /go/src/app/kbot .
# Копіюємо сертифікати з alpine для підтримки SSL/TLS
COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["./kbot"]
