

$___X_CMD_TMUX_BIN set        status-interval 10

$___X_CMD_TMUX_BIN setw -g    window-status-separator ' '
$___X_CMD_TMUX_BIN setw -g    window-status-format "#I:#W "
$___X_CMD_TMUX_BIN setw -g    window-status-current-format "#[fg=red,bg=cyan,bold]#I:#W#{?window_zoomed_flag,🔍,}"

$___X_CMD_TMUX_BIN set -g     status-left-style   "bg=orange"

# $___X_CMD_TMUX_BIN set -g     status-left "#($___X_CMD_TMUX_BIN show -v mouse)  "
# $___X_CMD_TMUX_BIN set -g     status-left "#(date +%H:%M)  "
# $___X_CMD_TMUX_BIN set -g     status-left "#(date +%T)  "

___x_cmd_os_name_
$___X_CMD_TMUX_BIN set -g     status-right "| #(. $___X_CMD_ROOT_MOD/os/lib/loadavg; ___X_CMD_OS_NAME_=$___X_CMD_OS_NAME_ ___x_cmd_os_loadavg___get_from_osname) | #{host} #(date +%H:%M)"
$___X_CMD_TMUX_BIN set -g     status-right-style  "bg=blue fg=yellow,bold"
# $___X_CMD_TMUX_BIN set -g     status-right-style  "bg=black fg=blue"
