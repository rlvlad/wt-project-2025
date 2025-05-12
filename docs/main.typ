#import "lib.typ": *
#import "properties.typ": *

#set-theme(yaml("classic-light.yaml"))

#show: project.with(..properties)

#show: frontmatter.with()
#include "sections/abstract.typ"

#show: mainmatter.with()
#include "sections/original_submission.typ"

// our work
#include "sections/submission.typ"
// #include "sections/pipeline.typ"
// #include "sections/ifml.typ"
#include "sections/sequence_diagram.typ"
#include "sections/filters.typ"
#include "sections/sql.typ"
#include "sections/css_rules.typ"

#bibliography(
  "bibliography.yml",
  style: "ieee",
  full: false,
)
