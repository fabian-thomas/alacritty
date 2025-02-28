{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = rec {
          alacritty = (pkgs.callPackage ./package.nix { src = ./.; });
          default = alacritty;
        };
        apps = rec {
          alacritty = flake-utils.lib.mkApp { drv = self.packages.${system}.alacritty; };
          default = alacritty;
        };
      }
    );
}
