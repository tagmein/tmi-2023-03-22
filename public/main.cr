set document [ at document ]

set style [ load ./lib/style.cr ]

set toolbar [
 at document createElement, call div
]

at document body appendChild, call [ get toolbar ]

at [ get toolbar ] classList add, call [
 set rules '
  & {
   background-color: #797979;
   display: flex;
   flex-direction: row;
   height: 60px;
  }
 '
 get style, point
]
