
# List of available projects
PROJECTS := wheel

# Folders to keep during web server cleanup
FOLDER_TO_KEEP := .well-known cgi-bin resources

# Internal variables
BASE_FOLDER := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
WEB_BUILD_FOLDER := build/web

# Make targets
.PHONY: all list $(PROJECTS)

all: list

list:
	@echo "Available projects:"
	@for project in $(PROJECTS); do \
		echo "  - $$project"; \
	done

wheel:
	@echo "Building WHEEL project..."; \
	cd $(BASE_FOLDER); \
	flutter clean; \
	flutter pub get; \
	flutter build web --release
	COMPILED_FOLDER=release/wheel; \
	if [ -z "$${COMPILED_FOLDER}" ]; then \
		echo "ERROR -- COMPILED_FOLDER is not found. Please check the build process."; \
		exit 1; \
	fi; \
	rm -rf $${COMPILED_FOLDER}; \
	mkdir -p $${COMPILED_FOLDER}; \
	cp -r $(WEB_BUILD_FOLDER)/. $${COMPILED_FOLDER} \
	# Make sure the authentication are provided (WHEEL_SSH_USER, WHEEL_SSH_SERVER, WHEEL_SSH_FOLDER_MAIN) \
	if [ -z "$${WHEEL_SSH_USER}" ] || [ -z "$${WHEEL_SSH_SERVER}" ] || [ -z "$${WHEEL_SSH_FOLDER_MAIN}" ]; then \
		echo "ERROR -- WHEEL_SSH_USER, WHEEL_SSH_SERVER, or WHEEL_SSH_FOLDER_MAIN is not set. Please set them before building."; \
		exit 1; \
	fi; \
	ssh $${WHEEL_SSH_USER}@$${WHEEL_SSH_SERVER} "cd $${WHEEL_SSH_FOLDER_MAIN} && find . $(addprefix ! -name ,$(FOLDER_TO_KEEP)) -delete"; \
	rsync -azvP $(BASE_FOLDER)/$${COMPILED_FOLDER}/ $${WHEEL_SSH_USER}@$${WHEEL_SSH_SERVER}:$${WHEEL_SSH_FOLDER_MAIN}; \
	echo "Project built and sent successfully."

