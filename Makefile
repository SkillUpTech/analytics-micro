docker_registry ?= skt-pub.azurecr.io/analytics-micro
am_version ?= latest
hadoop_services := hadoop/hdfs hadoop/pipeline hadoop/spark
openedx_services := openedx/api openedx/insights
web_services := web/mysql web/nginx

# Services which depend on hadoop/base
hadoop_base_children := hadoop/hdfs hadoop/pipeline

# Services which depend on openedx/base
openedx_base_children := openedx/api openedx/insights

# Macros
tag = $(patsubst services/%/.target,$(docker_registry)/%:$(am_version),$@)
docker_build = cd $(dir $@) && DOCKER_BUILDKIT=1 docker build --tag $(tag) .
as_targets = $(patsubst %,services/%/.target,$1)

# Convenience variables
all_services := $(call as_targets,$(hadoop_services)) $(call as_targets,$(openedx_services)) $(call as_targets,$(web_services))

SHELL := /bin/bash

# Targets
.PHONY: default up logs

help:
	@echo "-- Available commands --"
	@echo "make build     Build all images locally as needed."
	@echo "make init      Generate default .env files in $$(realpath ./conf/) as needed."
	@echo "make up        Start and detach from all services, then follow the log stream."
	@echo "make logs      Follow the log streams of all running services."
	@echo "make dev       Equivalent to running 'build' then 'init'"

init:
	find conf/ -type f -name '*.template' -exec sh -c 'set -x; cp --no-clobber -- $$0 $${0%.template}' '{}' \;

up:
	docker-compose up --detach
	docker-compose logs --tail 0 --follow

logs:
	docker-compose logs --tail 0 --follow

dev: build init

build: $(call as_targets,$(hadoop_services)) $(call as_targets,$(openedx_services)) $(call as_targets,$(web_services))

$(all_services): services/util/.target

$(call as_targets,$(hadoop_base_children)): services/hadoop/base/.target

$(call as_targets,$(openedx_base_children)): services/openedx/base/.target

.SECONDEXPANSION:

# Causes all '.target' targets to recursively depend on all files in their parent directories.
# If they only depended on "%/Dockerfile", the target wouldn't rebuild if, say, a script
# were modified but the Dockerfile remained the same. We skip the README (if applicable) and empty files
# (such as the .target file itself). Subdirectories are also depended upon to detect when a file is removed.
%/.target: $$(shell find % -not \( -name README.md -or -empty \))
	$(docker_build)
	touch $@
