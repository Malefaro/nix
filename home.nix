{ config, pkgs, ... }:

{

  fonts.fontconfig.enable = true;

  home = {
    packages = with pkgs; [
      zsh
      neovim
      git
      ripgrep
      tmux
      alacritty
      (nerdfonts.override {
        fonts = [
          "Hack"
        ];
      })
    ];
  };

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  imports = [
    ./user.nix
  ];

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
      # push = {
      #   default = "simple";
      # };
      pull = {
        rebase = false;
      };
      # init = {
      #   defaultBranch = "main";
      # };
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
#            "command-not-found"
#            "poetry"
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

        source $HOME/.profile
        export PATH=$PATH:/usr/local/go/bin
        export GOPATH=~/GoLang
        export GOBIN=$GOPATH/bin
        export GOPROXY=""
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)"
        eval "$(pyenv virtualenv-init -)"
        eval "$(pyenv init --path)"

        export PATH="$HOME/.poetry/bin:$PATH"
        export PATH="$GOBIN:$PATH"
        export PATH="$HOME/.local/bin:$PATH"

        eval "$(op completion zsh)"; compdef _op op

        alias hms="home-manager switch"

        source $HOME/.exports
        . "$HOME/.cargo/env"
      '';
  };
}
