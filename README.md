# orangepi-zero3w-7.3-artifacts

Gate-passed build artifacts for the **Orange Pi Zero 3W (Allwinner A733 / `sun60iw2`)**
kernel **7.3** bring-up. Source of truth for the build is host `.168`
(`/home/host/kernel-trees/host-build/mainline-7.3`), which is the only machine that
compiles this kernel.

Every successful build is published automatically by
`opikernel/scripts/publish-7.3-artifacts.py` (cron, `--if-new`). Nothing is published
unless it passes the gate below.

## Layout

```
LATEST                     <- name of the newest published build dir
PUBLISH-LOG.md             <- append-only history, one line per build
builds/<UTCstamp>-<md5[:8]>/Image.xz                     kernel Image, xz-compressed
                            sun60i-a733-orangepi-zero3w.dtb
                            boot.scr / boot.cmd           canonical boot script copies
                            config-7.3-<md5[:8]>.gz       full .config, gzip
                            modules-*.tar.gz              module bundle (vermagic-matched)
                            BUILD.json                    md5/sha256/magic/ikconfig evidence
                            SHA256SUMS                    hashes of every payload file
```

## Publish gate (all must hold)

1. `Image` magic is `1f2003d5` (raw arm64 Image, `booti`-compatible) and < 64 MiB
   (a larger Image at `0x41000000` overlaps the DTB window at `0x43000000`).
2. Embedded ikconfig has `CONFIG_ARM64_VA_BITS=39` — 52-bit is fatal on this SoC
   (Cortex-A76/A55 v8.2 lacks FEAT_LVA, vendor BL31/ATF panics invisibly).
3. `CONFIG_EFI_STUB` absent or `=n` — the vendor U-Boot 2018 `booti` path.
4. No `make` running and the Image has been quiescent for >= 90 s.
5. Image md5 not already in `builds/` (dedupe).

Rejections are logged to `opikernel/logs/publish-7.3-artifacts-rejected.log`, never pushed.

## Boot constraints baked into every artifact (32-bit U-Boot 2018)

- HARD ceiling `0x43999999`; kernel `0x41000000` (copy-down `0x40200000`), DTB `0x43000000`.
- `cp.b` / `ext4write` / `crc32` size arguments are parsed as **HEX**.
- `fdt resize 65536` before `booti`; `rootwait`; `modprobe.blacklist=aic8800_btlpm`.

`BUILD.json.publisher.boot_cmd` carries the exact U-Boot command line for that build.
