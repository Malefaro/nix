# Installation

1. install nix
2. install home-manager: [instruction](https://nix-community.github.io/home-manager/index.html#sec-install-standalone)
3. link this dir to `~/.config/nixpkgs`
4. run `home-manager switch`
5. install vim-plug:
```
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```
6. Run `:PlugInstall` after nvim launch
