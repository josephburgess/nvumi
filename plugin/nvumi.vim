if exists('g:loaded_nvumi') | finish | endif

" nnoremap <Plug>PlugCommand :lua require(...).plug_command()<CR>

let s:save_cpo = &cpo
set cpo&vim

let g:loaded_nvumi = 1

let &cpo = s:save_cpo
unlet s:save_cpo
