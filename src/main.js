globalThis.__dirname = __dirname
globalThis.require = require

require('./crown')()
 .runFile('./lib/server.cr')
