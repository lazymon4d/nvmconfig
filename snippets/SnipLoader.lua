local SnipLoader = {}

local function readSnip(path)
  local file = io.open(path, "r")
  local snip = file:read("*a")
  file:close()
  return snip
end

local function GetSnippets(snippetsPath)
  local snips = {}
  local files = vim.fn.readdir(snippetsPath)
  for _, file in ipairs(files) do
    if file ~= "." and file ~= ".." then
      local fullPath = snippetsPath .. file
      snips[file] = readSnip(fullPath) 
    end
  end
  return snips
end

function SnipLoader.LoadSnippets(ls, langs)
  for lang, path in pairs(langs) do
    local snips = {}
    for trigger, snippet in pairs(GetSnippets(path)) do
      table.insert(snips, ls.snippet(trigger, snippet))
    end
    ls.add_snippets(lang, snips)
  end    
end

return SnipLoader
