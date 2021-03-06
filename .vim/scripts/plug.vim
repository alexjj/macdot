if !exists('g:env')
    finish
endif

let g:plug = {
            \ "plug":   expand(g:env.path.vim) . "/autoload/plug.vim",
            \ "base":   expand(g:env.path.vim) . "/plugged",
            \ "url":    "https://raw.github.com/junegunn/vim-plug/master/plug.vim",
            \ "github": "https://github.com/junegunn/vim-plug",
            \ }

function! g:plug.ready()
    return filereadable(self.plug)
endfunction

if g:plug.ready() && g:env.vimrc.plugin_on
    " start to manage with vim-plug
    call plug#begin(g:plug.base)

    " file and directory
    Plug 'b4b4r07/vim-shellutils'
    Plug 'b4b4r07/mru.vim'
    Plug 'junegunn/fzf'
    Plug 'junegunn/fzf.vim'
    Plug 'justinmk/vim-dirvish'
    Plug 'tweekmonster/fzf-filemru'
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-endwise'
    Plug 'b4b4r07/enhancd', { 'tag': '2.2.1' }
    Plug 'Shougo/vimproc.vim',  { 'do': 'make' }
    Plug 'vim-jp/vimdoc-ja'
    Plug 'osyo-manga/vim-anzu'
    Plug 'tyru/caw.vim'
    Plug 'AndrewRadev/gapply.vim'
    Plug 'thinca/vim-quickrun'
    Plug 'mattn/vim-terminal'
    Plug 'thinca/vim-prettyprint', { 'on': 'PP' }
    Plug 'rhysd/github-complete.vim'
    Plug 'junegunn/vim-emoji'
    Plug 'b4b4r07/vim-shell-with-tmux', { 'on': 'Sh' }
    Plug 'tyru/open-browser.vim'
    Plug 'tyru/open-browser-github.vim'
    Plug 'kien/ctrlp.vim'
    Plug 'b4b4r07/vim-hcl'
    Plug 'fatih/vim-hclfmt'
    Plug has('lua') ? 'Shougo/neocomplete.vim' : 'Shougo/neocomplcache'
    Plug g:env.is_gui ? 'itchyny/lightline.vim' : ''

    " syntax? language support
    Plug 'fatih/vim-go', { 'for': 'go' }
    Plug 'jnwhiteh/vim-golang', { 'for': 'go' }
    "Plug 'zaiste/tmux.vim', { 'for': 'tmux' }
    Plug 'keith/tmux.vim', { 'for': 'tmux' }
    Plug 'dag/vim-fish', { 'for': 'fish' }
    Plug 'zplug/vim-zplug', { 'for': 'zplug' }
    Plug 'chase/vim-ansible-yaml'
    Plug 'evanmiller/nginx-vim-syntax', { 'for': 'nginx' }
    Plug 'cespare/vim-toml', { 'for': 'toml' }
    Plug 'elzr/vim-json', { 'for': 'json' }
    Plug 'b4b4r07/vim-ltsv', { 'for': 'ltsv' }
    Plug 'jelera/vim-javascript-syntax', { 'for': 'javascript' }
    Plug 'maksimr/vim-jsbeautify', { 'for': 'javascript' }
    Plug 'chrisbra/csv.vim', { 'for': 'csv' }
    Plug 'zplug/vim-zplug', { 'for': 'zplug' }

    " colorscheme
    Plug 'b4b4r07/solarized.vim'
    Plug 'w0ng/vim-hybrid'
    Plug 'junegunn/seoul256.vim'
    Plug 'nanotech/jellybeans.vim'
    Plug 'whatyouhide/vim-gotham'

    " Add plugins to &runtimepath
    call plug#end()
endif

" Add plug's plugins
let g:plug.plugs = get(g:, 'plugs', {})
let g:plug.list  = keys(g:plug.plugs)

if !g:plug.ready()
    function! g:plug.init()
        let ret = system(printf("curl -fLo %s --create-dirs %s", self.plug, self.url))
        "call system(printf("git clone %s", self.github))
        if v:shell_error
            return Error('g:plug.init: error occured')
        endif

        " Restart vim
        if !g:env.is_gui
            silent! !vim
            quit!
        endif
    endfunction
    command! PlugInit call g:plug.init()

    if g:env.vimrc.suggest_neobundleinit == g:true
        autocmd! VimEnter * redraw
                    \ | echohl WarningMsg
                    \ | echo "You should do ':PlugInit' at first!"
                    \ | echohl None
    else
        " Install vim-plug
        PlugInit
    endif
endif

function! g:plug.is_installed(strict, ...)
    let list = []
    if type(a:strict) != type(0)
        call add(list, a:strict)
    endif
    let list += a:000

    for arg in list
        let name   = substitute(arg, '^vim-\|\.vim$', "", "g")
        let prefix = "vim-" . name
        let suffix = name . ".vim"

        if a:strict == 1
            let name   = arg
            let prefix = arg
            let suffix = arg
        endif

        if has_key(self.plugs, name)
                    \ ? isdirectory(self.plugs[name].dir)
                    \ : has_key(self.plugs, prefix)
                    \ ? isdirectory(self.plugs[prefix].dir)
                    \ : has_key(self.plugs, suffix)
                    \ ? isdirectory(self.plugs[suffix].dir)
                    \ : g:false
            continue
        else
            return g:false
        endif
    endfor

    return g:true
endfunction

function! g:plug.is_rtp(p)
    return index(split(&rtp, ","), get(self.plugs[a:p], "dir")) != -1
endfunction

function! g:plug.is_loaded(p)
    return g:plug.is_installed(1, a:p) && g:plug.is_rtp(a:p)
endfunction

function! g:plug.check_installation()
    if empty(self.plugs)
        return
    endif

    let list = []
    for [name, spec] in items(self.plugs)
        if !isdirectory(spec.dir)
            call add(list, spec.uri)
        endif
    endfor

    if len(list) > 0
        let unplugged = map(list, 'substitute(v:val, "^.*github\.com/\\(.*/.*\\)\.git$", "\\1", "g")')

        " Ask whether installing plugs like NeoBundle
        echomsg 'Not installed plugs: ' . string(unplugged)
        if confirm('Install plugs now?', "yes\nNo", 2) == 1
            PlugInstall
            " Close window for vim-plug
            silent! close
            " Restart vim
            if !g:env.is_gui
                silent! !vim
                quit!
            endif
        endif
    endif
endfunction

if g:plug.ready() && g:env.vimrc.plugin_on
    function! PlugList(A,L,P)
        return join(g:plug.list, "\n")
    endfunction

    command! -nargs=1 -complete=custom,PlugList PlugHas
                \ if g:plug.is_installed('<args>')
                \ | echo g:plug.plugs['<args>'].dir
                \ | endif
endif

" __END__ {{{1
" vim:fdm=marker expandtab fdc=3:
