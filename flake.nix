{
  description = "image";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;
  };

  outputs = { self, ... }@inputs:
    with inputs;
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
      };

      lib = nixpkgs.lib;
    in {
      # nix build '.#qcow2-image'
      # See for further options:
      # https://github.com/NixOS/nixpkgs/blob/master/nixos/lib/make-disk-image.nix
      qcow2-image = import "${nixpkgs}/nixos/lib/make-disk-image.nix" {
        config = (nixpkgs.lib.nixosSystem {
          inherit lib pkgs system;
          modules = [ ./configuration.nix ];
        }).config;

        inherit pkgs lib;
        format = "qcow2";
        diskSize = 4096;
      };
    };
}
