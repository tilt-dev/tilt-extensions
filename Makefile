.PHONY: test publish-ci-image

test:
	./test.sh

publish-ci-image:
	cd .circleci && docker build --pull -t tiltdev/tilt-extensions-ci .
	docker push tiltdev/tilt-extensions-ci
