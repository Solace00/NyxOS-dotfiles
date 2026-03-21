{ pkgs }:
with pkgs;
[
  # ── editors ───────────────────────────────────
  vscode

  # ── terminal utils ────────────────────────────
  fastfetch
  btop
  bat
  eza
  fd
  ripgrep
  unzip
  wget
  zoxide
  lazygit
  gh

  # ── compilers & build ─────────────────────────
  gcc
  zeromq

  # ── python ────────────────────────────────────
  (python3.withPackages (ps: with ps; [
    pip
    virtualenv
    setuptools
    wheel
    cython
    numpy
    pandas
    matplotlib
    jupyter
    scikit-learn
  ]))
]