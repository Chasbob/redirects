PACKAGE ?= redirects
CSV_INPUT_FILE ?= links.csv
NAMESPACE     := traefik
DEFAULT_REDIRECT ?= https://summer.hackathonsforschools.com/schedule
HOST_NAME		 ?= join.h4s.io
VERSION ?= $(shell git describe --tags --always --dirty --match="v*" 2> /dev/null || cat $(CURDIR)/.version 2> /dev/null || echo v0)


DOCKER_REGISTRY_DOMAIN ?= docker.io
DOCKER_REGISTRY_PATH   ?= chasbob
DOCKER_IMAGE           ?= $(DOCKER_REGISTRY_PATH)/$(PACKAGE):$(VERSION)
DOCKER_IMAGE_DOMAIN    ?= $(DOCKER_REGISTRY_DOMAIN)/$(DOCKER_IMAGE)
CONTAINER_NAME		   ?= redirects

K8S_DIR ?= ./k8s
K8S_BUILD_DIR ?= ./build_k8s
K8S_FILES     := $(shell find $(K8S_DIR) -name '*.yaml' | sed 's:$(K8S_DIR)/::g')

LINKS ?= $(shell base64 $(CSV_INPUT_FILE))

MAKE_ENV += PACKAGE VERSION DOCKER_IMAGE DOCKER_IMAGE_DOMAIN NAMESPACE HOST_NAME

SHELL_EXPORT := $(foreach v,$(MAKE_ENV),$(v)='$($(v))' )

EXPOSED_PORT ?= 8080

.PHONY: build
build:
	docker build . -t "$(DOCKER_IMAGE)"

.PHONY: push
push: build-docker
	docker push "$(DOCKER_IMAGE)"

.PHONY: run
run:
	docker run -d --name $(CONTAINER_NAME) -e LINKS=$(LINKS) -e DEFAULT_REDIRECT=$(DEFAULT_REDIRECT) -p $(EXPOSED_PORT):80 $(DOCKER_IMAGE)

.PHONY: rm
rm:
	docker rm -f "$(CONTAINER_NAME)" | true

.PHONY: clean
clean:
	rm -rf $(K8S_BUILD_DIR)

.PHONY: logs
logs:
	docker logs -f "$(CONTAINER_NAME)"

.PHONY: all
all: rm build run logs

$(K8S_BUILD_DIR):
	@mkdir -p $(K8S_BUILD_DIR)

.PHONY: build-k8s
build-k8s: $(K8S_BUILD_DIR)
	@for file in $(K8S_FILES); do \
		mkdir -p `dirname "$(K8S_BUILD_DIR)/$$file"` ; \
		$(SHELL_EXPORT) envsubst <$(K8S_DIR)/$$file >$(K8S_BUILD_DIR)/$$file ;\
	done

.PHONY: deploy
deploy: build-k8s push
	kubectl apply -f $(K8S_BUILD_DIR)
