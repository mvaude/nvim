#!/usr/bin/env sh

set -x

whoami
ls -la /usr/local/bin/nvim
# su-exec neovim nvim +UpdateRemotePlugins +qa
cd "${WORKSPACE}" && nvim "$@"
# su-exec neovim sh
