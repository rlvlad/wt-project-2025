#let colortheme = orange

#let colors = yaml("classic-light.yaml")

#let default-background = rgb(colors.palette.base00)
#let lighter-background = rgb(colors.palette.base01)
#let selection-background = rgb(colors.palette.base02)
#let comments = rgb(colors.palette.base03)
#let dark-foreground = rgb(colors.palette.base04)
#let default-foreground = rgb(colors.palette.base05)
#let light-foreground = rgb(colors.palette.base06)
#let light-background = rgb(colors.palette.base07)
#let variables = rgb(colors.palette.base08)
#let data-types = rgb(colors.palette.base09)
#let support-types = rgb(colors.palette.base0A)
#let string = rgb(colors.palette.base0B)
#let support = rgb(colors.palette.base0C)
#let functions = rgb(colors.palette.base0D)
#let keywords = rgb(colors.palette.base0E)
#let deprecated = rgb(colors.palette.base0F)

#let project(
  title: "",
  subtitle: "",
  authors: (),
  columns: 1,
  tech-stack: false,
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

  let color_filter(correct, overridden) = {
    let correct_components = correct.rgb().components().slice(0, 3).map(x => x / 100% * 256)

    let red = correct_components.at(0)
    let green = correct_components.at(1)
    let blue = correct_components.at(2)

    if (red > 235 and green > 235 and blue > 235) {
      return overridden
    } else {
      return correct
    }
  }

  set page(
    margin: (
      rest: 1.5cm,
      top: 2.2cm,
    ),
    fill: color_filter(default-background, colortheme.lighten(90%)),
    header: { },
    footer: { },
  )

  set text(
    // font: "Libre Caslon Text",
    // font: "New Computer Modern",
    // font: "EB Garamond",
    // font: "Poppins",
    font: "Barlow",
    // weight: "regular",
    size: 11.5pt,
    lang: "en",
    fill: light-background,
  )

  set par(justify: true, linebreaks: "optimized")
  set list(indent: 1.2em, tight: false)
  set enum(indent: 1.2em, tight: false)
  set heading(numbering: "1.1")
  // show math.equation: set text(font: "Fira Math")

  // title page
  align(
    left + horizon,
    {
      v(3cm)

      text(
        size: 3em,
        weight: "bold",
        title.replace("@", "\n@"),
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
          strong(smallcaps(fullname)) + linebreak()
          link("mailto:" + mail, raw(mail)) + linebreak()
          text(fill: variables, link(github, github))
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

      // tech stack
      if (tech-stack) {
        let logos = (
          image(width: 3cm, "img/java.svg"),
          image(width: 3cm, "img/thymeleaf.svg"),
          image(width: 3cm, "img/javascript.svg"),
        )
        grid(
          columns: (1fr,) * logos.len(),
          align: center + horizon,
          gutter: 1em,
          ..logos
        )
      }
    },
  )

  set page(
    numbering: "1",
    header: {
      set text(6 / 7 * 1em, font: "JetBrains Mono")
      context {
        let sizeof(it) = measure(it).width
        // Queries the heading FOR THE PREVIOUS PAGE
        let headings1 = query(selector(heading.where(level: 1))).filter(h1 => here().page() - 1 == h1.location().page())
        let before = query(selector(heading.where(level: 1)).before(here()))

        let output

        output = if (headings1.len() != 0) {
          // if there is a lvl 1 heading on the page before, the header must be empty
          none
        } else if (before.len() != 0) {
          // otherwise it's the name of the current lvl 1 heading
          let numbering = counter(heading.where(level: 1)).display().first()
          text(
            // fill: light-background,
            {
              numbering
              [ --- ]
              before.last().body
            },
          )
        }

        if (calc.even(here().page())) {
          counter(page).display()
          h(1fr)
          title
        } else {
          output
          h(1fr)
          counter(page).display()
        }
        // v(-0.5em)
        // line(length: 100%, stroke: 0.1pt + black)
      }
    },
    header-ascent: 40%,
  )

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

  set page(columns: columns)
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

  show ref: it => text(fill: functions, it)
  show link: it => text(fill: blue, underline(stroke: blue, it))

  // set figure(gap: 2em)

  body
}

// LEGEND
#let legend(arr) = {
  let num = int(arr.len() / 2)
  grid(
    columns: (auto,) + (1fr,) * num,
    align: center + horizon,
    stroke: silver,
    inset: 10pt,
    grid.cell(
      rowspan: num,
      rotate(
        -90deg,
        reflow: true,
        text(weight: "bold", style: "italic", smallcaps("Legend")),
      ),
    ),
    ..arr.flatten()
  )
}

#let SINGLE_COLUMN(body) = {
  set page(columns: 1)

  body
}

#let frontmatter(body) = {
  set page(columns: 1)
  set heading(numbering: none, outlined: false, bookmarked: true)

  show heading: it => {
    text(size: 1.2em, it)
    v(6pt)
  }

  body
}

#let mainmatter(body) = {
  set page(columns: 2)
  set heading(numbering: "1.1", outlined: true)

  show heading: it => {
    set text(font: "JetBrains Mono")
    box(
      width: 1fr,
      inset: 10pt,
      fill: light-background,
      stroke: data-types,
      align(
        center,
        text(
          fill: selection-background,
          smallcaps(counter(heading).display() + " " + it.body),
        ),
      ),
    )
    // v(6pt)
  }

  show heading.where(level: 1): it => context {
    set page(header: { })
    pagebreak(to: "even", weak: true)
    set page(header: { }, columns: 1)
    let number = if it.numbering != none { counter(heading.where(level: 1)).display().first() }
    set text(size: 1.75em, font: "JetBrains Mono", hyphenate: false)
    v(30%)
    align(
      center,
      block(
        width: page.width * 0.61,
        smallcaps(number + v(0.7em) + it.body),
      ),
    )
  }

  body
}

#let backmatter(body) = {
  body
}

#let thymeleaf_trick(body) = {
  show "thymeleaf": (
    text(fill: rgb("#005F0F"), "thymeleaf")
      + h(0.1cm)
      + box(
        image(
          "img/thymeleaf.svg",
          width: 1em,
          height: 1em,
        ),
        // width: 1em,
        // height: 1em,
        baseline: 0.1cm,
      )
  )

  show "Thymeleaf": text(fill: rgb("#005F0F"), "Thymeleaf")

  body
}

// DATABASE
#let entity(string) = text(fill: red, weight: "semibold", string)
#let attr(string) = text(fill: olive, weight: "semibold", string)
#let attr_spec(string) = text(fill: olive, style: "oblique", string)
#let rel(string) = text(fill: blue, weight: "semibold", string)

// BEHAVIOURS
#let user_action(string) = text(fill: orange, weight: "semibold", string)
#let element(string) = text(fill: aqua.darken(40%), weight: "semibold", string)
#let page(string) = text(fill: purple, weight: "semibold", string)
#let server_action(string) = text(fill: yellow.darken(20%), weight: "semibold", string)

// PIPELINE
#let addon = emoji.rocket
#let u_action = emoji.person
#let s_action = emoji.computer
#let pg = emoji.page

#let comment(string) = text(fill: black.lighten(40%), h(1em) + raw("// " + string))

// Sequence diagrams

#import "@preview/chronos:0.2.1": * // sequence diagrams

#let thymeleaf = image("img/thymeleaf.svg", width: 1.5em, height: 1.5em, fit: "contain")

#let balance(content) = context {
  let height = measure(
    // width: page.width - page.margin.left.length - page.margin.left.length,
    width: 21cm - 1.5cm - 1.5cm,
    content,
  ).height
  place(
    top,
    scope: "parent",
    float: true,
    block(
      height: height, // to fix calculation error
      columns(2, content),
    ),
  )
}

#let seq_diagram(title, diagram-code, label_: "", comment: "", next_page: true, add_comment: true) = {
  place(
    top,
    scope: "parent",
    float: true,
    [
      #heading(level: 2, title)
      #label(label_)
    ],
  )
  [
    #figure(
      scope: "parent",
      placement: top,
      diagram-code,
    )
  ]
  if (add_comment) {
    place(
      top,
      scope: "parent",
      float: true,
      grid(
        columns: (auto, 1fr),
        column-gutter: 1em,
        align: center + horizon,
        text(weight: "bold", style: "oblique", "Comment"), line(length: 100%, stroke: 0.5pt + variables),
      ),
    )
  }
  // [ --- ]
  balance(emph(comment))
  if (next_page) {
    pagebreak(weak: true)
  }
}

#let redirects = $-->$

#import "@preview/subpar:0.2.2": *

// CSS

#let css_explanation(css_source_code, comment) = {
  table(
    inset: 10pt,
    stroke: (left: data-types + 2pt, rest: none),
    // fill: orange.lighten(80%),
    {
      css_source_code
      // text(
      //   weight: "bold",
      //   "Comment",
      // )
      // [ --- ]
      emph(comment)
    },
  )
  // css_source_code
  // text(
  //   weight: "bold",
  //   "Comment —",
  // )
  // comment
}

#let double_col_spaces(v_space) = {
  place(
    top,
    scope: "parent",
    float: true,
    v(v_space),
  )
}
