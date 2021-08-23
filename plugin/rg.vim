if exists('g:loaded_rg') || &cp
  finish
endif

if !exists("g:rg_default_options")
  let g:rg_default_options = "--no-ignore-messages --no-messages -H --color never --no-heading --vimgrep"
endif

" Location of the rg utility
if !exists("g:rgprg")
  if executable('rg')
    let g:rgprg = "rg"
  else
    finish
  endif
  let g:rgprg .= g:rg_default_options
endif

if !exists("g:rg_apply_qmappings")
  let g:rg_apply_qmappings = !exists("g:rg_qhandler")
endif

if !exists("g:rg_apply_lmappings")
  let g:rg_apply_lmappings = !exists("g:rg_lhandler")
endif

let s:rg_mappings = {
      \ "t": "<C-W><CR><C-W>T",
      \ "T": "<C-W><CR><C-W>TgT<C-W>j",
      \ "o": "<CR>",
      \ "O": "<CR><C-W>p<C-W>c",
      \ "go": "<CR><C-W>p",
      \ "h": "<C-W><CR><C-W>K",
      \ "H": "<C-W><CR><C-W>K<C-W>b",
      \ "v": "<C-W><CR><C-W>H<C-W>b<C-W>J<C-W>t",
      \ "gv": "<C-W><CR><C-W>H<C-W>b<C-W>J" }

if exists("g:rg_mappings")
  let g:rg_mappings = extend(s:rg_mappings, g:rg_mappings)
else
  let g:rg_mappings = s:rg_mappings
endif

if !exists("g:rg_qhandler")
  let g:rg_qhandler = "botright copen"
endif

if !exists("g:rg_lhandler")
  let g:rg_lhandler = "botright lopen"
endif

if !exists("g:rghighlight")
  let g:rghighlight = 0
endif

if !exists("g:rg_autoclose")
  let g:rg_autoclose = 0
endif

if !exists("g:rg_autofold_results")
  let g:rg_autofold_results = 0
endif

if !exists("g:rg_use_cword_for_empty_search")
  let g:rg_use_cword_for_empty_search = 1
endif

command! -bang -nargs=* -complete=file Rg           call rg#Rg('grep<bang>', <q-args>)
command! -bang -nargs=* -complete=file LRg          call rg#Rg('lgrep<bang>', <q-args>)

let g:loaded_rg = 1

" vim:set et sw=2 ts=2 tw=78 fdm=marker
