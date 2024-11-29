SHELL := /bin/bash -o pipefail -o errexit

test:
	./test.sh

publish-ci-image:
	docker buildx build --push --pull --platform linux/amd64 -t docker/tilt-extensions-ci -f .circleci/Dockerfile .circleci

shellcheck:
	LINT_ERRORS=0; \
	IFS=$$'\n'; for shellscript in $$(git ls-files -z | xargs -0 file | grep "shell script" | cut -d: -f1 || echo ""); do \
	   docker run --rm -v "$$PWD:/mnt" koalaman/shellcheck:stable "$${shellscript}" || LINT_ERRORS=$$((LINT_ERRORS+1)); \
	done; \
	exit "$${LINT_ERRORS}"

.PHONY: $(MAKECMDGOALS)
