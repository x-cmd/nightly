FROM --platform=$TARGETPLATFORM xcmd/base-alpine-1-curl

RUN eval "$(curl https://get.x-cmd.com/nightly)"

ENV ENV="/root/.ashrc"
RUN printf '[ -f "$HOME/.x-cmd/.boot/boot" ] && . "$HOME/.x-cmd/.boot/boot"' >> "$ENV"
