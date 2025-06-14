{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-wsl,
      home-manager,
      ...
    }@inputs:
    {

      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            nixos-wsl.nixosModules.default
            (
              {
                config,
                pkgs,
                inputs,
                ...
              }:
              {
                nix.settings.experimental-features = [
                  "nix-command"
                  "flakes"
                ];
                wsl.enable = true;
                wsl.defaultUser = "cysabi";

                # windows terminal fix
                environment.variables.COLORTERM = "truecolor";
                environment.variables.C = "/mnt/c/Users/cysabi";

                # vscode remote
                programs.nix-ld = {
                  enable = true;
                };

                # shell
                users.defaultUserShell = pkgs.fish;

                # packages
                environment.systemPackages = with pkgs; [
                  
                  # flakes
                  git
                  wget

                  # archives
                  zip
                  xz
                  unzip
                  p7zip

                  # networking tools
                  mtr # A network diagnostic tool
                  iperf3
                  dnsutils # `dig` + `nslookup`
                  ldns # replacement of `dig`, it provide the command `drill`
                  aria2 # A lightweight multi-protocol & multi-source command-line download utility
                  socat # replacement of openbsd-netcat
                  nmap # A utility for network discovery and security auditing
                  ipcalc # it is a calculator for the IPv4/v6 addresses

                  # misc
                  bat
                  fd
                  ripgrep
                  macchina
                  delta
                  file
                  which
                  gnused
                  gnutar
                  gawk
                  zstd
                  gnupg

                  # provides the command `nom` for more detailed log output
                  nix-output-monitor

                  bottom # replacement of htop/nmon
                  iotop # io monitoring
                  iftop # network monitoring

                  # system call monitoring
                  strace # system call monitoring
                  ltrace # library call monitoring
                  lsof # list open files

                  # system tools
                  sysstat
                  lm_sensors # for `sensors` command
                  ethtool
                  pciutils # lspci
                  usbutils # lsusb
                ];

                system.stateVersion = "25.05";
              }
            )
            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs.outPath = self.outPath;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.cysabi = {
                imports = [
                  ./cysabi.nix
                ];
              };
            }
          ];
        };
      };
    };
}
