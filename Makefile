PYTHON:=venv/bin/python
PIP:=venv/bin/pip
PYTEST:=venv/bin/py.test
COV:=venv/bin/coverage
REGISTRY?=ghcr.io
IMAGE_NAME?=elekto-dev/elekto

.PHONY: clean venv version run test cov test-build test-docker image push-image image-release

clean:
	rm -rf venv

venv: clean
	python3.11 -m venv venv
	$(PIP) install -e .
	$(PIP) install -r requirements.txt

version:
	$(PYTHON) -c "from elekto.version import __version__; print(__version__)"

run:
	$(PYTHON) console --run

test:
	$(PYTEST) test

cov:
	$(COV) run -m pytest test || true
	$(COV) html
	open htmlcov/index.html

image:
	docker build -t $(REGISTRY)/$(IMAGE_NAME):latest .

push-image: image
	$(eval VERSION := $(shell $(MAKE) --quiet version))
	docker tag $(REGISTRY)/$(IMAGE_NAME):latest $(REGISTRY)/$(IMAGE_NAME):$(VERSION)
	docker push $(REGISTRY)/$(IMAGE_NAME):$(VERSION)

image-release: image
	$(eval VERSION := $(shell $(MAKE) --quiet version))
	docker tag $(REGISTRY)/$(IMAGE_NAME):latest $(REGISTRY)/$(IMAGE_NAME):$(VERSION)
	docker tag $(REGISTRY)/$(IMAGE_NAME):latest $(REGISTRY)/$(IMAGE_NAME):latest
	docker push $(REGISTRY)/$(IMAGE_NAME):$(VERSION)
	docker push $(REGISTRY)/$(IMAGE_NAME):latest

test-build:
	docker build . -t elekto-test --target test

test-docker: test-build
	docker run -it --rm --entrypoint=./test-entrypoint.sh elekto-test

test-docker-notty: test-build
	docker run --rm --entrypoint=./test-entrypoint.sh elekto-test
