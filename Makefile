APP := $(shell basename $(shell git remote get-url origin) | sed 's/.git$$//')
REGISTRY := kozyrnik
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=linux# Значення за замовчуванням, можна змінити на darwin або windows
TARGETARCH=arm64# Значення за замовчуванням.

linux windows macos:
	@$(MAKE) image TARGETOS=$(if $(filter $@,macos),darwin,$@) TARGETARCH=$(TARGETARCH)

format:
	gofmt -s -w ./

lint:
	golint ./...

test:
	go test -v ./...

get:
	go get ./...

build: format get
	CGO_ENABLED=0 GOOS=$(TARGETOS) GOARCH=$(TARGETARCH) go build -v -o kbot -ldflags "-X 'github.com/kozyr-dv/kbot/cmd.appVersion=$(VERSION)'"

image:
	docker build . -t $(REGISTRY)/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH) --build-arg TARGETOS=$(TARGETOS) --build-arg TARGETARCH=$(TARGETARCH)

push:
	docker push $(REGISTRY)/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH)

clean:
	rm -rf kbot
	docker rmi -f $(REGISTRY)/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH)