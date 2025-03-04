NAME := trojan-go
PACKAGE_NAME := github.com/p4gefau1t/trojan-go
VERSION := `git describe --dirty`
COMMIT := `git rev-parse HEAD`

PLATFORM := linux
BUILD_DIR := build
VAR_SETTING := -X $(PACKAGE_NAME)/constant.Version=$(VERSION) -X $(PACKAGE_NAME)/constant.Commit=$(COMMIT)
GOBUILD = env CGO_ENABLED=1 $(GO_DIR)go build -tags "full" -trimpath -ldflags="-linkmode external -s -w -buildid= $(VAR_SETTING)" -o $(BUILD_DIR)

.PHONY: trojan-go release test
normal: clean trojan-go

clean:
	rm -rf $(BUILD_DIR)
	rm -f *.zip
	rm -f *.dat

geoip.dat:
	curl -OL https://github.com/v2fly/geoip/raw/release/geoip.dat

geosite.dat:
	curl -L https://github.com/v2fly/domain-list-community/raw/release/dlc.dat > geosite.dat

test:
	# Disable Bloomfilter when testing
	SHADOWSOCKS_SF_CAPACITY="-1" $(GO_DIR)go test -v ./...

trojan-go:
	mkdir -p $(BUILD_DIR)
	$(GOBUILD)

install: $(BUILD_DIR)/$(NAME) geoip.dat geosite.dat
	mkdir -p /etc/$(NAME)
	mkdir -p /usr/share/$(NAME)
	cp example/*.json /etc/$(NAME)
	cp $(BUILD_DIR)/$(NAME) /usr/bin/$(NAME)
	cp example/$(NAME).service /usr/lib/systemd/system/
	cp example/$(NAME)@.service /usr/lib/systemd/system/
	systemctl daemon-reload
	cp geosite.dat /usr/share/$(NAME)/geosite.dat
	cp geoip.dat /usr/share/$(NAME)/geoip.dat
	ln -fs /usr/share/$(NAME)/geoip.dat /usr/bin/
	ln -fs /usr/share/$(NAME)/geosite.dat /usr/bin/

uninstall:
	rm /usr/lib/systemd/system/$(NAME).service
	rm /usr/lib/systemd/system/$(NAME)@.service
	systemctl daemon-reload
	rm /usr/bin/$(NAME)
	rm -rd /etc/$(NAME)
	rm -rd /usr/share/$(NAME)
	rm /usr/bin/geoip.dat
	rm /usr/bin/geosite.dat

%.zip: % geosite.dat geoip.dat
	@zip -du $(NAME)-$@ -j $(BUILD_DIR)/$</*
	@zip -du $(NAME)-$@ example/*
	@-zip -du $(NAME)-$@ *.dat
	@echo "<<< ---- $(NAME)-$@"

release: geosite.dat geoip.dat darwin-amd64.zip darwin-arm64.zip linux-386.zip linux-amd64.zip \
	linux-arm.zip linux-armv5.zip linux-armv6.zip linux-armv7.zip linux-armv8.zip \
	linux-mips-softfloat.zip linux-mips-hardfloat.zip linux-mipsle-softfloat.zip linux-mipsle-hardfloat.zip \
	linux-mips64.zip linux-mips64le.zip freebsd-386.zip freebsd-amd64.zip \
	windows-386.zip windows-amd64.zip windows-arm.zip windows-armv6.zip windows-armv7.zip

darwin-amd64:
	mkdir -p $(BUILD_DIR)/$@
	GOARCH=amd64 GOOS=darwin \
	CGO_CFLAGS="-mmacosx-version-min=10.12 -arch x86_64 -isysroot `xcrun --sdk macosx --show-sdk-path`" \
	CGO_LDFLAGS="-mmacosx-version-min=10.12 -arch x86_64 -isysroot `xcrun --sdk macosx --show-sdk-path`" \
	$(GOBUILD)/$@

darwin-arm64:
	mkdir -p $(BUILD_DIR)/$@
	GOARCH=arm64 GOOS=darwin \
	CGO_CFLAGS="-mmacosx-version-min=10.12 -arch arm64 -isysroot `xcrun --sdk macosx --show-sdk-path`" \
	CGO_LDFLAGS="-mmacosx-version-min=10.12 -arch arm64 -isysroot `xcrun --sdk macosx --show-sdk-path`" \
	$(GOBUILD)/$@

ios-arm64:
	mkdir -p $(BUILD_DIR)/$@
	GOARCH=arm64 GOOS=ios \
	CGO_CFLAGS="-miphoneos-version-min=10.0 -arch arm64 -isysroot `xcrun --sdk iphoneos --show-sdk-path`" \
	CGO_LDFLAGS="-miphoneos-version-min=10.0 -arch arm64 -isysroot `xcrun --sdk iphoneos --show-sdk-path`" \
	$(GOBUILD)/$@

linux-386:
	mkdir -p $(BUILD_DIR)/$@
	GOARCH=386 GOOS=linux $(GOBUILD)/$@

linux-amd64:
	mkdir -p $(BUILD_DIR)/$@
	GOARCH=amd64 GOOS=linux $(GOBUILD)/$@

linux-arm:
	mkdir -p $(BUILD_DIR)/$@
	GOARCH=arm GOOS=linux $(GOBUILD)/$@

linux-armv5:
	mkdir -p $(BUILD_DIR)/$@
	GOARCH=arm GOOS=linux GOARM=5 $(GOBUILD)/$@

linux-armv6:
	mkdir -p $(BUILD_DIR)/$@
	GOARCH=arm GOOS=linux GOARM=6 $(GOBUILD)/$@

linux-armv7:
	mkdir -p $(BUILD_DIR)/$@
	GOARCH=arm GOOS=linux GOARM=7 $(GOBUILD)/$@

linux-armv8:
	mkdir -p $(BUILD_DIR)/$@
	GOARCH=arm64 GOOS=linux $(GOBUILD)/$@

linux-mips-softfloat:
	mkdir -p $(BUILD_DIR)/$@
	GOARCH=mips GOMIPS=softfloat GOOS=linux $(GOBUILD)/$@

linux-mips-hardfloat:
	mkdir -p $(BUILD_DIR)/$@
	GOARCH=mips GOMIPS=hardfloat GOOS=linux $(GOBUILD)/$@

linux-mipsle-softfloat:
	mkdir -p $(BUILD_DIR)/$@
	GOARCH=mipsle GOMIPS=softfloat GOOS=linux $(GOBUILD)/$@

linux-mipsle-hardfloat:
	mkdir -p $(BUILD_DIR)/$@
	GOARCH=mipsle GOMIPS=hardfloat GOOS=linux $(GOBUILD)/$@

linux-mips64:
	mkdir -p $(BUILD_DIR)/$@
	GOARCH=mips64 GOOS=linux $(GOBUILD)/$@

linux-mips64le:
	mkdir -p $(BUILD_DIR)/$@
	GOARCH=mips64le GOOS=linux $(GOBUILD)/$@

freebsd-386:
	mkdir -p $(BUILD_DIR)/$@
	GOARCH=386 GOOS=freebsd $(GOBUILD)/$@

freebsd-amd64:
	mkdir -p $(BUILD_DIR)/$@
	GOARCH=amd64 GOOS=freebsd $(GOBUILD)/$@

freebsd-arm64:
	mkdir -p $(BUILD_DIR)/$@
	GOARCH=arm64 GOOS=freebsd $(GOBUILD)/$@

windows-386:
	mkdir -p $(BUILD_DIR)/$@
	GOARCH=386 GOOS=windows $(GOBUILD)/$@

windows-amd64:
	mkdir -p $(BUILD_DIR)/$@
	GOARCH=amd64 GOOS=windows $(GOBUILD)/$@

windows-arm:
	mkdir -p $(BUILD_DIR)/$@
	GOARCH=arm GOOS=windows $(GOBUILD)/$@

windows-armv6:
	mkdir -p $(BUILD_DIR)/$@
	GOARCH=arm GOOS=windows GOARM=6 $(GOBUILD)/$@

windows-armv7:
	mkdir -p $(BUILD_DIR)/$@
	GOARCH=arm GOOS=windows GOARM=7 $(GOBUILD)/$@
