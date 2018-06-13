let s:sign_count = get(s:, 'sign_count', 0)

let s:importance_table = {'E': 0, 'W': 1}
let s:sign_names = ['QFxError', 'QFxWarn', 'QFxInfo']

function! s:min(a, b) abort
    if a:a < 0
        return a:b
    elseif a:b < 0
        return a:a
    elseif a:a < a:b
        return a:a
    else
        return a:b
    endif
endfunction

function! s:importance(elem) abort
    return get(s:importance_table, a:elem, 999)
endfunction

function! s:reduce(list) abort
    let l:errors = {}

    for l:error in a:list
        if l:error.bufnr < 0 | continue | endif

        let l:errors[l:error.bufnr] = get(l:errors, l:error.bufnr, {})
        let l:current = get(l:errors[l:error.bufnr], l:error.lnum, -1)
        let l:errors[l:error.bufnr][l:error.lnum] =
                    \ s:min(l:current, s:importance(l:error.type))
    endfor

    let l:ret = []

    for l:bufnr in keys(l:errors)
        for l:lnum in keys(l:errors[l:bufnr])
            call add(l:ret, {
                        \ 'bufnr': l:bufnr,
                        \ 'lnum': l:lnum,
                        \ 'level': l:errors[l:bufnr][l:lnum]
                        \ })
        endfor
    endfor

    return l:ret
endfunction

function! qfx#place() abort
    if s:sign_count > 0 | return | endif

    let l:qflist = s:reduce(getqflist())

    if len(l:qflist) > get(g:, 'qfx_signs_max', 200)
        echohl ErrorMsg
        echom 'To many results, aborting'
        echohl NONE

        return
    endif

    for l:error in l:qflist
        if l:error.bufnr < 0 | continue | endif

        let s:sign_count = s:sign_count + 1

        let l:err_sign = 'sign place ' . s:sign_count
                    \ . ' line=' . l:error.lnum
                    \ . ' name=' . get(s:sign_names, l:error.level, s:sign_names[-1])
                    \ . ' buffer=' . l:error.bufnr

        silent! execute l:err_sign
    endfor
endfunction

function! qfx#clear() abort
    while s:sign_count > 0
        execute 'sign unplace ' . s:sign_count
        let s:sign_count = s:sign_count - 1
    endwhile

    redraw!
endfunction
