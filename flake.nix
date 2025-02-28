{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-non-flake = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
      flake  = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-non-flake, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        version = "0.15.1-patched";

        nixpkgs-patched = (nixpkgs.legacyPackages.${system}.applyPatches {
          name = "nixpkgs-patched";
          src = nixpkgs-non-flake;
          patches = [ ./nix/nixpkgs-package.patch ];
        });
        pkgs = import nixpkgs-patched {
          inherit system;
        };
      in
      {
        packages = rec {
          alacritty = (pkgs.callPackage "${nixpkgs-patched}/pkgs/by-name/al/alacritty/package.nix" { src = ./.; inherit version; });
          default = alacritty;
        };
        apps = rec {
          alacritty = flake-utils.lib.mkApp { drv = self.packages.${system}.alacritty; };
          default = alacritty;
        };
      }
    );
}
