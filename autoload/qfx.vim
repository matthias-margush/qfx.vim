let s:sign_count = get(s:, 'sign_count', 0)

function! qfx#place() abort
    if s:sign_count > 0
        return
    endif

    let l:qflist = getqflist()

    if len(l:qflist) > get(g:, 'qfx_signs_max', 200)
        echohl ErrorMsg
        echom 'To many results, aborting'
        echohl NONE

        return
    endif

    for l:error in l:qflist
        if l:error.bufnr < 0 | continue | endif

        let s:sign_count = s:sign_count + 1

        if l:error.type ==# 'E'
            let l:type = 'QFxErr'
        elseif l:error.type ==# 'W'
            let l:type = 'QFxWarn'
        else
            let l:type = 'QFxInfo'
        endif

        let l:err_sign = 'sign place ' . s:sign_count
                    \ . ' line=' . l:error.lnum
                    \ . ' name=' . l:type
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
