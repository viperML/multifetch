{
  description = "Multifetch: one fetch to rule them all";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      {
        packages.multifetch = pkgs.writeShellScriptBin "multifetch" ''
          fetchers=($(ls "${nixpkgs}/pkgs/tools/misc" | grep '.fetch'))
          for fetcher in "''${fetchers[@]}"; do
              nix run ${nixpkgs}#"$fetcher"
          done
        '';
        apps.multifetch = {
          type = "app";
          program = "${self.packages."${system}".multifetch}/bin/multifetch";
        };
        defaultApp = self.apps.${system}.multifetch;
      }
    );
}
