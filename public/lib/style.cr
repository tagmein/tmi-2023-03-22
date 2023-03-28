set styleUnique [ add 1 [ get styleUnique, default -1 ]]

set className [
 template %0-%1 foo [ get styleUnique ]
]

set styleElement [
 at [ get document ] createElement, call style
]

set [ get styleElement ] innerText [
 at [ get rules ] replace, call & [
  template .%0 [ get className ]
 ]
]

at [ get document ] head appendChild, call [ get styleElement ]

at [ get className ]
