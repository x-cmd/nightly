FROM --platform=$TARGETPLATFORM xcmd/base-centos-1-curl

RUN eval "$(curl https://get.x-cmd.com/nightly)"
RUN printf '[ -f "$HOME/.x-cmd/.boot/boot" ] && . "$HOME/.x-cmd/.boot/boot"' >> "$HOME/.bashrc"