{
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";
}
