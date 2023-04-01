set surface [
 at [ get element ], call div
]

at [ get surface ] classList add, call [
 set name surface
 set rules '
  & {
   display: flex;
   flex-direction: column;
   flex-grow: 1;
   overflow-x: hidden;
   overflow-y: auto;
  }
 '
 get style, point
]

at [ get build ]
do [ call [ get document body ] [ get surface ] ]
