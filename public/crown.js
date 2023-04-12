const globalBasePath =
 globalThis.basePath ??
 (typeof location === 'object' &&
 location.pathname === 'srcdoc'
  ? ''
  : typeof __dirname === 'string'
  ? __dirname
  : location.pathname.replace(/\/$/, ''))

let fs, path, parse

if (typeof require !== 'function') {
 globalThis.loadCrownDependencies = async function () {
  const [_fs, _path] = await Promise.all(
   ['fs', 'path'].map(globalThis.require)
  )
  const [_parse] = await Promise.all(
   [globalBasePath + '/parse.js'].map(globalThis.require)
  )
  fs = _fs
  path = _path
  parse = _parse
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
    0
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
    1
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
  async is(argumentCrown) {
   const arg = uncrown(argumentCrown)
   currentValue = currentValue === arg
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
     path.join(basePath, filePath),
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
    1
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
    basePath.length > 0
     ? path.join(basePath, source)
     : source
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
    0
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
      console.error(`Error in ${command}`, finalArguments)
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
 const [_parse] = [globalBasePath + '/parse.js'].map(
  require
 )
 fs = _fs
 path = _path
 parse = _parse
 module.exports = crown
}
