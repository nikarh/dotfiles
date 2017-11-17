default: deps build

deps:
	cd src/control && godep restore

build:
	go install -ldflags "-s -w" control

clean:
	rm -rf pkg src/github.com src/control/vendor