SHELL := /bin/bash
-include .env
DOCKER_IMAGE_NAME ?= harbour-books
TAG ?= latest
export DOCKER_IMAGE_NAME
export TAG
.DEFAULT_GOAL := help
.PHONY: help lint build run push down logs

help:
	@echo "make lint - Check Dockerfile"
	@echo "make build - Build Docker Image (depends on lint)"
	@echo "make run - Start Docker containers"
	@echo "make push - Push Docker Image to ECR"
	@echo "make down - Stop Docker container"

lint:
	docker run --rm -i hadolint/hadolint < app/Dockerfile || true
build: lint
	docker build -t $(DOCKER_IMAGE_NAME):$(TAG) app
run:
	docker compose -f app/compose.yml up -d --wait --wait-timeout 60
push:
	docker push $(DOCKER_IMAGE_NAME):$(TAG)
down:
	docker compose down --remove-orphans
logs:
	docker compose logs -f