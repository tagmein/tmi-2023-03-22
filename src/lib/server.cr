set environmentPort [
 seek process env PORT
]
set port [
 seek parseInt
 call [ get environmentPort ] 10
]
log 'Starting server on port' [ get port ]
