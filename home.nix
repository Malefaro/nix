{ config, pkgs, lib, ... }:

let
  overlayedPkgs = import <nixpkgs> {
    overlays = [
      (self: super: {
        neovim-unwrapped = super.neovim-unwrapped.overrideAttrs (_: rec {
          version = "0.6.0";
          src = pkgs.fetchFromGitHub {
            owner = "neovim";
            repo = "neovim";
            rev = "v0.6.0";
            sha256 = "sha256-mVVZiDjAsAs4PgC8lHf0Ro1uKJ4OKonoPtF59eUd888=";
          };
        # src = builtins.fetchTarball https://github.com/neovim/neovim/releases/download/v0.6.0/nvim-linux64.tar.gz;
        });
      })
    ];
  };
  extraPkgs = if pkgs.stdenv.isLinux then [pkgs.lldb] else [];
in
{

  fonts.fontconfig.enable = true;


  home = {
    packages = with pkgs; [
      zsh
      git
      ripgrep
      tmux
      # kitty
      direnv
      gopls
      universal-ctags
      go_1_18
      (nerdfonts.override {
        fonts = [
          "Hack"
          "JetBrainsMono"
        ];
      })
    ]++extraPkgs;
    # ];  ++ [overlayedPkgs.neovim];
  };

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  imports = [
    ./user.nix
    ./tmux.nix
    ./zsh.nix
  ];

  xdg.configFile."nvim/lua" = {
    source = ./config/nvim/lua;
    recursive = true;
  };
  xdg.configFile.kitty = {
    source = ./config/kitty;
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

  programs.neovim = {
    enable = true;
    # package = overlayedPkgs.neovim-unwrapped;
    extraConfig = (lib.strings.fileContents ./config/nvim/init.vim);
    plugins = with pkgs.vimPlugins; [
      vim-plug
    ];
  };

  programs.git = {
    enable = true;
    userName = "Danil Anokhin";
    userEmail = "malefaro@gmail.com";
    aliases = {
      prettylog = "...";
      st = "status";
      cm = "commit -m";
      a = "add";
    };
    extraConfig = {
      core = {
        editor = "nvim";
      };
      color = {
        ui = true;
      };
      pull = {
        rebase = false;
      };
    };
    ignores = [
      ".DS_Store"
      "*.pyc"
    ];
  };
}
