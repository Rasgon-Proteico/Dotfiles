" ~/.vimrc

set number             " Muestra los números de línea
set mouse=a            " Habilita el uso del ratón en todos los modos
set tabstop=2          " Un tabulador ocupa 2 espacios
set shiftwidth=2       " La indentación automática usa 2 espacios
set expandtab          " Convierte los tabuladores en espacios
syntax on              " Activa el resaltado de sintaxis

if has('unix') && system('which wl-copy') != ''

   set clipboard=unnamedplus
nnoremap <C-a> ggVG
  let g:clipboard = {
      \   'name': 'wl-clipboard',
      \   'copy': {
      \      '+': 'wl-copy',
      \      '*': 'wl-copy --primary',
      \   },
      \   'paste': {
      \      '+': 'wl-paste',
      \      '*': 'wl-paste --primary',
      \   },
      \   'cache_enabled': 1,
      \ }
endif
" Mapear la tecla ñ para que funcione como Inicio
nnoremap ñ ^
inoremap ñ <Esc>I

" Mapear la tecla de acento agudo (´) para que funcione como Fin
nnoremap ´ $
inoremap ´ <Esc>A```

