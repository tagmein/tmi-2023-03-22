set linkElement [
 get element, call a
]

get linkElement setAttribute, call href '/#tagmein/account'

set refresh [
 function [
  set account [
   get tmiOperator, call account:get
  ]
  get account, true [
   set [ get linkElement ] textContent [
    get account name,
    default [
     get account email
    ]
   ]
  ], false [
   set [ get linkElement ] textContent 'Sign in'
  ]
 ]
]

object [
 container [ get linkElement ]
 refresh [ get refresh ]
]
