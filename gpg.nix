{ pkgs, config, lib, ... }:
let
  xserverCfg = config.services.xserver;

  pinentryFlavour = if xserverCfg.desktopManager.lxqt.enable
  || xserverCfg.desktopManager.plasma5.enable then
    "qt"
  else if xserverCfg.desktopManager.xfce.enable then
    "gtk2"
  else if xserverCfg.enable || config.programs.sway.enable then
    "gnome3"
  else
    "curses";

  # Instead of hard-coding the pinentry program, chose the appropriate one
  # based on the environment of the image the user has chosen to build.
  gpg-agent-conf = pkgs.runCommand "gpg-agent.conf" { } ''
    echo "pinentry-program ${
      pkgs.pinentry.${pinentryFlavour}
    }/bin/pinentry" >> $out
  '';

in {
  # Unset history so it's never stored
  # Set GNUPGHOME to an ephemeral location and configure GPG with the
  # guide's recommended settings.
  environment.interactiveShellInit = ''
    unset HISTFILE
    export GNUPGHOME="/run/user/$(id -u)/gnupg"
    if [ ! -d "$GNUPGHOME" ]; then
      echo "Creating \$GNUPGHOME…"
      install --verbose -m=0700 --directory="$GNUPGHOME"
    fi
    [ ! -f "$GNUPGHOME/gpg-agent.conf" ] && cp --verbose ${gpg-agent-conf} "$GNUPGHOME/gpg-agent.conf"
    echo "\$GNUPGHOME is \"$GNUPGHOME\""
  '';

  # yubikey packages just in case
  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  # enable gpg if signing is needed
  programs = {
    ssh.startAgent = false;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

}
