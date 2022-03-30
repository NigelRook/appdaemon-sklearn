APPDAEMON_TAG ?= $(shell git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' https://github.com/AppDaemon/appdaemon.git | tail -n 1 | cut -c 52-)

build:
	docker build --build-arg APPDAEMON_TAG=${APPDAEMON_TAG} -t elginroko/appdaemon:${APPDAEMON_TAG} .

push: build
	docker push elginroko/appdaemon:${APPDAEMON_TAG}
