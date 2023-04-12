function callback delay [
 set state [
  object [
   timeoutId null
  ]
 ]
 function args [
  get state timeoutId, is null, false [
   get clearTimeout, call [
    get state timeoutId
   ]
  ]
  set [ get state ] timeoutId [
   get setTimeout, call [
    function [
     get callback, call [ get args ]
     set [ get state ] timeoutId null
    ]
   ] [ get delay, default 1000 ]
  ]
 ]
]
