{ pkgs }:
{
  haskellBackend = pkgs.callPackage ./haskell-backend { };
  haskellFrontend = pkgs.callPackage ./haskell-frontend { };
  rustBackend = pkgs.callPackage ./rust-backend { };
  rustFrontend = pkgs.callPackage ./rust-frontend { };
  database = pkgs.callPackage ./database { };
}
