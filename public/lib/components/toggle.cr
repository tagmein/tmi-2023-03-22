function label onChange initialValue [
 set outerContainer [
  at [ get element ], call div
 ]

 at [ get outerContainer ] classList add, call [
  set name outerContainer
  set rules '
   & {
    align-items: center;
    cursor: pointer;
    display: flex;
    padding: 0 15px;
   }

   &:hover {
    background-color: #686868;
   }
  '
  get style, point
 ]

 set toggleContainer [
  at [ get element ], call div
 ]

 at [ get toggleContainer ] classList add, call [
  set name toggleContainer
  set rules '
   & {
    display: inline-flex;
    align-items: center;
    user-select: none;
   }
  '
  get style, point
 ]

 at [ get build ], call [ get outerContainer ] [ get toggleContainer ]

 set isChecked [
  object [
   current [
    get initialValue, default false
   ]
  ]
 ]

 set toggleHandle [
  at [ get element ], call div
 ]

 at [ get toggleHandle ] classList add, call [
  set name toggleHandle
  set rules '
   & {
    background-color: #393939;
    border-radius: 15px;
    height: 30px;
    position: relative;
    width: 50px;
   }
   &::before {
    content: "";
    background-color: white;
    border-radius: 50%;
    height: 26px;
    left: 2px;
    position: absolute;
    top: 2px;
    transition: transform 0.25s ease;
    width: 26px;
   }
   &.checked {
    background-color: #ccc;
   }
   &.checked::before {
    transform: translateX(20px);
   }
  '
  get style, point
 ]

 at [ get build ], call [ get toggleContainer ] [ get toggleHandle ]

 set labelText [
  at [ get element ], call label
 ]

 at [ get labelText ] classList add, call [
  set name labelText
  set rules '
   & {
    font-size: 18px;
    height: 30px;
    line-height: 1.8;
    margin-left: 10px;
    pointer-events: none;
   }
  '
  get style, point
 ]

 set [ get labelText ] textContent [ get label ]

 at [ get build ], call [ get outerContainer ] [ get labelText ]

 get isChecked current, true [
  at [ get toggleHandle ] classList add, call checked
 ]

 at [ get outerContainer ] addEventListener, call click [
  function [
   set [ get isChecked ] current [ get isChecked current, not ]
   at [ get isChecked current ]
   true [
    at [ get toggleHandle ] classList add, call checked
   ]
   false [
    at [ get toggleHandle ] classList remove, call checked
   ]
   at [ get onChange ], call [ get isChecked current ]
  ]
 ]

 get outerContainer
]
