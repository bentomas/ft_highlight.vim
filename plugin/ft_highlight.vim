if exists('g:loaded_ft_highlight')
  finish
endif

let g:fthighlight_add_ft_mappings     = get(g:, 'fthighlight_add_ft_mappings',     1)
let g:fthighlight_add_repeat_mappings = get(g:, 'fthighlight_add_repeat_mappings', 1)
let g:fthighlight_add_ft_nop_mappings = get(g:, 'fthighlight_add_ft_nop_mappings', 1)

let s:autocmds_added = 0
function! s:AddHighlightClearAutoCmds()
    if !s:autocmds_added
        let s:autocmds_added = 1

        augroup FfforwardHighlight
            autocmd!
            autocmd CursorMoved  * :call s:ClearHighlightIfMoved()
            autocmd CursorMovedI * :call s:ClearHighlightIfMoved()
            autocmd InsertEnter  * :call s:ClearHighlight()
            autocmd BufLeave     * :call s:ClearHighlight()
            autocmd FocusLost    * :call s:ClearHighlight()
            "autocmd TextChanged  * :call s:ClearHighlight()
            "autocmd CursorHold   * :call s:ClearHighlight()
        augroup End
    endif
endfunction

function! s:PerformAndHighlight(action)
    let s:last_fFtTchar = nr2char(getchar())
    execute 'normal! '.a:action.s:last_fFtTchar

    call s:ShowHighlight()
endfunction

function! s:ShowHighlight()
    call s:AddHighlightClearAutoCmds()

    let s:highlight_lnum = line('.')
    let s:highlight_col  = col('.')

    call s:ClearHighlight()
    let s:curmatch = matchadd('FfforwardFindTill', '\%'.s:highlight_lnum.'l'.s:last_fFtTchar)
endfunction

function! s:ClearHighlight()
    if exists('s:curmatch')
        call matchdelete(s:curmatch)
        unlet s:curmatch
    endif
endfunction

function! s:ClearHighlightIfMoved()
    let lnum = line('.')
    let col  = col('.')
    if exists('s:highlight_lnum') && exists('s:highlight_col') && (lnum != s:highlight_lnum || col != s:highlight_col)
        call s:ClearHighlight()
    endif
endfunction

highlight FfforwardFindTill term=underline cterm=underline
"highlight link FfforwardFindTill IncSearch

noremap <silent> <Plug>(FTHighlightClearHighlight) :call <SID>ClearHighlight()<CR>
noremap <silent> <Plug>(FTHighlightShowHighlight)  :call <SID>ShowHighlight()<CR>
noremap <silent> <Plug>(FTHighlightFindForward)    :call <SID>PerformAndHighlight('f')<CR>
noremap <silent> <Plug>(FTHighlightFindBackward)   :call <SID>PerformAndHighlight('F')<CR>
noremap <silent> <Plug>(FTHighlightTillForward)    :call <SID>PerformAndHighlight('t')<CR>
noremap <silent> <Plug>(FTHighlightTillBackward)   :call <SID>PerformAndHighlight('T')<CR>
map     <silent> <Plug>(FTHighlightRepeatForward)  ;<Plug>(FTHighlightShowHighlight)
map     <silent> <Plug>(FTHighlightRepeatBackward) ,<Plug>(FTHighlightShowHighlight)

if g:fthighlight_add_ft_mappings
    map f <Plug>(FTHighlightFindForward)
    map F <Plug>(FTHighlightFindBackward)
    map t <Plug>(FTHighlightTillForward)
    map T <Plug>(FTHighlightTillBackward)
endif

if g:fthighlight_add_repeat_mappings
    map ; <Plug>(FTHighlightRepeatForward)
    map , <Plug>(FTHighlightRepeatBackward)
endif

if g:fthighlight_add_ft_nop_mappings
    " this makes vim wait for another character after an f is pressed to
    " see if the next character will match this.  basically it solves using
    " getchar() causing the cursor to jump to the command line
    map f<Plug>(FTHighlightNOP) <nop>
    map F<Plug>(FTHighlightNOP) <nop>
    map t<Plug>(FTHighlightNOP) <nop>
    map T<Plug>(FTHighlightNOP) <nop>
endif
