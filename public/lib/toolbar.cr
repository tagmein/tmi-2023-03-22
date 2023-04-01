set toolbar [
 at [ get element ], call
]

at [ get toolbar ] classList add, call [
 set name toolbar
 set rules '
  & {
   background-color: #595959;
   box-shadow: 0 0 20px #00000045;
   border-bottom: 1px solid #676767;
   color: #dfdfdf;
   display: flex;
   flex-direction: row;
   flex-shrink: 0;
   font-weight: bold;
   height: 60px;
   line-height: 44px;
   overflow-x: auto;
   overflow-y: hidden;
   width: 100%;
   z-index: 1;
  }
 '
 get style, point
]

set channelSelect [
 at [ get element ], call
]

at [ get channelSelect ] classList add, call [
 set name channelSelect
 set rules '
  & {
   border-right: 1px solid #676767;
   max-width: 100%;
   min-width: 60px;
   position: relative;
  }
 '
 get style, point
]

set channelSelectLabel [
 at [ get element ], call
]

at [ get channelSelectLabel ] classList add, call [
 set name channelSelectLabel
 set rules '
  & {
   padding: 10px 15px;
  }
 '
 get style, point
]

set channelSelectHidden [
 at [ get element ], call select
]

at [ get channelSelectHidden ] classList add, call [
 set name channelSelectHidden
 set rules '
  & {
   cursor: pointer;
   height: 100%;
   left: 0;
   opacity: 0;
   position: absolute;
   top: 0;
   width: 100%;
  }
 '
 get style, point
]

at [ get build ]
do [ call [ get toolbar ]       [ get channelSelect ] ]
do [ call [ get channelSelect ] [ get channelSelectLabel ] ]
do [ call [ get channelSelect ] [ get channelSelectHidden ] ]
do [ call [ get document body ] [ get toolbar ] ]

at [ get channelSelectHidden ] addEventListener, call change [
 function [
  at [ get switchChannel ], call [
   at [ get channelSelectHidden ] value
  ]
 ]
]

object [
 setChannels [
  function channels selectedChannel [
   set [ get channelSelectHidden ] innerHTML ''
   each [ get channels ] [
    function channel [
     set option [
      at [ get element ], call option
     ]
     set [ get option ] value [ get channel key ]
     set [ get option ] innerText [ get channel label ]
     do [
      get selectedChannel, is [ get option value ]
      true [
       set [ get option ] selected true
       set [ get channelSelectLabel ] innerText [ get channel label ]
      ]
     ]
     at [ get build ], call [ get channelSelectHidden ] [ get option ]
    ]
   ]
  ]
 ]
]
