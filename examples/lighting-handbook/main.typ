// The Apartment Lighting Handbook — Chapter 1, set with the textbook template.
// Build: python3 scripts/build.py examples/lighting-handbook/main.typ

#import "/src/lib.typ": *
#import "figures.typ": *

#show: book.with(
  title: [The Apartment Lighting Handbook],
  short-title: [Apartment Lighting],
  subtitle: [Chapter 1: Lighting a Room],
  series: [Volume I · DIY Systems Series],
  abstract: [RGBCCT ceiling strips, analog PWM control, 24 V power and ESPHome, taught through the bedroom build.],
  author: "BIFL & DIY",
  meta: (
    ("Build", [Bedroom · instance 1 of 6]),
    ("System", [24 V RGBCCT COB · QuinLED An-Penta-Deca · ESPHome → Home Assistant → Apple Home]),
    ("Prepared for", [Zuri]),
    ("Edition", [Second edition · 7 November 2026]),
  ),
  cheat-sheet: [
    #cheat-block([Key equations])[
      #grid(columns: (1fr, auto), row-gutter: 5pt,
        [PWM power], $overline(P) = D P_"full"$,
        [Dimmest step], $D_"min" = 1 slash 2^n$,
        [Gamma], $D = b^gamma, gamma = 2.8$,
        [Power], $P = V I$,
        [Ohm's law], $V = I R$,
        [Two-wire drop], $Delta V = 2 I L r$,
        [Illuminance], $E = Phi dot "UF" slash A$)
    ]
    #cheat-block([Sizing rules])[
      - Supply: $P_"rated" >= 1.25 P_"load"$. If not, cap outputs in firmware.
      - Strip: 20 W/m at full; about 10 m per feed at 24 V.
      - Feed: keep drop under about 3% of 24 V. 14 AWG ≈ 8.3 mΩ/m.
      - Deca: 5 A per channel, 30 A total.
    ]
    #cheat-block([Pads at a cut])[
      V+ (shared) · R · G · B · WW · CW. Order varies by maker: read the printed letters, never the wire colors. Cut only on the printed line (every 41.6 mm).
    ]
    #cheat-block([Fault isolation])[
      - One color dark on one segment → that pigtail or terminal.
      - One color dark on all segments → GPIO mapping in YAML.
      - Everything dark → supply, fuse, controller.
      - Far end dim or yellow → voltage drop; inject power.
      - Button works, app doesn't → Home Assistant or HomeKit Bridge.
    ]
    #cheat-block([Build order])[
      + Flash and adopt in Home Assistant.
      + Bench test with a 1 m offcut.
      + Cut, join and light segments on the floor.
      + Test-fit channel and diffusers on the bench.
      + Mount, connect, 30-minute heat check.
      + Expose to Apple Home. Stop. Document.
    ]
    #cheat-block([ESPHome output line])[
      #text(size: 7.2pt, raw("- { platform: ledc, id: a_r, pin: GPIO_A_R,\n    frequency: 19531Hz, max_power: 0.8 }", lang: "yaml", block: true))
    ]
  ],
)

#introduction(
  about: [
    This is a book about lighting your apartment with LED strips you install, control and repair yourself. It teaches from first principles, the way a school textbook does, but every example uses the real numbers from your build. You don't need to read it in order. Each chapter stands on its own and points back to the pages it builds on, so you can jump straight to the part you need tonight.

    The book is organized into parts. *Part I* explains how a lit room works: light, strips, dimming, power and control, each taught through the bedroom. Later volumes take one subsystem each and go deeper. *The Part of Tens* closes the book with short lists you can scan in a minute.
  ],
  assumptions: (
    [You remember a little school physics: voltage, current and power. If not, Chapter 1 opens with a refresher.],
    [You can use a screwdriver and a crimper, and you're willing to learn to read a datasheet.],
    [You will never open a mains-voltage device. Everything you wire in this book runs at 24 V.],
    [You run Home Assistant, or you're willing to. The book covers what happens when it's down.],
  ),
  beyond: [The Cheat Sheet at the front of this book collects the formulas, sizing rules and fault table on one page. The ESPHome configuration lives in your git repository, which is the real source of truth for the build.],
  where-next: [If you're about to buy parts, start with Appendix B and the supply sizing in Section 1.4. If something is already installed and misbehaving, go to Appendix E. If you want to understand the whole system, start at Chapter 1 and read straight through.],
)

#part([How a Lit Room Works], blurb: [Five small systems make a ceiling of light: a source, a controller, a supply, a channel and the software that ties them together. This part builds each one, using the bedroom as the worked case.])

// ======================================================================
#chapter(
  [Lighting a Room],
  lead: [A ceiling of light is five small systems working together: a *source* that makes light, a *controller* that dims it, a *supply* that feeds it, a *channel* that shapes it, and *software* that lets you ask for it. This chapter builds each one in that order, using your bedroom as the worked case.],
  objectives: (
    [Explain how five LED channels mix into any color and any shade of white.],
    [Read a strip's pads and predict which faults kill one color and which kill all of them.],
    [Describe how PWM dims an LED, and why bit depth decides how well it fades to dark.],
    [Size a power supply and a feed wire for a given run, with margin.],
    [Trace what still works when Wi-Fi or Home Assistant fails.],
  ),
)

#background[
  You need three ideas from school physics. *Voltage* is the push that drives charge around a circuit, in volts (V). *Current* is how much charge flows past a point each second, in amperes (A). *Power* is how fast energy is used, in watts (W). If any of these feel shaky, the first two Read More links at the end of Section 1.4 are a ten-minute refresher.
]

== What light is made of

Every color your strip shows is a mix of three primaries: red, green and blue. Light from separate sources mixes by adding: red plus green looks yellow, and all three at full look white. A screen works this way, and so does the RGB half of your strip.

#definition(title: [Additive mixing])[A color produced by overlapping light sources, where the perceived result is the sum of their spectra. Red, green and blue are the additive primaries.] <def:additive>

#keyterm("Phosphor")[A coating that absorbs short-wavelength light and re-emits it as a broad spectrum. It is what turns a blue die white.]
The trouble is that RGB white is a poor white. Each emitter is a narrow spike of wavelengths, so the gaps between them are missing from the mix. Objects that reflect those missing wavelengths look dull. Skin goes grey and wood looks like plastic. White LEDs solve this with a blue emitter coated in #term("phosphor"), a material that absorbs some blue and re-emits it across a broad band.

#history(era: "1962–2014", title: [Why white LEDs had to wait for blue])[
  The first visible LED glowed red. Nick Holonyak Jr. demonstrated it at General Electric's lab near Syracuse in October 1962, using a gallium arsenide phosphide crystal @holonyak-1962. Green followed, but blue resisted for three decades. Without blue there was no white LED, because phosphor needs short-wavelength light to pump. Isamu Akasaki and Hiroshi Amano at Nagoya University, and Shuji Nakamura at Nichia in Tokushima, finally made bright blue gallium nitride LEDs in the early 1990s. They shared the 2014 Nobel Prize in Physics for it @nobel-2014. Every white emitter on your strip is a blue die under phosphor: their invention, mass-produced.
]

Your strip carries two phosphor whites: a warm one near 2800–3200 K and a cool one near 6000–6500 K @sll-strip. Mixing the two places the white anywhere between them.

#definition(title: [Correlated color temperature, CCT])[The temperature, in kelvin, of an ideal glowing body whose color most closely matches a given white light. Lower values are warmer (more orange); higher values are cooler (more blue).] <def:cct>

#did-you-know[The naming runs backward. "Warm" white has the *lower* temperature: 2700 K is a candle-like glow, 6500 K is overcast daylight.]
#figure(cct-scale, caption: [Correlated color temperature. Candlelight sits left of this scale, overcast daylight at its right end. Your strip spans roughly 2800–6500 K.]) <fig:cct>

#intuition(title: [Why color has a temperature])[
  Heat any solid and it glows. A stove coil goes dull red, then orange; a tungsten filament at about 2700 K is yellow-white; the Sun's surface, near 5800 K, looks white. Physicists call the ideal version a *blackbody*, and its color depends only on its temperature. An LED is not hot at all, so its CCT is a comparison: "this white looks like a blackbody at 3000 K." That is why the word *correlated* is in the name.
]

#trade[Designers use warm white (2700–3000 K) in bedrooms and evenings, and cooler white (4000 K and up) for tasks. Tunable CCT lets one fixture do both.]
RGB plus CCT gives the strip type its name: #term("RGBCCT"), five channels in all. A second number describes how good a white is.

#definition(title: [Color rendering index, CRI or R#sub[a]])[A score out of 100 for how faithfully a light reproduces a standard set of test colors, compared with a reference source of the same CCT.] <def:cri>

#sidenote[CRI dates from 1965, written to rate early fluorescent tubes. It averages only eight pastel samples. IES TM-30 (2015) scores 99 samples and catches the saturated reds CRI misses @doe-tm30.]
Your strip is specified above 90 @sll-strip, the threshold most lighting designers treat as good for living spaces.

#check-yourself(
  ([Why does an RGB-only strip make a poor white, even at full power?], [Each emitter is a narrow spike, so wavelengths between the spikes are missing; colors that reflect those wavelengths look dull.]),
  ([Which is warmer, a 3000 K white or a 5000 K white?], [3000 K. Lower CCT is warmer (more orange).]),
)

#read-more(
  (title: "The Nobel Prize in Physics 2014: Popular information", url: "https://www.nobelprize.org/prizes/physics/2014/popular-information/", source: "nobelprize.org", kind: "article", note: [How blue LEDs work and why they took thirty years. Clear diagrams, no prerequisites.]),
  (title: "TM-30 Frequently Asked Questions", url: "https://www.energy.gov/eere/ssl/tm-30-frequently-asked-questions", source: "U.S. Department of Energy", kind: "article", note: [What CRI misses and how TM-30 fixes it.]),
  (title: "Color temperature", url: "https://en.wikipedia.org/wiki/Color_temperature", source: "Wikipedia", kind: "article"),
)

== How a strip makes light

#keyterm("FPC")[Flexible printed circuit, the ribbon the LEDs sit on.]
#keyterm("COB")[Chip on board. Dense LED dies under one phosphor layer, giving a dotless line.]
An LED strip is a #term("flexible printed circuit", display: [flexible printed circuit]): a thin ribbon of copper on polyimide, with LEDs soldered along it. Older strips use spaced packages called SMD, which show as a row of dots. Your strip is #term("COB"), chip on board: 840 tiny dies per meter under a continuous strip of phosphor @sll-strip, so it reads as one unbroken line.

#figure(smd-vs-cob, caption: [SMD and COB strips, lit. SMD packages sit apart and show as dots; COB dies sit under one continuous phosphor strip and read as a line.]) <fig:cob>

#trade[Small resistors on each circuit set the current through its LEDs. That is why the strip can run straight from a constant-voltage supply.]
The strip repeats one short circuit along its length, each with copper pads at both ends. You can cut between any two. On your strip the interval is 41.6 mm @sll-strip, marked by a printed line.

#definition(title: [Cut interval])[The length of one repeating circuit on a strip. Cuts are only valid at multiples of it; the partial circuit left by a cut anywhere else does not light.] <def:cut>

=== Reading the pads

#watch-out[Read the letters printed on the copper pads before connecting anything. Wire colors on a pigtail are not a standard.]
Each cut point exposes six pads. One carries *+24 V* to every LED. The other five are the return paths for each color, which the controller connects to ground to switch that color on.

#figure(pad-row, caption: [The six pads at a cut point on an RGBCCT strip. The order is not standardized between makers.]) <fig:pads>

#definition(title: [Common anode])[A wiring scheme in which all LED channels share one positive supply conductor, and each channel is switched on its negative (return) side.] <def:anode>

#figure(schematic, caption: [A common-anode RGBCCT strip and its controller. Every color hangs from the same +24 V rail; each is switched to ground by its own transistor.]) <fig:schematic>

#trade[Use this theorem as your first diagnostic. One dark color: check that pigtail. Everything dark: check the supply and the controller's input fuse.]
This structure makes faults readable. Because power is shared and the returns are not, the pattern of what goes dark tells you where to look.

#theorem(title: [Fault isolation in a common-anode strip])[If one color fails along a whole segment while the other four work, the fault lies in that color's return path: its pad connection, its wire, or its switch. If all five fail together, the fault lies in the shared supply path.] <thm:fault>

#remember[One dark color: look at that color's own wire. Everything dark: look at the supply.]
#proof[The five colors share every part of the +24 V path. A break there removes voltage from all of them, so it cannot darken one color alone. The only parts unique to a single color are its own return pad, conductor and switch. A failure confined to one color must therefore be in one of those.]

#mistake(
  wrong: [Matching the pigtail's wire colors to the strip because "red goes to R".],
  right: [Read the printed pad letters at the cut, then follow each conductor to its terminal.],
)[Pigtail colors vary by maker and even by batch. A swapped pair does not damage anything, but it makes @thm:fault point at the wrong channel.]

#check-yourself(
  ([Can you cut the strip 20 mm from a cut line?], [No. Cuts are valid only at multiples of the 41.6 mm cut interval; the partial circuit will not light.]),
  ([All five colors on one segment are dark. Where do you look first?], [The shared supply path: the supply, the controller's input fuse, and the +24 V conductor to that segment.]),
)

== How a controller dims

An LED does not dim gracefully when you lower its voltage. Below a threshold it simply switches off, and its color drifts on the way down. So controllers dim by switching the LED fully on and fully off, faster than the eye can follow.

#definition(title: [Pulse-width modulation, PWM])[A method of controlling average power by switching a load fully on and off at a fixed frequency $f$, varying the fraction of each period that it is on.] <def:pwm>
#definition(title: [Duty cycle])[The fraction $D$ of each PWM period during which the output is on, with $0 <= D <= 1$.] <def:duty>
#notation($D$, [duty cycle, fraction of a PWM period that is on])
#notation($f$, [PWM frequency], unit: [Hz])

#figure(pwm-wave, caption: [PWM at two duty cycles. The dashed line marks the average the eye perceives.]) <fig:pwm>

#intuition(title: [Why switching beats lowering the voltage])[
  An LED is a diode. Below about its forward voltage almost no current flows; just above it, current climbs steeply. Small changes in voltage therefore cause large, unpredictable changes in brightness and color, and the curve shifts with temperature. Switching uses only the two states an LED handles perfectly, fully on at its rated current and fully off, and lets time do the averaging. Your eye integrates the flashes into one steady level.
]

#theorem(title: [Average power under PWM])[For a load drawing power $P_"full"$ when fully on, PWM at duty cycle $D$ delivers average power $ overline(P) = D dot P_"full". $] <thm:pwm>
#proof[In each period $T = 1 slash f$ the load draws $P_"full"$ for time $D T$ and nothing for $(1 - D) T$. Energy per period is $D T P_"full"$; dividing by $T$ gives the average.]

#keyterm("MOSFET")[A transistor used as a fast electronic switch. In low-side switching it sits between the load and ground.]
Five channels, five duty cycles: that is how the controller sets brightness and color at once. The switching is done by a #term("MOSFET"), one per channel, between the strip's return pad and ground. The QuinLED An-Penta-Deca, the Deca for short, has fifteen, rated 5 A each and 30 A together @quinled-deca: enough for three RGBCCT segments.

=== Frequency and bit depth

#keyterm("Bit depth")[Number of bits describing the duty cycle. $n$ bits give $2^n$ levels.]
Two settings decide how good the dimming looks. *Frequency* is cycles per second. Too low, and flicker shows, especially on phone cameras. *Bit depth* $n$ sets how finely the duty cycle can be chosen.

#principle(title: [Dimming resolution])[A PWM output with bit depth $n$ can only produce duty cycles in steps of $1 slash 2^n$. The dimmest non-zero level is $D_"min" = 1 slash 2^n$.] <pr:resolution>

#keyterm("Gamma correction")[A power-law curve applied to requested brightness so dimming feels even to the eye.]
At 8 bits there are 256 steps; at 12 bits there are 4,096. That sounds like plenty until you account for how eyes work. We see brightness roughly logarithmically, so firmware bends the requested brightness $b$ through a #term("gamma correction", display: [gamma]) curve before it becomes a duty cycle: $D = b^gamma$. ESPHome's default is $gamma = 2.8$.
#notation($gamma$, [gamma exponent of the brightness curve])
#notation($b$, [requested brightness, 0 to 1])

#deep-dive(title: [Why the exponent is near 3])[
  Your eye does not judge brightness linearly. The CIE 1976 lightness scale, L\*, which color scientists use to model perceived lightness, grows roughly with the cube root of luminance. To make equal slider steps *feel* equal, firmware has to undo that compression by raising brightness to a power near 3. Values between 2.2 and 3 are common; ESPHome's 2.8 sits at the steep end, which is why its dark end needs the extra bit depth.
]

#example(title: [How much of the slider is dead at the dark end?], steps: (
  ([Goal], [Find the slider position $b$ below which the output rounds to zero duty.]),
  ([Setup], [The first non-zero duty is $1 slash 2^n$. Solve $b^gamma = 1 slash 2^n$, so $b = (1 slash 2^n)^(1 slash gamma)$.]),
  ([8-bit], [$b = (1 slash 256)^(1 slash 2.8) approx 0.138$. The bottom 13.8% of the slider is either off or a single coarse step.]),
  ([12-bit], [$b = (1 slash 4096)^(1 slash 2.8) approx 0.051$. Only the bottom 5% is lost, and the steps above it are 16 times finer.]),
  ([Result], [For a light that must fade to a nightlight, 12-bit matters. QuinLED recommends about 19.5 kHz at 12-bit under ESPHome; WLED drives these boards at 8-bit only @quinled-caps.]),
))[] <ex:dead>

#figure(dim-curve, caption: [The dark end of the dimming curve. At 8-bit the requested brightness turns into a coarse staircase; at 12-bit the staircase hugs the ideal curve.]) <fig:curve>

#trade[WLED's strengths are effects on addressable strips. On an analog strip the dark-end smoothness wins, which is why this build runs ESPHome.]
@ex:dead is the quantitative reason behind the control-plane choice made during planning: the same hardware dims visibly better under ESPHome than under WLED.

#did-you-know[Phone cameras read the sensor one row at a time. If the PWM frequency is low, each row catches a different part of the on-off cycle, and you see dark bands roll across the video.]
#check-yourself(
  ([A channel is at 40% duty and draws 20 W when fully on. What is its average power?], [$0.4 times 20 = 8$ W, by @thm:pwm.]),
  ([Why does the dark end matter more than the bright end when choosing bit depth?], [Gamma correction squeezes the dark end of the slider into very few duty values, so coarse steps show there first.]),
)

#read-more(
  (title: "QuinLED An-Penta-Mini capabilities", url: "https://quinled.info/quinled-an-penta-mini-capabilities/", source: "QuinLED", kind: "datasheet", note: [PWM frequency and bit depth under ESPHome versus WLED.]),
  (title: "Pulse-width modulation", url: "https://en.wikipedia.org/wiki/Pulse-width_modulation", source: "Wikipedia", kind: "article"),
)

== How power reaches the strip

#keyterm("SMPS")[Switch-mode power supply. Efficient and compact; every LED brick is one.]
Your wall gives 120 V alternating current; the strip wants 24 V direct current. The box in between is a #term("switch-mode power supply", display: [switch-mode power supply]): it rectifies the mains, chops it at high frequency through a small transformer, and regulates a steady output.

#definition(title: [Constant voltage, CV])[A supply that holds its output voltage fixed and lets the load draw whatever current it needs, up to the supply's rating.] <def:cv>

#watch-out[Never open the supply or wire anything on its mains side. The SELV boundary is the brick's output cable.]
#keyterm("SELV")[Safety extra-low voltage. The 24 V side, safe to touch and to wire yourself.]
The supply is the only part of the build that touches mains, by design. It is a sealed, certified product, cULus-listed @digikey-gst280, that plugs into an outlet. Everything after its output is safety extra-low voltage, #term("SELV"), which you can wire yourself.

=== Power, current and headroom

#principle(title: [Electrical power])[Power equals voltage times current: $P = V I$. For a fixed supply voltage, current rises in direct proportion to power.] <pr:power>
#notation($P$, [power], unit: [W])
#notation($V$, [voltage], unit: [V])
#notation($I$, [current], unit: [A])

#keyterm("Derating")[Running a part below its maximum rating to extend its life.]
Strip datasheets give watts per meter; multiply by length for the load. A supply run near its limit runs hot, and heat is what ages its capacitors. The strip maker recommends 25% headroom @sll-strip.

#remember[Size the supply at 1.25 × the load. If it doesn't fit, lower the load in firmware, not the margin.]
#principle(title: [Supply sizing])[Choose a supply with rated power $P_"rated" >= 1.25 dot P_"load"$. If no suitable supply exists, *derate* the load in firmware until the inequality holds.] <pr:sizing>

#watch-out[Buy supplies from authorized distributors such as DigiKey or Mouser. Counterfeit Mean Well units are common on marketplaces.]
The bedroom is the first real test of this principle.

#example(title: [Sizing the bedroom supply], steps: (
  ([Given], [Perimeter about 14 m. Strip draws 20 W/m at full @sll-strip. Supply: Mean Well GST280A24, 280 W @digikey-gst280.]),
  ([Load], [$P_"load" = 14 "m" times 20 "W/m" = 280 "W"$]),
  ([Need], [$1.25 times 280 = 350 "W" > 280 "W"$. The rule fails.]),
  ([Fix], [Cap every output at 80% in firmware: $P_"load" = 0.8 times 280 = 224 "W"$.]),
  ([Check], [$1.25 times 224 = 280 "W" <= 280 "W"$. The rule holds exactly, and the room still gets far more light than it needs (@ex:lux).]),
))[] <ex:supply>

#mistake(
  wrong: [Buying a 280 W supply for a 280 W load because "the numbers match".],
  right: [Size to 1.25 × load, or derate the load until it fits.],
)[A supply at 100% runs at its hottest, and its electrolytic capacitors dry out fastest there. The result is a supply that works on day one and fails in year two.]

#trade[Ripple and noise is the AC left on a DC output. This supply is rated 280 mV peak to peak @master-gst280.]
A capped supply also runs cooler, which slows the drying of its electrolytic capacitors, the most common way these supplies eventually fail.

=== Resistance and voltage drop

Current flowing through copper loses voltage along the way. That loss heats the wire and, on a strip, shows up as dimmer, slightly yellower light at the far end.

#history(era: "1827", title: [A schoolteacher's law])[
  Georg Simon Ohm was teaching mathematics at a Jesuit gymnasium in Cologne when he began measuring how current through a wire depended on its length and thickness. He published the result in Berlin in 1827 as _Die galvanische Kette, mathematisch bearbeitet_, "The galvanic circuit investigated mathematically" @ohm-1827. The reception was cold, and Ohm resigned his post. Recognition came later. The Royal Society gave him the Copley Medal in 1841, and the unit of resistance carries his name.
]

#theorem(title: [Ohm's law])[The voltage across a conductor equals the current through it times its resistance: $V = I R$.] <thm:ohm>
#notation($R$, [resistance], unit: [Ω])

#keyterm("Ampacity")[The current a wire can carry continuously without overheating.]
#corollary(title: [Drop on a two-wire run])[A feed of length $L$ made of wire with resistance $r$ per meter, carrying current $I$, loses $ Delta V = I dot 2 L dot r, $ since current travels out on one conductor and back on the other.] <cor:drop>
#notation($Delta V$, [voltage drop along a conductor], unit: [V])
#notation($r$, [wire resistance per meter], unit: [Ω/m])
#notation($L$, [length of a run], unit: [m])

#keyterm("AWG")[American Wire Gauge. Lower numbers are thicker and have less resistance per meter.]
#did-you-know[AWG numbers come from wire drawing: a finer wire is pulled through more dies. The scale was set by Brown & Sharpe, a Rhode Island instrument maker, and adopted by American wire mills in 1857 @awg-wiki.]
The gauge of a wire sets its resistance per meter, so the corollary turns wire choice into arithmetic.

#example(title: [Feed wire and channel current], steps: (
  ([Feed], [$I = P slash V = 224 "W" slash 24 "V" approx 9.3 "A"$ on the brick-to-Deca wire.]),
  ([Drop], [14 AWG copper has $r approx 8.3 "mΩ/m"$. For a 3 m run: $Delta V = 9.3 times 6 times 0.0083 approx 0.46 "V"$, or 1.9% of 24 V. Acceptable.]),
  ([Per ch.], [Each 7 m segment draws 140 W across five channels: $140 slash 5 slash 24 approx 1.2 "A"$ per channel, about a quarter of the Deca's 5 A rating @quinled-deca.]),
))[] <ex:feed>

#keyterm("Power injection")[Feeding power into a second point on a long run to limit voltage drop.]
The same loss happens inside the strip's own copper. At 24 V the maker's rule is about 10 m per feed @sll-strip. Past that, you feed power into a second point, called #term("power injection"). Each bedroom segment is 7 m, so neither needs it.

#check-yourself(
  ([A 24 V supply delivers 6 A. What power is it supplying?], [$P = V I = 24 times 6 = 144$ W.]),
  ([Why does the drop formula have a factor of 2?], [Current flows out on one conductor and back on the other, so the copper length is twice the run length.]),
)

#read-more(
  (title: "Ohm's law", url: "https://en.wikipedia.org/wiki/Ohm%27s_law", source: "Wikipedia", kind: "article", note: [Refresher on voltage, current and resistance.]),
  (title: "Electric power", url: "https://en.wikipedia.org/wiki/Electric_power", source: "Wikipedia", kind: "article"),
  (title: "American wire gauge", url: "https://en.wikipedia.org/wiki/American_wire_gauge", source: "Wikipedia", kind: "article", note: [Resistance-per-meter table for every gauge.]),
)

== Putting it in a room

#trade[Plan segment starts at the controller. Every segment that starts elsewhere needs an unlit lead wire to reach it.]
A 12 × 11 ft bedroom has a perimeter of about 14 m. Rather than one long run, it is split into two *segments* of about 7 m. Both start at the controller's corner and travel in opposite directions until they meet. Each has its own five channels, so they can be controlled separately or grouped as one light.

#definition(title: [Segment])[A continuous length of strip driven by its own set of five channels. Segments are electrically independent even when they look continuous.] <def:segment>

#figure(room-layout, caption: [Bedroom layout, seen from above. The two segments meet in the far corner without being joined.]) <fig:layout>

Splitting the run does three things at once. It spreads the load across ten channels instead of five. It keeps each run under the 10 m single-feed limit. And it puts both segment starts at the controller, so no unlit lead wire has to cross the ceiling.

#keyterm("Lumen, lux")[Lumens measure the total light a source emits. Lux measures lumens falling on one square meter.]
Because this strip replaces the room's main light, it has to be bright enough on its own. One more worked example settles that.
#notation($Phi$, [luminous flux], unit: [lm])
#notation($E$, [illuminance], unit: [lx])

#example(title: [Is it bright enough to be the main light?], steps: (
  ([Given], [Each white channel gives about 1,300 lm/m at full @sll-strip. Room: 11 × 12 ft, about 12.3 m². Firmware cap 80%.]),
  ([Assume], [Only about 40% of the emitted light reaches the working plane after bouncing off walls and ceiling. This utilization factor (UF) is an assumption for a ceiling cove; real rooms vary.]),
  ([Flux], [$Phi = 14 times 1300 times 0.8 approx 14 thin 600 "lm"$ from one white channel alone.]),
  ([Lux], [$E = Phi dot "UF" slash A = 14 thin 600 times 0.4 slash 12.3 approx 470 "lx"$.]),
  ([Result], [That exceeds what general bedroom lighting typically aims for, using only one of the two whites. Brightness is not a constraint. Confirm with a lux-meter app after install.]),
))[] <ex:lux>

=== The channel

#watch-out[Many channels sold as "12 mm" have internal ridges meant for 10 mm strips. A COB strip needs a true 12 mm clear to the floor @quinled-profile.]
The strip sits in an aluminum *channel* with an opal diffuser. The channel is a heat sink, a mechanical mount and an optical diffuser in one part.

#principle(title: [Thermal life])[An LED's lifetime is governed by its junction temperature. Lowering that temperature, by heat-sinking and by derating drive current, extends useful life.] <pr:thermal>

#trade[Seat the diffusers on the bench before mounting. Snapping them in overhead is the most-reported frustration.]
Aluminum plus the 80% cap keeps the junction cool; the maker rates the strip for 50,000 hours @sll-strip.

== How you control it

#trade[Land wires in screw terminals with fork crimps or ferrules, not bare strands @quinled-crimps.]
Control happens in three layers. Each can fail without taking the layers below it down.

#keyterm("YAML")[A plain-text configuration format. Your ESPHome file is the controller's whole recipe.]
#did-you-know[ESPHome began around 2018 as one developer's side project. Nabu Casa, the company behind Home Assistant, took it over in 2021 @nabu-esphome, and in 2024 both projects moved to the non-profit Open Home Foundation.]
*ESPHome* is firmware that runs on the controller's ESP32 chip. You describe the device (its outputs, lights and button) in a YAML file, and ESPHome compiles it into firmware. It is maintained under the Open Home Foundation, a non-profit @esphome-changelog.

#keyterm("OTA")[Over-the-air. Updating firmware over Wi-Fi after the first USB flash.]
*Home Assistant* runs on your Beelink. It talks to ESPHome over a local API and gathers every device in the apartment in one place. *HomeKit Bridge*, a Home Assistant integration, then presents chosen devices to *Apple Home*.

#theorem(title: [Local-first control])[A control input handled by firmware on the controller keeps working when every layer above the controller is unavailable.] <thm:local>
#proof[The button is wired to a controller input, and the action it triggers (toggle the light) is compiled into the controller's own firmware. Executing it requires only power and the controller itself. Home Assistant, Wi-Fi and Apple's hub are not in that path.]

#trade[Keep the YAML in git. Any ESP32 PWM board can be re-flashed with it, which is what makes this build repairable by you.]
@tab:layers applies the theorem to each layer in turn.

#figure(
  table(columns: (1.6fr, 1fr, 1fr, 1fr), align: (left, center, center, center),
    [If this is down], [Wall button], [Home Assistant], [Apple Home, Siri],
    [Nothing], [✓], [✓], [✓],
    [Apple home hub], [✓], [✓], [✗],
    [Home Assistant], [✓], [✗], [✗],
    [Wi-Fi], [✓], [✗], [✗],
    [Controller or supply], [✗], [✗], [✗],
  ),
  caption: [Failure isolation by layer. The physical-switch gate holds in every case except the hardware itself.],
) <tab:layers>

#read-more(
  (title: "RGBWW light", url: "https://esphome.io/components/light/rgbww.html", source: "ESPHome documentation", kind: "article", note: [The light platform Appendix C uses, with color-temperature options.]),
  (title: "HomeKit Bridge", url: "https://www.home-assistant.io/integrations/homekit/", source: "Home Assistant documentation", kind: "article"),
  (title: "QuinLED An-Penta-Deca ESPHome example", url: "https://quinled.info/quinled-an-penta-deca-esphome-configuration-example/", source: "QuinLED", kind: "datasheet"),
)

== Summary and review

#summary(
  [RGB mixes any hue; two phosphor whites give good white. Together they make an RGBCCT strip with five channels.],
  [The strip is common anode: one shared +24 V, five switched returns. One dark color points to its own return path (#pref(<thm:fault>)).],
  [Controllers dim by PWM. Frequency prevents flicker; bit depth sets how finely the light fades to dark.],
  [Size a supply at 1.25 × load; when that does not fit, derate in firmware.],
  [Current heats wire and drops voltage, $Delta V = I dot 2 L r$. Inject power past about 10 m at 24 V.],
  [Splitting a room into segments spreads the load and avoids lead wires.],
  [Control runs on the board first, so the wall switch survives any network failure.],
)

#key-equations(
  ([PWM power], $overline(P) = D P_"full"$), ([Dimming resolution], $D_"min" = 1 slash 2^n$),
  ([Gamma], $D = b^gamma$), ([Power], $P = V I$),
  ([Ohm's law], $V = I R$), ([Two-wire drop], $Delta V = 2 I L r$),
  ([Supply sizing], $P_"rated" >= 1.25 P_"load"$), ([Illuminance], $E = Phi dot "UF" slash A$),
)

#problems(intro: [Answers to all problems are in the Answer Key at the back.])

#problem(level: 1, answer: [The fault is in segment B's blue return path: a loose or misaligned clip at B's pigtail, a broken blue conductor, or the blue wire not landed in its terminal. A failed MOSFET on that one channel is possible but rarer. The shared supply is ruled out, since the other four colors work.])[Segment B's blue channel is dark, but red, green and both whites work. Using @thm:fault, name the likely causes.]

#problem(level: 1, answer: [$21 times 20 = 420$ W at full. The principle asks for $1.25 times 420 = 525$ W of supply, beyond any single desktop brick. Use two supplies feeding separate segments, or derate in firmware.])[The living room is about 21 m, split into three 7 m segments. What load must the supply side carry at full output, and what does the sizing principle ask for?]

#problem(level: 2, answer: [The eye is most sensitive to change at the dark end, and gamma correction compresses the dark end of the slider into very few duty-cycle values. At 8-bit those few values are 1/256 apart, a visible jump each time. At 12-bit they are 1/4096 apart, too small to see.])[Explain in your own words why the light fades in visible steps near zero at 8-bit but not at 12-bit.]

#problem(level: 0, answer: [The light toggles. @thm:local: the button and its action live in the controller's firmware, which needs only power.])[Home Assistant crashes overnight. You walk in and press the door button. What happens, and which result guarantees it?]

#problem(level: 1, answer: [$Delta V = 4 times 18 times 0.053 approx 3.8$ V, about 16% of 24 V. Not acceptable: the far end would visibly dim and shift color. Use 14–16 AWG for a feed like that.])[A 9 m feed on 22 AWG wire ($r approx 53$ mΩ/m) carries 4 A. Is the drop acceptable at 24 V?]

#problem(level: 1, answer: [The load may be at most $150 slash 1.25 = 120$ W, so $120 slash 20 = 6$ m at full output.])[Your supply is rated 150 W. How many meters of this strip can it drive at full output while respecting the sizing principle?]

#problem(level: 2, answer: [$D = 0.10^2.8 approx 0.0016$, or about 0.16% duty: roughly 6–7 steps of the 4,096 available.])[At 12-bit and $gamma = 2.8$, what duty cycle does a slider setting of 10% produce?]

#problem(level: 3, answer: [Open-ended. A good answer compares lux at the working plane (@ex:lux method) against a target for reading, about 300–500 lx, and notes that a cove light lights the ceiling first, so a task lamp may still be the better tool.])[Your partner wants to read in bed by the strip alone. Decide whether that works, stating every assumption you make.]

#looking-ahead(
  [This chapter gave each subsystem one section. Later volumes take one subsystem each and go a level deeper, still anchored to the apartment build.],
  ([▸], [PWM and dimming], [Frequency versus bit depth, gamma curves, flicker metrics, and camera banding.]),
  ([▸], [Voltage drop and power injection], [Resistance tables, injection layouts, and the living room's three-segment run.]),
  ([▸], [Color science], [CCT, CRI versus TM-30, white balance between production batches.]),
  ([▸], [Power supplies], [Switch-mode topology, why capacitors fail, and what a safety listing certifies.]),
  ([▸], [ESPHome], [The YAML model, outputs versus lights, OTA updates, and keeping configs in git.]),
  ([▸], [Home Assistant], [Entities, light groups, automations, and how HomeKit Bridge maps them.]),
)

// ======================================================================
#part([The Part of Tens], blurb: [Short lists you can read in a minute, standing in the hardware store or on a ladder.])

#chapter(
  [Ten Mistakes That Ruin an LED Build],
  lead: [Every one of these has a section in this book behind it. Each costs either a redo, a part, or a ceiling's worth of channel.],
)

#ten-list(
  ([Sizing the supply to exactly the load], [A supply at 100% runs hot and dries its capacitors fastest. Size at 1.25 × load, or cap the outputs in firmware (#pref(<pr:sizing>)).]),
  ([Trusting pigtail wire colors], [Colors vary by maker and batch. Read the letters printed on the pads at every cut.]),
  ([Cutting off the line], [A cut between marks leaves a partial circuit that never lights. Cut only on the printed line, every 41.6 mm.]),
  ([Ignoring voltage drop], [A long thin feed turns the far end dim and yellow. Do the $Delta V = 2 I L r$ arithmetic before buying wire (@cor:drop).]),
  ([Running past one feed], [At 24 V, plan on about 10 m per feed. Longer runs need power injection, or a split into segments.]),
  ([Buying "12 mm" channel that isn't], [Internal ridges sized for 10 mm strips crush a COB strip. Test-fit one piece first.]),
  ([Landing bare strands in screw terminals], [Strands splay and loosen. Use fork crimps or ferrules.]),
  ([Buying a supply on a marketplace], [Counterfeit Mean Well units are common. Buy from an authorized distributor.]),
  ([Mounting before the bench test], [Every fault is ten times harder to find on the ceiling. Light every segment on the floor first.]),
  ([Choosing firmware for effects instead of dimming], [On an analog strip, 12-bit PWM under ESPHome fades to a nightlight; 8-bit can't (@ex:dead).]),
)

// ======================================================================
#show: appendix

#chapter([System specification])
These are the interfaces every room shares. Changing one reopens the decision for the whole apartment; swapping a part that meets them does not.

#wide(figure(
  table(columns: (0.9fr, 1.8fr, 2fr),
    [Layer], [Standard], [Why it is the standard],
    [Strip], [24 V RGBCCT COB, 12 mm, 6-pin pads], [Any maker's strip drops in. About 10 m per feed at 24 V versus about 5 m at 12 V.],
    [Power], [24 V certified plug-in supply, IEC C14 inlet], [The only mains path is a certified product. No hardwiring in a rental.],
    [Controller], [ESP32 analog PWM, five channels per segment], [Reflashable. Any ESP32 PWM board can take over.],
    [Firmware], [ESPHome, YAML kept in git], [Plain-file configuration, local only, foundation-maintained.],
    [Control plane], [Home Assistant → HomeKit Bridge → Apple Home], [One owner for every zone.],
    [Physical control], [Momentary button wired to the controller (gate)], [Works with the network or Home Assistant down (@thm:local).],
    [Mount], [Aluminum channel, opal diffuser, true 12 mm clearance], [Heat sink, mechanical hold, even line.],
  ),
  caption: [The apartment lighting system specification.],
))

#chapter([Bill of materials, bedroom])
#wide(figure(
  table(columns: (1fr, 2.2fr, 0.8fr, 0.7fr),
    [Part], [Specification], [Qty], [Approx.],
    [LED strip], [SuperLightingLED FCOB-24V-RGBCCT, IP20, 5 m reel], [3], [\$98.94],
    [Controller], [QuinLED An-Penta-Deca], [1], [\$39.99],
    [Power supply], [Mean Well GST280A24-C6P, 24 V, 280 W], [1], [\~\$75],
    [Mains cord], [US plug to IEC C13], [1], [\$4.99],
    [Channel], [Aluminum, 12 mm, opal diffuser, 1 m], [15], [\$104.85],
    [Strip-to-wire], [6-pin, 12 mm], [2 + 2 spare], [\$3.96],
    [Strip-to-strip], [6-pin, 12 mm, straight], [2 + 1 spare], [\~\$3],
    [Corner], [6-pin, 12 mm, L-shape], [2 + 1 spare], [\~\$5],
    [Feed wire], [14 AWG, two-conductor], [about 3 m], [—],
    [Wall button], [Momentary, low voltage, plus 22 AWG pair], [1 + about 4 m], [—],
    [Fork crimps], [For the Deca's screw terminals], [1 set], [—],
    [Raceway], [Paintable, outlet to ceiling], [1 kit], [—],
  ),
  caption: [Bill of materials for the bedroom (instance 1 of 6).],
))
#tip[Buy one channel piece first and test-fit the strip before ordering the other fourteen.]
About \$340 before shipping. Each 7 m segment is one 5 m reel plus a 2 m piece from the third reel, joined with a strip-to-strip connector. Buy one channel piece first and test-fit the strip before ordering the rest.

#chapter([ESPHome skeleton])
Fill the GPIO placeholders from QuinLED's Deca pinout guide and ESPHome example @quinled-esphome. The `max_power` setting is the 80% derate from @ex:supply.

#wide(```yaml
esphome:
  name: bedroom-lights

esp32:
  board: esp32dev          # confirm against QuinLED example

wifi: !include wifi.yaml
api:                        # Home Assistant connection
ota:
  - platform: esphome

output:                     # one per channel
  - { platform: ledc, id: a_r,  pin: GPIO_A_R,  frequency: 19531Hz, max_power: 0.8 }
  - { platform: ledc, id: a_g,  pin: GPIO_A_G,  frequency: 19531Hz, max_power: 0.8 }
  # ...a_b, a_ww, a_cw, then the same five for segment B

light:
  - platform: rgbww
    id: seg_a
    name: "Bedroom A"
    red: a_r
    green: a_g
    blue: a_b
    warm_white: a_ww
    cold_white: a_cw
    cold_white_color_temperature: 6000 K
    warm_white_color_temperature: 3000 K
    restore_mode: RESTORE_DEFAULT_OFF
  # seg_b: same block with b_* outputs

binary_sensor:              # door button, works offline
  - platform: gpio
    pin: { number: GPIO_BUTTON, mode: INPUT_PULLUP, inverted: true }
    on_press:
      - light.toggle: seg_a
      - light.toggle: seg_b
```)
In Home Assistant, group "Bedroom A" and "Bedroom B" into one "Bedroom" light, then expose that group through the HomeKit Bridge.

#chapter([Build sequence])
Build in one window. Test on the bench before anything goes on the ceiling.

+ Flash ESPHome over USB-C and confirm the device appears in Home Assistant.
+ Bench test: supply → Deca → a 1 m offcut. Cycle each color alone, then both whites. Confirm the button toggles it.
+ Cut and join each 7 m segment on the bench. Light each full segment on the floor.
+ Test-fit strip in channel and seat the diffusers on the bench.
+ Mount the Deca and run raceway for the feed and button wires.
+ Mount the channel, seat the strips, and connect the pigtails. Corners use L-connectors.
+ Run at full white for 30 minutes, then touch-check the supply, the Deca and the strip ends for heat.
+ Expose to Apple Home. The done-state is reached: stop here.
+ Document: photograph the terminals, commit the final YAML, record actual lengths in this book.

#chapter([Troubleshooting])
#wide(figure(
  table(columns: (1fr, 1.2fr, 1.3fr),
    [Symptom], [Likely cause], [Fix],
    [Nothing lights], [Supply off or dead, blown fuse, controller offline], [Check supply LED, then fuse, then ESPHome logs],
    [One color dark on one segment], [Loose clip or wrong pad order at that pigtail (@thm:fault)], [Reseat or re-crimp; check pad letters],
    [One color dark on both segments], [Wrong GPIO in YAML], [Fix pin mapping and reflash],
    [Dead past one point], [Broken joint at a cut or connector], [Bridge with a strip-to-strip clip or solder],
    [Far end dimmer or yellower], [Voltage drop], [Inject power at the far end; check connector contact],
    [Flicker on camera or when dim], [PWM frequency too low], [Raise `frequency` in YAML],
    [Whites differ between segments], [Different production batches], [Order one batch; trim white balance in software],
    [Button dead, app works], [Button wiring or pin configuration], [Check continuity and `binary_sensor` logs],
    [App dead, button works], [Home Assistant or HomeKit Bridge down], [Restart Home Assistant],
    [Controller warm to the touch], [Normal under load @quinled-hot], [No action needed],
  ),
  caption: [Symptoms, causes and fixes.],
))

// ======================================================================
#back-chapter([Glossary])
#glossary()

#back-chapter([List of symbols])
#symbol-list()

#back-chapter([References])
#bibliography("refs.yml", title: none, style: "american-medical-association")
#v(0.6em)
#text(size: 9pt)[Copper resistance per meter (@ex:feed and Problem 1.5) uses standard AWG table values. The utilization factor in @ex:lux is an assumption, not a measured value.]

#back-chapter([Further reading])
#further-reading()

#back-chapter([Figure credits])
#figure-credits()

#back-chapter([Answer key])
#answer-key()

#back-chapter([Index])
#make-index()
