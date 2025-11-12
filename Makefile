SHELL := /bin/sh

# Detect or set the host system for flake attribute paths
SYSTEM ?= x86_64-linux

.PHONY: dev build-backend build-frontend docker-backend nix-docker-backend k8s-apply k8s-delete

dev:
    @nix develop

build-backend:
    @nix build .#packages.$(SYSTEM).rust-backend

build-frontend:
    @nix build .#packages.$(SYSTEM).rust-frontend
    @echo "Frontend bundle available under result/"

docker-backend:
	docker build -f rust/backend/Dockerfile.backend -t todomvc-rust-backend:local .

nix-docker-backend:
    @nix build .#packages.$(SYSTEM).rust-backend-image
    @echo "Image tar available at ./result"

k8s-apply:
	kubectl apply -f k8s/

k8s-delete:
	kubectl delete -f k8s/ --ignore-not-found
