{ config, pkgs, lib, modulesPath, ... }:
with lib; {

  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  config = {

    # Filesystems
    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      autoResize = true;
    };

    # Bootloader
    boot.growPartition = true;
    boot.kernelParams = [ "console=ttyS0" ];
    boot.loader.grub.device = "/dev/vda";
    boot.loader.timeout = 0;

    # Locale settings
    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      keyMap = "us";
    };

    # Openssh
    programs.ssh.startAgent = false;
    services.openssh = {
      enable = true;
      passwordAuthentication = false;
      startWhenNeeded = true;
      challengeResponseAuthentication = false;
      permitRootLogin = "yes";
    };

    # Enable flakes
    nix.package = pkgs.nixFlakes;

    # Install some basic utilities
    environment.systemPackages = [ pkgs.git pkgs.ag pkgs.htop ];

    # Let 'nixos-version --json' know about the Git revision
    # of this flake.
    # system.configurationRevision = pkgs.lib.mkIf (self ? rev) self.rev;

    # TODO set hostname
    # Hostname, should match the flake output name
    networking.hostName = "my-host";


    # Users/SSH-keys to add. Make sure to authorize the CI secret key in order
    # to be able to use automatic deployments.
    users = {

    # TODO set keys
      users.root = {

        # Include public key as a string
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGFfAWbxcmVv1Xby3geOKhVTY65RH8TB46CAjFkps/Ni"
        ];

        # Or pull them from a URL
        openssh.authorizedKeys.keyFiles = [
          (pkgs.fetchurl {
            url = "https://github.com/pinpox.keys";
            sha256 = "sha256-Cf/PSZemROU/Y0EEnr6A+FXE0M3+Kso5VqJgomGST/U=";
          })
        ];
      };
    };
  };
}
