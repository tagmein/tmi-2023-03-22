const END = {
 name: 'end',
}

const COMMENT = {
 name: 'comment',
 '\n'(control) {
  control.statement.push('#')
  control.queueToStatement()
  control.statementToBlock()
  return INITIAL
 },
}

const STRING_ESCAPE = {
 name: 'string_escape',
 '\\'(control) {
  control.queue += '\\'
  return STRING
 },
 "'"(control) {
  control.queue += "'"
  return STRING
 },
}

const STRING = {
 name: 'string',
 '\\'(control) {
  return STRING_ESCAPE
 },
 "'"(control) {
  control.statement.push(control.queue)
  control.queue = ''
  return INITIAL
 },
}

const INITIAL = {
 end(control) {
  control.queueToStatement()
  control.statementToBlock()
  return END
 },
 name: 'script',
 ' '(control) {
  control.queueToStatement()
 },
 '\n'(control) {
  control.queueToStatement()
  control.statementToBlock()
 },
 ','(control) {
  control.queueToStatement()
  control.statementToBlock()
 },
 '#'(control) {
  control.queueToStatement()
  control.statementToBlock()
  return COMMENT
 },
 "'"(control) {
  control.queueToStatement()
  return STRING
 },
 '['(control) {
  control.queueToStatement()
  control.block = []
  control.stack.push(control.block)
  control.statement.push(control.block)
  control.statementStack.push(control.statement)
  control.statement = []
 },
 ']'(control) {
  if (control.stack.length <= 1) {
   throw new Error('Unexpected ] character')
  }
  control.queueToStatement()
  control.statementToBlock()
  control.stack.pop()
  control.block = control.stack[control.stack.length - 1]
  control.statement = control.statementStack.pop()
 },
}

function parse(source) {
 const top = []
 const control = {
  beginAtIndex: 0,
  block: top,
  queue: '',
  stack: [top],
  statement: [],
  statementStack: [],
  queueToStatement() {
   if (control.queue.length) {
    switch (control.queue) {
     case 'null':
      control.statement.push(null)
      break
     case 'undefined':
      control.statement.push(undefined)
      break
     case 'true':
      control.statement.push(true)
      break
     case 'false':
      control.statement.push(false)
      break
     default:
      if (
       String(parseFloat(control.queue)) === control.queue
      ) {
       control.statement.push(parseFloat(control.queue))
      } else {
       control.statement.push(control.queue)
      }
    }
    control.queue = ''
   }
  },
  statementToBlock() {
   if (control.statement.length) {
    control.block.push(control.statement)
    control.statement = []
   }
  },
 }
 let state = INITIAL
 for (const charIndex in source) {
  const char = source[charIndex]
  if (char in state) {
   try {
    const newState = state[char](control)
    if (newState) {
     state = newState
    }
   } catch (e) {
    e.message =
     e.message +
     ` (at ${charIndex}, '${source.substring(
      charIndex,
      charIndex + 20
     )}')`
    throw e
   }
   control.beginAtIndex = charIndex
  } else {
   control.queue += char
  }
 }
 if (control.queue.length > 0) {
  if (!('end' in state)) {
   throw new Error(
    `Unterminated ${state.name} at ${control.beginAtIndex}-${source.length}`
   )
  }
  state = state.end(control)
 }
 return top
}

const globalBasePath =
 globalThis.basePath ??
 (typeof location === 'object' &&
 location.pathname === 'srcdoc'
  ? ''
  : typeof __dirname === 'string'
  ? __dirname
  : location.pathname.replace(/\/$/, ''))

let fs, path

if (typeof require !== 'function') {
 globalThis.loadCrownDependencies = async function () {
  const [_fs, _path] = await Promise.all(
   ['fs', 'path'].map(globalThis.require)
  )
  fs = _fs
  path = _path
 }
 globalThis.browserModules = {}
 const browserModuleDefinitions = {
  fs() {
   return {
    async readFile(filePath, encoding, callback) {
     // encoding is ignored in browser
     try {
      const fileResponse = await fetch(filePath)
      const fileContents = await fileResponse.text()
      callback(undefined, fileContents)
     } catch (error) {
      callback(error)
     }
    },
   }
  },
  path() {
   return {
    dirname(filePath) {
     const segments = filePath.split('/')
     segments.pop()
     return segments.join('/')
    },
    join(...segments) {
     return segments.join('/')
    },
   }
  },
 }

 globalThis.require = async function (requirePath) {
  if (requirePath in browserModuleDefinitions) {
   if (!(requirePath in globalThis.browserModules)) {
    globalThis.browserModules[requirePath] =
     browserModuleDefinitions[requirePath]()
   }
  } else if (!(requirePath in globalThis.browserModules)) {
   await new Promise(function (resolve, reject) {
    browserModules.fs.readFile(
     requirePath,
     'utf-8',
     function (error, contents) {
      if (error) {
       reject(error)
      } else {
       const scriptElement =
        document.createElement('script')
       scriptElement.innerHTML = `const module = {}\n${contents}\nglobalThis.browserModules[${JSON.stringify(
        requirePath
       )}] = module.exports`
       document.head.appendChild(scriptElement)
       resolve()
      }
     }
    )
   })
  }
  return globalThis.browserModules[requirePath]
 }
}

const SCOPE = {
 PARENT: Symbol('SCOPE:PARENT'),
}

function smartJoin(basePath, filePath) {
 if (filePath.startsWith('//')) {
  return filePath.substring(1)
 } else if (filePath.startsWith('/')) {
  return (
   '/' +
   basePath.split('/').slice(0, 2).join('/') +
   filePath
  )
 } else {
  return path.join(basePath, filePath)
 }
}

function uncrown(value) {
 return typeof value?.current === 'function'
  ? value.current()
  : value
}

function crown(
 context = globalThis,
 names = new Map(),
 basePath = globalBasePath
) {
 let currentError
 let currentValue = context
 let lastComment
 const me = {
  '#'(comment) {
   lastComment = comment
   return me
  },
  async '<'(argumentCrown) {
   const arg = uncrown(argumentCrown)
   currentValue = currentValue < arg
  },
  async '<='(argumentCrown) {
   const arg = uncrown(argumentCrown)
   currentValue = currentValue <= arg
  },
  async '='(argumentCrown) {
   const arg = uncrown(argumentCrown)
   currentValue = currentValue === arg
  },
  async '>'(argumentCrown) {
   const arg = uncrown(argumentCrown)
   currentValue = currentValue > arg
  },
  async '>='(argumentCrown) {
   const arg = uncrown(argumentCrown)
   currentValue = currentValue >= arg
  },
  add(...argumentCrowns) {
   currentValue = argumentCrowns.reduce(
    (sum, x) => sum + uncrown(x),
    typeof currentValue === 'number' ? currentValue : 0
   )
  },
  at(...path) {
   let isFirstSegment = true
   for (const segment of path) {
    if (typeof segment === 'string') {
     if (
      currentValue === undefined ||
      currentValue === null
     ) {
      throw new Error(
       `cannot read '${segment}' of ${currentValue}`
      )
     }
     const test =
      typeof currentValue === 'object' ||
      typeof currentValue === 'function'
       ? currentValue
       : Object.getPrototypeOf(currentValue)
     if (segment in test) {
      const nextValue = currentValue[segment]
      if (
       typeof nextValue === 'function' &&
       currentValue !== globalThis
      ) {
       currentValue =
        currentValue[segment].bind(currentValue)
      } else {
       currentValue = currentValue[segment]
      }
     } else {
      currentValue = undefined
      break
     }
    } else {
     const candidate = uncrown(segment)
     if (isFirstSegment) {
      currentValue = candidate
     } else {
      if (
       typeof currentValue === 'string' &&
       typeof segment === 'number'
      ) {
       currentValue = currentValue[segment]
      } else {
       const test =
        typeof currentValue === 'object' ||
        typeof currentValue === 'function'
         ? currentValue
         : Object.getPrototypeOf(currentValue)
       if (currentValue && candidate in test) {
        const nextValue = currentValue[candidate]
        if (typeof nextValue === 'function') {
         currentValue =
          currentValue[candidate].bind(currentValue)
        } else {
         currentValue = currentValue[candidate]
        }
       } else {
        currentValue = undefined
        break
       }
      }
     }
    }
    isFirstSegment = false
   }
   return me
  },
  async call(...argumentCrowns) {
   if (typeof currentValue !== 'function') {
    throw new Error(
     `Expecting value to be a function, but got: ${typeof currentValue}`
    )
   }
   currentValue = uncrown(
    await currentValue(
     ...argumentCrowns.map((x) =>
      x === me ? x : uncrown(x)
     )
    )
   )
   return me
  },
  clone() {
   const newNames = new Map()
   newNames.set(SCOPE.PARENT, names)
   return crown(currentValue, newNames, basePath)
  },
  comment() {
   return lastComment
  },
  current() {
   return currentValue
  },
  default(crownValue) {
   const value = uncrown(crownValue)
   if (
    currentValue === null ||
    currentValue === undefined ||
    (typeof currentValue === 'number' &&
     isNaN(currentValue))
   ) {
    currentValue = value
   }
   return me
  },
  divide(...argumentCrowns) {
   currentValue = argumentCrowns.reduce(
    (product, x) => product / uncrown(x),
    typeof currentValue === 'number' ? currentValue : 1
   )
  },
  do() {
   return me
  },
  async each(callbackCrown) {
   if (!Array.isArray(currentValue)) {
    throw new Error(
     `each command requires current value to be an Array, got ${typeof currentValue}`
    )
   }
   const callback = uncrown(callbackCrown)
   const result = []
   for (
    let index = 0;
    index < currentValue.length;
    index++
   ) {
    result.push(
     uncrown(await callback(currentValue[index], index))
    )
   }
   currentValue = result
   return me
  },
  async entries(callbackCrown) {
   if (!currentValue || typeof currentValue !== 'object') {
    throw new Error(
     `entries command requires current value to be an object, got ${typeof currentValue}`
    )
   }
   const array = Object.entries(currentValue)
   const callback = uncrown(callbackCrown)
   const result = []
   for (let index = 0; index < array.length; index++) {
    result.push(
     uncrown(await callback(...array[index], index))
    )
   }
   currentValue = result
   return me
  },
  async false(instructionCrown) {
   if (!currentValue) {
    await me.clone().walk(uncrown(instructionCrown))
   }
  },
  async filter(argumentCrown) {
   if (!Array.isArray(currentValue)) {
    throw new Error(
     'Can only use "filter" when current value is an Array'
    )
   }
   const callback = uncrown(argumentCrown)
   const filteredValue = []
   await Promise.all(
    currentValue.map(async (x) => {
     if (await uncrown(await callback(x))) {
      filteredValue.push(x)
     }
    })
   )
   currentValue = filteredValue
   return me
  },
  async find(argumentCrown) {
   if (!Array.isArray(currentValue)) {
    throw new Error(
     'Can only use "find" when current value is an Array'
    )
   }
   const callback = uncrown(argumentCrown)
   for (let i = 0; i < currentValue.length; i++) {
    if (await uncrown(await callback(currentValue[i], i))) {
     currentValue = currentValue[i]
     return me
    }
   }
   currentValue = undefined
   return me
  },
  function(...argumentNames) {
   const functionImplementation = argumentNames.pop()
   currentValue = async function (...runtimeArguments) {
    const scopeCrown = me.clone()
    for (const index in argumentNames) {
     scopeCrown.set(
      argumentNames[index],
      runtimeArguments[index]
     )
    }
    await scopeCrown.walk(functionImplementation)
    return scopeCrown
   }
   return me
  },
  get(name, ...nameSegments) {
   let searchScope = names
   while (searchScope.has(SCOPE.PARENT)) {
    if (searchScope.has(name)) {
     break
    }
    searchScope = searchScope.get(SCOPE.PARENT)
   }
   if (!searchScope.has(name)) {
    currentValue = undefined
    return
    // todo add required flag?
    // throw new Error(`name ${JSON.stringify(name)} is not set`)
   }
   currentValue = searchScope.get(name)
   for (const segment of nameSegments) {
    if (
     typeof currentValue === 'undefined' ||
     currentValue === null
    ) {
     throw new Error(
      `cannot get '${segment}' of ${currentValue}`
     )
    }
    const test =
     typeof currentValue === 'object' ||
     typeof currentValue === 'function'
      ? currentValue
      : Object.getPrototypeOf(currentValue)
    if (
     !test.hasOwnProperty?.(segment) &&
     (typeof test !== 'object' || !(segment in test))
    ) {
     currentValue = undefined
     continue
    }
    if (typeof currentValue[segment] === 'function') {
     currentValue = currentValue[segment].bind(currentValue)
    } else {
     currentValue = currentValue[segment]
    }
   }
   return me
  },
  async group(groupByExpression) {
   if (!Array.isArray(currentValue)) {
    throw new Error(
     `group command requires current value to be an Array, got ${typeof currentValue}`
    )
   }
   const groups = {}
   await Promise.all(
    currentValue.map(async (item) => {
     const scopeCrown = me.clone().value(item)
     await scopeCrown.walk(groupByExpression)
     const itemGroup = await uncrown(scopeCrown)
     if (!(itemGroup in groups)) {
      groups[itemGroup] = []
     }
     groups[itemGroup].push(item)
    })
   )
   currentValue = groups
   return me
  },
  async is(argumentCrown) {
   const arg = uncrown(argumentCrown)
   currentValue = currentValue === arg
  },
  async list(definition = []) {
   currentValue = []
   for (const [v] of definition) {
    if (Array.isArray(v)) {
     const scope = me.clone()
     currentValue.push((await scope.walk(v)).current())
    } else {
     currentValue.push(v)
    }
   }
   return me
  },
  async load(_filePath) {
   const filePath = uncrown(_filePath)
   await new Promise(function (resolve, reject) {
    fs.readFile(
     smartJoin(basePath, filePath),
     'utf-8',
     function (error, content) {
      if (error) {
       reject(error)
      } else {
       try {
        const code = parse(content)
        const fileModule = eval(`(
         function () {
          return async function ${filePath.replace(
           /[^a-zA-Z]+/g,
           '_'
          )} (scope) {
          await scope.walk(${JSON.stringify(code)})
          return scope
         }})()`)
        currentValue = fileModule
        resolve()
       } catch (e) {
        currentError = e
        console.error(e)
        reject(e)
       }
      }
     }
    )
   })
   return me
  },
  log(...values) {
   console.log(...values.map(uncrown))
  },
  async map(argumentCrown) {
   if (!Array.isArray(currentValue)) {
    throw new Error(
     'Can only use "map" when current value is an Array'
    )
   }
   const callback = uncrown(argumentCrown)
   currentValue = await Promise.all(
    currentValue.map(async (x) =>
     uncrown(await callback(x))
    )
   )
   return me
  },
  multiply(...argumentCrowns) {
   currentValue = argumentCrowns.reduce(
    (product, x) => product * uncrown(x),
    typeof currentValue === 'number' ? currentValue : 1
   )
  },
  new(...argumentCrowns) {
   currentValue = new currentValue(
    ...argumentCrowns.map(uncrown)
   )
   return me
  },
  not() {
   currentValue = !currentValue
   return me
  },
  async object(definition = []) {
   currentValue = {}
   for (const [k, v] of definition) {
    if (Array.isArray(v)) {
     const scope = me.clone()
     currentValue[k] = (await scope.walk(v)).current()
    } else {
     currentValue[k] = v
    }
   }
   return me
  },
  async point() {
   if (typeof currentValue !== 'function') {
    throw new Error(
     `current value must be function, got ${typeof currentValue}`
    )
   }
   currentValue = (await currentValue(me.clone())).current()
   return me
  },
  async prepend(...commands) {
   const statements = commands.pop()
   for (const statement of statements) {
    const [prefix, ...rest] = statement[0]
    const compound = [commands.concat(prefix)].concat(rest)
    await me.walk(compound)
   }
   return me
  },
  async promise(handler) {
   try {
    currentValue = await new Promise(uncrown(handler))
   } catch (e) {
    currentError = e
    console.error('error in promise', e)
   }
   return me
  },
  regexp(...argumentCrowns) {
   const [definition, flags] = argumentCrowns.map(uncrown)
   currentValue = new RegExp(definition, flags)
   return me
  },
  async run([source]) {
   return me.walk(parse(source))
  },
  async runFile(source) {
   const filePath =
    basePath.length === 0 || source.startsWith('/')
     ? source
     : path.join(basePath, source)
   basePath = path.dirname(filePath)
   return new Promise(function (resolve, reject) {
    fs.readFile(
     filePath,
     'utf-8',
     function (error, contents) {
      if (error) {
       reject(error)
       return
      } else {
       resolve(me.run([contents]))
      }
     }
    )
   })
  },
  async runJsonFile(source) {
   return me.walk(
    crown().at('require').call(crown().value(source))
   )
  },
  set(...pathCrowns) {
   const path = pathCrowns.map(uncrown)
   const value = path.pop()
   const name = path.pop()
   if (path.length) {
    const context = uncrown(me.at(...path))
    if (context === 'null') {
     throw new Error(
      `cannot set property "${name}" of null`
     )
    }
    if (typeof context !== 'object') {
     throw new Error(
      `cannot set property "${name}" of ${typeof context}`
     )
    }
    context[name] = uncrown(value)
   } else {
    names.set(name, uncrown(value))
   }
   return me
  },
  subtract(...argumentCrowns) {
   currentValue = argumentCrowns.reduce(
    (sum, x) => sum - uncrown(x),
    typeof currentValue === 'number' ? currentValue : 0
   )
  },
  template(template, ...parameterCrowns) {
   const parameters = parameterCrowns.map(uncrown)
   currentValue = template.replace(
    /%(\d+)/g,
    function (_, index) {
     return parameters[parseInt(index, 10)]
    }
   )
   return me
  },
  toString() {
   const currentValueString = Array.isArray(currentValue)
    ? `Array (${currentValue.length})`
    : String(currentValue)
   const currentValueDescription =
    currentValueString.length > 0
     ? currentValueString
     : currentValue?.constructor?.name
   return `crown with ${typeof currentValue}: ${currentValueDescription}`
  },
  async true(instructionCrown) {
   if (currentValue) {
    await me.clone().walk(uncrown(instructionCrown))
   }
  },
  unset(...pathCrowns) {
   const path = pathCrowns.map(uncrown)
   const name = path.pop()
   if (path.length) {
    const context = uncrown(me.at(...path))
    if (context === 'null') {
     throw new Error(
      `cannot unset property "${name}" of null`
     )
    }
    if (typeof context !== 'object') {
     throw new Error(
      `cannot unset property "${name}" of ${typeof context}`
     )
    }
    delete context[name]
   } else {
    names.delete(name)
   }
   return me
  },
  value(newValue) {
   currentValue = newValue
   return me
  },
  async walk(instructionsCrown) {
   if (currentError) {
    console.log('will not walk due to error')
    return me
   }
   const instructions = uncrown(instructionsCrown)
   if (!Array.isArray(instructions)) {
    throw new Error(
     `walk expects an Array, got: ${typeof instructions}`
    )
   }
   if (instructions.length === 0) {
    return me
   }
   const wrappedInstructions = Array.isArray(
    instructions[0]
   )
    ? instructions
    : [instructions]
   for (const statementIndex in wrappedInstructions) {
    if (currentError) {
     console.log('stop walk due to error')
     break
    }
    const statement = wrappedInstructions[statementIndex]
    if (!Array.isArray(statement)) {
     throw new Error(
      `walk[${statementIndex}] expects an Array, got: ${typeof statement}`
     )
    }
    const [command, ...arguments] = statement
    if (!(command in me)) {
     throw new Error(
      `walk[${statementIndex}]: "${command}" is not a valid operation`
     )
    }
    const automaticWalk =
     {
      false: false,
      function: false,
      group: false,
      list: false,
      object: false,
      prepend: false,
      true: false,
     }[command] ?? true
    try {
     const finalArguments = await Promise.all(
      arguments.map((x) =>
       automaticWalk && Array.isArray(x)
        ? me.clone().walk(crown(x))
        : x
      )
     )
     try {
      await me[command](...finalArguments)
     } catch (e) {
      currentError = e
      console.error(
       `Error in ${command}`,
       finalArguments.map(uncrown)
      )
      console.error('Current value', currentValue)
      console.error(e)
      throw e
     }
    } catch (e) {
     currentError = e
     console.error(
      `Error computing arguments for ${command}`,
      arguments
     )
     console.error('Current value', currentValue)
     console.error(e)
     throw e
    }
   }
   return me
  },
 }
 return me
}

if (typeof module === 'object') {
 const [_fs, _path] = ['fs', 'path'].map(require)
 fs = _fs
 path = _path
 module.exports = crown
}
