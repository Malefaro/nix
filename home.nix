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
      alacritty
      direnv
      gopls
      universal-ctags
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
  ];

  xdg.configFile."nvim/lua" = {
    source = ./config/nvim/lua;
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

  programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      oh-my-zsh = {
        enable = true;
        plugins = [
          "web-search"
          "jsontools"
        ];
        theme = "agnoster";
      };
      plugins = [
        {
          name = "zsh-syntax-highlighting";
          src = pkgs.fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-syntax-highlighting";
            rev = "2d60a47cc407117815a1d7b331ef226aa400a344";
            sha256 = "1pnxr39cayhsvggxihsfa3rqys8rr2pag3ddil01w96kw84z4id2";
          };
        }
      ];
      localVariables = {
        EDITOR = "nvim";
      };
      initExtra = ''
        unset LESS

        export DEBUG=true
        export LOG_LEVEL=debug
        source $HOME/.profile
        export PATH=$PATH:/usr/local/go/bin
        export GOPATH=~/GoLang
        export GOBIN=$GOPATH/bin
        export GOPROXY=""
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)"
        eval "$(pyenv init --path)"

        export PATH="$HOME/.poetry/bin:$PATH"
        export PATH="$GOBIN:$PATH"
        export PATH="$HOME/.local/bin:$PATH"

        eval "$(op completion zsh)"; compdef _op op
        eval "$(direnv hook zsh)"

        alias hms="home-manager switch"

        source $HOME/.exports
        . "$HOME/.cargo/env"
      '';
  };
  programs.tmux = {
    enable = true;
    extraConfig = (lib.strings.fileContents ./config/tmux/tmux.conf);
    baseIndex = 1;
    keyMode = "vi";
    terminal = "xterm-256color";
    plugins = [
        {
			plugin = pkgs.tmuxPlugins.dracula;
			extraConfig = ''
set -g @dracula-refresh-rate 1
set -g @dracula-show-fahrenheit false
set -g @dracula-plugins "cpu-usage ram-usage time"
set -g @dracula-cpu-usage true
set -g @dracula-ram-usage true
set -g @dracula-show-left-icon session
set -g @dracula-cpu-display-load true
# powerline
set -g @dracula-show-powerline true
set -g @dracula-show-left-sep 
set -g @dracula-show-right-sep 
# time
set -g @dracula-military-time true
set -g @dracula-day-month true
set -g @dracula-show-timezone false
			'';
		}
    ];
  };
}
