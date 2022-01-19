docker_registry ?= skt-pub.azurecr.io/analytics-micro
am_version ?= latest
hadoop_services := hadoop/hdfs hadoop/pipeline hadoop/spark
openedx_services := openedx/api openedx/insights

# Services which depend on hadoop/base
hadoop_base_children := hadoop/hdfs hadoop/pipeline

# Services which depend on openedx/base
openedx_base_children := openedx/api openedx/insights

# Macros
tag = $(patsubst services/%/.target,$(docker_registry)/%:$(am_version),$@)
docker_build = cd $(dir $@) && DOCKER_BUILDKIT=1 docker build --tag $(tag) .
as_targets = $(patsubst %,services/%/.target,$1)


build: $(call as_targets,$(hadoop_services)) $(call as_targets,$(openedx_services))

services/hadoop/base/.target: services/util/.target

$(call as_targets,$(hadoop_base_children)): services/hadoop/base/.target

$(call as_targets,$(openedx_base_children)): services/openedx/base/.target

%/.target: %/Dockerfile
	$(docker_build)
	touch $@
