#!/usr/bin/env bash
set -e

if [ "$(id -u)" -ne 0 ]; then
	echo -e 'Script must be run as
    root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
	exit 1
fi


source ./library_scripts.sh

# nanolayer is a cli utility which keeps container layers as small as possible
# source code: https://github.com/devcontainers-extra/nanolayer
# `ensure_nanolayer` is a bash function that will find any existing nanolayer installations,
# and if missing - will download a temporary copy that automatically get deleted at the end
# of the script
ensure_nanolayer nanolayer_location "v0.4.39"

$nanolayer_location \
    install \
    devcontainer-feature \
    "ghcr.io/devcontainers-extra/features/homebrew-package:latest" \
    --option package='mailpit' --option version="$VERSION"

sed -i "s|__DAEMONOPTS__|${OPTIONS}|g" mailpit

install_mailpit_service() {
    cp ./mailpit /etc/init.d/mailpit
    su - "$_REMOTE_USER" <<EOF
        set -e

        sudo chmod +x /etc/init.d/mailpit
        sudo ln -s /home/linuxbrew/.linuxbrew/bin/mailpit /usr/bin/mailpit
EOF
}

install_mailpit_service

echo 'Done!'
