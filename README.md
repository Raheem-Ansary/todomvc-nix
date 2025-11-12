# Nix-powered full‑stack DevOps template (Rust, Docker, K8s, CI/CD)

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

This fork of nix-community/todomvc-nix is curated as a clean, modern full‑stack Nix + DevOps template focused on a Rust stack, while preserving the original examples (including Haskell) as references.

Use it as a reproducible starting point for personal projects, startups, and learning — with Nix flakes, Docker images, Kubernetes manifests, a DevOps‑friendly dev shell, and CI ready to go.

Related: original write‑up – [todomvc-nix: One-Stop Solution for Developing Projects Using Nix](https://numtide.com/articles/todomvc-nix-rejuvenation/)

## Overview
- Primary stack: Rust backend (`rust/backend`), Rust WASM frontend (`rust/frontend`), Postgres.
- Reproducible dev environments with `nix develop`.
- `nix build` packages for backend, frontend, and a Nix-built backend Docker image (Linux).
- Dockerfiles + docker-compose for local demos.
- Kubernetes manifests in `k8s/` (cloud‑agnostic).
- GitHub Actions CI builds and checks flakes.
- Haskell backend/frontend kept as optional references; Rust is the recommended path.

## Tech Stack
- Backend: Rust (tide, sqlx)
- Frontend: Rust (wasm-pack, rollup)
- Database: Postgres
- Nix: flakes, devShells, dockerTools
- DevOps: Docker, docker-compose, kubectl, helm, kustomize, OpenTofu (tofu), GitHub Actions

## Quick Start (Nix)
1) Enter the dev shell
- `nix develop`

2) Build artifacts
- Backend: `nix build .#packages.x86_64-linux.rust-backend`
- Frontend: `nix build .#packages.x86_64-linux.rust-frontend` (static bundle under `result/`)

3) Run locally (compose)
- Ensure Docker is running
- `docker-compose up --build`
  - Backend: http://localhost:8185 (readiness: `/health`)
  - Frontend: http://localhost:8080 (optional static server)

Environment defaults used by shell/compose:
- `DATABASE_URL=postgresql://todomvc_dbuser:todomvc_dbpass@localhost:5432/todomvc_db`
- `BIND_ADDR=127.0.0.1:8185` (container overrides to `0.0.0.0:8185`)

## Docker
- Backend image (Nix): `nix build .#packages.x86_64-linux.rust-backend-image` (Linux only)
- Classic Dockerfile (multi‑stage): `rust/backend/Dockerfile.backend`
- Optional frontend container: `rust/frontend/Dockerfile.frontend` (expects prebuilt assets)

## Kubernetes
- Apply: `kubectl apply -f k8s/`
- Resources:
  - `k8s/backend-deployment.yaml` (replicas=2, probes on `/health`, port 8185)
  - `k8s/backend-service.yaml` (ClusterIP:80 -> 8185)
- Configure the image (placeholder): `your-docker-username/todomvc-rust-backend:latest`.
- Provide a `Secret` named `todomvc-database` with key `url` for `DATABASE_URL`.

## CI/CD
- GitHub Actions
  - Flake checks: `.github/workflows/nix-flake.yml`
  - CI build: `.github/workflows/ci.yml` (nix develop check, build backend/frontend, optional Nix Docker image)
- Optional Docker push: set `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` secrets.

## Make Targets
- `make dev` – enter dev shell
- `make build-backend` – build Rust backend
- `make build-frontend` – build Rust frontend bundle
- `make docker-backend` – build classic Docker image
- `make nix-docker-backend` – build Docker image via Nix
- `make k8s-apply` / `make k8s-delete` – manage manifests

## IaC: OpenTofu (tofu)
- This template uses OpenTofu (tofu), the community‑driven fork of Terraform.
- OpenTofu avoids the recent unfree licensing; it is available as `opentofu` in nixpkgs and included in the dev shell.
- Basic usage examples:
  - `tofu init`
  - `tofu validate`
  - `tofu plan`
  - `tofu apply`

## Structure
- Rust: `rust/backend`, `rust/frontend`, `rust/common`
- Haskell examples: `haskell/*` (kept as references)
- Nix: `flake.nix`, `nix/*`, `overlay.nix`, `devshell.nix` (legacy dev shell preserved as `devShells.haskell`)
- DevOps: `docker-compose.yml`, `k8s/*`, `.github/workflows/*`, `Makefile`

## Notes on Haskell Examples
Haskell backend/frontend remain available for learning and comparison. The recommended path for this template is the Rust stack. If something in the legacy examples is outdated, it is noted here rather than removed.

## Acknowledgements
Most code originated from the upstream project and community references. See [References.md](References.md).
