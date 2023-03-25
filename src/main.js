const crown = require('./crown')

globalThis.require = require

/*const server = crown()
 .runJsonFile('./lib/server.json')*/

const server2 = crown()
 .runFile('./lib/server.cr')

/*const server3 = crown().run`
 set environmentPort [ seek process env PORT ]
 set port [
  at parseInt
  call [ get environmentPort ] 10
 ]
 log 'Starting server on port' [ get port ]
`*/

// console.log(server.toString())
// console.log(server2.toString())
// console.log(server3.toString())
