// Native Typst drawings for Chapter 1. No image files, so they scale and
// recolor with the theme.

#import "/src/lib.typ": *

#let _ln(x1, y1, x2, y2, s: 0.9pt + ink) = place(top + left, line(start: (x1, y1), end: (x2, y2), stroke: s))
#let _at(x, y, body) = place(top + left, dx: x, dy: y, body)
#let _mono(body, size: 7pt, fill: muted) = text(font: mono, size: size, fill: fill, body)

// ---------- Figure: CCT scale ----------
#let cct-scale = {
  let w = 100%
  block(width: 100%, {
    rect(width: 100%, height: 0.9cm, radius: 2pt, stroke: 0.4pt + rule,
      fill: gradient.linear(rgb("#ff9447"), rgb("#ffc690"), rgb("#fff4e6"), rgb("#f4f7ff"), rgb("#cfdcff")))
    v(-0.5em)
    let ticks = ((2700, 0%), (3000, 7.9%), (4000, 34.2%), (5000, 60.5%), (6500, 100%))
    block(width: 100%, height: 1.2em, {
      for (k, x) in ticks {
        place(top + left, dx: x, line(start: (0pt, 0pt), end: (0pt, 4pt), stroke: 0.5pt + muted))
        let a = if x == 0% { left } else if x == 100% { right } else { center }
        place(top + left, dx: x - if a == right { 1.2cm } else if a == center { 0.6cm } else { 0cm }, dy: 5pt,
          box(width: 1.2cm, align(a, _mono[#k K])))
      }
    })
  })
}

// ---------- Figure: pad order ----------
#let pad-row = {
  let pads = (("V+ shared", ink), ("R", rgb("#d0342c")), ("G", rgb("#2e9e4f")), ("B", rgb("#2f6fd6")), ("WW", rgb("#e0a030")), ("CW", rgb("#8fb4e0")))
  align(center, stack(dir: ltr, spacing: 5pt, ..pads.map(((l, c)) => box(
    stroke: 0.6pt + rule, radius: 2pt, inset: (x: 7pt, y: 5pt),
    [#box(circle(radius: 3.2pt, fill: c), baseline: 1pt) #h(2pt) #_mono(size: 7.5pt, fill: ink, l)]))))
}

// ---------- Figure: common-anode schematic ----------
#let schematic = {
  let colors = (rgb("#d0342c"), rgb("#2e9e4f"), rgb("#2f6fd6"), rgb("#e0a030"), rgb("#8fb4e0"))
  let names = ("R", "G", "B", "WW", "CW")
  let W = 12.4cm
  let rail = 0.5cm
  let gnd = 6.0cm
  box(width: W, height: 6.8cm, {
    _ln(1.1cm, rail, W, rail, s: 1.1pt + ink)
    _ln(1.1cm, gnd, W, gnd, s: 1.1pt + ink)
    _at(0cm, rail - 0.18cm, _mono(size: 7.5pt, fill: ink)[+24 V])
    _at(0cm, gnd - 0.18cm, _mono(size: 7.5pt, fill: ink)[GND])
    // controller boundary
    _at(1.5cm, 3.6cm, rect(width: W - 1.7cm, height: 1.2cm, radius: 3pt,
      stroke: (paint: accent, thickness: 0.7pt, dash: "dashed")))
    for i in range(5) {
      let x = 2.6cm + i * 2.15cm
      // resistor zigzag
      _ln(x, rail, x, 0.9cm)
      let y0 = 0.9cm
      let pts = range(7).map(k => (x + if calc.odd(k) { 0.13cm } else if k == 0 or k == 6 { 0cm } else { -0.13cm }, y0 + k * 0.1cm))
      for k in range(6) { _ln(pts.at(k).at(0), pts.at(k).at(1), pts.at(k + 1).at(0), pts.at(k + 1).at(1)) }
      _ln(x, 1.5cm, x, 2.0cm)
      // LED (triangle pointing down + bar)
      _at(x - 0.22cm, 2.0cm, polygon(fill: colors.at(i), stroke: 0.7pt + ink, (0cm, 0cm), (0.44cm, 0cm), (0.22cm, 0.38cm)))
      _ln(x - 0.24cm, 2.38cm, x + 0.24cm, 2.38cm)
      _ln(x + 0.3cm, 2.05cm, x + 0.5cm, 1.9cm, s: 0.6pt + colors.at(i))
      _ln(x + 0.36cm, 2.2cm, x + 0.56cm, 2.05cm, s: 0.6pt + colors.at(i))
      _at(x - 0.75cm, 2.05cm, text(font: sans, size: 7.5pt, weight: "bold", names.at(i)))
      _ln(x, 2.38cm, x, 3.85cm)
      // switch
      _at(x - 0.32cm, 3.85cm, rect(width: 0.64cm, height: 0.75cm, radius: 2pt, fill: white, stroke: 0.7pt + ink,
        align(center + horizon, _mono(size: 6.5pt, fill: ink)[Q#(i + 1)])))
      _ln(x - 0.85cm, 4.22cm, x - 0.32cm, 4.22cm, s: 0.8pt + accent)
      _at(x - 0.92cm, 4.15cm, circle(radius: 0.06cm, fill: accent))
      _ln(x, 4.6cm, x, gnd)
    }
    _at(W - 1.6cm, 0.1cm, text(font: sans, size: 6.5pt, fill: muted)[on the strip])
    _at(1.6cm, 6.25cm, text(font: sans, size: 6.5pt, fill: accent)[Dashed box: inside the controller. Orange leads: PWM from the ESP32 to each switch.])
  })
}

// ---------- Figure: PWM at two duty cycles ----------
#let pwm-wave = {
  let wave(duty, label) = box(width: 11cm, height: 1.45cm, {
    let x0 = 1.6cm
    let T = 3cm
    let hi = 0.15cm
    let lo = 1.15cm
    _at(0cm, 0.55cm, _mono(size: 7pt)[#label])
    _ln(x0, lo, x0 + 3 * T + 0.3cm, lo, s: 0.4pt + rule)
    for k in range(3) {
      let a = x0 + k * T
      let b = a + duty * T
      _ln(a, lo, a, hi, s: 1pt + accent)
      _ln(a, hi, b, hi, s: 1pt + accent)
      _ln(b, hi, b, lo, s: 1pt + accent)
      _ln(b, lo, a + T, lo, s: 1pt + accent)
    }
    let avg = lo - duty * (lo - hi)
    _ln(x0, avg, x0 + 3 * T + 0.3cm, avg, s: (paint: ink, thickness: 0.6pt, dash: "dashed"))
    _at(x0 + 3 * T + 0.4cm, avg - 0.15cm, text(font: sans, size: 6.5pt, fill: ink)[avg])
  })
  align(center, stack(spacing: 4pt,
    wave(0.25, [D = 25%]),
    wave(0.75, [D = 75%]),
    box(width: 11cm, height: 0.5cm, {
      _ln(1.6cm, 0.2cm, 4.6cm, 0.2cm, s: 0.5pt + muted)
      _ln(1.6cm, 0.1cm, 1.6cm, 0.3cm, s: 0.5pt + muted)
      _ln(4.6cm, 0.1cm, 4.6cm, 0.3cm, s: 0.5pt + muted)
      _at(4.8cm, 0.06cm, _mono(size: 6.5pt)[T = 1/f ≈ 51 µs at 19.5 kHz])
    })))
}

// ---------- Figure: dimming curve, 8-bit vs 12-bit ----------
#let dim-curve = {
  let W = 10cm
  let H = 5cm
  let bmax = 0.25
  let dmax = 0.02
  let gamma = 2.8
  let px(b) = b / bmax * W
  let py(d) = H - calc.min(d, dmax) / dmax * H
  let series(levels) = {
    let pts = ()
    let n = 500
    for k in range(n + 1) {
      let b = bmax * k / n
      let d = b
      d = calc.pow(b, gamma)
      if levels != none { d = calc.round(d * levels) / levels }
      pts.push((px(b), py(d)))
    }
    pts
  }
  let poly(pts, s) = place(top + left, curve(stroke: s, curve.move(pts.first()), ..pts.slice(1).map(p => curve.line(p))))
  align(center, box(width: W + 1.6cm, height: H + 1.3cm, {
    place(top + left, dx: 1.3cm, box(width: W, height: H, {
      // grid
      for i in range(6) { _ln(px(bmax * i / 5), 0cm, px(bmax * i / 5), H, s: 0.3pt + rule) }
      for j in range(5) { _ln(0cm, py(dmax * j / 4), W, py(dmax * j / 4), s: 0.3pt + rule) }
      poly(series(none), (paint: ink, thickness: 0.7pt, dash: "dashed"))
      poly(series(4095), 0.8pt + blue)
      poly(series(255), 1.1pt + accent)
      _ln(0cm, 0cm, 0cm, H, s: 0.6pt + ink)
      _ln(0cm, H, W, H, s: 0.6pt + ink)
      for i in range(6) { _at(px(bmax * i / 5) - 0.4cm, H + 0.12cm, box(width: 0.8cm, align(center, _mono(size: 6.3pt)[#(i * 5)%]))) }
      for j in range(5) { _at(-1.15cm, py(dmax * j / 4) - 0.15cm, box(width: 1cm, align(right, _mono(size: 6.3pt)[#calc.round(j * 0.5, digits: 1)%]))) }
      // legend
      _at(0.3cm, 0.3cm, block(fill: white, stroke: 0.4pt + rule, inset: 5pt, {
        set text(font: sans, size: 6.8pt)
        grid(columns: 2, column-gutter: 5pt, row-gutter: 4pt, align: horizon,
          line(length: 0.6cm, stroke: 1.1pt + accent), [8-bit (256 steps)],
          line(length: 0.6cm, stroke: 0.8pt + blue), [12-bit (4,096 steps)],
          line(length: 0.6cm, stroke: (paint: ink, thickness: 0.7pt, dash: "dashed")), [ideal curve, γ = 2.8])
      }))
    }))
    place(top + left, dx: 1.3cm, dy: H + 0.65cm, box(width: W, align(center, text(font: sans, size: 7pt)[Brightness requested (slider)])))
  }))
}

// ---------- Figure: bedroom layout ----------
#let room-layout = {
  let ww = rgb("#e0a030")
  let cw = rgb("#8fb4e0")
  box(width: 12cm, height: 7.4cm, {
    // ceiling
    _at(4.2cm, 1.0cm, rect(width: 7.2cm, height: 5.4cm, stroke: (paint: muted, thickness: 0.5pt, dash: "dashed")))
    _at(6.3cm, 3.4cm, align(center, _mono(size: 7pt)[12 ft × 11 ft ceiling\ perimeter ≈ 14 m]))
    // segment A: top + right
    _ln(4.5cm, 1.3cm, 11.1cm, 1.3cm, s: 3.5pt + ww)
    _ln(11.1cm, 1.3cm, 11.1cm, 6.0cm, s: 3.5pt + ww)
    _at(7.2cm, 1.55cm, text(font: sans, size: 7.5pt, weight: "bold")[Segment A · ~7 m])
    // segment B: left + bottom
    _ln(4.5cm, 1.6cm, 4.5cm, 6.1cm, s: 3.5pt + cw)
    _ln(4.5cm, 6.1cm, 10.85cm, 6.1cm, s: 3.5pt + cw)
    _at(4.8cm, 5.1cm, text(font: sans, size: 7.5pt, weight: "bold")[Segment B · ~7 m])
    _at(11.0cm, 5.98cm, circle(radius: 0.12cm, stroke: 0.8pt + ink, fill: white))
    _at(9.0cm, 6.55cm, _mono(size: 6.5pt)[ends meet, not joined])
    // controller and supply
    _at(2.6cm, 0.0cm, rect(width: 1.6cm, height: 0.75cm, radius: 3pt, stroke: 0.8pt + ink, align(center + horizon, text(font: sans, size: 7.5pt, weight: "bold")[Deca])))
    _ln(4.2cm, 0.6cm, 4.55cm, 1.3cm, s: 0.8pt + ww)
    _ln(4.0cm, 0.75cm, 4.5cm, 1.6cm, s: 0.8pt + cw)
    _ln(3.2cm, 0.75cm, 3.2cm, 2.6cm, s: 1pt + ink)
    _at(2.1cm, 1.5cm, _mono(size: 6.5pt)[14 AWG])
    _at(0.6cm, 2.6cm, rect(width: 2.8cm, height: 0.95cm, radius: 3pt, stroke: 0.8pt + ink, align(center + horizon, {
      text(font: sans, size: 7.5pt, weight: "bold")[24 V brick]; linebreak(); _mono(size: 6pt)[GST280A24] })))
    _ln(3.75cm, 0.75cm, 3.75cm, 4.6cm, s: (paint: ink, thickness: 0.6pt, dash: "dashed"))
    _ln(3.4cm, 4.6cm, 3.75cm, 4.6cm, s: (paint: ink, thickness: 0.6pt, dash: "dashed"))
    _at(2.5cm, 3.9cm, _mono(size: 6.5pt)[22 AWG])
    _at(0.6cm, 4.2cm, rect(width: 2.8cm, height: 0.85cm, radius: 3pt, stroke: 0.8pt + ink, align(center + horizon, {
      text(font: sans, size: 7.5pt, weight: "bold")[Door button]; linebreak(); _mono(size: 6pt)[momentary] })))
  })
}

// ---------- Figure: SMD vs COB strip, lit ----------
#let smd-vs-cob = {
  let L = 11cm
  let H = 1.1cm
  let glow = rgb("#ffb347")
  let core = rgb("#fff4dc")
  let strip(body) = box(width: L, height: H, {
    place(rect(width: L, height: H, radius: 2pt, fill: rgb("#ece7da")))
    place(dy: 0.12cm, line(length: L, stroke: 0.6pt + rgb("#c99a5b")))
    place(dy: H - 0.12cm, line(length: L, stroke: 0.6pt + rgb("#c99a5b")))
    body
  })
  let smd = strip({
    for i in range(12) {
      let cx = 0.55cm + i * 0.9cm
      place(dx: cx - 0.42cm, dy: H / 2 - 0.42cm, circle(radius: 0.42cm,
        fill: gradient.radial(glow.transparentize(30%), glow.transparentize(100%))))
      place(dx: cx - 0.2cm, dy: H / 2 - 0.2cm, rect(width: 0.4cm, height: 0.4cm, radius: 1pt, fill: core, stroke: 0.5pt + rgb("#d89a4a")))
    }
  })
  let cob = strip({
    place(dx: 0.15cm, dy: H / 2 - 0.4cm, rect(width: L - 0.3cm, height: 0.8cm, radius: 0.4cm,
      fill: gradient.linear(glow.transparentize(100%), glow.transparentize(35%), glow.transparentize(100%), angle: 90deg)))
    place(dx: 0.3cm, dy: H / 2 - 0.17cm, rect(width: L - 0.6cm, height: 0.34cm, radius: 0.17cm, fill: core, stroke: 0.5pt + rgb("#d89a4a")))
  })
  let tag(t) = text(font: sans, size: 7pt, weight: "bold", fill: rgb("#e8e2d4"), tracking: 0.06em, upper(t))
  align(center, block(fill: rgb("#2b2824"), radius: 4pt, inset: (x: 12pt, y: 12pt),
    grid(columns: (auto, auto), column-gutter: 8pt, row-gutter: 12pt, align: (right + horizon, left + horizon),
      tag[SMD], smd,
      tag[COB], cob)))
}

// ---------- Figure: the units chain, V × I = P ----------
#let units-chain = {
  let card(sym, name, unit, per, val, color) = box(
    width: 3.3cm, stroke: 0.7pt + color, radius: 3pt, inset: 7pt,
    align(center, stack(spacing: 4pt,
      text(font: serif, size: 20pt, weight: "bold", fill: color, sym),
      text(size: 8pt, weight: "bold", fill: ink, name),
      _mono(size: 7.5pt, fill: muted, unit),
      line(length: 2.4cm, stroke: 0.4pt + rule),
      text(size: 7.5pt, fill: ink, per),
      _mono(size: 8pt, fill: color, val))))
  let op(s) = box(height: 3cm, align(horizon, text(font: serif, size: 22pt, fill: muted, s)))
  align(center, stack(dir: ltr, spacing: 6pt,
    card($V$, [Voltage], [J/C = volt], [energy each coulomb carries], [24 J/C], rgb("#2f6fd6")),
    op[×],
    card($I$, [Current], [C/s = ampere], [coulombs arriving each second], [7.6 C/s], rgb("#2e9e4f")),
    op[=],
    card($P$, [Power], [J/s = watt], [energy delivered each second], [182 J/s], accent),
  ))
}

// ---------- Figure: the bucket line ----------
#let bucket-line = {
  let W = 12.4cm
  box(width: W, height: 3.3cm, {
    // source and load
    _at(0cm, 0.9cm, rect(width: 2.2cm, height: 1.5cm, radius: 3pt, stroke: 0.7pt + ink, fill: shade,
      align(center + horizon, text(size: 8pt)[Supply \ #_mono(fill: ink)[24 V]])))
    _at(W - 2.2cm, 0.9cm, rect(width: 2.2cm, height: 1.5cm, radius: 3pt, stroke: 0.7pt + ink, fill: shade,
      align(center + horizon, text(size: 8pt)[Strip \ #_mono(fill: ink)[182 W]])))
    // conveyor
    _ln(2.2cm, 1.65cm, W - 2.2cm, 1.65cm, s: 0.6pt + muted)
    for i in range(6) {
      let x = 2.8cm + i * 1.25cm
      _at(x, 1.0cm, rect(width: 0.75cm, height: 0.6cm, radius: (bottom: 3pt), stroke: 0.7pt + rgb("#2f6fd6"),
        fill: rgb("#2f6fd6").lighten(75%)))
      _at(x + 0.1cm, 1.06cm, _mono(size: 6pt, fill: rgb("#2f6fd6"))[24 J])
    }
    _at(2.6cm, 0.25cm, text(size: 7.5pt, fill: rgb("#2f6fd6"))[each bucket = 1 coulomb, holding 24 J  →  that is $V$])
    _at(2.6cm, 2.15cm, text(size: 7.5pt, fill: rgb("#2e9e4f"))[7.6 buckets pass every second  →  that is $I$])
    _at(2.6cm, 2.7cm, text(size: 7.5pt, fill: accent)[24 J × 7.6 per second = 182 J every second  →  that is $P$])
  })
}
