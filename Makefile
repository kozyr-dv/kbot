APP=$(shell basename $(shell git remote get-url origin))
REGISTRY=kozyrnik
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=linux# darwin windows
TARGETARCH=amd64# amd64 arm64

linux:
	$(MAKE) image TARGETOS=linux TARGETARCH=${TARGETARCH}

windows:
	$(MAKE) image TARGETOS=windows TARGETARCH=${TARGETARCH}

macos:
	$(MAKE) image TARGETOS=darwin TARGETARCH=${TARGETARCH}

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

get:
	go get

build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/kozyr-dv/kbot/cmd.appVersion=${VERSION}

image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH} --build-arg=TARGETOS=${TARGETOS} --build-arg=TARGETARCH=${TARGETARCH}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}

clean:
	rm -rf kbot
	docker rmi -f ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}