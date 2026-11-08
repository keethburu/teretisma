# Teretisma
The new fonts are based on the [Noto Sans](https://github.com/google/fonts/tree/main/ofl/notosans) and [Noto Serif](https://github.com/google/fonts/tree/main/ofl/notoserif) SemiCondensed families, distributed through [Google Fonts](https://github.com/google/fonts) and have been modified in order to meet the requirements of a wide variety of disciplines and publication forms.
They cover the Unicode characters for most modern scripts based on the Latin alphabet as well as Greek and Cyrillic alphabets. They further include linguistic characters (IPA and other phonetic extensions) and special characters for a wide range of specific transliteration forms (e.g., for Arabic or hieroglyphs).

![Graphic showing a preview of all Teretisma fonts listed in this repository](assets/images/font-preview.svg)

The characters included in our fonts come from the following Unicode blocks:
- Basic Latin / Latin-1 Supplement
- Latin Extended Additional / Latin Extended-A/B/D
- Cyrillic
- Greek / Greek Extended
- IPA Extensions
- Phonetic Extensions / Supplement
- Spacing Modifier Letters
- Control Pictures
- Combining Diacritical Marks / Supplement
- General Punctuation
- Geometric Shapes / Arrows

For scripts beyond the Latin, Greek, and Cyrillic alphabets additional fonts must be used.
For mathematical or logical operators the additional font [Teretisma Sans Math](/fonts/Teretisma-Sans-Math-Regular.otf) can be used (only in Regular style).

## Font Download
[Latest stable release](https://github.com/keethburu/teretisma/releases/latest) · [Installable OpenType fonts](https://github.com/keethburu/teretisma/releases/latest/download/teretisma-fonts.zip) · [TeX packages](https://github.com/keethburu/teretisma/releases/latest/download/teretisma-tex.zip)

## This repository
This repository provides:
1. The Teretisma Fonts Teretisma Sans, Teretisma Serif, Teretisma Sans Math, Teretisma Icons. see [Fonts](/fonts)
2. The Source Code to re-create the Teretisma font from Google's Noto SemiCondensed. see [Scripts](/scripts)

## Support
Use the issue tracker of the repository hosting this independent project.

## Heritage and independent development

Teretisma is an independent continuation of the [De Gruyter font repository](https://gitlab.com/degruyter-public/font/de-gruyter-sans_serif), copied from commit `e633c0d` with its complete Git history. We gratefully acknowledge De Gruyter, le-tex publishing services, and the original contributors for the fonts, glyph customisations, build tools, and TeX integration. Teretisma is not affiliated with or endorsed by De Gruyter.

The first Teretisma commit records the unchanged imported tree; the second renames the project. Subsequent builds refresh the Noto inputs directly from Google Fonts and regenerate the font distributions under the Teretisma installation names. Historical ownership and license notices remain as attribution. The inherited TeX PDF manuals have been reissued as text manuals with the renamed package references.

De Gruyter is historical provenance, not the ongoing upstream. [google/fonts](https://github.com/google/fonts) is the upstream distribution reference for Noto font updates. Its per-family directories contain the downloadable fonts, metadata, and applicable license:

- [Noto Sans](https://github.com/google/fonts/tree/main/ofl/notosans)
- [Noto Serif](https://github.com/google/fonts/tree/main/ofl/notoserif)
- [Noto Sans Symbols](https://github.com/google/fonts/tree/main/ofl/notosanssymbols)
- [Noto Sans Symbols 2](https://github.com/google/fonts/tree/main/ofl/notosanssymbols2)
- [Noto Sans Math](https://github.com/google/fonts/tree/main/ofl/notosansmath)

[New Athena Unicode](https://classicalstudies.org/publications-and-research/nau-download) remains a separate inherited glyph source, licensed under OFL 1.1 according to the bundled fonts' embedded notices.

The current source inputs are in `scripts/source_fonts/`. The Noto inputs are generated from the Google Fonts revision recorded in `upstream.lock.json`; the Teretisma manual masters and New Athena Unicode inputs retain their inherited provenance. The local `google-fonts` remote points to `https://github.com/google/fonts.git`; there is no De Gruyter remote or branch-tracking relationship. The Minion Math TeX support files are retained; Minion Math itself is a separate dependency and is not supplied or licensed by this project.

## License

The font software is licensed under the **SIL Open Font License 1.1 (OFL-1.1)**: see the root [LICENSE](LICENSE), its distribution copy [fonts/LICENSE](fonts/LICENSE), and the source-font copy [scripts/source_fonts/LICENSE](scripts/source_fonts/LICENSE). These include the historical copyright notices found in the bundled font metadata. Release ZIPs include the font license as `OFL.txt`.

Google Fonts supplies each Noto family's license in its own directory; for example, [Noto Sans OFL.txt](https://github.com/google/fonts/blob/main/ofl/notosans/OFL.txt). Current upstream copyright statements describe current upstream releases; they do not replace the historical notices belonging to our older bundled snapshots.

The inherited build scripts remain under **GNU GPL version 3 or later (GPL-3.0-or-later)** as stated in [scripts/LICENSE](scripts/LICENSE). The root font license does not relicense those scripts or any separately licensed third-party components. Existing copyright, author, trademark, and license notices remain intact; renaming the project does not transfer ownership of the inherited work.

Modified build scripts and TeX integration were renamed for Teretisma on 2026-11-08.

## Continuous upstream updates

GitHub Actions checks the five tracked Noto families in `google/fonts` every day at 05:17 UTC and can also be run manually. A change to unrelated Google Fonts families does not create an update. Each input and license is pinned by commit and SHA-256 in [upstream.lock.json](upstream.lock.json).

Changed inputs produce the next patch-version candidate on `automation/upstream` and a pull request. The build instantiates static SemiCondensed fonts at width 87.5 and weights 400/700, refreshes the symbol weights and math font, rebuilds the ten Teretisma OpenType fonts, and regenerates the Serif/Sans TeX Type 1 outlines and metrics. The manual specialist glyphs and hand-positioned compositions remain in the inherited masters; New Athena Unicode is a separately pinned input and is not fetched from Google Fonts.

Before an update is proposed, validation checks installation names, embedded licensing, character coverage, layout features, shaping, archive consistency, and XeLaTeX/pdfLaTeX rendering. Failures stop the update. Scheduled runs do not merge candidates or replace stable releases. GitHub must allow Actions to create pull requests under Settings → Actions → General; otherwise the validated update branch is still pushed and the run reports the permission error.

## Stable releases

Use [the latest stable release](https://github.com/keethburu/teretisma/releases/latest) for installation and a version tag such as `v0.1.0` for an immutable reference. The stable release assets are `teretisma-fonts.zip`, `teretisma-tex.zip`, `OFL.txt`, and `SHA256SUMS`. The latest font download has a permanent URL: [teretisma-fonts.zip](https://github.com/keethburu/teretisma/releases/latest/download/teretisma-fonts.zip).

A maintainer reviews and merges an upstream candidate, verifies its checks, updates the release notes, and tags the commit with `v` followed by the value in `VERSION`. The release workflow verifies that the tag and font version agree and publishes the committed, validated fonts. Tags are never moved to newer builds.

For local build commands and requirements, see [scripts/README.md](scripts/README.md).
