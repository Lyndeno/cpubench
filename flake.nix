{
  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    naersk.url = "github:nix-community/naersk";
    naersk.inputs.nixpkgs.follows = "nixpkgs";

    pre-commit-hooks-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
    };
  };

  outputs = {
    self,
    nixpkgs,
    utils,
    naersk,
    pre-commit-hooks-nix,
  }:
    utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages."${system}";
      naersk-lib = naersk.lib."${system}";
    in rec {
      packages.cpubench = naersk-lib.buildPackage {
        pname = "cpubench";
        root = ./.;
        buildInputs = [pkgs.libcpuid];
      };
      packages.default = packages.cpubench;

      apps.cpubench = utils.lib.mkApp {
        drv = packages.cpubench;
      };
      apps.default = apps.cpubench;

      formatter = pkgs.alejandra;

      devShells.default = let
        pre-commit-format = pre-commit-hooks-nix.lib.${system}.run {
          src = ./.;

          hooks = {
            alejandra.enable = true;
            rustfmt.enable = true;
          };
        };
      in
        pkgs.mkShell {
          nativeBuildInputs = with pkgs; [rustc cargo rustfmt libcpuid];
          RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
          shellHook = ''
            ${pre-commit-format.shellHook}
          '';
        };
    });
}
