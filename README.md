# World Clock (Minimalist Map) for Omarchy

A flat, minimalist world map wallpaper for [Omarchy](https://omarchy.org/).
Major cities are plotted on the map as dots; each shows its name and local
time, refreshed automatically every second (timezone- and DST-aware).

Map data derived from Wikimedia Commons'
[BlankMap-Equirectangular.svg](https://commons.wikimedia.org/wiki/File:BlankMap-Equirectangular.svg)
(public domain), restyled to a dark, minimalist palette.

Plugin ID: `bishu.minimalist-worldclock`

## Install

```sh
omarchy plugin add https://github.com/bishalber/omarchy-minimalist-worldclock.git --enable
```

## Requirements

Pure QML/Quickshell — no compiled binary, no network access at runtime.
Uses the system `date` command (via `bash`) to read each city's local time
per IANA timezone, so timezone data comes from your system's `tzdata`.

## Toggle

```sh
omarchy plugin disable bishu.minimalist-worldclock
omarchy plugin enable bishu.minimalist-worldclock
```

## Customize

Edit the `cities` list at the top of `Service.qml` to add, remove, or
relocate cities (name, IANA timezone, latitude, longitude). Saved changes
hot-reload automatically.

## License

MIT — see [LICENSE](LICENSE). The bundled map asset
(`assets/world-map.png`) is derived from a public-domain Wikimedia Commons
file.
