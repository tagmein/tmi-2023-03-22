globalThis.__dirname = __dirname
globalThis.require = require

const crown = require('../public/crown.js')

async function main() {
 await crown(globalThis, undefined, __dirname)
  .runFile('./lib/server.cr')
}

main().catch(e => console.error(e))
