{
  description = "todomvc-nix – Full-stack Nix DevOps template (Rust primary)";

  # To update all inputs:
  # $ nix flake update --recreate-lock-file

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  # Haskell dependencies (kept to preserve original examples)
  inputs.polysemy = { url = "github:polysemy-research/polysemy"; flake = false; };
  inputs.http-media = { url = "github:zmthy/http-media/develop"; flake = false; };
  inputs.servant = { url = "github:haskell-servant/servant"; flake = false; };
  inputs.servant-jsaddle = { url = "github:haskell-servant/servant-jsaddle/master"; flake = false; };
  inputs.miso = { url = "github:dmjio/miso/master"; flake = false; };

  outputs = { self, nixpkgs, flake-utils, polysemy, http-media, servant, miso, servant-jsaddle }:
    {
      overlay = import ./overlay.nix { inherit polysemy http-media servant miso servant-jsaddle; };
    } // (
      flake-utils.lib.eachSystem [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ] (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlay ];
            config = { allowBroken = true; };
          };

          # Shortcuts to existing packages from overlay
          rustBackend = pkgs.todomvc.nix.rustBackend;
          rustFrontend = pkgs.todomvc.nix.rustFrontend;

          # Minimal Docker image (Linux only) for the Rust backend
          rustBackendImage = pkgs.lib.optionalAttrs pkgs.stdenv.isLinux (
            let
              launcher = pkgs.writeScriptBin "run-backend" ''
                #!${pkgs.bash}/bin/bash
                exec ${rustBackend}/bin/rust-backend
              '';
            in pkgs.dockerTools.buildImage {
              name = "todomvc-rust-backend";
              tag = "latest";
              copyToRoot = [ launcher rustBackend ];
              config = {
                Env = [
                  "BIND_ADDR=0.0.0.0:8080"
                  "RUST_LOG=info"
                ];
                ExposedPorts = { "8080/tcp" = { }; };
                Cmd = [ "/bin/run-backend" ];
              };
            }
          );
        in
        {
          legacyPackages = pkgs.todomvc;

          packages = {
            rust-backend = rustBackend;
            rust-frontend = rustFrontend;
            default = rustBackend;
          } // pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
            rust-backend-image = rustBackendImage;
          };

          devShells = {
            default = pkgs.mkShell {
              packages = with pkgs; [
                git jq gnumake
                rustc cargo
                nodejs yarn
                docker docker-compose
                kubectl kustomize helm
                postgresql
                terraform tflint
              ];
              shellHook = ''
                echo "[todomvc] Dev shell ready: git jq make rustc cargo node yarn docker k8s psql terraform"
              '';
            };
          };

          checks = { };
        })
    );
}
