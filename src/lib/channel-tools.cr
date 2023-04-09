set byKey [
 function key [
  get privateData, call [ 
   template channel:%0 [ get key ]
  ]
  at read, call
 ]
]

object [
 byKey [ get byKey ]
 create [
  function email name [
   set channelListData [
    get privateData, call [ 
     template account.channel-list:%0 [ get email ]
    ]
   ]
   set newChannelKey [ get randomKey, call ]
   set channelData [
    get privateData, call [ 
     template channel:%0 [ get newChannelKey ]
    ]
   ]
   set channelObject [
    object [
     created [ get Date now, call ]
     key [ get newChannelKey ]
     name [ get name ]
     owner [ get email ]
    ]
   ]
   promise [
    function resolve [
     get fileSystem mkdir, call [
      get path join, call [ get publicBase ] data [ get newChannelKey ]
     ] [ get resolve ]
    ]
   ]
   get channelData write, call [ get channelObject ]
   set existingchannelList [
    get channelListData read, call
   ]
   get existingchannelList, true [
    get channelListData write, call [
     get existingchannelList concat, call [
      list [
       [ get newChannelKey ]
      ]
     ]
    ]
   ], false [
    get channelListData write, call [
     list [
      [ get newChannelKey ]
     ]
    ]
   ]
   get channelObject
  ]
 ]
 forget [
  function email channelKeyToForget [
   set channelListData [
    get privateData, call [ 
     template account.channel-list:%0 [ get email ]
    ]
   ]
   set currentList [
    get channelListData read, call
   ]
   set responseObject [ object ]
   get currentList includes
   call [ get channelKeyToForget ], true [
    get channelListData write, call [
     get currentList, filter [
      function item [
       get item, is [ get channelKeyToForget ], not
      ]
     ]
    ]
    set [ get responseObject ] current true
   ], false [
    set [ get responseObject ] current false
   ]
   get responseObject current
  ]
 ]
 list [
  function email [
   set responseList [ object ]
   set channelListData [
    get privateData, call [ 
     template account.channel-list:%0 [ get email ]
    ]
   ]
   set currentList [
    get channelListData read, call
   ]
   get currentList, true [
    set [ get responseList ] current [
     get currentList, map [
      function key [
       get byKey, call [ get key ]
      ]
     ]
    ]
   ], false [
    set [ get responseList ] current [
     list []
    ]
   ]
   get responseList current
  ]
 ]
]
