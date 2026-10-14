#!/usr/bin/env bash
# =============================================================================
#  Information Visualization -- one-click Python setup (macOS and Linux)
#
#  What it does (safe to run more than once):
#   1. looks for conda (Miniforge, Miniconda or Anaconda);
#      if none is found, installs Miniforge in your home folder (no admin needed)
#   2. creates (or updates) the course environment "infovis" from environment.yml
#   3. runs check_setup.py, which draws a test chart
#   4. opens JupyterLab in the lecture folder
#
#  How to run it:  double-click this file.
#  If macOS blocks it: right-click > Open > Open.  Or open the Terminal app,
#  type  bash  followed by a space, drag this file into the window, press Enter.
# =============================================================================
set -u
SETUP_DIR="$(cd "$(dirname "$0")" && pwd)"
LECTURE_DIR="$(dirname "$SETUP_DIR")"
ENV_NAME="infovis"

say()  { printf "\n\033[1;31m==>\033[0m \033[1m%s\033[0m\n" "$1"; }
fail() {
  printf "\n\033[1;31mSETUP STOPPED:\033[0m %s\n" "$1"
  printf "Take a screenshot of this window and bring it to the exercise session.\n\n"
  read -r -p "Press Enter to close this window." _ || true
  exit 1
}

find_conda() {
  local c
  for c in "$(command -v conda 2>/dev/null)" \
           "$HOME/miniforge3/bin/conda" "$HOME/mambaforge/bin/conda" \
           "$HOME/miniconda3/bin/conda" "$HOME/anaconda3/bin/conda" \
           "$HOME/opt/anaconda3/bin/conda" "$HOME/opt/miniconda3/bin/conda" \
           "/opt/homebrew/Caskroom/miniforge/base/bin/conda" \
           "/opt/miniconda3/bin/conda" "/opt/anaconda3/bin/conda"; do
    if [ -n "$c" ] && [ -x "$c" ]; then echo "$c"; return 0; fi
  done
  return 1
}

say "Information Visualization: Python setup (this can take 5 to 15 minutes)"

# ---- 1. conda ------------------------------------------------------------------
CONDA="$(find_conda || true)"
if [ -z "$CONDA" ]; then
  say "No conda found. Downloading Miniforge (about 80 MB)..."
  OS="$(uname)"; ARCH="$(uname -m)"
  URL="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-${OS}-${ARCH}.sh"
  TMP="${TMPDIR:-/tmp}/Miniforge3-installer.sh"
  curl -fL --retry 3 -o "$TMP" "$URL" || fail "download failed. Check your internet connection."
  say "Installing Miniforge in $HOME/miniforge3 ..."
  bash "$TMP" -b -p "$HOME/miniforge3" || fail "Miniforge installation failed."
  rm -f "$TMP"
  CONDA="$HOME/miniforge3/bin/conda"
else
  say "Found conda: $CONDA"
fi

# ---- 2. environment ----------------------------------------------------------------
if "$CONDA" env list | awk '{print $1}' | grep -qx "$ENV_NAME"; then
  say "Updating the existing '$ENV_NAME' environment..."
  "$CONDA" env update -n "$ENV_NAME" -f "$SETUP_DIR/environment.yml" \
    || fail "could not update the environment."
else
  say "Creating the '$ENV_NAME' environment (downloads about 500 MB)..."
  "$CONDA" env create -n "$ENV_NAME" -f "$SETUP_DIR/environment.yml" \
    || fail "could not create the environment."
fi

# activate the environment in this window
CONDA_ROOT="$(dirname "$(dirname "$CONDA")")"
# shellcheck disable=SC1091
source "$CONDA_ROOT/etc/profile.d/conda.sh" || fail "could not load conda."
conda activate "$ENV_NAME" || fail "could not activate the environment."

# make the environment visible as a kernel in any Jupyter / VS Code
python -m ipykernel install --user --name "$ENV_NAME" \
  --display-name "Python (infovis)" >/dev/null 2>&1 || true

# ---- 3. check ------------------------------------------------------------------------
say "Checking the installation..."
python "$SETUP_DIR/check_setup.py" || fail "the check found a problem (see the list above)."

# ---- 4. JupyterLab --------------------------------------------------------------------
if [ "${INFOVIS_NO_LAB:-0}" = "1" ]; then exit 0; fi
say "Starting JupyterLab in your browser. Keep this window open while you work;"
printf "    close it (or press Ctrl+C twice) when you are done.\n"
printf "    Next time, just double-click Start_JupyterLab_Mac.command\n\n"
jupyter lab --notebook-dir="$LECTURE_DIR"
