{
  description = "A Nix-flake-based Node.js development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    # system should match the system you are running on
    system = "x86_64-linux";
  in {
    devShells."${system}".default = let
      pkgs = import nixpkgs {
        inherit system;
      };
    in
      pkgs.mkShell {
        # create an environment with nodejs_18, pnpm, and yarn
        packages = with pkgs; [
          nodejs_latest
          nodePackages.pnpm
          nodePackages.nodemon
          nodePackages.autoprefixer
          terser
          stylelint
          docker-compose
        ];

        shellHook = ''
          exec ${pkgs.nodejs_latest}/bin/npm run watch-css
        '';
      };
  };
}
