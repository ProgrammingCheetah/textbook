#import "/src/lib.typ": *
// Every component on a few pages. Build: python3 scripts/build.py tests/kitchen-sink.typ
#show: book.with(title: [Test Book], series: [Volume I · Test], meta: (("Build", [x]),),
  cheat-sheet: [#cheat-block([Rules])[- One. - Two.] #cheat-block([More])[Text.]])
#introduction(about: [About.], assumptions: ([You can read.],), beyond: [Beyond.], where-next: [Start anywhere.])
#part([First Part], blurb: [What this part covers.])
#chapter([First Chapter], lead: [Lead paragraph here.], objectives: ([one], [two]))
== Section one
#keyterm("Phosphor")[A coating.]
Some text with #term("ohm") and a cite. #lorem(80)
#definition(title: [Additive])[A thing.] <def:a>
#theorem(title: [Fault])[Statement $x = y$.] <thm:f>
#proof[Because.]
$ P = V I $ <eq:p>
See @thm:f and #pref(<def:a>) and @eq:p.
#example(title: [Sizing], steps: (([Given], [a]), ([Result], [b])))[]
#watch-out[Careful.]
#remember[Keep this.]
#tip[Do this.]
#deep-dive(title: [Detail])[#lorem(30)]
#lorem(200)
== Section two
#history(era: "1879", title: [Edison])[#lorem(40)]
#intuition[#lorem(30)]
#mistake(wrong: [Wrong], right: [Right])[Why.]
#check-yourself(([Q1], [A1]), ([Q2], [A2]))
#read-more((title: "QuinLED", url: "https://quinled.info", source: "QuinLED", kind: "article"))
#photo(none, caption: [A strip.], alt: [COB strip close-up], credit: "Someone, CC BY 4.0", source: "https://example.com") <fig:s>
#notation($Delta V$, [drop], unit: [V])
#problems()
#problem(level: 2, answer: [42])[What?]
#chapter([Second])
== S
#lorem(50)
#part([The Part of Tens])
#chapter([Ten Things])
#ten-list(([One], [Body.]), ([Two], [Body.]))
#show: appendix
#chapter([Spec])
#wide(table(columns: 3, [a],[b],[c],[1],[2],[3]))
#back-chapter([Glossary])
#glossary()
#back-chapter([Answers])
#answer-key()
#back-chapter([Index])
#make-index()
#back-chapter([Symbols])
#symbol-list()
#back-chapter([Credits])
#figure-credits()
#back-chapter([Further reading])
#further-reading()
