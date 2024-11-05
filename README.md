# nvim_config

Currently configured LSPs for:

- java [\[jdtls\]](https://github.com/mfussenegger/nvim-jdtls)
  - [java-test](https://github.com/microsoft/vscode-java-test) for unit testing

  - [java-debug-adapter](https://github.com/microsoft/java-debug) for debugging

- c/c++ [\[clangd\]](https://clangd.llvm.org)

- arduino [\[clangd\]](https://clangd.llvm.org)

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
