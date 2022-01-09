FROM --platform=$TARGETPLATFORM xcmd/alpine

RUN eval "$(curl https://get.x-cmd.com)"

ENV ENV="/root/.ashrc"
RUN printf '[ -f "$HOME/.x-cmd/.boot/boot" ] && . "$HOME/.x-cmd/.boot/boot"' >> "$ENV"
