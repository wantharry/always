#!/usr/bin/env python3
"""Writes Contents.json for the tvOS brand-assets catalog structure."""
import json, os

ROOT = "DailyGlanceTV/Assets.xcassets"
BRAND = f"{ROOT}/AppIcon.brandassets"


def write(path, obj):
    with open(path, "w") as f:
        json.dump(obj, f, indent=2)
    print("wrote", path)


def image_layer_contents(dirpath, prefix, w, h):
    write(f"{dirpath}/Contents.json", {
        "images": [
            {"idiom": "tv", "filename": f"{prefix}-{w}x{h}.png", "scale": "1x"},
            {"idiom": "tv", "filename": f"{prefix}-{w*2}x{h*2}.png", "scale": "2x"},
        ],
        "info": {"version": 1, "author": "xcode"}
    })


def imagestack_layers(imagestack_path, prefix_map):
    write(f"{imagestack_path}/Contents.json", {
        "layers": [
            {"filename": "Front.imagestacklayer"},
            {"filename": "Middle.imagestacklayer"},
            {"filename": "Back.imagestacklayer"},
        ],
        "info": {"version": 1, "author": "xcode"}
    })
    for layer, prefix in prefix_map.items():
        layerdir = f"{imagestack_path}/{layer}.imagestacklayer"
        write(f"{layerdir}/Contents.json", {
            "info": {"version": 1, "author": "xcode"}
        })
        image_layer_contents(f"{layerdir}/Content.imageset", prefix, 400, 240)


def main():
    os.makedirs(ROOT, exist_ok=True)
    write(f"{ROOT}/Contents.json", {
        "info": {"version": 1, "author": "xcode"}
    })

    os.makedirs(BRAND, exist_ok=True)
    write(f"{BRAND}/Contents.json", {
        "assets": [
            {"filename": "App Icon - App Store.imagestack", "idiom": "tv", "role": "primary-app-icon", "size": "1280x768"},
            {"filename": "App Icon.imagestack", "idiom": "tv", "role": "primary-app-icon", "size": "400x240"},
            {"filename": "Top Shelf Image.imageset", "idiom": "tv", "role": "top-shelf-image", "size": "1920x720"},
            {"filename": "Top Shelf Image Wide.imageset", "idiom": "tv", "role": "top-shelf-image-wide", "size": "2320x720"},
        ],
        "info": {"version": 1, "author": "xcode"}
    })

    imagestack_layers(f"{BRAND}/App Icon.imagestack", {"Front": "front", "Middle": "middle", "Back": "back"})

    store_stack = f"{BRAND}/App Icon - App Store.imagestack"
    write(f"{store_stack}/Contents.json", {
        "layers": [
            {"filename": "Front.imagestacklayer"},
            {"filename": "Middle.imagestacklayer"},
            {"filename": "Back.imagestacklayer"},
        ],
        "info": {"version": 1, "author": "xcode"}
    })
    for layer, prefix in [("Front", "front"), ("Middle", "middle"), ("Back", "back")]:
        layerdir = f"{store_stack}/{layer}.imagestacklayer"
        write(f"{layerdir}/Contents.json", {
            "info": {"version": 1, "author": "xcode"}
        })
        write(f"{layerdir}/Content.imageset/Contents.json", {
            "images": [
                {"idiom": "tv", "filename": f"icon-store-{prefix}-1280x768.png", "scale": "1x"},
            ],
            "info": {"version": 1, "author": "xcode"}
        })

    ts = f"{BRAND}/Top Shelf Image.imageset"
    image_layer_contents(ts, "top-shelf-image", 1920, 720)

    tsw = f"{BRAND}/Top Shelf Image Wide.imageset"
    image_layer_contents(tsw, "top-shelf-image-wide", 2320, 720)

    accent = f"{ROOT}/AccentColor.colorset"
    os.makedirs(accent, exist_ok=True)
    write(f"{accent}/Contents.json", {
        "colors": [
            {
                "idiom": "universal",
                "color": {
                    "color-space": "srgb",
                    "components": {"red": "0.980", "green": "0.620", "blue": "0.420", "alpha": "1.000"}
                }
            }
        ],
        "info": {"version": 1, "author": "xcode"}
    })


if __name__ == "__main__":
    main()
