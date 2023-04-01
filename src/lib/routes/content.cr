set [ get response ] statusCode 200
at [ get response ]
do [ at setHeader, call Content-Type application/json ]
set responseString [
 at [ get JSON ] stringify, call [
  object [
   value test
   channels [
    list [
     [ object [ key tagmein, label 'Tag Me In' ] ]
     [ object [ key foobar, label 'Foo Bar' ] ]
    ]
   ]
   nodes [
    list [
     hello
     world
     abc
    ]
   ]
  ]
 ]
]
do [ at end, call [ get responseString ] ]
