" Display signs on QuickFix result lines
" Maintainer: Hauleth <lukasz@niemier.pl>
" License: MIT

if exists('g:loaded_qfx')
    finish
endif
let g:loaded_qfx = 1

let s:save_cpo = &cpo
set cpo&vim

sign define QFxErr  texthl=ErrorMsg text= 
sign define QFxWarn texthl=Cursor   text= 
sign define QFxInfo texthl=Search   text= 

command! -nargs=0 -bar QfxClear call qfx#clear()
command! -nargs=0 -bar QfxPlace call qfx#place()

augroup qfx
    autocmd!
    autocmd QuickFixCmdPre [^l]* SignsClear
    autocmd QuickFixCmdPost [^l]* SignsPlace

    autocmd BufWinLeave * if getbufvar(0 + expand('<abuf>'), '&ft') ==? 'qf' | QfxClear | endif
    autocmd BufWinEnter * if getbufvar(0 + expand('<abuf>'), '&ft') ==? 'qf' | QfxPlace | endif
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
