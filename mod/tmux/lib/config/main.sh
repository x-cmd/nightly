

# . "${___X_CMD_ROOT_MOD}/xrc/latest"
. "${___X_CMD_ROOT_MOD}/xrc/latest"

___X_CMD_TMUX_BIN="${___X_CMD_TMUX_BIN:-tmux}"
xrc:mod tmux/lib/config/plugin-util.sh  tmux/lib/config/plugin-copy.sh  tmux/lib/config/plugin-scroll.sh

___x_cmd_tmux_set_color(){
    : bg : color222 color111 color150 color140
    $___X_CMD_TMUX_BIN set status-bg "$1"
    # x $___X_CMD_TMUX_BIN set status-fg "$2"
}


$___X_CMD_TMUX_BIN setw -g    window-status-separator ' '
$___X_CMD_TMUX_BIN setw -g    window-status-format "#I:#W "
$___X_CMD_TMUX_BIN setw -g    window-status-current-format "#[fg=red,bg=cyan,bold]#I:#W#{?window_zoomed_flag,🔍,}"


$___X_CMD_TMUX_BIN set -g     status-right-style  "bg=yellow"
$___X_CMD_TMUX_BIN set -g     status-left-style   "bg=orange"

# $___X_CMD_TMUX_BIN set -g     status-left "#($___X_CMD_TMUX_BIN show -v mouse)  "

# $___X_CMD_TMUX_BIN set -g     status-left "#(date +%H:%M)  "

$___X_CMD_TMUX_BIN set        status-interval 1
# $___X_CMD_TMUX_BIN set -g     status-left "#(date +%T)  "
$___X_CMD_TMUX_BIN set -g     status-right "#{host} #(date +%H:%M)"

# Provide keby
$___X_CMD_TMUX_BIN bind b     display-popup -E "${SHELL:-/bin/sh} $___X_CMD_ROOT_MOD/tmux/lib/config/popup.sh"


