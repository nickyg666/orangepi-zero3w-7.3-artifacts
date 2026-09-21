# SUPERSEDED — do not install

This build's `Image.xz` decompresses to 41,666,568 B, magic `1f2003d5` (looks perfect) and
contains **zero** occurrences of the `sunxi-wakeupgen` driver match string.

The DTB shipped in every 7.3 bundle declares `/interrupt-controller@0` compatible
`allwinner,sunxi-wakeupgen`. A kernel without that driver cannot probe the irqchip, so
`pinctrl@2000000` — and every mmc/SDIO/pinmux consumer deferring on it — fails with `-517`
forever. That is exactly the 09-20 boot failure (no `mmc0` pins, no root device).

Verified by byte-reading both published Images:
- `20260920-143001-3056d664` → `strings -a Image | grep -c sunxi-wakeupgen` = **0** (pre-port)
- `20260920-231110-eff8af11` → same command = **1** (port landed; `System.map`: `t wakeupgen_init`,
  `d __of_table_sunxi_wakeupgen`)

Use `20260920-231110-eff8af11` (this repo's `LATEST`). `scripts/publish-7.3-artifacts.py` now hard-fails this
case (gate step 8, `irqchip_wakeupgen_facts()`), so it cannot recur.
