-- Shared quota fetching for the bar widget and the detail panel.
--
-- Both providers report how much of a window has been *used*; everything above
-- this layer works in "remaining" (100 - used), because that is the number the
-- bar shows. A window is nil when the provider does not expose it at all, which
-- is different from a window we failed to read — the latter sets `err`.

local M = {}

local CLAUDE_CREDENTIALS = "~/.claude/.credentials.json"
local CLAUDE_USAGE_URL = "https://api.anthropic.com/api/oauth/usage"
local CLAUDE_BETA = "oauth-2025-04-20"

-- Newest rollouts first; the most recent session may not have reached an
-- assistant turn yet, so scan a few until one carries a rate_limits event.
local CODEX_COMMAND = [[
for f in $(@coreutils@/ls -t "$HOME"/.codex/sessions/*/*/*/rollout-*.jsonl 2>/dev/null | @coreutils@/head -5); do
  line=$(@coreutils@/tac "$f" | @grep@ -m1 '"rate_limits"')
  if [ -n "$line" ]; then printf '%s' "$line"; break; fi
done
]]

-- A window shorter than a day is the "session" bucket, anything longer is the
-- "weekly" one. Codex plans differ in which slot they populate, so the window
-- length decides rather than the primary/secondary ordering.
local SESSION_MAX_MINUTES = 1440

--------------------------------------------------------------------------------
-- helpers

local function decode(raw)
  if type(raw) ~= "string" or raw == "" then
    return nil
  end
  local ok, value = pcall(noctalia.json.decode, raw)
  if not ok or type(value) ~= "table" then
    return nil
  end
  return value
end

-- Days since the Unix epoch (Howard Hinnant's days_from_civil). Used instead of
-- os.time because os.time interprets its table as local time and the API
-- timestamps are UTC.
local function daysFromCivil(y, m, d)
  if m <= 2 then
    y -= 1
  end
  local era = math.floor(y / 400)
  local yoe = y - era * 400
  local mp = if m > 2 then m - 3 else m + 9
  local doy = math.floor((153 * mp + 2) / 5) + d - 1
  local doe = yoe * 365 + math.floor(yoe / 4) - math.floor(yoe / 100) + doy
  return era * 146097 + doe - 719468
end

-- "2026-08-12T02:10:00.100520+00:00" -> unix seconds. The Claude endpoint always
-- reports UTC, so the offset suffix is not parsed.
local function epochFromIso(iso)
  if type(iso) ~= "string" then
    return nil
  end
  local y, mo, d, h, mi, s = iso:match("^(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")
  if not y then
    return nil
  end
  return daysFromCivil(tonumber(y), tonumber(mo), tonumber(d)) * 86400
    + tonumber(h) * 3600
    + tonumber(mi) * 60
    + tonumber(s)
end

local function window(used, resetsAt)
  if type(used) ~= "number" then
    return nil
  end
  return {
    used = used,
    -- Floor rather than round so the bar never claims more headroom than there is.
    remaining = math.max(0, math.min(100, 100 - math.floor(used))),
    resetsAt = resetsAt,
  }
end

--------------------------------------------------------------------------------
-- claude: live, via the same OAuth endpoint Claude Code's own /usage reads

local function claudeToken()
  local raw = noctalia.readFile(noctalia.expandPath(CLAUDE_CREDENTIALS))
  local creds = decode(raw)
  if not creds then
    return nil, "no credentials"
  end
  local oauth = creds.claudeAiOauth
  if type(oauth) ~= "table" or type(oauth.accessToken) ~= "string" then
    return nil, "not signed in"
  end
  -- Deliberately no refresh: Claude Code owns this file and rewrites it. An
  -- expired token means the numbers are stale, not that anything is broken.
  if type(oauth.expiresAt) == "number" and oauth.expiresAt <= noctalia.nowMs() then
    return nil, "token expired"
  end
  return oauth.accessToken
end

function M.fetchClaude(callback)
  local token, err = claudeToken()
  if not token then
    callback({ err = err })
    return
  end

  noctalia.http({
    url = CLAUDE_USAGE_URL,
    method = "GET",
    headers = {
      "Authorization: Bearer " .. token,
      "anthropic-beta: " .. CLAUDE_BETA,
      "Content-Type: application/json",
    },
  }, function(res)
    if not res.ok then
      callback({ err = "unreachable" })
      return
    end
    if res.status ~= 200 then
      callback({ err = "http " .. tostring(res.status) })
      return
    end
    local body = decode(res.body)
    if not body then
      callback({ err = "bad response" })
      return
    end

    local five = body.five_hour
    local seven = body.seven_day
    callback({
      session = if type(five) == "table"
        then window(five.utilization, epochFromIso(five.resets_at))
        else nil,
      weekly = if type(seven) == "table"
        then window(seven.utilization, epochFromIso(seven.resets_at))
        else nil,
    })
  end)
end

--------------------------------------------------------------------------------
-- codex: last-seen, from the session rollout files
--
-- There is no live endpoint here. Codex writes a rate_limits event into its
-- rollout JSONL as it goes, so these numbers are as fresh as the last time Codex
-- actually ran; `observedAt` carries that so the UI can say so.

function M.fetchCodex(callback)
  noctalia.runAsync(CODEX_COMMAND, function(res)
    local line = res.stdout and noctalia.string.trim(res.stdout) or ""
    if line == "" then
      callback({ err = "no sessions" })
      return
    end
    local event = decode(line)
    local limits = event and type(event.payload) == "table" and event.payload.rate_limits
    if type(limits) ~= "table" then
      callback({ err = "no quota data" })
      return
    end

    -- Built by appending rather than as a literal: `secondary` is routinely null,
    -- and a nil hole in an array literal truncates generalized iteration.
    local slots = {}
    if type(limits.primary) == "table" then
      table.insert(slots, limits.primary)
    end
    if type(limits.secondary) == "table" then
      table.insert(slots, limits.secondary)
    end

    local out = { observedAt = epochFromIso(event.timestamp) }
    for _, slot in slots do
      if type(slot.window_minutes) == "number" then
        local key = if slot.window_minutes <= SESSION_MAX_MINUTES then "session" else "weekly"
        out[key] = window(slot.used_percent, slot.resets_at)
      end
    end
    callback(out)
  end)
end

--------------------------------------------------------------------------------
-- presentation

-- Providers in bar order. `logo` names the asset stem under assets/.
M.providers = {
  { key = "claude", name = "Claude", logo = "claude", fetch = M.fetchClaude },
  { key = "codex", name = "Codex", logo = "codex", fetch = M.fetchCodex },
}

function M.logoPath(provider)
  local variant = if noctalia.isDarkMode() then "dark" else "light"
  return noctalia.pluginDir() .. "/assets/" .. provider.logo .. "-" .. variant .. ".svg"
end

-- Fetch every provider and hand back one table keyed by provider key. Callbacks
-- are asynchronous and unordered, so the result only fires once all have landed.
function M.fetchAll(callback)
  local results = {}
  local outstanding = #M.providers
  for _, provider in M.providers do
    provider.fetch(function(result)
      results[provider.key] = result
      outstanding -= 1
      if outstanding == 0 then
        callback(results)
      end
    end)
  end
end

M.PLACEHOLDER = "--"

function M.remainingText(win)
  if not win then
    return M.PLACEHOLDER
  end
  return tostring(win.remaining)
end

-- The windows a provider actually reports, in display order.
--
-- A missing window means the provider has no such concept — Codex plans have no
-- 5-hour bucket at all — which is different from a window we failed to read.
-- Absent windows are omitted entirely rather than rendered as a placeholder, so
-- a provider with only a weekly limit shows one number, not one number and a
-- gap. A read failure sets `err` instead and is handled by the caller.
function M.presentWindows(result)
  local out = {}
  if result.session then
    table.insert(out, { name = "Session", win = result.session })
  end
  if result.weekly then
    table.insert(out, { name = "Weekly", win = result.weekly })
  end
  return out
end

-- Colour by headroom, not by usage: the bar answers "how much is left".
-- `normal` differs between call sites — text reads best in the plain foreground
-- role, while a progress fill needs an accent to separate it from its track.
local function severity(win)
  if not win then
    return "unknown"
  end
  if win.remaining < 20 then
    return "critical"
  end
  if win.remaining < 40 then
    return "low"
  end
  return "normal"
end

local PALETTE = {
  text = { unknown = "surface_variant", critical = "error", low = "tertiary", normal = "on_surface" },
  fill = { unknown = "surface_variant", critical = "error", low = "tertiary", normal = "primary" },
}

function M.remainingColor(win)
  return PALETTE.text[severity(win)]
end

function M.remainingFill(win)
  return PALETTE.fill[severity(win)]
end

function M.formatDuration(seconds)
  if type(seconds) ~= "number" or seconds <= 0 then
    return "now"
  end
  local days = math.floor(seconds / 86400)
  local hours = math.floor((seconds % 86400) / 3600)
  local minutes = math.floor((seconds % 3600) / 60)
  if days > 0 then
    return string.format("%dd %dh", days, hours)
  end
  if hours > 0 then
    return string.format("%dh %dm", hours, minutes)
  end
  return string.format("%dm", minutes)
end

function M.nowSeconds()
  return math.floor(noctalia.nowMs() / 1000)
end

function M.resetText(win)
  if not win or type(win.resetsAt) ~= "number" then
    return "unknown"
  end
  return string.format(
    "in %s (%s)",
    M.formatDuration(win.resetsAt - M.nowSeconds()),
    noctalia.formatTime("%a %H:%M", win.resetsAt)
  )
end

return M
