// New book from the textbook template.
// Build: typst compile --font-path <textbook>/fonts main.typ
//    or: python3 <textbook>/scripts/build.py main.typ

#import "@local/textbook:0.1.0": *

#show: book.with(
  title: [Book Title],
  short-title: [Short Title],
  subtitle: [Chapter 1: First Chapter],
  series: [Volume I · DIY Systems Series],
  abstract: [One sentence on what the book teaches and through which build.],
  meta: (
    ("Build", [What is being built]),
    ("Edition", [First edition · date]),
  ),
)

#chapter(
  [First Chapter],
  lead: [Two or three sentences that frame the chapter.],
  objectives: (
    [First thing the reader will be able to do.],
    [Second thing.],
  ),
)

#background[What the reader should already know.]

== First section

#keyterm("Term")[Short definition for the margin and the glossary.]
Running text that introduces the #term("term").

#definition(title: [Name])[Precise statement.] <def:name>

#check-yourself(
  ([Question?], [Answer.]),
)

== Summary and review

#summary([First point.], [Second point.])

#problems()
#problem(level: 1, answer: [Answer.])[Problem statement.]

#show: appendix
#chapter([Specification])
Reference material.

#back-chapter([Glossary])
#glossary()
#back-chapter([List of symbols])
#symbol-list()
#back-chapter([Further reading])
#further-reading()
#back-chapter([Figure credits])
#figure-credits()
#back-chapter([Answer key])
#answer-key()
#back-chapter([Index])
#make-index()
