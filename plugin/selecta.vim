if exists('g:selecta_loaded')
    finish
endif

" Set a special flag used only by this plugin for preventing doubly
" loading the script.
let g:selecta_loaded = 1

let g:selecta_files_tool = "ag --hidden -l"

function! SelectaCommand(choice_command, selecta_args, vim_command)
  let job = { 'buf': bufnr('%'), 'vim_command': a:vim_command, 'temps': { 'result': tempname() }, 'name': 'SelectaCommand' }

  function! job.on_exit(id, code, event)
    bd!

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

  exec 'botright' '21new'
  call termopen(a:choice_command." | selecta ".a:selecta_args." > ".job.temps.result, job)

  setf job
  startinsert
endfunction

function! SelectaBuffer()
  let bufnrs = filter(range(1, bufnr("$")), 'buflisted(v:val)')
  let buffers = map(bufnrs, 'bufname(v:val)')
  call SelectaCommand('echo "' . join(buffers, "\n") . '"', "", ":b")
endfunction

" Find all files in all non-dot directories starting in the working directory.
" Fuzzy select one of those. Open the selected file with :e.
nnoremap <expr> <Plug>(selecta-file) :call SelectaCommand(g:selecta_files_tool, "", ":e")<cr>

" Fuzzy select a buffer
nnoremap <expr> <Plug>(selecta-buffer) :call SelectaBuffer()<cr>

" Default hotkeys
nmap <leader>f <Plug>(selecta-file)
nmap <leader>b <Plug>(selecta-buffer)