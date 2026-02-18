{
  description = "NixOS configurations for frost, tatsu, and custom ISO";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";

      mkMachine =
        hostname:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            { networking.hostName = hostname; }
            ./modules/common.nix
            ./machines/${hostname}/default.nix
          ];
        };

      isoConfig =
        { pkgs, ... }:
        {
          users.users.root.openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOEPMl3fFGeNzvprnt5kWBfa9dRahnYCsbD8TNM3i0Jf"
          ];
          environment.systemPackages = [ pkgs.vim ];
          isoImage.squashfsCompression = "zstd -Xcompression-level 6";
        };
    in
    {
      nixosConfigurations = {
        frost = mkMachine "frost";
        tatsu = mkMachine "tatsu";

        minimal-installer = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            isoConfig
          ];
        };
      };

      packages.${system} = {
        minimal-iso = self.nixosConfigurations.minimal-installer.config.system.build.isoImage;
      };
    };
}
