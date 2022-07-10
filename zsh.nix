{ config, pkgs, lib, ... }:
{
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

        export POWERLEVEL9K_MODE="nerdfont-complete"
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
}
