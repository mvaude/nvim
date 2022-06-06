# Neovim configuration

Continuous WIP for neovim configuration.

## Docker

### Build

```sh
docker build -t nvim:latest .
```

### Run

```sh
docker run --name nvim --rm -ti -v $(pwd):/mnt/workspace nvim
```

## Plugins

- [packer.nvim](https://github.com/wbthomason/packer.nvim) - plugin manager

## Acknowledgements

[Dotfiles](https://github.com/stars/mvaude/lists/dotfiles) I follow.

## Articles

- https://www.atlassian.com/git/tutorials/dotfiles
- https://hannadrehman.com/top-neovim-plugins-for-developers-in-2022
