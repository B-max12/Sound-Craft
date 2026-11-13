#!/usr/bin/env python3
"""Generates SoundCraft draft brand assets.

Draws the draft cricket-with-guitar mark (original artwork, pending owner's
approved concept file — Owner Action Queue #1). Produces:
  assets/brand/soundcraft-mark-draft.png      (1024 master)
  assets/brand/soundcraft-mark-draft-48.png   (48 legibility check)
  assets/brand/soundcraft-splash-draft.png    (spring splash scene draft)
  assets/illustrations/empty-library.png      (empty-state art)
Plus platform icons via flutter_launcher_icons (see flutter_launcher_icons.yaml).
"""
from PIL import Image, ImageDraw, ImageFilter
import os

OUT = os.path.join(os.path.dirname(__file__), "..", "apps", "soundcraft", "assets")

# Palette (contract §2.2)
BG_MAIN = (11, 16, 13, 255)        # charcoal forest black
SURFACE = (18, 26, 21, 255)
ELEVATED = (27, 38, 30, 255)
PRIMARY = (120, 230, 74, 255)      # spring green
DEEP = (36, 90, 53, 255)           # muted accent
WARM = (233, 191, 118, 255)        # guitar wood
TEXT = (244, 247, 242, 255)


def draw_mark(draw: ImageDraw.ImageDraw, s: float, cx: float, cy: float, wave: bool = True):
    """Draws the cricket + guitar + soundwave motif centered at (cx, cy)."""
    u = s  # unit

    # Cricket body (elongated, segmented — NOT a frog)
    bx, by = cx - 0.08 * u, cy + 0.06 * u
    body_w, body_h = 0.16 * u, 0.40 * u
    for i in range(4):  # segmentation
        seg_h = body_h / 4
        alpha = 255 - i * 25
        draw.rounded_rectangle(
            [bx - body_w / 2, by - body_h / 2 + i * seg_h,
             bx + body_w / 2, by - body_h / 2 + (i + 1) * seg_h],
            radius=u * 0.06,
            fill=(120, 230, 74, alpha),
        )
    # Head
    head_r = u * 0.095
    draw.ellipse([bx - head_r, by - body_h / 2 - head_r * 1.6,
                  bx + head_r, by - body_h / 2 + head_r * 0.4], fill=PRIMARY)
    # Antennae (long slender curves)
    ant_w = max(2, int(u * 0.022))
    head_tip = (bx, by - body_h / 2 - head_r * 1.4)
    draw.arc([bx - 0.24 * u, by - 0.62 * u, bx + 0.02 * u, by - 0.28 * u],
             start=250, end=360, fill=PRIMARY, width=ant_w)
    draw.arc([bx - 0.02 * u, by - 0.66 * u, bx + 0.22 * u, by - 0.30 * u],
             start=180, end=290, fill=PRIMARY, width=ant_w)
    # Hind leg (long bent leg)
    draw.line([(bx + 0.03 * u, by + 0.04 * u), (bx + 0.17 * u, by - 0.05 * u),
               (bx + 0.15 * u, by + 0.13 * u)], fill=PRIMARY, width=max(3, int(u * 0.03)), joint="curve")

    # Guitar (warm wood): body + neck
    gx, gy = cx + 0.20 * u, cy + 0.14 * u
    draw.ellipse([gx - 0.085 * u, gy - 0.085 * u, gx + 0.085 * u, gy + 0.085 * u], fill=WARM)
    draw.ellipse([gx - 0.035 * u, gy - 0.035 * u, gx + 0.035 * u, gy + 0.035 * u], fill=DEEP)
    draw.line([(gx + 0.05 * u, gy - 0.07 * u), (cx - 0.14 * u, cy - 0.22 * u)],
              fill=WARM, width=max(3, int(u * 0.025)))

    # Soundwave bars (bright green)
    if wave:
        bar_w = max(3, int(u * 0.032))
        for i in range(3):
            x = cx + (0.42 + i * 0.09) * u
            h = (0.12 + i * 0.05) * u
            draw.rounded_rectangle(
                [x - bar_w / 2, cy - h / 2, x + bar_w / 2, cy + h / 2],
                radius=bar_w / 2, fill=PRIMARY,
            )


def make_mark(size: int) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    pad = size * 0.06
    # Deep green disc background with subtle inner ring
    draw.ellipse([pad, pad, size - pad, size - pad], fill=DEEP)
    ring = size * 0.012
    draw.ellipse([pad + ring * 2, pad + ring * 2, size - pad - ring * 2, size - pad - ring * 2],
                 outline=(120, 230, 74, 90), width=max(2, int(ring)))
    draw_mark(draw, size, size / 2, size / 2)
    return img


def make_splash(size: int = 1024) -> Image.Image:
    """Spring scene draft: blossom branch + cricket + guitar + soundwave."""
    img = Image.new("RGBA", (size, size), BG_MAIN)
    draw = ImageDraw.Draw(img)
    # Soft moon glow
    glow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    gdraw = ImageDraw.Draw(glow)
    gdraw.ellipse([size * 0.62, size * 0.10, size * 0.92, size * 0.40],
                  fill=(120, 230, 74, 38))
    glow = glow.filter(ImageFilter.GaussianBlur(size * 0.06))
    img.alpha_composite(glow)
    # Branch across upper area
    branch_color = (58, 44, 34, 255)
    draw.line([(0, size * 0.30), (size * 0.55, size * 0.22), (size, size * 0.30)],
              fill=branch_color, width=int(size * 0.03), joint="curve")
    # Blossoms (pink accents, restrained)
    blossom = (238, 180, 200, 255)
    for (fx, fy) in [(0.16, 0.27), (0.28, 0.215), (0.42, 0.225), (0.62, 0.235), (0.80, 0.27)]:
        r = size * 0.028
        for ang in range(5):
            import math
            a = ang * 2 * math.pi / 5
            px, py = fx * size + r * 0.8 * math.cos(a), fy * size + r * 0.8 * math.sin(a)
            draw.ellipse([px - r * 0.5, py - r * 0.5, px + r * 0.5, py + r * 0.5], fill=blossom)
        draw.ellipse([fx * size - r * 0.25, fy * size - r * 0.25,
                      fx * size + r * 0.25, fy * size + r * 0.25], fill=WARM)
    # Cricket seated on branch with guitar
    draw_mark(draw, size * 0.9, size * 0.42, size * 0.55)
    # Ground grass hint
    for gx in range(0, size, size // 24):
        h = size * 0.05 + (gx % (size // 12))
        draw.line([(gx, size), (gx + size * 0.012, size - h)],
                  fill=DEEP, width=max(2, size // 300))
    return img


def make_empty_state(size: int = 640) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw_mark(draw, size * 0.8, size / 2, size * 0.52, wave=True)
    return img


def main():
    brand = os.path.join(OUT, "brand")
    illus = os.path.join(OUT, "illustrations")
    os.makedirs(brand, exist_ok=True)
    os.makedirs(illus, exist_ok=True)

    master = make_mark(1024)
    master.save(os.path.join(brand, "soundcraft-mark-draft.png"))
    master.resize((48, 48), Image.LANCZOS).save(os.path.join(brand, "soundcraft-mark-draft-48.png"))
    master.resize((192, 192), Image.LANCZOS).save(os.path.join(brand, "soundcraft-mark-draft-192.png"))

    splash = make_splash()
    splash.save(os.path.join(brand, "soundcraft-splash-draft.png"))
    splash.convert("RGB").resize((512, 512), Image.LANCZOS).save(
        os.path.join(brand, "soundcraft-splash-draft-preview.jpg"), quality=88)

    empty = make_empty_state()
    empty.save(os.path.join(illus, "empty-library.png"))
    print("brand assets generated")


if __name__ == "__main__":
    main()
