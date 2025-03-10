# buffjump.nvim

_*This is a fork of
[bufjump.nvim](https://github.com/kwkarlwang/bufjump.nvim/tree/master), which I
found had a few issues for me. I fancied a small rewrite._

## Problem
CTRL-^ (CTRL-6, {count}CTRL-^), CTRL-T, CTRL-O, and CTRL-I are very helpful, but in
many situations, only one of them will work, or none at all. The mental load of
picking the right one is too high, especially since none might do what you want.
(:bnext, :bprevious don't really cut it either; use a harpoon-like plugin if the
files you're editing do not change often).

### Example
Working on file A, you "go-to-definitioned" to file B. Then you remembered
something and "telescoped" to file C to look for it. You jumped around file C
a bit. Now you want to go back to file A. What will your brain pick quickly? CTRL-^
will fail. CTRL-T will fail. With CTRL-O you will need to press it like 6 times to
go back to the desired file, while making sure not to overshoot. You will feel stupid
in all cases.

## TLDR
This plugin makes CTRL-^, CTRL-T, CTRL-O, CTRL-I nearly obsolete. It "merges"
them, eliminating mental load when choosing the correct one. (It uses
the build-in jumplist)

## Recommended Setup
_*(assuming Lazy) (those are all the config options)_
```lua
{
  'asterikss/buffjump.nvim',
  keys = { '<C-i>', '<C-o>', '<C-n>', '<C-p>' },
  opts = {
    forward_key = '<C-n>',
    backward_key = '<C-p>',
    forward_same_buf_key = '<C-i>',
    backward_same_buf_key = '<C-o>',
    on_success = function()
      vim.cmd('normal! g`"zz')
    end,
    on_success_same_buf = function()
      vim.cmd('normal! zz')
    end,
  },
}
```

This ensures the screen will be centered after every jump, and if the jump occurred
between buffers, the cursor will move to the last position after exiting the buffer
instead of the last cursor position in the jump list stack.

(Example: You jump to file B, then move down by pressing CTRL-D 5 times. If you jump
to the previous buffer, then back again to buffer B, your cursor will by default be
placed where you were before moving with CTRL-D, since CTRL-D does not populate the
jump list.)

### Minimal Setup
```lua
{
  'asterikss/buffjump.nvim',
}
```

Then something like:

```lua
:lua require('buffjump').backward()
:lua require('buffjump').forward()
:lua require('buffjump').backward_same_buf()
:lua require('buffjump').forward_same_buf()
```
