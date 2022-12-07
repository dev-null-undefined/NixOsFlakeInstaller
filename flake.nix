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
    in {
      iso = nixos.lib.nixosSystem {
        inherit (base) system;
        modules = base.modules ++ [
          "${nixos}/nixos/modules/installer/cd-dvd/installation-cd-graphical-plasma5.nix"
          ./configuration.nix
        ];
      };
    };
  };
}
