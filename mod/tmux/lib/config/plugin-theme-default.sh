

$___X_CMD_TMUX_BIN set        status-interval 10

$___X_CMD_TMUX_BIN setw -g    window-status-separator ' '
$___X_CMD_TMUX_BIN setw -g    window-status-format "#I:#W "
$___X_CMD_TMUX_BIN setw -g    window-status-current-format "#[fg=red,bg=cyan,bold]#I:#W#{?window_zoomed_flag,🔍,}"


$___X_CMD_TMUX_BIN set -g     status-right-style  "bg=yellow"
$___X_CMD_TMUX_BIN set -g     status-left-style   "bg=orange"

# $___X_CMD_TMUX_BIN set -g     status-left "#($___X_CMD_TMUX_BIN show -v mouse)  "

# $___X_CMD_TMUX_BIN set -g     status-left "#(date +%H:%M)  "

# $___X_CMD_TMUX_BIN set -g     status-left "#(date +%T)  "
$___X_CMD_TMUX_BIN set -g     status-right "#{host} #(date +%H:%M)"

