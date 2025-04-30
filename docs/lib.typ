#let colortheme = orange

#let project(
  title: "",
  subtitle: "",
  authors: (),
  columns: 1,
  literal-numbering: false,
  body,
) = {
  set document(
    title: title,
    author: authors.map(a => sym.copyright + " " + a.fullname),
    date: datetime(
      day: 12,
      month: 4,
      year: 2025,
    ),
  )

  set page(
    // margin: (
    //   top: 2.5cm,
    //   rest: 2cm,
    // ),
    // margin: (
    //   top: 2cm,
    //   rest: 1.5cm,
    // ),
    fill: colortheme.lighten(90%),
    columns: columns,
    numbering: "1",
    header: {
      set text(6 / 7 * 1em, font: "Libertinus Serif")
      context {
        let sizeof(it) = measure(it).width
        // Queries the heading FOR THE CURRENT PAGE
        let headings1 = query(selector(heading.where(level: 1))).filter(h1 => here().page() - 1 == h1.location().page())
        let before = query(selector(heading.where(level: 1)).before(here()))

        let output

        output = if (headings1.len() != 0) {
          // if there is a lvl 1 heading on the page before, the header must be empty
          none
        } else if (before.len() != 0) {
          // otherwise it's the name of the current lvl 1 heading
          let numbering = counter(heading.where(level: 1)).display().first()
          box(
            inset: 10pt,
            height: 1em,
            width: 1em,
            radius: 2pt,
            fill: orange.lighten(10%),
            stroke: orange.lighten(10%),
            baseline: 0.15 * 1em,
            align(
              center + horizon,
              text(
                fill: colortheme.lighten(85%),
                numbering,
              ),
            ),
          )
          " "
          before.last().body
        }

        show text: it => smallcaps(it)
        if (calc.even(here().page())) {
          counter(page).display()
          h(1fr)
          output
        } else {
          output
          h(1fr)
          counter(page).display()
        }
        // v(-0.5em)
        // line(length: 100%, stroke: 0.1pt + black)
      }
    },
    footer: { },
  )

  set text(
    // font: "Libre Caslon Text",
    // font: "New Computer Modern",
    font: "EB Garamond",
    size: 12pt,
    lang: "en",
  )

  set par(justify: true, linebreaks: "optimized")
  set list(indent: 1.2em, tight: false)
  set enum(indent: 1.2em, tight: false)
  set heading(numbering: "1.1.")
  // show math.equation: set text(font: "Fira Math")

  // title page

  align(
    left + horizon,
    {
      v(3cm)

      text(
        size: 3em,
        weight: "bold",
        title,
      )

      parbreak()

      text(
        size: 1.6em,
        subtitle,
      )

      v(1cm)

      let author_display(fullname, mail, github) = align(
        center,
        {
          set text(size: 1.1em)
          smallcaps(fullname) + linebreak()
          link("mailto:" + mail, raw(mail)) + linebreak()
          text(fill: blue, link(github, github))
        },
      )

      // authors
      grid(
        columns: (1fr,) * authors.len(),
        align: center,
        ..authors.map(author => (
          author_display(
            author.fullname,
            author.mail,
            author.github,
          )
        ))
      )

      v(3em)
    },
  )

  pagebreak()

  // set page(
  //   header: context {
  //     let output
  //     if (literal-numbering) {
  //       output = "Page " + counter(page).display() + " of " + str(counter(page).final().at(0))
  //     } else {
  //       output = counter(page).display()
  //     }
  //     if (calc.odd(here().page())) {
  //       h(1fr)
  //       output
  //     } else {
  //       output
  //       h(1fr)
  //     }
  //   },
  // )

  // mainmatter
  show outline.entry: it => {
    v(1em, weak: true)
    link(
      it.element.location(),
      it.indented(
        it.prefix(),
        it.element.body + box(width: 1fr, repeat([\u{0009} . \u{0009} \u{0009}])) + it.page(),
      ),
    )
  }

  show outline.entry.where(level: 1): it => {
    v(1.6em, weak: true)
    link(
      it.element.location(),
      strong(
        it.indented(
          it.prefix(),
          it.element.body + h(1fr) + it.page(),
        ),
      ),
    )
  }


  outline()

  show raw.where(block: true): it => {
    // set text(font: "JetBrains Mono NF", weight: "light")
    set text(size: 0.9em)
    block(
      width: 100%,
      fill: rgb("#ebf1f5"),
      inset: 10pt,
      stroke: rgb("#9cc9e7"),
      // radius: 4pt,
      it,
    )
  }

  show heading.where(level: 1): it => context {
    set page(header: { })
    pagebreak(to: "even", weak: true)
    set page(header: { })
    v(10%)
    let number = if it.numbering != none { counter(heading.where(level: 1)).display().first() }
    v(-15%)
    set text(size: 2em)
    align(
      smallcaps(text(font: "Liberation Serif", number) + linebreak() + box(width: 21cm, it.body)),
      center + horizon,
    )
  }
  show heading: it => it + v(6pt)

  show ref: it => text(fill: orange, it)
  show link: it => text(fill: blue, underline(stroke: blue, it))

  body
}

// LEGEND
#let legend(arr) = {
  grid(
    columns: (1fr,) + (1fr,) * arr.len(),
    align: center + horizon,
    stroke: (x, y) => (
      right: if x == 0 or x == arr.len() {
        silver
      },
      left: if x == 0 {
        silver
      },
      top: if y == 0 {
        silver
      },
      bottom: if y == 0 {
        silver
      },
    ),
    inset: 10pt,
    text(weight: "bold", style: "italic", smallcaps("Legend")),
    ..arr.flatten()
  )
}

// DATABASE
#let entity(string) = text(fill: red, weight: "semibold", string)
#let attr(string) = text(fill: olive, weight: "semibold", string)
#let attr_spec(string) = text(fill: olive, style: "oblique", string)
#let rel(string) = text(fill: blue, weight: "semibold", string)
// #let entity(string) = highlight(fill: red, text(fill: white, string))
// #let attr(string) = highlight(fill: olive, text(fill: white, string))
// #let attr_spec(string) = underline(stroke: olive + 1.5pt, string)
// #let rel(string) = highlight(fill: blue, text(fill: white, string))

// BEHAVIOURS
#let user_action(string) = text(fill: orange, weight: "semibold", string)
#let element(string) = text(fill: aqua.darken(40%), weight: "semibold", string)
#let page(string) = text(fill: purple, weight: "semibold", string)
#let server_action(string) = text(fill: yellow.darken(20%), weight: "semibold", string)
// #let user_action(string) = highlight(fill: orange, string)
// #let element(string) = highlight(fill: aqua, string)
// #let page(string) = highlight(fill: purple.lighten(50%), string)
// #let server_action(string) = highlight(fill: yellow, string)

// PIPELINE

#let addon = emoji.rocket
#let u_action = emoji.person
#let s_action = emoji.computer
#let pg = emoji.page

#let comment(string) = text(fill: black.lighten(40%), h(1em) + raw("// " + string))

#import "@preview/chronos:0.2.1": * // sequence diagrams

#let thymeleaf = image("img/thymeleaf.png", width: 1.5em, height: 1.5em, fit: "contain")

#let seq_diagram(title, diagram-code, label_: "", comment: "") = {
  // align(
  //   center,
  //   box(
  //     width: 70%,
  //     stroke: (bottom: black),
  //     inset: (bottom: 1em),
  //     text(14pt, smallcaps(title)),
  //   ),
  // )
  heading(level: 2, title)
  [
    #figure(diagram-code)#label(label_)
  ]
  text(weight: "bold", "Comment")
  [ --- ]
  emph(comment)
}

#let redirects = $-->$

#import "@preview/subpar:0.2.2": *
