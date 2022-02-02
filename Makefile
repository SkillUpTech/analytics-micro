docker_registry ?= sktpub.azurecr.io/analytics-micro
am_version ?= latest
hadoop_services := hadoop/hdfs hadoop/pipeline hadoop/spark hadoop/hive-server
openedx_services := openedx/api openedx/insights
web_services := web/mysql web/nginx
compose := docker-compose -f docker-compose.yml -f docker-compose.pipeline.yml

# Services which depend on hadoop/base
hadoop_base_children := hadoop/hdfs hadoop/pipeline hadoop/hive-server

# Services which depend on openedx/base
openedx_base_children := openedx/api openedx/insights

# - Macros - #

# Generate the appropriate Docker image tag corresponding to the current target.
tag = $(patsubst services/%/.target,$(docker_registry)/%:$(am_version),$@)

# Execute the appropriate 'docker build' command for the current target.
docker_build = cd $(dir $@) && DOCKER_BUILDKIT=1 docker build --tag $(tag) .

# Generate the appropriate Docker image tag corresponding to the target to be pushed.
push_tag = $(patsubst services/%/.push,$(docker_registry)/%,$@)

# Execute 'docker push' on the current target. Pushes all tags.
docker_push = docker push -a $(push_tag)

# Copy each '.env.template' file under conf/ to create the corresponding '.env' configuration files. Has no effect if the '.env' file already exists.
init_templates = find conf/ -type f -name '*.template' -exec sh -xc 'cp --no-clobber -- $$1 $${1%.template}' 'make-init' '{}' \;

# Places a file named '.target' in each directory which contains a Dockerfile. The timestamp of the .target file is set to 1 second prior to that of the Dockerfile.
create_targets = find services/ -type f -name Dockerfile -exec sh -xc 'touch -d "$$(date -R -r $$1) - 1 second" $$(dirname "$$1")/.target' 'create-targets'  '{}' \;

# Deletes all files named '.target' in the 'services' directory.
destroy_targets = find services/ -type f -name .target -delete

# Function which accepts an abbreviated target name (ex: 'openedx/insights') and produces the corresponding target path (ex: 'services/openedx/insights/.target').
as_targets = $(patsubst %,services/%/.target,$1)

# Function which accepts an abbreviated target name (ex: 'openedx/insights') and produces the corresponding 'push' target (ex: 'services/openedx/insights/.push').
as_push = $(patsubst %,services/%/.push,$1)

# - Convenience variables - #

all_services := $(call as_targets,$(hadoop_services) $(openedx_services) $(web_services))

SHELL := /bin/bash

# Targets
.PHONY: help build init up hadoop-tasks down logs dev force-rebuild destroy

help:
	@echo "-- Available commands --"
	@echo "make build             Build all images locally as needed."
	@echo "make init              Generate target files and default .env files in $$(realpath ./conf/) as needed."
	@echo "make up                Start and detach from the non-hadoop services, then follow the log stream."
	@echo "make hadoop-tasks      Start the hadoop services, then update the insights data."
	@echo "make down              Stop all services and remove containers."
	@echo "make logs              Follow the log streams of all running services."
	@echo "make dev               Equivalent to running 'init' then 'build'"
	@echo "make force-rebuild     Destroy and recreate all target files, then run 'make build'"
	@echo "make format-namenode   WARNING: Format the HDFS NameNode (loses all data)."
	@echo "make destroy           WARNING: Destroys all containers AND VOLUMES!"
	@echo "make shell.SERVICE     Launch and attach a one-off shell container for the given SERVICE name."
	@echo "make exec.SERVICE      Attach a bash shell directly to a live SERVICE by name."
	@echo "make start.SERVICE     Launch a one-off instance of SERVICE after bringing up its dependencies."

init:
	$(init_templates)
	$(create_targets)

up:
	$(compose) up --detach nginx
	$(compose) logs --tail 0 --follow

hadoop-tasks:
	$(compose) run --detach pipeline
	$(compose) logs --tail 0 --follow

down:
	$(compose) down

logs:
	$(compose) logs --tail 0 --follow

dev: init build

build: $(all_services)

force-rebuild:
	$(destroy_targets)
	$(create_targets)
	$(MAKE) build

format-namenode:
	$(compose) run namenode format

destroy:
	$(compose) down -v
	
shell.%:
	$(compose) run --rm --entrypoint /usr/bin/env $(patsubst shell.%,%,$@) bash

exec.%:
	docker exec -it analytics-micro_$(patsubst exec.%,%,$@)_1 bash

start.%:
	$(compose) run --rm $(patsubst start.%,%,$@)

push: $(call as_push,$(hadoop_services) $(openedx_services) $(web_services))

%/.push:
	$(docker_push)

$(call as_targets,web/nginx): $(call as_targets,openedx/insights openedx/api)

$(call as_targets,openedx/insights openedx/api hadoop/base hadoop/pipeline): services/util/.target

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
