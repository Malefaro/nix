{ config, pkgs, lib, ... }:
{
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
