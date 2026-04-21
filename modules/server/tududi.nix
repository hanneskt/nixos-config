{
  config,
  lib,
  ...
}:

let
  cfg = config.myServices.tududi;
in
{
  options.myServices.tududi = {
    enable = lib.mkEnableOption "Tududi wrapper";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "todo.klinckaert.be";
    };

    envFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the agenix secret file containing TUDUDI_USER_EMAIL, TUDUDI_USER_PASSWORD, and TUDUDI_SESSION_SECRET.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 21069;
      description = "Local port to bind the container to.";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/tududi";
      description = "Path on the host machine to store the database and uploads.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}/db' 0750 1001 1001 - -"
      "d '${cfg.dataDir}/uploads' 0750 1001 1001 - -"
    ];

    virtualisation.oci-containers.containers."tududi" = {
      image = "chrisvel/tududi:latest";

      environmentFiles = [ cfg.envFile ];

      environment = {
        TUDUDI_ALLOWED_ORIGINS = "https://${cfg.domain}";
        PUID = "1001";
        GUID = "1001";
      };

      ports = [ "127.0.0.1:${toString cfg.port}:3002" ];

      volumes = [
        "${cfg.dataDir}/db:/app/backend/db"
        "${cfg.dataDir}/uploads:/app/backend/uploads"
      ];
    };

    services.caddy = {
      enable = true;
      virtualHosts."${cfg.domain}".extraConfig = ''
        reverse_proxy 127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
