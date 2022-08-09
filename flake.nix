{
  description = "Multifetch: one fetch to rule them all";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-parts,
  }:
    flake-parts.lib.mkFlake {inherit self;} {
      systems = nixpkgs.lib.systems.flakeExposed;
      perSystem = {pkgs, ...}: {
        packages.default = pkgs.writeShellScriptBin "multifetch" ''
          fetchers=($(ls "${nixpkgs}/pkgs/tools/misc" | grep '.fetch'))
          for fetcher in "''${fetchers[@]}"; do
              nix run ${nixpkgs}#"$fetcher"
          done
        '';
      };
    };
}
