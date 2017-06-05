DOCKER_IMAGE 		?= mazingstudio/nginx-pagespeed
DOCKER_INSTANCE ?= nginx-pagespeed

docker-build:
	docker build -t $(DOCKER_IMAGE) .

docker-run: docker-build
	(docker stop $(DOCKER_INSTANCE) || exit 0) && \
	(docker rm $(DOCKER_INSTANCE) || exit 0) && \
	docker run \
		-p 0.0.0.0:80:80 \
		-p 0.0.0.0:443:443 \
		-v $$PWD/etc/nginx/nginx.conf:/etc/nginx/nginx.conf \
		-v $$PWD/etc/nginx/conf.d:/etc/nginx/conf.d \
		-v $$PWD/etc/nginx/sites-enabled:/etc/nginx/sites-enabled \
		--name $(DOCKER_INSTANCE) \
		-t $(DOCKER_IMAGE) nginx

require-version:
	@if [[ -z "$$VERSION" ]]; then echo "Missing \$$VERSION"; exit 1; fi

docker-push: docker-build require-version
	docker tag $(DOCKER_IMAGE) $(DOCKER_IMAGE):$$VERSION && \
	docker push $(DOCKER_IMAGE):$$VERSION

