set document [ at document ]
set styleUnique [ object ]
set style [ load ./lib/style.cr ]

at [ load ./lib/global-style.cr ], point

set build [
 function parent child [
  at [ get parent ] appendChild
  call [ get child ]
 ]
]

set element [
 function tagName [
  at [ get document ] createElement, call [
   get tagName, default div
  ]
 ]
]

at [ load ./lib/toolbar.cr ], point
