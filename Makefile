APP=$(shell basename $(shell git remote get-url origin))
REGISTRY=kozyrnik
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=linux
TARGETARCH=arm64
BUILD_COMMAND=go build -v -o kbot -ldflags "-X 'github.com/andriy66/kbot/cmd.appVersion=${VERSION}'"

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v ./...

get:
	go get
build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH}  ${BUILD_COMMAND}
linux: format get
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 ${BUILD_COMMAND}
macos: format get
	CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 ${BUILD_COMMAND}
windows: format get
    #CGO_ENABLED=0 GOOS=windows GOARCH=amd64 ${BUILD_COMMAND}

image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}
clean:
	docker rmi ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}