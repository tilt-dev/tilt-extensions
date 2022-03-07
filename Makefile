.PHONY: test publish-ci-image

test:
	./test.sh

publish-ci-image:
	docker build --pull --platform linux/amd64 -t gcr.io/windmill-public-containers/tilt-extensions-ci -f .circleci/Dockerfile .circleci
	docker push gcr.io/windmill-public-containers/tilt-extensions-ci

shellcheck:
	find . -type f -name '*.sh' -not -path "*/node_modules/*" -not -path "*/.git-sources/*" -not -path "*/.git/*" -exec \
    docker run --rm -it -e SHELLCHECK_OPTS="-e SC2001" -v $$(pwd):/mnt nlknguyen/alpine-shellcheck {} \;
