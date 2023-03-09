{
  description = "GitHub Action to require each commit in a PR to pass CI checks";

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    devenv.url = "github:cachix/devenv/latest";
    devshell.inputs.flake-utils.follows = "flake-utils";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    devshell.url = "github:numtide/devshell";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    devenv,
    devshell,
    flake-utils,
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [devshell.overlays.default];
        };

        # Generate a user-friendly version number.
        version = builtins.substring 0 8 self.lastModifiedDate;
      in rec {
        # Provide some binary packages for selected system types.
        packages = flake-utils.lib.flattenTree {
          each-commit-green = pkgs.buildGoModule {
            pname = "each-commit-green";
            inherit version;
            # In 'nix develop', we don't need a copy of the source tree
            # in the Nix store.
            src = ./.;
            vendorSha256 = "sha256-2lLwZWu0rLhiRMDk5vqF1RWL+DJyUdOQ2j/6U1E47FI=";
          };
        };
        defaultPackage = packages.each-commit-green;
        apps.each-commit-green = flake-utils.lib.mkApp {drv = packages.each-commit-green;};
        defaultApp = apps.each-commit-green;
        devShell = pkgs.devshell.mkShell {
          motd = "";
          packages = [devenv.packages.${system}.devenv];
        };
      }
    );
}
