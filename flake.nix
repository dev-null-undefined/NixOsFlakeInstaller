{
  description = "NixosFlakeInstaller";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    dotfiles-config = { 
      url = "github:dev-null-undefined/DotFiles";
      flake = false;
    };
    nixos-config = {
      url = "github:dev-null-undefined/NixOs";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, dotfiles-config, nixos-config }: {
    nixosConfigurations = let
      # Shared base configuration.
      base = {
        system = "x86_64-linux";
        modules = [
          # Common system modules...
        ];
      };
      airGapped = false;
      secure = false;
    in with nixpkgs.lib; {
      iso = nixpkgs.lib.nixosSystem {
        inherit (base) system;

        specialArgs = { inherit dotfiles-config nixos-config; };

        modules = base.modules ++ [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-plasma5.nix"
          ./configuration.nix
          ./gpg.nix
          ./sshd.nix
          ./fonts.nix
        ] ++ optional (airGapped) ./airgapped.nix
          ++ optional (airGapped || secure) ./secure.nix;
      };
    };
  };
}
