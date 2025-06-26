local group = vim.api.nvim_create_augroup("chris468.load-modified", { clear = true })

---@param event string|string[]
---@param pattern? string
---@param predicate? fun(args: vim.api.keyset.create_autocmd.callback_args): boolean
local function register(event, pattern, predicate)
  vim.api.nvim_create_autocmd(event, {
    group = group,
    pattern = pattern,
    callback = function(a)
      if predicate == nil or predicate(a) then
        vim.cmd("checktime")
      end
    end,
  })
end

local neogit_events = {
  NeogitStatusRefreshed = true,
  NeogitPushComplete = true,
  NeogitPullComplete = true,
  NeogitFetchComplete = true,
  NeogitBranchCheckout = true,
  NeogitBranchReset = true,
  NeogitRebase = true,
  NeogitReset = true,
  NeogitCherryPick = true,
  NeogitMerge = true,
}

register({ "FocusGained", "TermClose", "TermLeave" })
register("User", "Neogit*", function(arg)
  return neogit_events[arg.match]
end)
