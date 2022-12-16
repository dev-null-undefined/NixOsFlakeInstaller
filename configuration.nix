{ config, pkgs, ... }:

let
  owner = "dev-null-undefined";
  DotFiles = pkgs.fetchFromGitHub {
    inherit owner;
    repo = "DotFiles";
    rev = "master";
    sha256 = "sha256-LnHmnltdfyLyZqDiHm44B3OObQ9ifCE2szki+pQWPj0=";
  };
  DotFilesDependecies = with pkgs; [
    # ZSH
    # ------
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions

    # Cat with syntax highlight
    bat

    # fuzzy finders
    fzf
    broot

    # Better ls
    lsd
    python3

    # Flex spec sharing Utilities
    screenfetch
    neofetch
    cpufetch
    macchina
    # ------

    # TMUX
    # ------
    tmux
    # ------

    # VIM
    # ------
    vim_configurable
    neovim
    # lsp server for nix
    nil
    # lsb server for C++
    ccls
    # ------
  ];

  NixOsConfig = pkgs.fetchFromGitHub {
    inherit owner;
    repo = "NixOs";
    rev = "master";
    sha256 = "sha256-YlpuuHfVxEd2w1GiedQJl3rM5xuql2DV+/i2l6G1xFs=";
  };
  NixOsDependecies = [ ];

  Dependecies = DotFilesDependecies ++ NixOsDependecies;

in {
  isoImage.isoBaseName = pkgs.lib.mkForce "nixos-${owner}";

  # use the latest Linux kernel
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  # Needed for https://github.com/NixOS/nixpkgs/issues/58959 latest kernel and ZFS suppport
  # boot.supportedFilesystems =
  #  pkgs.lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];

  # Setup ssh services for remote access
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
  users.users.nixos = {
    isNormalUser = true;
    shell = pkgs.zsh;
    useDefaultShell = false;
  };

  # Enable experimental flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs;
    [ gnupg wget tealdeer kitty ] ++ Dependecies;

  system.activationScripts.dotFilesInit = let
    userName = "nixos";
    homeDir = "/home/" + "${userName}/";
    gitdir = homeDir + "git/";
    DotFilesDir = gitdir + "DotFiles/";
    NixOsConfigDir = gitdir + "NixOs/";
  in ''
    mkdir -p ${DotFilesDir} ${NixOsConfigDir}
    #chown nixos ${DotFilesDir} ${NixOsConfigDir}

    cp -R ${DotFiles}/{,.[^.],..?}* ${DotFilesDir}
    cp -R ${NixOsConfig}/{,.[^.],..?}* ${NixOsConfigDir}
    echo 'magic() { rm ~/.zshrc && ${DotFilesDir}/scripts/copy_configs_reverse && ${DotFilesDir}/install.sh }' >> ${homeDir}/.zshrc
  '';

  # speed up image creation time by using lower compression level
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";
}

