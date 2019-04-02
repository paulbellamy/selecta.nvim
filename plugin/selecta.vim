if exists('g:selecta_loaded')
  finish
endif

" Set a special flag used only by this plugin for preventing doubly
" loading the script.
let g:selecta_loaded = 1

if !exists('g:selecta_files_tool')
  let g:selecta_files_tool = "ag --hidden -l"
endif

function! s:activate_autocmds(bufnr, job_id)
  augroup SelectaAutoHide
    autocmd!
    " Commented, because this autoevent doesn't exist in neovim yet: https://github.com/neovim/neovim/issues/8428
    " exec 'autocmd TermLeave <buffer='.a:bufnr.'> nested call jobstop('.a:job_id.')'
    exec 'autocmd BufLeave <buffer='.a:bufnr.'> nested call jobstop('.a:job_id.')'
  augroup END
endfunction


function! s:deactivate_autocmds()
  augroup SelectaAutoHide
    autocmd!
  augroup END
endfunction

function! selecta#command(choice_command, selecta_args, vim_command)
  exec 'botright' '21new'

  let job = {
  \ 'buf': bufnr('%'),
  \ 'name': 'selecta#command',
  \ 'temps': { 'result': tempname() },
  \ 'vim_command': a:vim_command
  \ }

  function! job.on_exit(id, code, event)
    call s:deactivate_autocmds()
    exec 'bd!'.self.buf

    if a:code != 0
      return 1
    endif

    if filereadable(self.temps.result)
      let l:selection = readfile(self.temps.result)[0]

      exec self.vim_command." ".l:selection
    else
      echom "selecta: error: can't read selection from (".self.temps.result.")"
    endif
  endfunction

  let job_id = termopen(a:choice_command." | selecta ".a:selecta_args." > ".job.temps.result, job)
  setf job

  call s:activate_autocmds(job.buf, job_id)

  startinsert
endfunction

function! selecta#buffer()
  let bufnrs = filter(range(1, bufnr("$")), 'buflisted(v:val)')
  let buffers = map(bufnrs, 'bufname(v:val)')
  call selecta#command('echo "' . join(buffers, "\n") . '"', "", ":b")
endfunction

nnoremap <Plug>(selecta-file)   :<C-U>call selecta#command(g:selecta_files_tool, "", ":e")<CR>
nnoremap <Plug>(selecta-buffer) :<C-U>call selecta#buffer()<CR>

" Default hotkeys
nmap <leader>f <Plug>(selecta-file)
nmap <leader>b <Plug>(selecta-buffer)
