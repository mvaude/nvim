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
    git clone https://github.com/m0uld/neovim.git


ARG VERSION=master

WORKDIR /neovim

RUN git checkout ${VERSION} && make CMAKE_INSTALL_PREFIX=/root/nvim CMAKE_BUILD_TYPE=RelWithDebInfo install

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
      	NVIM_CONFIG="/home/neovim/.config/nvim" \
      	NVIM_PCK="/home/neovim/.local/share/nvim/site/pack" \
      	ENV_DIR="/home/neovim/.local/share/venvs" \
	      NVIM_PROVIDER_PYLIB="python3_neovim" \
      	PATH="/home/neovim/.local/bin:${PATH}"

RUN \
	# install packages
	apk --no-cache add \
	# needed by neovim :CheckHealth to fetch info
  curl=7.83.1-r1 \
	# needed to change uid and gid on running container
  # shadow=4.10-r3 \
	# needed to install apk packages as neovim user on the container
  # sudo=1.9.10-r0 \
	# needed to switch user
  # su-exec=0.2-r1 \
	# needed for neovim python3 support
  python3=3.10.4-r0 \
	# needed for pip
  py3-virtualenv=20.14.1-r0 \
  # fuzzing search
	fzf=0.30.0-r2 \
	# needed by fzf because the default shell does not support fzf
	zsh=5.8.1-r4 \
	# install build packages
	# && apk --no-cache add --virtual build-dependencies \
	# python3-dev \
	# gcc \
	# musl-dev \
	git \
  && set -x \
	# create user
	&& addgroup --gid "${GID}" "${GNAME}" \
	&& adduser --uid "${UID}" --ingroup "${GNAME}" --home /home/"${UNAME}" --shell "${SHELL}" --disabled-password --gecos "" "${UNAME}"
  # && echo "${UNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers \
  # && chmod 0440 /etc/sudoers
	# install pipsi and python language server
	# && curl https://raw.githubusercontent.com/mitsuhiko/pipsi/master/get-pipsi.py | sudo -u ${UNAME} python3 \
	# && sudo -u ${UNAME} pipsi install python-language-server \
	# install plugins
	# && mkdir -p "${NVIM_PCK}/common/start" "${NVIM_PCK}/filetype/start" "${NVIM_PCK}/colors/opt" \
	# && git -C "${NVIM_PCK}/common/start" clone --depth 1 https://github.com/tpope/vim-commentary \
	# && git -C "${NVIM_PCK}/common/start" clone --depth 1 https://github.com/junegunn/fzf.vim \
	# && git -C "${NVIM_PCK}/common/start" clone --depth 1 https://github.com/tpope/vim-surround \
	# && git -C "${NVIM_PCK}/common/start" clone --depth 1 https://github.com/tpope/vim-obsession \
	# && git -C "${NVIM_PCK}/common/start" clone --depth 1 https://github.com/yuttie/comfortable-motion.vim \
	# && git -C "${NVIM_PCK}/common/start" clone --depth 1 https://github.com/wellle/targets.vim \
	# && git -C "${NVIM_PCK}/common/start" clone --depth 1 https://github.com/SirVer/ultisnips \
	# && git -C "${NVIM_PCK}/filetype/start" clone --depth 1 https://github.com/mattn/emmet-vim \
	# && git -C "${NVIM_PCK}/filetype/start" clone --depth 1 https://github.com/lervag/vimtex \
	# && git -C "${NVIM_PCK}/filetype/start" clone --depth 1 https://github.com/captbaritone/better-indent-support-for-php-with-html \
	# && git -C "${NVIM_PCK}/colors/opt" clone --depth 1 https://github.com/fxn/vim-monochrome \
	# && git -C "${NVIM_PCK}/common/start" clone --depth 1 https://github.com/autozimu/LanguageClient-neovim \
	# && cd "${NVIM_PCK}/common/start/LanguageClient-neovim/" && sh install.sh \
  # && chown -R ${UNAME}:${GNAME} /home/neovim/.local
	# remove build packages
	# && apk del build-dependencies

USER neovim

RUN \
  #mkdir -p ${ENV_DIR}/${NVIM_PROVIDER_PYLIB} \
	python3 -m venv ${ENV_DIR}/${NVIM_PROVIDER_PYLIB} \
	&& ${ENV_DIR}/${NVIM_PROVIDER_PYLIB}/bin/pip install pynvim

USER root

# RUN apk --no-cache add \
#     autoconf=2.71-r0 \
#     automake=1.16.5-r0 \
#     build-base=0.5-r2 \
#     cmake=3.23.1-r0 \
#     samurai=1.2-r1 \
#     coreutils=9.1-r0 \
#     curl=7.83.1-r1 \
#     gettext-tiny-dev=0.3.2-r1 \
#     git=2.36.1-r0 \
#     libtool=2.4.7-r0 \
#     pkgconf=1.8.0-r0 \
#     unzip=6.0-r9 \
#     && \
#     git clone https://github.com/neovim/neovim.git

# Copy init.lua
COPY --from=builder --chown=neovim:neovim /root/nvim /usr/local

# RUN chown -R neovim:neovim /usr/local/bin/nvim && \
#       chmod 4755 /usr/local/bin/nvim

#RUN groupadd -r nvim && useradd -r -s /bin/false -g nvim nvim
#RUN addgroup -S nvim && adduser -S nvim -G nvim

USER neovim:neovim
COPY entrypoint.sh /usr/local/bin/
COPY . /home/neovim/.config/nvim


VOLUME "${WORKSPACE}"
#VOLUME "${NVIM_CONFIG}"

ENTRYPOINT ["sh", "/usr/local/bin/entrypoint.sh"]

# To support kickstart.nvim
# RUN apk --no-cache add \
#     fd=8.3.0-r0  \
#     ctags=5.9.20220327.0-r0 \
#     ripgrep=13.0.0-r0 \
#     git=2.36.1-r0

# Install lua-language-server
# RUN apk --no-cache add \
#     git=2.36.1-r0 \
#     build-base=0.5-r2 \
#     samurai=1.2-r1 \
#     bash=5.1.16-r2

# RUN mkdir -p /root/.local && \
#     cd /root/.local &&  \
#     git clone --recursive https://github.com/sumneko/lua-language-server && \
#     cd lua-language-server/3rd/luamake && \
#     ./compile/install.sh && \
#     cd ../.. && \
#     ./3rd/luamake/luamake rebuild
#
# RUN echo "export PATH=$PATH:/root/.local/lua-language-server/bin" >> "$ENV"
#
# # Add clangd extras
# RUN apk --no-cache add \
#     clang-extra-tools

