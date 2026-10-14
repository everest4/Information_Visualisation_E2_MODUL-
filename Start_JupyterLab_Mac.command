#!/usr/bin/env bash
# Information Visualization -- start JupyterLab in this folder (macOS and Linux).
# Double-click this file. Run setup/Setup_Python_Mac.command once before.
# Keep the Terminal window open while you work; close it when you are done.
LECTURE_DIR="$(cd "$(dirname "$0")" && pwd)"
CONDA=""
for c in "$(command -v conda 2>/dev/null)" \
         "$HOME/miniforge3/bin/conda" "$HOME/mambaforge/bin/conda" \
         "$HOME/miniconda3/bin/conda" "$HOME/anaconda3/bin/conda" \
         "$HOME/opt/anaconda3/bin/conda" "$HOME/opt/miniconda3/bin/conda" \
         "/opt/homebrew/Caskroom/miniforge/base/bin/conda" \
         "/opt/miniconda3/bin/conda" "/opt/anaconda3/bin/conda"; do
  if [ -n "$c" ] && [ -x "$c" ]; then CONDA="$c"; break; fi
done
if [ -z "$CONDA" ]; then
  echo "conda was not found. Run setup/Setup_Python_Mac.command first."
  read -r -p "Press Enter to close this window." _; exit 1
fi
CONDA_ROOT="$(dirname "$(dirname "$CONDA")")"
# shellcheck disable=SC1091
source "$CONDA_ROOT/etc/profile.d/conda.sh" && conda activate infovis \
  && jupyter lab --notebook-dir="$LECTURE_DIR" || {
  echo; echo "JupyterLab did not start. Run setup/Setup_Python_Mac.command again.";
  read -r -p "Press Enter to close this window." _; exit 1; }
