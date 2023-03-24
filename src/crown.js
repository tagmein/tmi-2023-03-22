const fs = require('fs')
const path = require('path')

const parse = require('./parse')

function uncrown(value) {
 return typeof value === 'object' && ('current' in value)
  ? value.current()
  : value
}

module.exports = function crown(context = globalThis, names = new Map) {
 let currentValue = context
 const me = {
  call(...argumentCrowns) {
   if (typeof currentValue !== 'function') {
    throw new Error(`Expecting value to be a function, but got: ${typeof currentValue}`)
   }
   currentValue = currentValue(
    ...argumentCrowns.map(uncrown)
   )
   return me
  },
  clone() {
   return crown(currentValue, names)
  },
  current() {
   return currentValue
  },
  get(name) {
   if (!names.has(name)) {
    throw new Error(`name ${JSON.stringify(name)} is not set`)
   }
   currentValue = names.get(name)
  },
  log(...values) {
   console.log(...values.map(uncrown))
  },
  run([source]) {
   return me.walk(parse(source))
  },
  runFile(source) {
   return me.run([
    fs.readFileSync(
     path.join(__dirname, source),
     'utf-8'
    )
   ])
  },
  runJsonFile(source) {
   return me.walk(
    crown()
     .seek('require')
     .call(
      crown().value(source)
     )
   )
  },
  seek(...path) {
   for (const segment of path) {
    if (currentValue && (segment in currentValue)) {
     currentValue = currentValue[segment]
    }
    else {
     currentValue = undefined
     break
    }
   }
   return me
  },
  set(name, value) {
   names.set(name, uncrown(value))
   return me
  },
  toString() {
   const currentValueString = Array.isArray(currentValue)
    ? `Array (${currentValue.length})`
    : String(currentValue)
   const currentValueDescription = currentValueString.length > 0
    ? currentValueString
    : currentValue?.constructor?.name
   return `crown with ${typeof currentValue}: ${currentValueDescription}`
  },
  value(newValue) {
   currentValue = newValue
   return me
  },
  walk(instructionsCrown) {
   const instructions = uncrown(instructionsCrown)
   if (!Array.isArray(instructions)) {
    throw new Error(`walk expects an Array, got: ${typeof instructions}`)
   }
   if (instructions.length === 0) {
    throw new Error('walk expects at least one instruction, 0 provided')
   }
   const wrappedInstructions = Array.isArray(instructions[0]) ? instructions : [instructions]
   for (const statementIndex in wrappedInstructions) {
    const statement = wrappedInstructions[statementIndex]
    if (!Array.isArray(statement)) {
     throw new Error(`walk[${statementIndex}] expects an Array, got: ${typeof statement}`)
    }
    const [command, ...arguments] = statement
    if (!(command in me)) {
     throw new Error(`walk[${statementIndex}]: "${command}" is not a valid operation`)
    }
    me[command](
     ...arguments.map(
      x => Array.isArray(x)
       ? me.clone().walk(crown(x))
       : x
     )
    )
   }
   return me
  }
 }
 return me
}
