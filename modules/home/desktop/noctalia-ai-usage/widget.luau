-- Bar cell: one column per provider — logo, remaining session quota, remaining
-- weekly quota. Values are bare integers with no "%", so they stay legible on a
-- narrow vertical bar.

local usage = require("./usage.luau")

local POLL_MS = 60000
local LOGO_SIZE = 14
local VALUE_FONT_SIZE = 11

local snapshot = {}

local function providerColumn(provider)
  local result = snapshot[provider.key] or {}
  local children = {
    {
      type = "image",
      props = {
        key = "logo",
        path = usage.logoPath(provider),
        width = LOGO_SIZE,
        height = LOGO_SIZE,
        -- A provider we could not read at all is dimmed as a whole rather
        -- than showing a confident-looking logo above a placeholder.
        opacity = if result.err then 0.4 else 1.0,
      },
    },
  }

  local windows = usage.presentWindows(result)
  if #windows == 0 then
    -- Nothing readable yet: one placeholder, so the cell keeps a sane height
    -- instead of collapsing to a bare logo.
    table.insert(children, {
      type = "label",
      props = {
        key = "none",
        text = usage.PLACEHOLDER,
        fontSize = VALUE_FONT_SIZE,
        color = usage.remainingColor(nil),
      },
    })
  else
    for _, entry in windows do
      table.insert(children, {
        type = "label",
        props = {
          key = entry.name,
          text = usage.remainingText(entry.win),
          fontSize = VALUE_FONT_SIZE,
          color = usage.remainingColor(entry.win),
        },
      })
    end
  end

  return {
    type = "column",
    props = { key = provider.key, gap = 0, align = "center" },
    children = children,
  }
end

local function tooltipText()
  local lines = {}
  for _, provider in usage.providers do
    local result = snapshot[provider.key] or {}
    if result.err then
      table.insert(lines, provider.name .. ": " .. result.err)
    else
      table.insert(lines, provider.name)
      for _, entry in usage.presentWindows(result) do
        table.insert(
          lines,
          string.format("  %s: %d%% left, resets %s", entry.name, entry.win.remaining, usage.resetText(entry.win))
        )
      end
    end
  end
  return table.concat(lines, "\n")
end

local function render()
  local children = {}
  for _, provider in usage.providers do
    table.insert(children, providerColumn(provider))
  end
  barWidget.render({
    type = "column",
    props = { gap = 4, align = "center" },
    children = children,
  })
  barWidget.setTooltip(tooltipText())
end

function update()
  noctalia.setUpdateInterval(POLL_MS)
  -- Paint immediately from whatever the last poll produced, so a slow or failed
  -- fetch never blanks the bar.
  render()
  usage.fetchAll(function(results)
    snapshot = results
    render()
  end)
end

function onClick()
  noctalia.togglePanel("jens/ai-usage:detail")
end
