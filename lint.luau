local fs = require("@lune/fs")

local Paths = {
    `./src/shared/Replit`,
    `./src/shared/TaskPP`
}

local LintRules = {
    MaxLayers = 2, -- how many layers of ifs, functions etc can be used
    AllowFunctionCreation = false, -- if it should allow function creation within a function or a code block
    MaxElseIfChain = 3, -- maximum elseif statements before suggesting a switch/table lookup
    MaxLineLength = 120, -- maximum characters per line
    WarnOnTodo = true, -- warn about TODO/FIXME comments
    WarnOnEmptyBlocks = true, -- warn about empty if/for/while blocks
    MaxFunctionLength = 50, -- maximum lines in a function before warning
    RequireSpacesAroundOperators = false, -- require spaces around =, ==, +, -, etc
    WarnOnGlobalAssignment = false -- warn when assigning without 'local' keyword
}

local LintErrors = {}

local function AddError(file: string, line: number, message: string)
    table.insert(LintErrors, {
        File = file,
        Line = line,
        Message = message
    })
end

local function LintFile(fileName: string, tokenized: {string})
    local currentDepth = 0
    local maxDepthReached = 0
    local elseIfCount = 0
    local inIfBlock = false
    local functionStartLine = nil
    local blockStack = {} -- track what kind of block we're in
    local lastBlockWasEmpty = false
    local linesInCurrentBlock = 0
    local declaredLocals = {} -- track all locally declared variables
    
    -- Keywords that increase nesting depth
    local depthIncreaseKeywords = {
        "if", "for", "while", "repeat", "do", "function"
    }
    
    -- Keywords that decrease nesting depth
    local depthDecreaseKeywords = {
        "end", "until"
    }
    
    for lineNum, line in ipairs(tokenized) do
        local trimmed = line:gsub("^%s+", ""):gsub("%s+$", "")
        local originalLine = line
        
        -- Check line length
        if LintRules.MaxLineLength and #originalLine > LintRules.MaxLineLength then
            AddError(fileName, lineNum, `Line exceeds maximum length ({#originalLine} > {LintRules.MaxLineLength} characters)`)
        end
        
        -- Check for TODO/FIXME comments
        if LintRules.WarnOnTodo then
            if trimmed:match("%-%-.*TODO") or trimmed:match("%-%-.*FIXME") then
                AddError(fileName, lineNum, "TODO/FIXME comment found - consider addressing this")
            end
        end
        
        -- Track local variable declarations
        if trimmed:match("^local%s+") then
            -- Extract variable names from local declarations
            -- Handle: local x, local x = 5, local x, y = 1, 2
            local declPart = trimmed:match("^local%s+([^=]+)")
            if declPart then
                -- Split by comma to handle multiple declarations
                for varName in declPart:gmatch("%s*(%w+)%s*,?") do
                    declaredLocals[varName] = true
                end
            end
        end
        
        -- Check for global variable assignments (assignment without 'local')
        if LintRules.WarnOnGlobalAssignment then
            -- Match: identifier = value (but not local, and not function parameters/returns)
            local varName = trimmed:match("^(%w+)%s*=")
            if varName and not trimmed:match("^local%s") and 
               not trimmed:match("^return%s") and not trimmed:match("^elseif%s") and
               not trimmed:match("==") and not trimmed:match("~=") and
               not trimmed:match("<=") and not trimmed:match(">=") and
               not declaredLocals[varName] then
                AddError(fileName, lineNum, "Potential global variable assignment detected. Consider using 'local'")
            end
        end
        
        -- Check for missing spaces around operators
        if LintRules.RequireSpacesAroundOperators then
            -- Check for operators without spaces (but allow ==, !=, <=, >=, --, ..)
            if trimmed:match("%w+=%w") and not trimmed:match("%w+[=!<>~]=%w") and not trimmed:match("%.%.") then
                AddError(fileName, lineNum, "Missing spaces around '=' operator")
            end
            if trimmed:match("%w+%+%w") and not trimmed:match("%+%+") then
                AddError(fileName, lineNum, "Missing spaces around '+' operator")
            end
            -- Check for minus but exclude negative numbers (e.g., = -1) and decrement (--)
            if trimmed:match("%w+%-%w") and not trimmed:match("%-%-") and not trimmed:match("[=%(,]%s*%-") then
                AddError(fileName, lineNum, "Missing spaces around '-' operator")
            end
        end
        
        -- Skip empty lines and comments for structural checks
        if trimmed == "" or trimmed:match("^%-%-") then
            if #blockStack > 0 then
                linesInCurrentBlock = linesInCurrentBlock + 1
            end
            continue
        end
        
        -- Count lines in current block
        if #blockStack > 0 then
            linesInCurrentBlock = linesInCurrentBlock + 1
        end
        
        -- Check for elseif chains
        if trimmed:match("^elseif%s") then
            elseIfCount = elseIfCount + 1
            if elseIfCount > LintRules.MaxElseIfChain then
                AddError(fileName, lineNum, `Too many elseif statements ({elseIfCount}). Consider using a table lookup or pattern matching instead`)
            end
        elseif trimmed:match("^if%s") then
            -- Reset elseif counter on new if statement
            elseIfCount = 0
            inIfBlock = true
        elseif trimmed:match("^else%s*$") or trimmed:match("^end%s*$") then
            -- Reset on else or end
            if trimmed:match("^end%s*$") then
                elseIfCount = 0
                inIfBlock = false
            end
        end
        
        -- Check for named function creation when not allowed
        if not LintRules.AllowFunctionCreation then
            -- Check for "local function name()" or "function name()"
            local isNamedFunction = trimmed:match("^local%s+function%s+%w+") or 
                                   trimmed:match("^function%s+%w+")
            
            if isNamedFunction and currentDepth > 0 then
                AddError(fileName, lineNum, "Named function creation is not allowed inside code blocks (must be at depth 0)")
            end
        end
        
        -- Check for depth increase
        for _, keyword in ipairs(depthIncreaseKeywords) do
            -- Match keyword at start of line or as standalone word
            local matched = false
            if keyword == "do" then
                matched = trimmed:match("^do%s*$") or trimmed:match("^do%s+") or trimmed == "do"
            elseif keyword == "function" then
                -- Match both "function" and "local function"
                matched = trimmed:match("^function%s") or trimmed:match("^function%(") or 
                         trimmed:match("^local%s+function%s") or trimmed:match("^local%s+function%(")
            else
                matched = trimmed:match("^" .. keyword .. "%s") or trimmed:match("^" .. keyword .. "%(")
            end
            
            if matched then
                -- Track function start for length checking
                if keyword == "function" and functionStartLine == nil then
                    functionStartLine = lineNum
                    linesInCurrentBlock = 0
                end
                
                -- Push block type onto stack
                table.insert(blockStack, {type = keyword, line = lineNum, empty = true})
                
                -- Increment depth first
                currentDepth = currentDepth + 1
                maxDepthReached = math.max(maxDepthReached, currentDepth)
                
                -- Check max layers (depth 1 is first layer, depth 2 is second layer, etc.)
                if currentDepth > LintRules.MaxLayers then
                    AddError(fileName, lineNum, `Nesting depth ({currentDepth}) exceeds maximum allowed ({LintRules.MaxLayers})`)
                end
                break
            end
        end
        
        -- Mark blocks as non-empty if they have content
        if #blockStack > 0 and trimmed ~= "" and not trimmed:match("^end") and not trimmed:match("^until") then
            blockStack[#blockStack].empty = false
        end
        
        -- Check for depth decrease
        for _, keyword in ipairs(depthDecreaseKeywords) do
            if trimmed:match("^" .. keyword) or trimmed:match(keyword .. "%s*$") then
                if currentDepth > 0 then
                    -- Check for empty blocks
                    if LintRules.WarnOnEmptyBlocks and #blockStack > 0 then
                        local block = blockStack[#blockStack]
                        if block.empty and (block.type == "if" or block.type == "for" or block.type == "while") then
                            AddError(fileName, block.line, `Empty {block.type} block detected`)
                        end
                    end
                    
                    -- Check function length
                    if functionStartLine and #blockStack > 0 and blockStack[#blockStack].type == "function" then
                        local functionLength = lineNum - functionStartLine
                        if LintRules.MaxFunctionLength and functionLength > LintRules.MaxFunctionLength then
                            AddError(fileName, functionStartLine, `Function is too long ({functionLength} lines). Consider breaking it into smaller functions (max: {LintRules.MaxFunctionLength})`)
                        end
                        functionStartLine = nil
                    end
                    
                    -- Pop from block stack
                    if #blockStack > 0 then
                        table.remove(blockStack)
                    end
                    
                    currentDepth = currentDepth - 1
                end
                break
            end
        end
        
        -- Handle single-line if statements (if x then y end)
        if trimmed:match("if.*then.*end") then
            -- Adjust depth as it opened and closed on same line
            currentDepth = currentDepth - 1
        end
    end
end

-- Main execution
print("Starting lint check...")
print("Active Rules:")
print(`  • MaxLayers: {LintRules.MaxLayers}`)
print(`  • AllowFunctionCreation: {LintRules.AllowFunctionCreation}`)
print(`  • MaxElseIfChain: {LintRules.MaxElseIfChain}`)
print(`  • MaxLineLength: {LintRules.MaxLineLength}`)
print(`  • WarnOnTodo: {LintRules.WarnOnTodo}`)
print(`  • WarnOnEmptyBlocks: {LintRules.WarnOnEmptyBlocks}`)
print(`  • MaxFunctionLength: {LintRules.MaxFunctionLength}`)
print(`  • RequireSpacesAroundOperators: {LintRules.RequireSpacesAroundOperators}`)
print(`  • WarnOnGlobalAssignment: {LintRules.WarnOnGlobalAssignment}`)
print("")

local totalFiles = 0
for _, path in ipairs(Paths) do
    if not fs.isDir(path) then
        warn(`Path does not exist or is not a directory: {path}`)
        continue
    end
    
    for _, fileName in ipairs(fs.readDir(path)) do
        -- Only process .lua and .luau files
        if not (fileName:match("%.lua$") or fileName:match("%.luau$")) then
            continue
        end
        
        local filePath = `{path}/{fileName}`
        local success, fileData = pcall(fs.readFile, filePath)
        
        if not success then
            warn(`Failed to read file: {filePath}`)
            continue
        end
        
        totalFiles = totalFiles + 1
        local tokens = fileData:split("\n")
        LintFile(filePath, tokens)
    end
end

-- Report results
print(`Linted {totalFiles} file(s)`)
print("")

if #LintErrors == 0 then
    print("✓ No linting errors found!")
else
    print(`✗ Found {#LintErrors} linting error(s):`)
    print("")
    for _, error in ipairs(LintErrors) do
        print(`  {error.File}:{error.Line}`)
        print(`    {error.Message}`)
        print("")
    end
end