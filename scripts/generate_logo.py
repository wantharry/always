#!/usr/bin/env python3
"""Generates the layered App Icon + Top Shelf logo for Daily Glance.

Design: a sun-with-clock-hands glyph (the "glance" concept - sun for
day, clock hands for time) in white on the app's dawn gradient
(orange -> purple), matching the in-app DashboardTheme dawn palette.
"""
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = "DailyGlanceTV/Assets.xcassets/AppIcon.brandassets"
FONT_ROUNDED = "/System/Library/Fonts/SFNSRounded.ttf"

DAWN_ORANGE = (250, 158, 107)
DAWN_PURPLE = (140, 89, 140)
WHITE = (255, 255, 255)
GOLD = (255, 214, 130)


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def diagonal_gradient(size, c1, c2):
    w, h = size
    img = Image.new("RGB", (w, h))
    px = img.load()
    diag = w + h
    for y in range(h):
        for x in range(0, w, 2):
            t = (x + y) / diag
            color = lerp(c1, c2, t)
            px[x, y] = color
            if x + 1 < w:
                px[x + 1, y] = color
    return img


def radial_glow(size, color, alpha=180, center=None):
    w, h = size
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    cx, cy = center if center else (w / 2, h / 2)
    maxr = math.hypot(max(cx, w - cx), max(cy, h - cy))
    px = img.load()
    for y in range(h):
        for x in range(0, w, 2):
            d = math.hypot(x - cx, y - cy) / maxr
            a = max(0, int(alpha * (1 - d) ** 2))
            px[x, y] = (*color, a)
            if x + 1 < w:
                px[x + 1, y] = (*color, a)
    return img


def draw_sun_clock_glyph(size, scale=1.0):
    w, h = size
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)

    cx, cy = w / 2, h / 2
    r = h * 0.24 * scale

    # sun rays
    ray_len = h * 0.09 * scale
    ray_w = max(4, int(h * 0.018 * scale))
    for i in range(8):
        ang = (math.pi * 2 / 8) * i
        x1 = cx + (r + h * 0.03) * math.cos(ang)
        y1 = cy + (r + h * 0.03) * math.sin(ang)
        x2 = cx + (r + h * 0.03 + ray_len) * math.cos(ang)
        y2 = cy + (r + h * 0.03 + ray_len) * math.sin(ang)
        d.line([(x1, y1), (x2, y2)], fill=(*GOLD, 255), width=ray_w)

    # sun disc with soft shadow
    shadow = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.ellipse([cx - r, cy - r + h * 0.015, cx + r, cy + r + h * 0.015], fill=(0, 0, 0, 90))
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=h * 0.015))
    img.alpha_composite(shadow)

    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(*WHITE, 255))

    # clock hands inside the disc
    hand_color = (60, 42, 90, 255)
    hour_len = r * 0.5
    minute_len = r * 0.72
    d.line([(cx, cy), (cx, cy - hour_len)], fill=hand_color, width=max(4, int(h * 0.02 * scale)))
    d.line([(cx, cy), (cx + minute_len * 0.87, cy - minute_len * 0.5)], fill=hand_color, width=max(3, int(h * 0.016 * scale)))
    d.ellipse([cx - h * 0.012, cy - h * 0.012, cx + h * 0.012, cy + h * 0.012], fill=hand_color)

    return img


def save(img, path):
    img.save(path, "PNG")
    print("wrote", path, img.size)


def make_icon_layers():
    dims = [(400, 240), (800, 480)]
    for (w, h) in dims:
        back = diagonal_gradient((w, h), DAWN_ORANGE, DAWN_PURPLE)
        save(back, f"{ROOT}/App Icon.imagestack/Back.imagestacklayer/Content.imageset/back-{w}x{h}.png")

        middle = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        glow = radial_glow((w, h), WHITE, alpha=60, center=(w * 0.5, h * 0.42))
        middle.alpha_composite(glow)
        save(middle, f"{ROOT}/App Icon.imagestack/Middle.imagestacklayer/Content.imageset/middle-{w}x{h}.png")

        front = draw_sun_clock_glyph((w, h), scale=1.0)
        save(front, f"{ROOT}/App Icon.imagestack/Front.imagestacklayer/Content.imageset/front-{w}x{h}.png")


def make_app_store_icon_layers():
    w, h = 1280, 768
    store_root = f"{ROOT}/App Icon - App Store.imagestack"

    back = diagonal_gradient((w, h), DAWN_ORANGE, DAWN_PURPLE)
    save(back, f"{store_root}/Back.imagestacklayer/Content.imageset/icon-store-back-{w}x{h}.png")

    middle = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    glow = radial_glow((w, h), WHITE, alpha=60, center=(w * 0.5, h * 0.42))
    middle.alpha_composite(glow)
    save(middle, f"{store_root}/Middle.imagestacklayer/Content.imageset/icon-store-middle-{w}x{h}.png")

    front = draw_sun_clock_glyph((w, h), scale=1.0)
    save(front, f"{store_root}/Front.imagestacklayer/Content.imageset/icon-store-front-{w}x{h}.png")


def make_top_shelf():
    combos = [
        ("Top Shelf Image", [(1920, 720), (3840, 1440)]),
        ("Top Shelf Image Wide", [(2320, 720), (4640, 1440)]),
    ]
    for name, dims in combos:
        for (w, h) in dims:
            img = diagonal_gradient((w, h), DAWN_ORANGE, DAWN_PURPLE).convert("RGBA")
            glow = radial_glow((w, h), WHITE, alpha=45, center=(w * 0.16, h * 0.5))
            img.alpha_composite(glow)
            d = ImageDraw.Draw(img)

            glyph_h = int(h * 0.7)
            glyph = draw_sun_clock_glyph((glyph_h, glyph_h), scale=1.0)
            gx = int(w * 0.06)
            gy = (h - glyph_h) // 2
            img.alpha_composite(glyph, (gx, gy))

            font_size = int(h * 0.19)
            font = ImageFont.truetype(FONT_ROUNDED, font_size)
            text = "Daily Glance"
            tx = gx + glyph_h + int(w * 0.03)
            ty = h // 2 - font_size // 2 - int(h * 0.03)
            d.text((tx, ty), text, font=font, fill=(255, 255, 255, 255))

            sub_font_size = int(h * 0.082)
            sub_font = ImageFont.truetype(FONT_ROUNDED, sub_font_size)
            d.text((tx, ty + font_size + int(h * 0.02)), "Time · Weather · Calendar · News",
                    font=sub_font, fill=(255, 240, 225, 210))

            img = img.convert("RGB")
            fname = f"{name.lower().replace(' ', '-')}-{w}x{h}.png"
            save(img, f"{ROOT}/{name}.imageset/{fname}")


if __name__ == "__main__":
    make_icon_layers()
    make_app_store_icon_layers()
    make_top_shelf()
