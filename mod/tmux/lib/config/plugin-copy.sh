
# Section: copy mode
# copy-pipe
___X_CMD_TMUX_COPY_CANCEL="${___X_CMD_TMUX_COPY_CANCEL:-copy-pipe-and-cancel}"

x os name_
case "$___X_CMD_OS_NAME_" in
    darwin)
        $___X_CMD_TMUX_BIN \
            bind-key -T copy-mode MouseDragEnd1Pane send-keys -X "$___X_CMD_TMUX_COPY_CANCEL" pbcopy \; \
            bind y run -b "$___X_CMD_TMUX_BIN save-buffer - | pbcopy" \; # \
            # bind y run -b "$___X_CMD_TMUX_BIN save-buffer - | reattach-to-user-namespace pbcopy"
        ;;

    linux)
        if command -v xsel >/dev/null 2>&1; then
            $___X_CMD_TMUX_BIN \
                bind-key -T copy-mode MouseDragEnd1Pane send-keys -X "$___X_CMD_TMUX_COPY_CANCEL" 'xsel -i -b' \; \
                bind-key y run -b "$___X_CMD_TMUX_BIN save-buffer - | xsel -i -b"
        elif command -v xclip >/dev/null 2>&1; then
            $___X_CMD_TMUX_BIN \
                bind-key -T copy-mode MouseDragEnd1Pane send-keys -X "$___X_CMD_TMUX_COPY_CANCEL" 'xclip -i -selection clipboard' \; \
                bind-key y run -b "$___X_CMD_TMUX_BIN save-buffer - | xclip -i -selection clipboard"
        else
            printf "%s\n" "Please install xsel or xclip." >&2
        fi
    ;;

    win)
        if [ -c /dev/clipboard ]; then
            $___X_CMD_TMUX_BIN \
                bind-key -T copy-mode MouseDragEnd1Pane send-keys -X "$___X_CMD_TMUX_COPY_CANCEL" 'cat >/dev/clipboard' \; \
                bind-key y run -b "$___X_CMD_TMUX_BIN save-buffer - > /dev/clipboard"
        else
            $___X_CMD_TMUX_BIN \
                bind-key -T copy-mode MouseDragEnd1Pane send-keys -X "$___X_CMD_TMUX_COPY_CANCEL" clip.exe \; \
                bind-key y run -b "$___X_CMD_TMUX_BIN save-buffer - | clip.exe"
        fi
    ;;
esac

# # TODO: better design for this.
# # copy to X11 clipboard
# if -b 'command -v xsel > /dev/null 2>&1' 'bind y run -b "$___X_CMD_TMUX_BIN save-buffer - | xsel -i -b"'
# if -b '! command -v xsel > /dev/null 2>&1 && command -v xclip > /dev/null 2>&1' 'bind y run -b "$___X_CMD_TMUX_BIN save-buffer - | xclip -i -selection clipboard >/dev/null 2>&1"'
# # copy to macOS clipboard
# if -b 'command -v pbcopy > /dev/null 2>&1' 'bind y run -b "$___X_CMD_TMUX_BIN save-buffer - | pbcopy"'
# if -b 'command -v reattach-to-user-namespace > /dev/null 2>&1' 'bind y run -b "$___X_CMD_TMUX_BIN save-buffer - | reattach-to-user-namespace pbcopy"'
# # copy to Windows clipboard
# if -b 'command -v clip.exe > /dev/null 2>&1' 'bind y run -b "$___X_CMD_TMUX_BIN save-buffer - | clip.exe"'
# if -b '[ -c /dev/clipboard ]' 'bind y run -b "$___X_CMD_TMUX_BIN save-buffer - > /dev/clipboard"'


## EndSection