local M = {}

local on_success = nil
local on_success_same_buf = nil

local _jumpbackward = function(num)
  vim.cmd('normal!' .. tostring(num) .. '') -- Control-o
end

local _jumpforward = function(num)
  vim.cmd('normal!' .. tostring(num) .. '	') -- Control-i
end

M.backward = function()
  local getjumplist = vim.fn.getjumplist()
  local jumplist = getjumplist[1]
  if #jumplist == 0 then
    return
  end

  -- plus one because of one-based index
  local i = getjumplist[2] + 1
  local j = i
  local curBufNum = vim.fn.bufnr()
  local targetBufNum = curBufNum

  while j > 1 and (curBufNum == targetBufNum or not vim.api.nvim_buf_is_valid(targetBufNum)) do
    j = j - 1
    targetBufNum = jumplist[j].bufnr
  end
  if targetBufNum ~= curBufNum and vim.api.nvim_buf_is_valid(targetBufNum) then
    _jumpbackward(i - j)
    if on_success then
      on_success()
    end
  end
end

M.backward_same_buf = function()
  local jumplistAndPos = vim.fn.getjumplist()

  local jumplist = jumplistAndPos[1]
  if #jumplist == 0 then
    return
  end
  local lastUsedJumpPos = jumplistAndPos[2] + 1
  local curBufNum = vim.fn.bufnr()

  local j = lastUsedJumpPos
  local foundJump = false
  repeat
    j = j - 1
    if j > 0 and (curBufNum == jumplist[j].bufnr and vim.api.nvim_buf_is_valid(jumplist[j].bufnr)) then
      foundJump = true
    end
  until j == 0 or foundJump

  if foundJump then
    _jumpbackward(lastUsedJumpPos - j)
    if on_success_same_buf then
      on_success_same_buf()
    end
  end
end

M.forward = function()
  local getjumplist = vim.fn.getjumplist()
  local jumplist = getjumplist[1]
  if #jumplist == 0 then
    return
  end

  local i = getjumplist[2] + 1
  local j = i
  local curBufNum = vim.fn.bufnr()
  local targetBufNum = curBufNum

  -- find the next buffer that is different
  while j < #jumplist and (curBufNum == targetBufNum or vim.api.nvim_buf_is_valid(targetBufNum) == false) do
    j = j + 1
    targetBufNum = jumplist[j].bufnr
  end
  while j + 1 <= #jumplist and jumplist[j + 1].bufnr == targetBufNum and vim.api.nvim_buf_is_valid(targetBufNum) do
    j = j + 1
  end
  if j <= #jumplist and targetBufNum ~= curBufNum and vim.api.nvim_buf_is_valid(targetBufNum) then
    _jumpforward(j - i)

    if on_success then
      on_success()
    end
  end
end

M.forward_same_buf = function()
  local jumplistAndPos = vim.fn.getjumplist()
  local jumplist = jumplistAndPos[1]
  if #jumplist == 0 then
    return
  end
  local lastUsedJumpPos = jumplistAndPos[2] + 1
  local curBufNum = vim.fn.bufnr()

  local j = lastUsedJumpPos
  local foundJump = false
  repeat
    j = j + 1
    if j <= #jumplist and curBufNum == jumplist[j].bufnr and vim.api.nvim_buf_is_valid(jumplist[j].bufnr) then
      foundJump = true
    end
  until j > #jumplist or foundJump

  if foundJump then
    _jumpforward(j - lastUsedJumpPos)
    if on_success_same_buf then
      on_success_same_buf()
    end
  end
end

M.setup = function(opts)
  if opts then
    if opts.forward_key then
      vim.keymap.set('n', opts.forward_key, M.forward)
    end
    if opts.backward_key then
      vim.keymap.set('n', opts.backward_key, M.backward)
    end
    if opts.forward_same_buf_key then
      vim.keymap.set('n', opts.forward_same_buf_key, M.forward_same_buf)
    end
    if opts.backward_same_buf_key then
      vim.keymap.set('n', opts.backward_same_buf_key, M.backward_same_buf)
    end
    -- Assumes the user passed a function
    if opts.on_success then
      on_success = opts.on_success
    end
    if opts.on_success_same_buf then
      on_success_same_buf = opts.on_success_same_buf
    end
  end
end

return M
