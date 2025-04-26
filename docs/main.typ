#import "lib.typ": *
#import "properties.typ": *

#show: project.with(..properties)

#include "sections/original_submission.typ"

#include "sections/submission.typ"
// #include "sections/pipeline.typ"
#include "sections/sequence_diagram.typ"
#include "sections/css_rules.typ"

#bibliography(
  "bibliography.yml",
  style: "ieee",
  full: true,
)
