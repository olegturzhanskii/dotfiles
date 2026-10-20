-- NOTE:
-- The checks behind the Git hooks and ./bin/doctor, run by Neovim without a configuration:
--
--     nvim --clean --headless -l scripts/nvim-checks.lua format FILE NAME
--     nvim --clean --headless -l scripts/nvim-checks.lua syntax FILE NAME
--     nvim --clean --headless -l scripts/nvim-checks.lua installed FILE NAME PLUGINS
--
-- FILE is what is read and NAME is what a problem is reported against, because the hooks check what Git is about to
-- record by writing it to a temporary file first.
--
-- PLUGINS is the directory Lazy installs into.
--
-- Nothing here writes a file, touches the network, or installs anything: --clean loads no plugin, so neither Lazy nor
-- Mason can start an install or an update.
--
-- Before it reports, each command runs its check on cases with a known answer, and refuses to report anything if the
-- check gets one of them wrong.

local problems = {}

local function report(message) problems[#problems + 1] = message end

local function read(path)
  local file, open_error = io.open(path, 'rb')

  if not file then
    report(open_error)

    return nil
  end

  local content = file:read '*a'

  file:close()

  return content
end

local full_hash = '^' .. ('%x'):rep(40) .. '$'

local function sorted_keys(map)
  local keys = vim.tbl_keys(map)

  table.sort(keys)

  return keys
end

-- NOTE:
-- Lazy writes one entry per plugin: the branch it follows and the exact commit it is on.
--
-- Fields beyond those two are allowed, so a later Lazy that records more does not break every commit.
local function check_format(content, name)
  local decoded, lock = pcall(vim.json.decode, content)

  if not decoded then
    report(('%s is not valid JSON: %s'):format(name, lock))

    return nil
  end

  if type(lock) ~= 'table' or vim.islist(lock) or next(lock) == nil then
    report(('%s should hold one entry per plugin'):format(name))

    return nil
  end

  local valid = true

  for _, plugin in ipairs(sorted_keys(lock)) do
    local entry = lock[plugin]

    if type(entry) ~= 'table' or type(entry.branch) ~= 'string' or entry.branch == '' then
      report(('%s: %s records no branch'):format(name, plugin))

      valid = false
    end

    if type(entry) ~= 'table' or type(entry.commit) ~= 'string' or not entry.commit:match(full_hash) then
      report(('%s: %s records no full commit hash'):format(name, plugin))

      valid = false
    end
  end

  return valid and lock or nil
end

-- NOTE:
-- load compiles a chunk without running it, so this finds a syntax error and nothing else, with no plugin needed.
local function check_syntax(content, name)
  local chunk, compile_error = load(content, '@' .. name)

  if not chunk then report(compile_error) end
end

local function installed_commit(directory)
  local result = vim.system({ 'git', '-C', directory, 'rev-parse', 'HEAD' }, { text = true }):wait()

  if result.code ~= 0 then return nil end

  return vim.trim(result.stdout)
end

-- NOTE:
-- Each plugin Lazy installs is a Git checkout, so Git is asked which commit each one is on.
--
-- A recorded plugin missing from disk is a difference too, and :Lazy restore installs it at the recorded commit.
local function check_installed(lock, name, plugins)
  for _, plugin in ipairs(sorted_keys(lock)) do
    local directory = plugins .. '/' .. plugin

    local recorded = lock[plugin].commit

    if vim.fn.isdirectory(directory) == 0 then
      report(('%s records %s, which is not installed'):format(name, plugin))
    else
      local installed = installed_commit(directory)

      if installed == nil then
        report(('%s: Git could not read the commit %s is on'):format(name, plugin))
      elseif installed ~= recorded then
        local message = '%s records %s at %s, and %s is installed'

        report(message:format(name, plugin, recorded:sub(1, 12), installed:sub(1, 12)))
      end
    end
  end
end

-- NOTE:
-- A case is a check run on input whose answer is known, and holds when the check reports a problem exactly when it
-- should.
local function holds(case)
  local before = #problems

  case.run()

  local reported = #problems > before

  for index = #problems, before + 1, -1 do
    table.remove(problems, index)
  end

  return reported == case.rejects
end

-- NOTE:
-- The repository holding this script stands in for an installed plugin, because it is a Git checkout that is always
-- present, so the installed check is controlled without a fixture, and in both directions: its own commit has to pass
-- and a commit it is not on has to be reported.
local function controls(command)
  local repository = vim.fs.dirname(vim.fs.dirname(vim.fn.fnamemodify(arg[0], ':p')))

  local function installed_case(commit, rejects)
    local lock = { [vim.fs.basename(repository)] = { branch = 'main', commit = commit } }

    return { rejects = rejects, run = function() check_installed(lock, 'control', vim.fs.dirname(repository)) end }
  end

  local function format_case(content, rejects)
    return { rejects = rejects, run = function() check_format(content, 'control') end }
  end

  local entry = '{"plugin.nvim": {"branch": "main", "commit": "%s"}}'

  local cases = {
    format = {
      format_case(entry:format(('a'):rep(40)), false),
      format_case(entry:format 'abc', true),
      format_case('{"plugin.nvim": ', true),
    },
    syntax = {
      { rejects = false, run = function() check_syntax('return 1', 'control') end },
      { rejects = true, run = function() check_syntax('local value = = 1', 'control') end },
    },
    installed = {
      installed_case(installed_commit(repository) or '', false),
      installed_case(('0'):rep(40), true),
    },
  }

  return cases[command]
end

local usage = [[
usage: nvim --clean --headless -l scripts/nvim-checks.lua format FILE NAME
       nvim --clean --headless -l scripts/nvim-checks.lua syntax FILE NAME
       nvim --clean --headless -l scripts/nvim-checks.lua installed FILE NAME PLUGINS
]]

local command = arg[1]

local arity = { format = 3, syntax = 3, installed = 4 }

if arity[command] == nil or #arg ~= arity[command] then
  io.stderr:write(usage)

  os.exit(2)
end

for _, case in ipairs(controls(command)) do
  if not holds(case) then
    local message = 'nvim-checks: the %s check got a case with a known answer wrong, so it reports nothing\n'

    io.stderr:write(message:format(command))

    os.exit(2)
  end
end

local content = read(arg[2])

if content ~= nil then
  if command == 'format' then
    check_format(content, arg[3])
  elseif command == 'syntax' then
    check_syntax(content, arg[3])
  else
    local lock = check_format(content, arg[3])

    if lock ~= nil then check_installed(lock, arg[3], arg[4]) end
  end
end

for _, message in ipairs(problems) do
  io.stderr:write(message .. '\n')
end

os.exit(#problems == 0 and 0 or 1)
