# Build neovim separately in the first stage
FROM alpine:3.16 AS builder

# Build neovim (and use it as an example codebase
RUN apk --no-cache add \
    autoconf=2.71-r0 \
    automake=1.16.5-r0 \
    build-base=0.5-r2 \
    cmake=3.23.1-r0 \
    coreutils=9.1-r0 \
    curl=7.83.1-r1 \
    gettext-tiny-dev=0.3.2-r1 \
    git=2.36.1-r0 \
    libtool=2.4.7-r0 \
    pkgconf=1.8.0-r0 \
    unzip=6.0-r9 \
    && \
    git clone https://github.com/neovim/neovim.git


ARG VERSION=master

WORKDIR /neovim

RUN git checkout ${VERSION} && make CMAKE_BUILD_TYPE=RelWithDebInfo install

FROM alpine:3.16 AS base

WORKDIR "/mnt/workspace"

LABEL \
        maintainer="maxime.vaude@gmail.com" \
        url.github="" \
        url.dockerhub=""

ENV \
        UID="1000" \
        GID="1000" \
        UNAME="neovim" \
        GNAME="neovim" \
        SHELL="/bin/zsh" \
        WORKSPACE="/mnt/workspace" \
      	NVIM_CONFIG="/root/.config/nvim" \
      	NVIM_PCK="/root/.local/share/nvim/site/pack" \
      	ENV_DIR="/root/.local/share/venvs" \
	      NVIM_PROVIDER_PYLIB="python3_neovim" \
      	PATH="/root/.local/bin:${PATH}"

RUN \
	# install packages
	apk --no-cache add \
	# needed by neovim :CheckHealth to fetch info
  curl=7.83.1-r1 \
	# needed for neovim python3 support
  python3=3.10.4-r0 \
	# needed for pip
  py3-virtualenv=20.14.1-r0 \
  # fuzzing search
	fzf=0.30.0-r2 \
	zsh=5.8.1-r4 \
  git=2.36.1-r0 \
  build-base=0.5-r2 \
  ripgrep=13.0.0-r0 \
  clang-extra-tools=13.0.1-r1 \
  fd=8.3.2-r0 \
  tree-sitter=0.20.6-r0 \
  nodejs=16.15.0-r1 \
  zoxide=0.8.1-r0 \
  shellcheck=0.8.0-r0 \
  yarn=1.22.19-r0 \
	&& python3 -m venv ${ENV_DIR}/${NVIM_PROVIDER_PYLIB} \
	&& ${ENV_DIR}/${NVIM_PROVIDER_PYLIB}/bin/pip install pynvim
	# create user
  # && addgroup --gid "${GID}" "${GNAME}" \
  # && adduser --uid "${UID}" --ingroup "${GNAME}" --home /home/"${UNAME}" --shell "${SHELL}" --disabled-password --gecos "" "${UNAME}"

# USER neovim

# RUN \
#   #mkdir -p ${ENV_DIR}/${NVIM_PROVIDER_PYLIB} \
# 	python3 -m venv ${ENV_DIR}/${NVIM_PROVIDER_PYLIB} \
# 	&& ${ENV_DIR}/${NVIM_PROVIDER_PYLIB}/bin/pip install pynvim

# USER root

# Copy init.lua
# COPY --from=builder --chown=neovim:neovim /usr/local /usr/local/
COPY --from=builder /usr/local /usr/local/

# USER neovim:neovim

COPY entrypoint.sh /usr/local/bin/
COPY . /root/.config/nvim
# Install plugins
RUN \
  git clone --depth 1 https://github.com/wbthomason/packer.nvim \
  /root/.local/share/nvim/site/pack/packer/start/packer.nvim \
  && yarn global add \
  prettier \
  eslint \
  bash-language-server \
  dockerfile-language-server-nodejs \
  yaml-language-server \
  typescript \
  typescript-language-server \
  vscode-langservers-extracted \
  # && curl -sLo go.tar.gz "https://go.dev/dl/go1.18.3.linux-amd64.tar.gz" \
  # && tar -C /usr/local/bin -xzf go.tar.gz \
  # && rm go.tar.gz \
  && ${ENV_DIR}/${NVIM_PROVIDER_PYLIB}/bin/pip install --no-cache-dir pyright black yamllint \
  # && /usr/local/bin/go install golang.org/x/tools/cmd/goimports@latest \
  # && /usr/local/bin/go install mvdan.cc/gofumpt@latest \
  # && /usr/local/bin/go install golang.org/x/tools/gopls@latest \
  && curl -sLo tf-ls.zip "https://releases.hashicorp.com/terraform-ls/0.27.0/terraform-ls_0.27.0_linux_amd64.zip" \
  && unzip -d /usr/local/bin tf-ls.zip \
  && rm tf-ls.zip \
  && curl -sLo tf.zip "https://releases.hashicorp.com/terraform/1.2.2/terraform_1.2.2_linux_amd64.zip" \
  && unzip -d /usr/local/bin tf.zip \
  && rm tf.zip \
  && cd /root/.local \
  && git clone --recursive https://github.com/sumneko/lua-language-server \
  && cd lua-language-server/3rd/luamake \
  && apk add --no-cache bash ninja \
  && ./compile/install.sh \
  && cd ../.. \
  && ./3rd/luamake/luamake rebuild \
  #FIX: extracted very much stuff besides the executable
  # rust runs in strange segmentation faults when building with amd64 even after increasing Docker memory limits. Stylua is only available as amd64 release
  # && curl https://sh.rustup.rs -sSf | zsh -s -- -y; cargo install stylua; rustup self uninstall -y;
  && curl -sLo stylua.zip "https://github.com/JohnnyMorganz/StyLua/releases/download/v0.13.1/stylua-linux.zip" && unzip -d /usr/local/bin stylua.zip && rm stylua.zip

# TODO: find a nicer fix
# RUN nvim --headless ':PackerSync' -c 'sleep 5' -c q
RUN nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync' \
  # https://github.com/nvim-treesitter/nvim-treesitter/issues/2900
  && nvim --headless -c 'TSUpdateSync' -c 'sleep 20' -c 'qa'

VOLUME "${WORKSPACE}"

ENV ENV="/root/.zshenv"

RUN echo "export PATH=$PATH:/root/.local/lua-language-server/bin:${ENV_DIR}/${NVIM_PROVIDER_PYLIB}/bin" >> "${ENV}"

WORKDIR "${WORKSPACE}"

ENTRYPOINT ["/bin/zsh", "-c", "nvim"]
