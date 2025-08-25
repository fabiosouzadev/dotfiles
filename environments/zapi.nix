# use:
# `nix develop .#python36 -c $SHELL`
{
  description = "Python Flake Shells";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    # This bad boy is the last one to support 3.6
    nixpkgs-python36.url = "nixpkgs/nixos-21.05";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs-python36 = import inputs.nixpkgs-python36 {inherit system;};
    pyPackages = with pkgs-python36; [
      (
        python36.withPackages (
          pkgspy:
            with pkgspy; [
              python
              venvShellHook
              pip
              setuptools
              wheel
              pre-commit
              virtualenv
              psycopg2
            ]
        )
      )
    ];
  in {
    devShells.x86_64-linux.python36 = pkgs-python36.mkShell {
      buildInputs = with pkgs-python36; [
        pyPackages
        curl
        gcc
        openssl
        postgresql
        libffi
        libxml2
        libxslt
        zlib
      ];
      shellHook = ''
        virtualenv venv &&. venv/bin/activate
        pip install -r requirements.txt
      '';
    };
  };
}
