.DEFAULT_GOAL: deps build

export GOPATH            ?= $(abspath .)
export GOBIN             ?= $(GOPATH)/bin
export PATH              ?= $(GOBIN):$(PATH)

deps:
	cd src/control && godep restore

build:
	go install -ldflags "-s -w" control

clean:
	rm -rf pkg src/github.com src/control/vendor