.PHONY: test publish-ci-image

test:
	./test.sh

publish-ci-image:
	docker buildx build --push --pull --platform linux/amd64 -t docker/tilt-extensions-ci -f .circleci/Dockerfile .circleci

shellcheck:
	find . -type f -name '*.sh' -not -path "*/node_modules/*" -not -path "*/.git-sources/*" -not -path "*/.git/*" -exec \
	    docker run --rm -it -e SHELLCHECK_OPTS="-e SC2001" -v $$(pwd):/mnt nlknguyen/alpine-shellcheck {} \;
