"""
cvd_tools.py -- check a chart or a palette for colour-vision deficiency (CVD).

    from cvd_tools import cvd_check, show_palette_cvd
    cvd_check("redesign.png")          # writes redesign_cvd.png (4 panels)
    show_palette_cvd(["#E69F00", "#56B4E9", "#009E73"])

Simulation: Machado, Oliveira & Fernandes (2009), severity 100%, applied in
linear RGB (the same matrices as the colorspacious and colorspace packages).
Greyscale: relative luminance (Rec. 709 weights). Only numpy and matplotlib.
"""
from pathlib import Path
import numpy as np
import matplotlib.pyplot as plt

MACHADO = {
    "Deuteranopia (no green cones)": np.array([
        [0.367322, 0.860646, -0.227968],
        [0.280085, 0.672501, 0.047413],
        [-0.011820, 0.042940, 0.968881]]),
    "Protanopia (no red cones)": np.array([
        [0.152286, 1.052583, -0.204868],
        [0.114503, 0.786281, 0.099216],
        [-0.003882, -0.048116, 1.051998]]),
    "Tritanopia (no blue cones)": np.array([
        [1.255528, -0.076749, -0.178779],
        [-0.078411, 0.930809, 0.147602],
        [0.004733, 0.691367, 0.303900]]),
}


def _to_linear(c):
    return np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)


def _to_srgb(c):
    c = np.clip(c, 0, 1)
    return np.where(c <= 0.0031308, 12.92 * c, 1.055 * c ** (1 / 2.4) - 0.055)


def simulate_cvd(rgb, kind="Deuteranopia (no green cones)"):
    """rgb: array (..., 3) with values 0-1. Returns the simulated colours."""
    lin = _to_linear(np.asarray(rgb, dtype=float)[..., :3])
    if kind == "Greyscale":
        y = lin @ np.array([0.2126, 0.7152, 0.0722])
        out = np.repeat(y[..., None], 3, axis=-1)
    else:
        out = lin @ MACHADO[kind].T
    return _to_srgb(out)


def cvd_check(png_file, out_file=None):
    """Save original, deuteranopia, protanopia and greyscale side by side."""
    img = plt.imread(png_file)
    if img.dtype == np.uint8:
        img = img / 255
    kinds = ["Original", "Deuteranopia (no green cones)",
             "Protanopia (no red cones)", "Greyscale"]
    fig, axs = plt.subplots(2, 2, figsize=(11, 8.5))
    for ax, k in zip(axs.flat, kinds):
        ax.imshow(img[..., :3] if k == "Original" else simulate_cvd(img, k))
        ax.set_title(k, loc="left", fontsize=11, fontweight="bold")
        ax.axis("off")
    fig.tight_layout()
    out_file = out_file or str(Path(png_file).with_name(Path(png_file).stem + "_cvd.png"))
    fig.savefig(out_file, dpi=150, facecolor="white")
    plt.close(fig)
    print("CVD check written to", out_file)
    return out_file


def show_palette_cvd(colours, ax=None):
    """Swatches of a palette as seen with normal vision and three CVD types."""
    from matplotlib.colors import to_rgb
    base = np.array([to_rgb(c) for c in colours])
    rows = {"Normal vision": base}
    rows.update({k.split(" (")[0]: simulate_cvd(base, k) for k in MACHADO})
    rows["Greyscale"] = simulate_cvd(base, "Greyscale")
    if ax is None:
        _, ax = plt.subplots(figsize=(1 + 0.7 * len(colours), 2.6))
    ax.imshow(np.stack(list(rows.values())), aspect="auto")
    ax.set_yticks(range(len(rows)), list(rows))
    ax.set_xticks([])
    ax.grid(False)
    for s in ax.spines.values():
        s.set_visible(False)
    return ax
