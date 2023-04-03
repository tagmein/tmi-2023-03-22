function callback delay [
 set state [
  object [
   timeoutId null
  ]
 ]
 function args [
  at [ get state ] timeoutId, is null, false [
   at [ get clearTimeout ], call [
    at [ get state ] timeoutId
   ]
  ]
  set [ get state ] timeoutId [
   at [ get setTimeout ], call [
    function [
     at [ get callback ], call [ get args ]
     set [ get state ] timeoutId null
    ]
   ] [ get delay, default 1000 ]
  ]
 ]
]
