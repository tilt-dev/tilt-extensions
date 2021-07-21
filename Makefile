.PHONY: test publish-ci-image

test:
	./test.sh

publish-ci-image:
	cd .circleci && docker build --pull -t tiltdev/tilt-extensions-ci .
	docker push tiltdev/tilt-extensions-ci

shellcheck:
	find . -type f -name '*.sh' -not -path "*/node_modules/*" -not -path "*/.git-sources/*" -exec \
    docker run --rm -it -e SHELLCHECK_OPTS="-e SC2001" -v $$(pwd):/mnt nlknguyen/alpine-shellcheck {} \;
