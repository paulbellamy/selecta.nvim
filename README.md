# selecta.nvim

Simple neovim selecta bindings for searching through files and buffers

## Usage

Search through files with: `,f`

Search through open buffers with: `,b`

To configure the file-search tool, add this to your `.vimrc`:

```
let g:selecta_files_tool = "ag --hidden -l"
```

## Installation

Depends on [selecta](https://github.com/garybernhardt/selecta), and (by default)
[the silver searcher](https://github.com/ggreer/the_silver_searcher).

Install using your favorite package manager, or use Vim's built-in package
support:

    mkdir -p ~/.vim/pack/paulbellamy/start
    cd ~/.vim/pack/paulbellamy/start
    git clone git@github.com:paulbellamy/selecta.nvim.git
