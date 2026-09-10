This is not the best guide.
A lot of steps may be missing and some could be wrong, but I will add/fix what I can when I recall it(possibly when I pull the config to another system).

# Neovim Config

Personal Neovim config, cross-platform (Ubuntu, Windows, Termux/Android).

## Requirements (all platforms)

- **Neovim** ≥ 0.11 (LSP config uses `vim.lsp.config` / `vim.lsp.enable`)
- **git**
- **ripgrep** — used by fzf-lua for live grep
- **fd** — used by fzf-lua for file finding
- **fzf** — required by fzf-lua
- **tree-sitter-cli** ≥ 0.25 — needed to build Treesitter parsers
- **nodejs** — needed by some Treesitter grammars (`latex`, `verilog`) that
  generate C source from `grammar.js`
- **clang** (or a C compiler) — needed to compile Treesitter parsers
- A terminal with **truecolor / gradient support** — Neovim 0.10+ actually
  handles this automatically via the `'termguicolors'` default; a
  modern terminal like Ghostty, Kitty, WezTerm, Alacritty, Windows Terminal,
  or Termux just makes it look nicer.

### Ubuntu

```bash
sudo apt install neovim git ripgrep fd-find fzf nodejs npm clang \
  build-essential curl
```

Install `tree-sitter-cli` via Cargo (apt's version is often too old):

```bash
cargo install tree-sitter-cli
```

### Windows

Install via [winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/):

```powershell
winget install Neovim.Neovim Git.Git BurntSushi.ripgrep.MSVC `
  sharkdp.fd junegunn.fzf OpenJS.NodeJS LLVM.LLVM
```

Install `tree-sitter-cli` via Cargo (or scoop):

```powershell
cargo install tree-sitter-cli
# or: scoop install tree-sitter
```

### Termux (Android)

Termux is the painful one.
Things Mason can't install on Termux must be installed via `pkg`, `cargo`, or `install-in-mason` — details below.

```bash
pkg update && pkg upgrade
pkg install neovim git ripgrep fd fzf nodejs clang make curl \
  tree-sitter termux-api

# required for termux-open to reach WPS Office / any external PDF viewer
termux-setup-storage

# for typst-preview.nvim
pkg install websocat

# selene (Rust linter) — no Termux package, use cargo
cargo install selene

# vimtex PDF viewer
pkg install texlive-bin #this one is also a bitch sometimes they update the package and the repo delays for a while so the command keeps failing. just wait for a month or so for it to get fixed
```

Then, in `~/.termux/termux.properties`:

```
allow-external-apps = true
```

Reload with `termux-reload-settings` (or restart Termux).
Without this, `termux-open` silently fails or permission is denied when vimtex calls it to display the PDF.

#### setup-mason-for-termux

Mason's installer refuses to download binaries for the `aarch64-unknown-linux-android` platform.
The [setup-mason-for-termux](https://github.com/Amirulmuuminin/setup-mason-for-termux) script patches Mason to fall back to Termux's package manager. Install it once, then use `install-in-mason` instead of `:MasonInstall` for anything Mason can't handle directly.

```bash
install-in-mason lua-language-server
install-in-mason tinymist
install-in-mason stylua
```

**Known to NOT work via `install-in-mason` on Termux:**

- `selene` — use `cargo install selene`
- `latexindent` — **broken on Termux**, see "LaTeX on Termux" below

## Config structure

```
init.lua                    entry point; runtimepath fix for Termux
lsp/                        per-server LSP configs (Neovim 0.11 style)
lua/
  config/                   options, keymaps, autocmds
  core/                     lazy.nvim bootstrap, LSP setup
  plugins/                  plugin specs
  snippets/                 LuaSnip snippets by filetype
```

### Termux detection

Config branches on Termux using:

```lua
vim.fn.executable("termux-setup-storage") == 1
```

`termux-setup-storage` is a real Termux binary on `$PATH`, and checking its existence with `vim.fn.executable()` is a cheap, side-effect-free way to detect the platform — unlike _running_ it, which triggers Android's storage permission prompt.

## Platform-specific behaviour

### Treesitter runtimepath (Termux only)

The `main` branch of `nvim-treesitter` installs parsers to `stdpath("data")/site/parser/`, which Termux's Neovim build does not add to `runtimepath` by default. `init.lua` fixes this:

```lua
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site")
```

Without it, `:TSInstall` reports success but `vim.treesitter.start()` fails with `Parser could not be created for buffer`.

### Mason tool filtering (Termux only)

`mason-tool-installer` skips `stylua`, `latexindent`, and `selene` on Termux, because Mason can't install them there.
They're installed via `pkg`/`cargo` instead (see Termux section above).

### VimTeX viewer

- Ubuntu: `zathura`
- Windows: `general` (default PDF handler)
- Termux: `termux-open` via `general`

Set in `lua/plugins/vimtex.lua` based on `has("win32")` and the Termux
check.

### Typst preview

`typst-preview.nvim`'s auto-downloader does not recognise Android as a supported platform, so it never fetches `tinymist` / `websocat`.
The plugin is pointed at the Termux-installed binaries explicitly:

```lua
opts = {
  dependencies_bin = {
    tinymist = vim.fn.exepath("tinymist"),
    websocat = vim.fn.exepath("websocat"),
  },
}
```

Use `vim.fn.exepath()` rather than bare strings — `vim.uv.spawn` doesn't
always inherit the shell's `$PATH`.

## LaTeX on Termux

The LaTeX toolchain on Termux has a few sharp edges, but everything works
once they're worked around.

### Always run `texhash` after installing packages

After installing **any** `texlive-*` package (e.g. `texlive-pictures` for
`circuitikz`), run:

```bash
texhash
```

Termux's `texlive-bin` doesn't keep its filename database in sync on its
own. Without `texhash`, you'll get `File 'xxx.sty' not found` errors even
though `kpsewhich xxx.sty` happily finds the file.

The reason: `kpsewhich` walks the whole tree directly, but `latexmk` relies
on the pre-built `ls-R` database for speed. The two disagree until you
rebuild it. `texhash` rebuilds every `ls-R` in one shot.

### `latexindent`

`latexindent` ships with `texlive-bin` but doesn't work out of the box on
Termux due to two path-resolution bugs:

1. The Perl wrapper hardcodes a `2026.0` version directory, but the
   package installs scripts under `2026`.
2. Even after fixing (1), the `defaultSettings.yaml` lookup uses
   `$FindBin::RealBin`, which on Android resolves to the **symlink** path
   (`$PREFIX/bin/texlive/`) rather than the real script directory.

The fix is to mirror the scripts into the `2026.0` path as **real files,
not symlinks** — Android's Perl `FindBin` doesn't follow symlink chains, so
the wrapper's `-f` existence check silently fails.

```bash
# ensure the Perl dependencies are present
cpan install YAML::Tiny File::HomeDir Log::Log4perl

# mirror the scripts to the path latexindent expects
mkdir -p $PREFIX/share/texlive/2026.0/texmf-dist/scripts/latexindent
cp -r $PREFIX/share/texlive/2026/texmf-dist/scripts/latexindent/. \
      $PREFIX/share/texlive/2026.0/texmf-dist/scripts/latexindent/
```

Verify:

```bash
echo '\documentclass{article}' > $TMPDIR/test.tex
latexindent $TMPDIR/test.tex
```

No `FATAL: Could not open defaultSettings.yaml` means you're good.

**Re-run the copy step after any `texlive-bin` upgrade.** The package
overwrites `2026/` but won't touch `2026.0/`, so the two drift out of sync
until you re-copy.

### Conform and texlab

Conform invokes `latexindent` directly for `.tex` files. If `latexindent`
ever starts returning error text instead of formatted output again, this
is the failure mode: the error message becomes the buffer content on save,
because Conform's contract is "formatter writes result to stdout, exits 0".

## First run

1. Clone into `~/.config/nvim` (or `%LOCALAPPDATA%\nvim` on Windows):
   ```bash
   git clone <this-repo> ~/.config/nvim
   ```
2. Launch `nvim`. lazy.nvim bootstraps itself and installs plugins.
3. Open any file. Treesitter installs parsers in the background.
4. Run `:checkhealth` — should be mostly green on Ubuntu/Windows. On
   Termux, expect warnings about `latexindent` and any tool Mason refused
   to install (see above).
