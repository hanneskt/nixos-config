{
  config,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./../../modules/server/ssh.nix
  ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  networking = {
    wireless = {
      enable = true;
      interfaces = [ "wlan0" ];
    };
    firewall = {
      extraCommands = ''
        iptables -t mangle -A PREROUTING -i wlan0 -j TTL --ttl-set 64
        iptables -t mangle -A FORWARD -i wlp1s0u1u3 -o wlan0 -j TTL --ttl-set 64
      '';
    };
  };
  hardware.bluetooth.enable = false;

  time.timeZone = "Europe/Brussels";
  users.users.hass.extraGroups = [ "dialout" ];

  # reduce SD writes
  services.journald.storage = "volatile";
  fileSystems."/tmp" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [
      "defaults"
      "size=512M"
      "mode=1777"
      "nosuid"
      "nodev"
    ];
  };
  fileSystems."/var/log" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [
      "defaults"
      "size=128M"
    ];
  };
  systemd.tmpfiles.rules = [
    "f ${config.services.home-assistant.configDir}/automations.yaml 0755 hass hass"
  ];

  services.create_ap = {
    enable = true;
    settings = {
      INTERNET_IFACE = "wlan0";
      WIFI_IFACE = "wlp1s0u1u4";
      SSID = "potato";
      PASSPHRASE = "ilikecheese";
    };
  };

  services.home-assistant = {
    enable = true;
    extraComponents = [
      "homeassistant_hardware"
      "airgradient"
      "zha" # zigbee
    ];
    config = {
      default_config = { };
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [
          "100.106.216.36"
        ];
        server_host = [ "0.0.0.0" ];
      };
      "automation ui" = "!include automations.yaml";
      "scene ui" = "!include scenes.yaml";
    };
  };

  services.tailscale = {
    enable = true;

  };
  system.stateVersion = "25.05";
}
