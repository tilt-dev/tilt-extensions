SHELL := /bin/bash -o pipefail -o errexit

test:
	./test.sh

publish-ci-image:
	docker buildx build --push --pull --platform linux/amd64 -t docker/tilt-extensions-ci -f .circleci/Dockerfile .circleci

pre-commit:
	pre-commit run --verbose --show-diff-on-failure --color=always --all-files

.PHONY: $(MAKECMDGOALS)
