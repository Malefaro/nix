{ config, pkgs, ... }:

{
  home = {
    # ...
    packages = with pkgs; [
      neovim
      git
      ripgrep
      tmux
      alacritty
    ];
  };
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "developer";
  home.homeDirectory = "/Users/developer";

  xdg.configFile.nvim = {
    source = ./config/nvim;
    recursive = true;
  };
  xdg.configFile.tmux = {
    source = ./config/tmux;
    recursive = true;
  };
  xdg.configFile.alacritty = {
    source = ./config/alacritty;
    recursive = true;
  };
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  # programs.zsh.enable = true;
  programs.git = {
    enable = true;
    userName = "Danil Anokhin";
    userEmail = "malefaro@gmail.com";
    aliases = {
      prettylog = "...";
    };
    extraConfig = {
      core = {
        editor = "nvim";
      };
      color = {
        ui = true;
      };
      # push = {
      #   default = "simple";
      # };
      # pull = {
      #   ff = "only";
      # };
      # init = {
      #   defaultBranch = "main";
      # };
    };
    ignores = [
      ".DS_Store"
      "*.pyc"
    ];
  };
}
