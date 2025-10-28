# devenv.nix
# use: 'devenv shell' to shell
# use: 'devenv up' to  up services
# to automatic shell:
# use: echo "eval \"\$(devenv direnvrc)\"\nuse devenv " > .envrc
{
  pkgs,
  config,
  ...
}: {
  packages = [pkgs.nodePackages.npm];
  languages.php = {
    enable = true;
    version = "8.2";
    ini = ''
      memory_limit = 256M
    '';
    fpm.pools.web = {
      settings = {
        "pm" = "dynamic";
        "pm.max_children" = 5;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 1;
        "pm.max_spare_servers" = 5;
      };
    };
  };

  services.caddy.enable = true;
  services.caddy.virtualHosts.":8080" = {
    extraConfig = ''
      root * .
      php_fastcgi unix/${config.languages.php.fpm.pools.web.socket}
      file_server browse
    '';
  };
  enterShell = ''
    if [[ ! -d node_modules ]]; then
        npm install
    fi
  '';
}
