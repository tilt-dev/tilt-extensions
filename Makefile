SHELL := /bin/bash -o pipefail -o errexit

test:
	./test.sh

publish-ci-image:
	./publish-ci-image.sh

pre-commit:
	pre-commit run --verbose --show-diff-on-failure --color=always --all-files

.PHONY: $(MAKECMDGOALS)
