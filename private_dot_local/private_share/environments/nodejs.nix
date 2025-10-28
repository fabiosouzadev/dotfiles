# use:
# `nix develop .#nodejs -c $SHELL`
{
  description = "Node Flake Shells";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in {
    devShells.x86_64-linux.nodejs = pkgs.mkShell {
      buildInputs = with pkgs; [
        nodejs
        nodePackages.npm
      ];
      shellHook = ''
        mkdir -p .nix-node
        export NODE_PATH=$PWD/.nix-node
        export PATH=$NODE_PATH/bin:$PATH
        npm config set prefix $NODE_PATH
      '';
    };
  };
}
