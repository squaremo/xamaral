GIT_SHA := $(shell git rev-parse --short HEAD)

docker:
	docker build . --target prod -t eu.gcr.io/xamaral/comments:$(GIT_SHA) -t comments:latest

push: docker
	docker push eu.gcr.io/xamaral/comments:$(GIT_SHA)

docker-dev:
	docker build . --target dev -t comments:latest

.PHONY: docker push docker-dev
