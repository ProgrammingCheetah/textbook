// Chapter: Electricity in Four Units. Included from main.typ.

#import "/src/lib.typ": *
#import "figures.typ": *

#chapter(
  [Electricity in Four Units],
  label: <ch:units>,
  lead: [Every calculation in this book uses four units: the *coulomb*, the *ampere*, the *volt* and the *watt*. Each one is defined from the one before it, so once you know what they mean, the formulas stop being things to memorize. You can work them out yourself, and you can check them by looking at the units.],
  objectives: (
    [Say what a coulomb, an ampere, a joule, a volt and a watt each measure.],
    [Derive $P = V I$ from the definitions, without memorizing it.],
    [Use a unit check to catch a wrong formula before it costs you a part.],
    [Turn a strip's W/m rating into the load, current and supply size for a room.],
    [Convert power into energy on your bill, in kilowatt-hours.],
  ),
)

#background[
  You need three habits from school math. *Multiplying fractions:* $(a slash b) times (b slash c) = a slash c$, because the $b$ cancels. Units cancel the same way. *Scientific notation:* $6.24 times 10^18$ means 6.24 followed by moving the decimal point 18 places right. *Rearranging:* if $P = V I$, then $I = P slash V$.
]

== Charge: the thing that flows

Everything electrical starts with *charge*. Electrons carry a tiny negative charge each, and a current is just a lot of them moving through a wire. One electron's charge is far too small to work with, so we count charge in a bigger unit.

#keyterm("Elementary charge")[The charge of one electron (negative) or one proton (positive). Symbol $e$.]
#definition(title: [Coulomb, C])[The SI unit of electric charge. Since 2019 the elementary charge is fixed at exactly $e = 1.602 thin 176 thin 634 times 10^(-19)$ C @bipm-ampere, so one coulomb is about $6.24 times 10^18$ elementary charges @nist-ampere.] <def:coulomb>
#notation($Q$, [electric charge], unit: [C])
#notation($e$, [elementary charge, $1.602 times 10^(-19)$], unit: [C])

#remember[A coulomb is a *count*: about 6.24 quintillion electrons. Think of it as one bucket of charge.]
You won't measure coulombs directly in this build. They matter because the next two units, the ampere and the volt, are both defined *per coulomb*.

#check-yourself(
  ([About how many electrons make one coulomb?], [About $6.24 times 10^18$, since $1 slash (1.602 times 10^(-19)) approx 6.24 times 10^18$.]),
  ([Is a coulomb a rate or an amount?], [An amount. It counts charge; it says nothing about time.]),
)

#read-more(
  (title: "Coulomb", url: "https://en.wikipedia.org/wiki/Coulomb", source: "Wikipedia", kind: "article", note: [Definition and history of the unit.]),
)

== Current: charge per second

A wire full of electrons does nothing until they move. *Current* measures how fast charge flows past a point.

#definition(title: [Ampere, A])[The SI unit of electric current. One ampere is one coulomb of charge passing a point each second @nist-ampere: $ I = Q / t, quad 1 "A" = 1 "C/s". $] <def:ampere>
#notation($t$, [time], unit: [s])

#did-you-know[Current is written $I$, not $C$, because it comes from André-Marie Ampère's French: _intensité du courant_. $C$ was already taken by the coulomb.]
#history(era: "1881–2019", title: [Naming the units, then fixing them to nature])[
  In 1881 the first International Electrical Congress met in Paris. It endorsed the ohm and the volt as practical units, and named the units of current, charge and capacitance the ampere, the coulomb and the farad @iec-1881. For most of the next century the ampere was defined by an idealized experiment: two infinitely long parallel wires, 1 m apart in a vacuum, pulling on each other with $2 times 10^(-7)$ newtons per meter. Nobody could build infinite wires, and the newton itself rested on a metal kilogram in a vault near Paris that slowly drifted. On 20 May 2019 the ampere was redefined by fixing the electron's charge instead @nist-ampere. Now anyone who can count electrons can make an ampere.
]

#example(title: [How many electrons does the bedroom strip move?], steps: (
  ([Given], [The full bedroom run draws 7.6 A at full output. (You will derive this number in @ex:bedroom.)]),
  ([Method], [7.6 A means 7.6 C every second. Each coulomb is $6.24 times 10^18$ electrons.]),
  ([Result], [$7.6 times 6.24 times 10^18 approx 4.7 times 10^19$ electrons per second, about 47 quintillion.]),
))[] <ex:electrons>

#check-yourself(
  ([A wire carries 2 A for 10 seconds. How much charge passed?], [$Q = I t = 2 times 10 = 20$ C.]),
  ([What does "1 A" say in words?], [One coulomb of charge passes a point every second.]),
)

#read-more(
  (title: "Ampere: Introduction", url: "https://www.nist.gov/si-redefinition/ampere-introduction", source: "NIST", kind: "article", note: [The old definition, why it failed, and the 2019 fix, in plain language.]),
  (title: "SI base unit: ampere", url: "https://www.bipm.org/en/si-base-units/ampere", source: "BIPM", kind: "article", note: [The official definition from the body that maintains the SI.]),
)

== Energy and voltage

#keyterm("Energy")[The capacity to do work: lift, heat, light. Measured in joules.]
To understand voltage you need one more unit, for *energy*.

#definition(title: [Joule, J])[The SI unit of energy. One joule is the work done by a force of one newton acting over one meter: $1 "J" = 1 "N" dot "m"$ @nist-sp330.] <def:joule>

To get a feel for it, lift an apple. A 100 g apple weighs about 0.98 N, so raising it 1 m takes about 1 J.

Now combine energy with charge. *Voltage* says how much energy each coulomb carries from the supply to the load.

#definition(title: [Volt, V])[The SI unit of potential difference. A voltage of one volt means each coulomb carries one joule of energy: $ V = E / Q, quad 1 "V" = 1 "J/C". $ The SI writes the same unit as watts per ampere, W/A @nist-sp330, which is equivalent.] <def:volt>
#notation($E$, [energy], unit: [J])

#keyterm("Potential difference")[The formal name for voltage. It is always measured *between* two points.]
#intuition(title: [Voltage is how full each bucket is])[
  Picture charge moving through the circuit as a line of buckets, one coulomb per bucket. The supply fills every bucket with the same amount of energy, and the strip empties them, turning that energy into light and heat. *Voltage is how much energy is in each bucket.* At 24 V, every coulomb arrives carrying 24 J. A 12 V supply sends half-full buckets.
]

#trade[This is why the book's whole system runs at 24 V. To deliver the same energy each second with half-full buckets, a 12 V system has to move twice as many of them, which means twice the current.]
#check-yourself(
  ([At 24 V, how much energy does 3 C of charge deliver?], [$E = V Q = 24 times 3 = 72$ J.]),
  ([Why is voltage measured between two points?], [It is a difference in energy per coulomb: what each coulomb gains at the supply and gives up in the load.]),
)

#read-more(
  (title: "Voltage", url: "https://en.wikipedia.org/wiki/Voltage", source: "Wikipedia", kind: "article", note: [The water analogy and its limits.]),
  (title: "SP 330, Appendix 1: Decisions of the CGPM", url: "https://www.nist.gov/pml/special-publication-330/sp-330-appendix-1", source: "NIST", kind: "article", note: [The 1960 table that defines the joule, watt, coulomb and volt.]),
)

== Power: energy per second

The last unit says how *fast* energy is delivered. A strip's rating, its supply and your wire all depend on it.

#definition(title: [Watt, W])[The SI unit of power. One watt is one joule of energy delivered every second @nist-sp330: $ P = E / t, quad 1 "W" = 1 "J/s". $] <def:watt>

Now the payoff. You already have everything you need to derive the most-used formula in this book.

#theorem(title: [Electrical power])[The power delivered to a load equals the voltage across it times the current through it: $ P = V I. $] <thm:pvi>
#proof[Power is energy per second, $P = E slash t$. Split that fraction through the charge $Q$ that carried the energy:
  $ P = E / t = E / Q dot Q / t. $
  The first factor is energy per coulomb, which is the voltage (@def:volt). The second is coulombs per second, which is the current (@def:ampere). So $P = V I$. The units agree: $"J/C" times "C/s" = "J/s" = "W"$.]

#figure(bucket-line, caption: [The bucket line. Voltage is energy per bucket, current is buckets per second, and their product is energy per second: power.]) <fig:buckets>

#remember[You never need to memorize $P = V I$. Energy per coulomb times coulombs per second is energy per second.]
#figure(units-chain, caption: [The units chain for the bedroom. The coulombs cancel, which is the whole proof.]) <fig:chain>

=== Checking a formula by its units

The proof above ended with a unit check. It is the most useful habit in this chapter, because it catches a wrong formula before you buy anything.

#keyterm("Dimensional analysis")[Checking a calculation by tracking its units. If the units come out wrong, the formula is wrong.]
#rule-env(title: [The unit check])[Carry units through every step of a calculation and cancel them like fractions. If the result does not come out in the unit you wanted, the setup is wrong, whatever the number looks like.] <rule:units>

#mistake(
  wrong: [Multiplying the run length by the voltage: $14 "m" times 24 "V" = 336$.],
  right: [Multiply the strip's W/m by the length to get watts, then divide by the voltage to get amperes.],
)[Meters times volts is "volt-meters", a unit that means nothing for this job. The unit check flags it at once. The strip's rating is in W/m, so $"W/m" times "m" = "W"$, and $"W" slash "V" = "A"$, since $"W" = "V" dot "A"$.]

=== The bedroom, from rating to supply

Here is the chain you will run for every room in the apartment.

#example(title: [Load, current and supply for the bedroom], steps: (
  ([Given], [Perimeter about 14 m. BTF-LIGHTING FCOB RGBCCT 960 LEDs/m strip, rated 13 W/m maximum at 24 V @btf-960. Mean Well GST280A24 supply, 280 W @digikey-gst280.]),
  ([Load], [$P = 13 "W/m" times 14 "m" = 182 "W"$. The meters cancel.]),
  ([Current], [Rearrange @thm:pvi: $I = P slash V = 182 "W" slash 24 "V" approx 7.6 "A"$. Since $"W" = "V" dot "A"$, the volts cancel.]),
  ([Supply], [Size with 25% headroom (@pr:sizing): $1.25 times 182 = 228 "W" <= 280 "W"$. The supply fits.]),
  ([Maker], [BTF's own rule is to keep the strip under 80% of the supply's maximum @btf-960: $182 slash 280 = 65%$. Also fine.]),
))[] <ex:bedroom>

#trade[25% headroom and "load under 80% of the supply" are the same rule written two ways: $1 slash 1.25 = 0.8$.]
#check-yourself(
  ([A 5 m strip is rated 13 W/m. What current does it draw at 24 V?], [$P = 13 times 5 = 65$ W, so $I = 65 slash 24 approx 2.7$ A.]),
  ([The same power at 12 V: what current?], [$65 slash 12 approx 5.4$ A, twice as much. Same energy per second, half the energy per coulomb.]),
)

#read-more(
  (title: "Electric power", url: "https://en.wikipedia.org/wiki/Electric_power", source: "Wikipedia", kind: "article", note: [More derivations of $P = V I$, including for AC circuits.]),
  (title: "Dimensional analysis", url: "https://en.wikipedia.org/wiki/Dimensional_analysis", source: "Wikipedia", kind: "article"),
)

== Energy over time: the kilowatt-hour

Power is a rate. Your electricity bill charges for the total *energy*, power multiplied by the time it ran.

#definition(title: [Kilowatt-hour, kWh])[The energy delivered by one kilowatt (1,000 W) running for one hour: $1 "kWh" = 1000 "J/s" times 3600 "s" = 3.6 times 10^6 "J"$.] <def:kwh>

#corollary(title: [Energy from power])[A load of power $P$ running for time $t$ uses energy $E = P t$. With $P$ in kilowatts and $t$ in hours, $E$ comes out in kWh.] <cor:energy>

#example(title: [What does the bedroom cost to run?], steps: (
  ([Given], [Full output 182 W = 0.182 kW (@ex:bedroom).]),
  ([Full], [$E = 0.182 "kW" times 5.5 "h" approx 1.0 "kWh"$. About five and a half hours at full white uses one kilowatt-hour.]),
  ([Typical], [Evenings rarely run at full. Under PWM, average power scales with duty cycle (#pref(<thm:pwm>)). At 30% for 4 h a night: $0.3 times 0.182 times 4 approx 0.22$ kWh per night.]),
  ([Cost], [*Assume* a rate of \$0.14 per kWh; read your own on the bill. Then $0.22 times 30 times 0.14 approx \$0.92$ a month.]),
))[] <ex:kwh>

#did-you-know[A joule is tiny. One kilowatt-hour is 3.6 million of them, roughly the work of lifting a small car 300 m.]
#check-yourself(
  ([A 60 W load runs for 10 hours. How much energy, in kWh?], [$0.06 times 10 = 0.6$ kWh.]),
  ([Which is a unit of power: kW or kWh?], [kW. A kWh is energy: power times time.]),
)

#read-more(
  (title: "Kilowatt-hour", url: "https://en.wikipedia.org/wiki/Kilowatt-hour", source: "Wikipedia", kind: "article", note: [Conversions and how utilities bill.]),
)

== Summary and review

#summary(
  [Charge is counted in coulombs. One coulomb is about $6.24 times 10^18$ electrons.],
  [Current is charge per second: $1 "A" = 1 "C/s"$.],
  [Energy is counted in joules. Voltage is energy per coulomb: $1 "V" = 1 "J/C"$.],
  [Power is energy per second: $1 "W" = 1 "J/s"$. Multiplying volts by amperes cancels the coulombs, which gives $P = V I$.],
  [Carry units through every step. If they don't come out right, the formula is wrong.],
  [Load is W/m times meters; current is load divided by voltage; supply is at least 1.25 times the load.],
  [Energy on your bill is power times time, in kilowatt-hours.],
)

#key-equations(
  ([Current], $I = Q slash t$), ([Voltage], $V = E slash Q$),
  ([Power], $P = E slash t$), ([Electrical power], $P = V I$),
  ([Current from power], $I = P slash V$), ([Energy], $E = P t$),
  ([Strip load], $P = ("W/m") times L$), ([Kilowatt-hour], $1 "kWh" = 3.6 "MJ"$),
)

#problems(intro: [Answers to all problems are in the Answer Key at the back.])

#problem(level: 0, answer: [$Q = I t = 0.5 times 60 = 30$ C.])[A button circuit draws 0.5 A for one minute. How much charge flowed?]

#problem(level: 1, answer: [$P = 13 times 7 = 91$ W, so $I = 91 slash 24 approx 3.8$ A.])[One bedroom segment is 7 m of the 13 W/m strip. What current does it draw at full output?]

#problem(level: 1, answer: [Volts times meters is not a unit of anything the build needs, so the setup is wrong. The intended answer: $P = 13 times 21 = 273$ W and $I = 273 slash 24 approx 11.4$ A.])[A friend computes the living room's current as $21 "m" times 24 "V" = 504$. Use the unit check to explain what went wrong, then find the correct current for 21 m of the 13 W/m strip.]

#problem(level: 2, answer: [$P = 1.25 times 273 approx 341$ W at minimum. The 280 W brick does not fit; use a larger supply or split the room across two supplies.])[What supply rating does the living room in the previous problem need, and does the bedroom's 280 W brick cover it?]

#problem(level: 2, answer: [$E = 0.273 times 3 times 365 approx 299$ kWh a year. At the assumed \$0.14/kWh, about \$42.])[The living room runs at full output 3 hours a day. How many kWh a year is that, and roughly what does it cost at \$0.14/kWh?]

#problem(level: 3, answer: [At 12 V the current doubles to about 15.2 A for the same 182 W. Drop in a wire is $Delta V = I R$, so it doubles too, and as a *fraction* of a voltage half as large it is four times worse. That is why the system standard is 24 V.])[The same bedroom strip existed in a 12 V version at the same W/m. What would happen to the current, and why does that make voltage drop four times worse as a fraction of supply voltage? (Look ahead to #pref(<thm:ohm>).)]

#looking-ahead(
  [With these four units you can follow every calculation in the next chapter.],
  ([▸], [Lighting a Room], [Light, strips, dimming, power and control, each built from these units.]),
  ([▸], [Supply sizing], [Why the 25% headroom exists, and what heat does to a supply.]),
  ([▸], [Ohm's law], [Resistance, and why current through copper costs you voltage.]),
)
