# nvim_config

#### Currently configured LSPs for:

- java [\[jdtls\]](https://github.com/mfussenegger/nvim-jdtls)
  - [java-test](https://github.com/microsoft/vscode-java-test) for unit testing

  - [java-debug-adapter](https://github.com/microsoft/java-debug) for debugging

- c/c++ [\[clangd\]](https://clangd.llvm.org)

- arduino [\[clangd\]](https://clangd.llvm.org)

- python [\[pylsp\]](https://github.com/python-lsp/python-lsp-server)
  - [nvim-dap-python](https://github.com/mfussenegger/nvim-dap-python) for debugging


- latex [\[texlab\]](https://github.com/latex-lsp/texlab) \
  Configured pdf-viewers:
  <details> 
    <summary> Okular (linux) </summary>

    ***

    Inverse-search configuration: \
      - Go to Settings -> Configure Okular... -> Editor \
      - Select "Custom Text Editor" \
      - Paste this: `texlab inverse-search -i "%f" -l %l`

    Shift+Click to run inverse search
  </details>
  
  <details>
    <summary> Skim (macos) </summary>

    ***

    Inverse-search configuration: \
      - Go to Skim -> Settings -> Sync \
      - Select preset: none \
      - Executable: `texlab` (If this doesn't work: `/path/to/nvim_share/mason/bin/texlab`)\
      - Arguments: `inverse-search -i "%file" -l %line`

    Shift+⌘+Click to run inverse search
  </details>

---
#### Jupyter notebooks:

Supported by using:
- [jupytext.nvim](https://github.com/GCBallesteros/jupytext.nvim)
- [quarto-nvim](https://github.com/quarto-dev/quarto-nvim)
- [otter.nvim](https://github.com/jmbuhr/otter.nvim)
- [molten-nvim](https://github.com/benlubas/molten-nvim)

Requirements:
- [quarto-cli](https://github.com/quarto-dev/quarto-cli) needs to be installed
- Molten needs to be configured (if it does not work by default, try running `:UpdateRemotePlugins`)

---

#### Image support:

- Implemented using [image.nvim](https://github.com/3rd/image.nvim)

- Use `:ConfigureImageBackend` to set it up

- Currently only tested with the [kitty](https://sw.kovidgoyal.net/kitty/graphics-protocol/) protocol, [ueberzugpp](https://github.com/jstkdng/ueberzugpp) would also need to be installed manually
