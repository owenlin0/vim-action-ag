if exists("g:loaded_vim_action_ag") || &cp || v:version < 700
  finish
endif
let g:loaded_vim_action_ag = 1

" http://stackoverflow.com/questions/399078/what-special-characters-must-be-escaped-in-regular-expressions
let g:vim_action_ag_escape_chars = get(g:, 'vim_action_ag_escape_chars', '#%.^$*+?()[{\\|')

function! s:Ag(mode) abort
  " preserver @@ register
  let reg_save = @@

  " copy selected text to @@ register
  if a:mode ==# 'v' || a:mode ==# ''
    silent execute "normal! `<v`>y"
  elseif a:mode ==# 'char'
    silent execute "normal! `[v`]y"
  else
    return
  endif

  " prepare for search highlight
  let escaped_for_vim = escape(@@, '/\')
  execute ":let @/='\\V".escaped_for_vim."'"

  " escape special chars,
  " % is file name in vim we need to escape that first
  " # is special in ag
  let escaped_for_ag = escape(@@, '%#')
  let escaped_for_ag = escape(escaped_for_ag, g:vim_action_ag_escape_chars)

  " execute Ag command
  echo ":FzfAg " . escaped_for_ag
  execute ":FzfAg " . escaped_for_ag

  " recover @@ register
  let @@ = reg_save
endfunction

" NOTE: set hlsearch does not work in a function
vnoremap <silent> <Plug>AgActionVisual :<C-U>call <SID>Ag(visualmode())<CR>
nnoremap <silent> <Plug>AgAction       :set hlsearch<CR>:<C-U>set opfunc=<SID>Ag<CR>g@
nnoremap <silent> <Plug>AgActionWord   :set hlsearch<CR>:<C-U>set opfunc=<SID>Ag<CR>g@iw

vmap gag <Plug>AgActionVisual
nmap gag <Plug>AgAction
