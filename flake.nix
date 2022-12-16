{
  description = "NixosFlakeInstaller";
  inputs.nixos.url = "github:nixos/nixpkgs/nixos-unstable";
  outputs = { self, nixos }: {
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
    in {
      iso = nixos.lib.nixosSystem {
        inherit (base) system;
        modules = base.modules ++ [
          "${nixos}/nixos/modules/installer/cd-dvd/installation-cd-graphical-plasma5.nix"
          ./configuration.nix
          ./gpg.nix
          ./sshd.nix
          ./fonts.nix
        ] ++ nixos.lib.optional (airGapped) ./airgapped.nix
          ++ nixos.lib.optional (airGapped || secure) ./secure.nix;
      };
    };
  };
}
