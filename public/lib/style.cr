set [ get styleUnique ] current [
 add 1 [
  get styleUnique current, default -1
 ]
]

set className [
 template %0-%1 [ get name, default class ] [ get styleUnique current ]
]

set styleElement [
 at [ get document ] createElement, call style
]

set [ get styleElement ] textContent [
 at [ get rules ] replace, call [
  regexp & g
 ] [
  template .%0 [ get className ]
 ]
]

at [ get document ] head appendChild, call [ get styleElement ]

at [ get className ]
