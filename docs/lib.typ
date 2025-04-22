#let colortheme = orange

#let project(
  title: "",
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
    margin: (
      top: 2cm,
      rest: 1.5cm,
    ),
    columns: columns,
    numbering: "1",
    header: context {
      let output
      if (literal-numbering) {
        output = "Page " + counter(page).display() + " of " + str(counter(page).final().at(0))
      } else {
        output = counter(page).display()
      }
      if (calc.odd(here().page())) {
        h(1fr)
        output
      } else {
        output
        h(1fr)
      }
    },
    footer: { },
  )

  set text(
    // font: "Libre Caslon Text",
    // font: "New Computer Modern",
    font: "EB Garamond",
    // size: 10pt,
    lang: "en",
  )
  set par(justify: true, linebreaks: "optimized")
  set list(indent: 1.2em, tight: false)
  set enum(indent: 1.2em, tight: false)
  set heading(numbering: "1.1.")
  // show math.equation: set text(font: "Fira Math")

  // title page
  v(3cm)
  
  align(
    center,
    text(
      size: 22pt,
      weight: "bold",
      title,
    ),
  )

  let author_display(fullname, mail, github) = align(
    center,
    {
      smallcaps(fullname) + linebreak()
      link("mailto:" + mail, raw(mail)) + linebreak()
      text(fill: blue, link(github, github))
    },
  )

  // authors
  grid(
    columns: (1fr,) * authors.len(),
    ..authors.map(author => (
      author_display(
        author.fullname,
        author.mail,
        author.github,
      )
    ))
  )

  v(3em)

  // mainmatter
  outline()

  show heading.where(level: 1): it => pagebreak() + it

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
