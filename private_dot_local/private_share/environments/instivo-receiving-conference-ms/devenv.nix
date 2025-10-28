{pkgs, ...}: {
  # https://devenv.sh/basics/
  env = {
    GREET = "devenv";
    SHELL = "${pkgs.zsh}/bin/zsh";
    MONGO_DATABASE_URL = "mongodb://mongouser:secret@localhost:27017/admin";
    DATABASE_URL = "postgresql://fabiosouzadev:123@localhost:5432/receiving-conference?schema=public";
    # PRISMA_MIGRATION_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/migration-engine";
    # PRISMA_QUERY_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/query-engine";
    # PRISMA_QUERY_ENGINE_LIBRARY = "${pkgs.prisma-engines}/lib/libquery_engine.node";
    # PRISMA_INTROSPECTION_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/introspection-engine";
    # PRISMA_FMT_BINARY = "${pkgs.prisma-engines}/bin/prisma-fmt";

    NODE_PATH = "$DEVENV_ROOT/.nix-node";
    PATH = "$NODE_PATH/bin:$PATH";
    MONGO_DATA_DIR = "${toString ./.}/.devenv/mongodb-data";
  };

  # https://devenv.sh/packages/
  packages = with pkgs; [
    openssl
    postgresql
    nodePackages.npm
    # nodePackages.prisma
    # mongodb-ce
    mongosh # CLI para MongoDB
    gnumake # Para scripts de build
  ];

  # https://devenv.sh/languages/
  # languages.rust.enable = true;
  languages.javascript = with pkgs; {
    enable = true;
    package = nodejs;
    npm = {
      enable = true;
      install.enable = true;
    };
  };

  # https://devenv.sh/processes/
  # processes.cargo-watch.exec = "cargo-watch";
  process.managers.process-compose.settings = {
    availability = {
      backoff_seconds = 2;
      max_restarts = 2;
      restart = "on_failure";
    };
  };

  # https://devenv.sh/services/
  # services.postgres = {
  #   enable = true;
  #   listen_addresses = "*";
  #   initialDatabases = [
  #     {
  #       name = "receiving-conference";
  #     }
  #   ];
  #   # initialScript = builtins.readFile ./data/dump.sql;
  # };
  # services.adminer = {
  #   enable = true;
  #   listen = "127.0.0.1:8081";
  # };
  services.mongodb = with pkgs; {
    enable = true;
    package = mongodb-ce;
    initDatabaseUsername = "mongouser";
    initDatabasePassword = "secret";
  };

  # https://devenv.sh/scripts/
  scripts = {
    dev.exec = "npm run start:dev";
    dbreset.exec = "mongosh --eval 'db.getSiblingDB(\"nestapp\").dropDatabase()'";
    dbshell.exec = "mongosh $DATABASE_URL";
    # migrate.exec = "prisma migrate dev";
    # generate.exec = "prisma generate";
  };

  enterShell = ''
    echo 🦾
    echo 🦾 "=== Ambiente de Desenvolvimento Nest.js + MongoDB ==="
    echo 🦾 "Configurando ambiente..."
    echo 🦾

    echo "Serviços disponíveis:"
    echo "- MongoDB rodando em mongodb://localhost:27017"
    echo ""
    echo "Comandos disponíveis:"
    echo "dev      - Inicia servidor Nest.js (npm start:dev)"
    echo "dbreset  - Reseta banco de dados"
    echo "dbshell  - Acessa shell do MongoDB"
    echo "migrate  - Prisma Migrate"
    echo "generate - Prisma generate"
    echo ""
    echo "Acesse: http://localhost:8080/graphql para o Playground"

  '';

  # https://devenv.sh/tasks/
  tasks = {
    #   "myproj:setup".exec = "npm run start:dev";
    "myapp:install" = {
      exec = ''
        npm config set prefix $NODE_PATH
        npm install
      '';
      execIfModified = [
        "package.json"
      ];
    };
    # "myapp:migrate" = {
    #   description = "Runs prisma migrate dev";
    #   exec = "prisma migrate dev";
    # };
    # "myapp:generate" = {
    #   description = "Runs prisma generate";
    #   exec = "prisma generate";
    #   after = ["devenv:enterShell"];
    # };
  };

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';

  # https://devenv.sh/git-hooks/
  # git-hooks.hooks.shellcheck.enable = true;

  # See full reference at https://devenv.sh/reference/options/
  dotenv.enable = true;
}
