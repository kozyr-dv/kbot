VERSION = v1.0.1
APP = $(shell basename $(shell git remote get-url origin) | sed 's/.git$$//' | tr '[:upper:]' '[:lower:]')
REGISTRY = kozyrnik
TARGETOS = linux
TARGETARCH = amd64

format:
    gofmt -s -w ./

goget:
    go get -v ./...

build: format goget
    CGO_ENABLED=0 go build -v -o kbot -ldflags "-X 'github.com/kozyr-dv/kbot/cmd.appVersion=$(VERSION)'"

linux: format goget
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -v -o kbot -ldflags "-X 'github.com/kozyr-dv/kbot/cmd.appVersion=$(VERSION)'"

arm: format goget
    CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -v -o kbot -ldflags "-X 'github.com/kozyr-dv/kbot/cmd.appVersion=$(VERSION)'"

macos: format goget
    CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build -v -o kbot -ldflags "-X 'github.com/kozyr-dv/kbot/cmd.appVersion=$(VERSION)'"

windows: format goget
    CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -v -o kbot.exe -ldflags "-X 'github.com/kozyr-dv/kbot/cmd.appVersion=$(VERSION)'"

lint:
    golint ./...

test:
    go test -v ./...

image:
    docker build . -t $(REGISTRY)/$(APP):$(VERSION)-$(TARGETARCH) .

push:
    docker push $(REGISTRY)/$(APP):$(VERSION)-$(TARGETARCH)

clean:
    docker rmi $(REGISTRY)/$(APP):$(VERSION)-$(TARGETARCH)
