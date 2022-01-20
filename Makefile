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

build: $(call as_targets,$(hadoop_services)) $(call as_targets,$(openedx_services)) $(call as_targets,$(web_services))

services/hadoop/base/.target: services/util/.target

$(call as_targets,$(hadoop_base_children)): services/hadoop/base/.target

$(call as_targets,$(openedx_base_children)): services/openedx/base/.target

.SECONDEXPANSION:

# Causes all '.target' targets to recursively depend on all files in their parent directories.
# If they only depended on "%/Dockerfile", the target wouldn't rebuild if, say, a script
# were modified but the Dockerfile remained the same. We skip the README (if applicable) and empty files
# (such as the .target file itself). Subdirectories are also depended upon in case a file is removed.
%/.target: $$(shell find % -not \( -name README.md -or -empty \))
	$(docker_build)
	touch $@
