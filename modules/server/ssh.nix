{
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no"; # for root
    settings.PasswordAuthentication = false; # for other users
    openFirewall = true;
  };

  networking.firewall.logRefusedConnections = false;
  services.fail2ban = {
    enable = true;
    bantime = "12h";
    maxretry = 2;
    ignoreIP = [
      "127.0.0.0/8"
      "100.64.0.0/10"
    ];
  };

  security.sudo.wheelNeedsPassword = false;
  users.users.hannes.extraGroups = [ "docker" ];
}
