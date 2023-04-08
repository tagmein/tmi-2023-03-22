set accountLink [
 at [ get element, call a ]
]

set account [
 at [ get tmiOperator ], call account:get
]

at [ get accountLink ] setAttribute, call href '/#tagmein/account'

get account, true [
 set [ get accountLink ] textContent [ get account name ]
], false [
 set [ get accountLink ] textContent 'Sign in'
]

get accountLink
