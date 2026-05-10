// Fonts defined as variables for easy customization
#let font-serif = "EB Garamond"
#let font-sans = "Inter"
#let font-mono = "JetBrains Mono"

#set page(
  paper: "a4",
  margin: 2cm,
)
#set text(
  font: font-serif,
  size: 11pt,
  lang: "en",
)
#set par(justify: true, leading: 0.65em)

// Headings in sans-serif
#show heading: set text(font: font-sans, weight: "semibold")
#show heading.where(level: 1): set text(size: 18pt)
#show heading.where(level: 2): set text(size: 14pt)

// Code in monospace
#show raw: set text(font: font-mono, size: 9.5pt)
#show raw.where(block: true): block.with(
  fill: luma(245),
  inset: 10pt,
  radius: 4pt,
  width: 100%,
)

// Document header
#align(center)[
  #text(font: font-sans, size: 26pt, weight: "bold")[
    My Typst Document
  ]

  #v(0.2cm)

  #text(font: font-sans, size: 11pt, fill: gray)[
    Deployed automatically via Vercel or Cloudflare Pages
  ]
]

#v(1cm)

= Introduction

This document is compiled automatically on every `git push` and served
as SVG by a CDN. You can edit this `document.typ` file and the result
will be updated on your site within seconds.

The body text uses *EB Garamond*, a digital revival of the typefaces
cut by Claude Garamont in the 16th century. Headings and UI use
_Inter_, and code uses `JetBrains Mono`.

= Typography

== Mathematics

A classic equation: $ integral_0^infinity e^(-x^2) dif x = sqrt(pi) / 2 $

The Pythagorean theorem: $a^2 + b^2 = c^2$, and Euler's identity:
$e^(i pi) + 1 = 0$.

== Source code

```python
def fibonacci(n: int) -> list[int]:
    """Return the first n Fibonacci numbers."""
    seq = [0, 1]
    for _ in range(n - 2):
        seq.append(seq[-1] + seq[-2])
    return seq[:n]

print(fibonacci(10))
```

== Quotes and emphasis

*Bold words*, _italic_, and `inline code` stand out clearly from
each other.

#quote(attribution: [Donald Knuth])[
  Typography exists to honor content.
]

= Going further

- Edit `document.typ` to change the content
- The build happens in `build.sh`
- The display page is `public/index.html`
- The fonts live in `fonts/` (all under the OFL license)
