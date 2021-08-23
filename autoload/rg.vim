if exists('g:autoloaded_rg') || &cp
  finish
endif


"-----------------------------------------------------------------------------
" Public API
"-----------------------------------------------------------------------------

function! rg#Rg(cmd, args) "{{{
  call s:Init(a:cmd)
  redraw

  " Local values that we'll temporarily set as options when searching
  let l:grepprg = g:rgprg
  let l:grepformat = '%f:%l:%c:%m,%f:%l:%m'  " Include column number

  " Strip some options that are meaningless for path search and set match
  " format accordingly.

  " Check user policy for blank searches
  if empty(a:args)
    if !g:rg_use_cword_for_empty_search
      echo "No regular expression found."
      return
    endif
  endif

  " If no pattern is provided, search for the word under the cursor
  let l:grepargs = empty(a:args) ? expand("<cword>") : a:args . join(a:000, ' ')

  "Bypass search if cursor is on blank string
  if l:grepargs == ""
    echo "No regular expression found."
    return
  endif

  " NOTE: we escape special chars, but not everything using shellescape to
  "       allow for passing arguments etc
  let l:escaped_args = escape(l:grepargs, '|#%')

  " echo "Searching ..."

  call s:SearchWithGrep(a:cmd, l:grepprg, l:escaped_args, l:grepformat)

  " Dispatch has no callbrg mechanism currently, we just have to display the
  " list window early and wait for it to populate :-/
  call rg#ShowResults()
  call s:Highlight(l:grepargs)
endfunction "}}}

function! rg#ShowResults() "{{{
  let l:handler = s:UsingLocList() ? g:rg_lhandler : g:rg_qhandler
  execute l:handler
  call s:ApplyMappings()
  redraw!
endfunction "}}}

"-----------------------------------------------------------------------------
" Private API
"-----------------------------------------------------------------------------

function! s:ApplyMappings() "{{{
  if !s:UsingListMappings() || &filetype != 'qf'
    return
  endif

  let l:wintype = s:UsingLocList() ? 'l' : 'c'
  let l:closemap = ':' . l:wintype . 'close<CR>'
  let g:rg_mappings.q = l:closemap

  if g:rg_autoclose
    " We just map the 'go' and 'gv' mappings to close on autoclose, wtf?
    for key_map in items(g:rg_mappings)
      execute printf("nnoremap <buffer> <silent> %s %s", get(key_map, 0), get(key_map, 1) . l:closemap)
    endfor

    execute "nnoremap <buffer> <silent> <CR> <CR>" . l:closemap
  else
    for key_map in items(g:rg_mappings)
      execute printf("nnoremap <buffer> <silent> %s %s", get(key_map, 0), get(key_map, 1))
    endfor
  endif

  if exists("g:rgpreview") " if auto preview in on, remap j and k keys
    nnoremap <buffer> <silent> j j<CR><C-W><C-P>
    nnoremap <buffer> <silent> k k<CR><C-W><C-P>
    nmap <buffer> <silent> <Down> j
    nmap <buffer> <silent> <Up> k
  endif
endfunction "}}}

function! s:GetDocLocations() "{{{
  let dp = ''
  for p in split(&rtp, ',')
    let p = p . '/doc/'
    if isdirectory(p)
      let dp = p . '*.txt ' . dp
    endif
  endfor

  return dp
endfunction "}}}

function! s:Highlight(args) "{{{
  if !g:rghighlight
    return
  endif

  let @/ = matchstr(a:args, "\\v(-)\@<!(\<)\@<=\\w+|['\"]\\zs.{-}\\ze['\"]")
  call feedkeys(":let &hlsearch=1 \| echo \<CR>", "n")
endfunction "}}}

" Initialize state for an :Rg* or :LRg* search
function! s:Init(cmd) "{{{
  let s:using_loclist       = (a:cmd =~# '^l') ? 1 : 0
endfunction "}}}

function! s:SearchWithGrep(grepcmd, grepprg, grepargs, grepformat) "{{{
  let l:grepprg_bak    = &l:grepprg
  let l:grepformat_bak = &grepformat

  try
    let &l:grepprg  = a:grepprg
    let &grepformat = a:grepformat

    silent execute a:grepcmd a:grepargs
  finally
    let &l:grepprg  = l:grepprg_bak
    let &grepformat = l:grepformat_bak
  endtry
endfunction "}}}

" Predicate for whether mappings are enabled for list type of current search.
function! s:UsingListMappings() "{{{
  if s:UsingLocList()
    return g:rg_apply_lmappings
  else
    return g:rg_apply_qmappings
  endif
endfunction "}}}

" Were we invoked with a :LRg command?
function! s:UsingLocList() "{{{
  return get(s:, 'using_loclist', 0)
endfunction "}}}

function! s:Warn(msg) "{{{
  echohl WarningMsg | echomsg 'Rg: ' . a:msg | echohl None
endf "}}}

let g:autoloaded_rg = 1
" vim:set et sw=2 ts=2 tw=78 fdm=marker
