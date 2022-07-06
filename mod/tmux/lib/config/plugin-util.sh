# shellcheck shell=sh disable=SC3043

___x_cmd_tmux_config_get_tmux_version() {
  $___X_CMD_TMUX_BIN -V | cut -d " " -f 2
}

___x_cmd_tmux_config_get_tmux_option() {
  local option_value;   option_value="$($___X_CMD_TMUX_BIN show-option -gqv "${1:?Please proivide opttion name}")"
  printf "%s\n" "${option_value:-$2}"
}
