-- Detail panel: the full breakdown behind the bar cell — both windows per
-- provider with a headroom bar and an exact reset time, plus how many tokens
-- Claude has actually spent recently.

local usage = require("./usage.luau")

-- Second ticks drive the reset countdown. The panel never polls the providers
-- itself — the bar widget owns that and publishes through the shared state
-- store, so opening this panel costs no additional requests. Only the local
-- token scan below runs here, and it touches nothing but disk.
local TOKENS_REFRESH_MS = 60000
local LOGO_SIZE = 16

-- Cache reads dominate the totals by an order of magnitude, so the window is a
-- rolling 24h rather than a calendar day: it needs no timezone reasoning, and
-- Claude Code prunes transcripts after a few days anyway, which would make any
-- longer window silently under-report.
local TOKENS_COMMAND = [[
cutoff=$(@coreutils@/date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%S)
@find@ "$HOME/.claude/projects" -name '*.jsonl' -type f -print0 2>/dev/null \
| @xargs@ -0 -r @coreutils@/cat 2>/dev/null \
| @jq@ -c -n --arg c "$cutoff" '
  reduce (inputs
          | select(.type=="assistant" and (.timestamp > $c))
          | .message.usage
          | select(. != null)) as $u
    ({out:0, inp:0, cc:0, cr:0};
     {out: (.out + ($u.output_tokens // 0)),
      inp: (.inp + ($u.input_tokens // 0)),
      cc:  (.cc  + ($u.cache_creation_input_tokens // 0)),
      cr:  (.cr  + ($u.cache_read_input_tokens // 0))})'
]]

local snapshot = {}
local tokens = nil
local lastTokensMs = 0
local watching = false

local function compact(n)
  if type(n) ~= "number" then
    return "?"
  end
  if n >= 1000000 then
    return string.format("%.1fM", n / 1000000)
  end
  if n >= 1000 then
    return string.format("%.0fk", n / 1000)
  end
  return tostring(n)
end

local function label(text, color, size)
  return {
    type = "label",
    props = { text = text, color = color or "on_surface", fontSize = size or 12 },
  }
end

-- Only called for windows the provider actually reports, so `win` is always set.
local function windowRow(name, win)
  return {
    type = "column",
    props = { gap = 2 },
    children = {
      {
        type = "row",
        props = { gap = 6, align = "center" },
        children = {
          { type = "label", props = { text = name, color = "on_surface_variant", fontSize = 12, width = 56 } },
          {
            type = "progress",
            props = {
              -- The bar fills with what is left, matching the number beside it.
              progress = win.remaining / 100,
              fill = usage.remainingFill(win),
              track = "surface_variant",
              flexGrow = 1,
              height = 6,
              radius = 3,
            },
          },
          {
            type = "label",
            props = {
              text = usage.remainingText(win) .. "%",
              color = usage.remainingColor(win),
              fontSize = 12,
              width = 36,
              textAlign = "right",
            },
          },
        },
      },
      {
        type = "row",
        props = { gap = 6 },
        children = {
          { type = "label", props = { text = "", width = 56 } },
          label("resets " .. usage.resetText(win), "on_surface_variant", 11),
        },
      },
    },
  }
end

local function providerSection(provider)
  local result = snapshot[provider.key] or {}
  local children = {
    {
      type = "row",
      props = { gap = 6, align = "center" },
      children = {
        {
          type = "image",
          props = { path = usage.logoPath(provider), width = LOGO_SIZE, height = LOGO_SIZE },
        },
        label(provider.name, "on_surface", 13),
      },
    },
  }

  if result.err then
    table.insert(children, label(result.err, "on_surface_variant", 12))
  elseif result.stale then
    -- Values retained from the last good poll; say so rather than presenting
    -- them as current.
    table.insert(children, label("last known — " .. result.stale, "on_surface_variant", 11))
  end

  if not result.err then
    -- Only the windows this provider actually has; Codex plans carry no
    -- 5-hour bucket, so it gets a single row rather than an empty one.
    for _, entry in usage.presentWindows(result) do
      table.insert(children, windowRow(entry.name, entry.win))
    end
    -- Codex has no live endpoint; these numbers are only as fresh as the last
    -- time Codex ran, so say when that was rather than implying they are live.
    if result.observedAt then
      table.insert(
        children,
        label(
          "last seen " .. usage.formatDuration(usage.nowSeconds() - result.observedAt) .. " ago",
          "on_surface_variant",
          11
        )
      )
    end
  end

  return { type = "column", props = { gap = 4, key = provider.key }, children = children }
end

local function tokensSection()
  if not tokens then
    return nil
  end
  return {
    type = "column",
    props = { gap = 2, key = "tokens" },
    children = {
      label("Claude tokens, last 24h", "on_surface", 13),
      label(
        string.format(
          "%s out · %s in · %s cache write · %s cache read",
          compact(tokens.out),
          compact(tokens.inp),
          compact(tokens.cc),
          compact(tokens.cr)
        ),
        "on_surface_variant",
        11
      ),
    },
  }
end

local function render()
  local children = { label("AI usage", "on_surface", 14) }
  for _, provider in usage.providers do
    table.insert(children, { type = "separator", props = {} })
    table.insert(children, providerSection(provider))
  end
  local tokenNode = tokensSection()
  if tokenNode then
    table.insert(children, { type = "separator", props = {} })
    table.insert(children, tokenNode)
  end

  panel.render({
    type = "column",
    props = { gap = 8, padding = 12 },
    children = children,
  })
end

function update()
  -- Ticks every second so the reset countdown stays live. Nothing expensive
  -- happens per tick: provider data arrives by watch, and the token scan has its
  -- own clock.
  panel.setWantsSecondTicks(true)

  if not watching then
    watching = true
    noctalia.state.watch(usage.STATE_KEY, function(value)
      snapshot = value or {}
      render()
    end)
  end

  -- A watch only delivers *changes*. If this runtime started after the widget's
  -- last poll, the next change could be a full backoff interval away, so read
  -- the current value directly until there is something to show.
  if next(snapshot) == nil then
    snapshot = noctalia.state.get(usage.STATE_KEY) or {}
  end

  local now = noctalia.nowMs()
  if now - lastTokensMs >= TOKENS_REFRESH_MS then
    lastTokensMs = now
    noctalia.runAsync(TOKENS_COMMAND, function(res)
      local raw = res.stdout and noctalia.string.trim(res.stdout) or ""
      if raw ~= "" then
        local ok, parsed = pcall(noctalia.json.decode, raw)
        if ok and type(parsed) == "table" then
          tokens = parsed
          render()
        end
      end
    end)
  end

  render()
end
