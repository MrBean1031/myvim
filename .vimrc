"[count],cc:光标以下count行逐行添加注释(7,cc)
"[count],cu:光标以下count行逐行取消注释(7,cu)
"[count],cm:光标以下count行尝试添加块注释(7,cm) 

if(has("win32") || has("win95") || has("win64") || has("win16")) "判定当前操作系统类型
    let g:iswindows=1
else
    let g:iswindows=0
endif

set nocompatible "不要vim模仿vi模式，建议设置，否则会有很多不兼容的问题

if has("autocmd")
    filetype plugin indent on "根据文件进行缩进
    augroup vimrcEx
        au!
        autocmd FileType text setlocal textwidth=78
        autocmd BufReadPost *
                    \ if line("'\"") > 1 && line("'\"") <= line("$") | "实现打开同一文件时，vim能够自动记住上一次的位置
                    \ exe "normal! g`\"" |
                    \ endif
    augroup END
else
    set autoindent " always set autoindenting on "智能缩进，相应的有cindent，官方说autoindent可以支持各种文件的缩进，但是效果会比只支持C/C++cindent效果会差一点，但笔者并没有看出来
endif " has("autocmd")

if(g:iswindows==1) "允许鼠标的使用
    "防止linux终端下无法拷贝
    if has('mouse')
        set mouse=a
    endif
    au GUIEnter * simalt ~x
else
    set mouse=a
endif

"设置;直接输入:，省事
nnoremap ; :

au GUIEnter * simalt ~x   "窗口最大化
"set cursorline           "高亮当前行
"set cursorcolumn         "高亮当前列


"Vundle Config
set rtp+=~/.vim/bundle/vundle/  
call vundle#rc()  
" let Vundle manage Vundle  
" required!
Bundle 'gmarik/vundle' 

"                                           /** vundle命令 **/  
" Brief help  
" :BundleList          - list configured bundles  
" :BundleInstall(!)    - install(update) bundles  
" :BundleSearch(!) foo - search(or refresh cache first) for foo   
" :BundleClean(!)      - confirm(or auto-approve) removal of unused bundles  
"     
" see :h vundle for more details or wiki for FAQ   
" NOTE: comments after Bundle command are not allowed..  


" 在vim中打开Powerline
"set rtp+=/usr/local/lib/python2.7/dist-packages/powerline/bindings/vim/
"set laststatus=2
"set t_Co=256

" 在vim中打开airline
let g:airline_en = 1
if (g:airline_en)
Plugin 'vim-airline'
endif
" 输入(时现实函数原型
let g:echofunc_en = 1
if (g:echofunc_en)
Plugin 'mbbill/echofunc'
endif


set tags=./tags  "必须放在ctags前，omnicppcomplete等插件才能生效

nmap sy :call Do_CsTag()<CR>
nmap <leader>fs :cs find s <C-R>=expand("<cword>")<CR><CR>:copen<CR><CR>
nmap <leader>fg :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <leader>fc :cs find c <C-R>=expand("<cword>")<CR><CR>:copen<CR><CR>
nmap <leader>ft :cs find t <C-R>=expand("<cword>")<CR><CR>:copen<CR><CR>
nmap <leader>fe :cs find e <C-R>=expand("<cword>")<CR><CR>:copen<CR><CR>
nmap <leader>ff :cs find f <C-R>=expand("<cfile>")<CR><CR>:copen<CR><CR>
nmap <leader>fi :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>:copen<CR><CR>
nmap <leader>fd :cs find d <C-R>=expand("<cword>")<CR><CR>:copen<CR><CR>
function! Do_CsTag()
    let dir = getcwd()
    if filereadable("tags")
        if(g:iswindows==1)
            let tagsdeleted=delete(dir."\\"."tags")
        else
            let tagsdeleted=delete("./"."tags")
        endif
        if(tagsdeleted!=0)
            echohl WarningMsg | echo "Fail to do tags! I cannot delete the tags" | echohl None
            return
        endif
    endif
    if has("cscope")
      silent! execute "cs kill -1"
    endif
    if filereadable("cscope.files")
        if(g:iswindows==1)
            let csfilesdeleted=delete(dir."\\"."cscope.files")
        else
            let csfilesdeleted=delete("./"."cscope.files")
        endif
        if(csfilesdeleted!=0)
            echohl WarningMsg | echo "Fail to do cscope! I cannot delete the cscope.files" | echohl None
            return
        endif
    endif
    if filereadable("cscope.out")
        if(g:iswindows==1)
            let csoutdeleted=delete(dir."\\"."cscope.out")
        else
            let csoutdeleted=delete("./"."cscope.out")
        endif
        if(csoutdeleted!=0)
            echohl WarningMsg | echo "Fail to do cscope! I cannot delete the cscope.out" | echohl None
            return
        endif
    endif
    if filereadable("filenametags")
        if(g:iswindows==1)
            let fntdeleted=delete(dir."\\"."filenametags")
        else
            let fntdeleted=delete("./"."filenametags")
        endif
        if(fntdeleted!=0)
            echohl WarningMsg | echo "Fail to do filename! I cannot delete the filenametags" | echohl None
            return
        endif
    endif
    if (executable('ctags'))
        silent! execute "!ctags -R -f ./tags --c++-kinds=+p --c-kinds=+p --fields=+iaS --extra=+q"
    endif
    if(executable('cscope') && has("cscope"))
        " 设定可以使用quickfix窗口来浏览cscope结果
        set cscopequickfix=s-,c-,d-,i-,t-,e-
        " 支持用Ctrl+]和Ctrl+t在代码间跳转
        set cscopetag
        " 如果想反向搜索顺序设置为1
        set csto=0
        if(g:iswindows!=1)
            silent! execute "!find . -name '*.[hHcCsS]*' -o -name '*.inl' -o -name '*.[xX]*' -o -name '*.[jJ][aA][vV][aA]' -o -name '*.py' > cscope.files"
        else
            silent! execute "!dir /s/b *.c*,*.inl,*.x*,*.h*,*.py,*.java,*.s* >> cscope.files"
        endif
        silent! execute "!cscope -Rb"
        execute "normal :"
        if filereadable("cscope.out")
            execute "cs add cscope.out"
        endif
    endif
    if filereadable("filenametags")
      let g:LookupFile_TagExpr="./filenametags"
    endif
    silent execute "redraw!"
endfunction

if (g:airline_en)
set laststatus=2 "永远显示状态栏
let g:airline_powerline_fonts=1
let g:airline#extensions#syntastic#enabled=1
let g:airline#extensions#whitespace#enable=0
let g:airline#extensions#whitespace#symbol='!'
let g:airline#extensions#tabline#enabled=1
let g:airline#extension#tabline#buffer_nr_show=1
let g:airline#extension#tabline#idx_mode=0
let g:airline#extension#tabline#show_splits=1
let g:airline#extension#tabline#fnamemod=':t'

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

endif

"进行Tlist的设置
"TlistUpdate可以更新tags
map tl :silent! Tlist<CR>
let Tlist_Ctags_Cmd='ctags'         "因为我们放在环境变量里，所以可以直接执行
let Tlist_Use_Right_Window=1        "让窗口显示在右边，0的话就是显示在左边
let Tlist_Show_One_File=1           "让taglist可以同时展示多个文件的函数列表，如果想只有1个，设置为1
let Tlist_File_Fold_Auto_Close=1    "非当前文件，函数列表折叠隐藏
let Tlist_Exit_OnlyWindow=1         "当taglist是最后一个分割窗口时，自动退出vim
let Tlist_Process_File_Always=1     "不是一直实时更新tags，因为没有必要
let Tlist_Inc_Winwidth=0


" omnicppcomplete
" 用于C/C++代码补全，这种补全主要针对命名空间、类、结构、联合等进行补全
" 使用前先执行如下 ctags 命令（本配置中可以直接使用 ccvext 插件来执行以下命令）
" ctags -R --c++-kinds=+p --fields=+iaS --extra=+q
"set completeopt=longest,menu  "关闭菜单
set completeopt=menu,menuone  "打开菜单
let OmniCpp_MayCompleteDot=1    "打开  . 操作符
let OmniCpp_MayCompleteArrow=1  "打开 -> 操作符
let OmniCpp_MayCompleteScope=1  "打开 :: 操作符
let OmniCpp_NamespaceSearch=1   "打开命名空间
let OmniCpp_GlobalScopeSearch=1  
let OmniCpp_DefaultNamespace=["std"]  
let OmniCpp_ShowPrototypeInAbbr=1     "打开显示函数原型
"let OmniCpp_SelectFirstItem = 2     "自动弹出时自动跳至第一个
"
"let OmniCpp_NamespaceSearch = 2     " search namespaces in the current buffer   and in included files
let OmniCpp_ShowPrototypeInAbbr = 1 " 显示函数参数列表
" let OmniCpp_DefaultNamespaces = ["std", "_GLIBCXX_STD"]
"
" set autochdir
set tags=./tags  " 引导omnicppcomplete找到tags文件


" echofunc配置
if (g:echofunc_en)
set tags=./tags
endif


" NERDTree配置
let g:NERDTreeWinPos="left"
"let g:NERDTreeShowBookmarks = 1  "显示书签
map <F2> :NERDTreeToggle<CR>


map fg : Dox<cr>
let g:DoxygenToolkit_authorName="Anders"
let g:DoxygenToolkit_licenseTag="My own license\<enter>"
let g:DoxygenToolkit_undocTag="DOXIGEN_SKIP_BLOCK"
let g:DoxygenToolkit_briefTag_pre = "@brief\t"
let g:DoxygenToolkit_paramTag_pre = "@param\t"
let g:DoxygenToolkit_returnTag = "@return\t"
let g:DoxygenToolkit_briefTag_funcName = "no"
let g:DoxygenToolkit_maxFunctionProtoLines = 30

""""""""""""""""""""""""""""""
" => Minibuffer plugin
""""""""""""""""""""""""""""""
"let g:minibufexpl_en = 0
"let g:minibufexplmapwindownavvim = 0
"let g:minibufexplmapwindownavarrows = 0
"let g:minibufexplmodseltarget = 1
""let g:minibufexplusesingleclick = 1
"let g:minibufexplvsplit = 25
"let g:minibufexplsplitbelow=0
""解决FileExplorer窗口变小问题
"let g:miniBufExplorerMaxHeight = 30
"let g:miniBufExplorerMoreThanOne = 0
"let g:bufExplorerSortBy = "name"

"autocmd BufRead,BufNew :call UMiniBufExplorer
"nmap mbt :MBEToggle<CR>

nmap <script> <silent> <S-F7> :BufExplorer<CR>

set splitbelow
nmap <S-C> :stj <C-R>=expand("<cword>")<CR><CR>

nnoremap j gj
nnoremap k gk

"搜索字符串，或以递增方式搜索字符串
"let Grep_Default_Filelist = '*.[chS]' 
"let Grep_Default_Filelist = '*.c *.cpp *.asm' 
let Grep_Skip_Files = '*tags* *cscope* *.o* *.lib *.a* *.r* *.d*'
nnoremap <silent> <C-f> :Rgrep<CR><CR><CR><CR>
nnoremap <silent> <C-g> :RgrepAdd<CR><CR><CR><CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sets how many lines of history VIM has to remember
set history=300

" Enable filetype plugin
"filetype plugin on
"filetype indent on

" Set to auto read when a file is changed from the outside
set autoread

" With a map leader it's possible to do extra key combinations
" like dafleader>w saves the current file
let mapleader = ","
let g:mapleader = ","
let maplocalleader = ","
let g:maplocalleader = ","

" Fast saving
nmap <leader>w :w!<cr>
nmap <leader>qq :qa!<cr>

" Fast editing of the .vimrc
map <leader>e :e! ~/.vimrc<cr>

" When vimrc is edited, reload it
autocmd! bufwritepost .vimrc source ~/.vimrc

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set 7 lines to the curors - when moving vertical..
"set so=7

set wildmenu "Turn on WiLd menu

set ruler "Always show current position

"set cmdheight=2 "The commandbar height

set hid "Change buffer - without saving

" Set backspace config
set backspace=indent,eol,start whichwrap+=<,>,[,] "允许退格键的使用
set whichwrap+=<,>,h,l

set ignorecase "Ignore case when searching

set hlsearch "Highlight search things

set incsearch "Make search act like search in modern browsers

set magic     "设置魔术（正则表达式：除了^ $ . *之外其他元字符都要加反斜杠）

set showmatch "Show matching bracets when text indicator is over them
set mat=2 "How many tenths of a second to blink
set showcmd

" No sound on errors
set noerrorbells
set novisualbell
set t_vb=

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
syntax enable "Enable syntax hl
syntax on

" Set font according to system
if (g:iswindows==1)
    set gfn=Bitstream\ Vera\ Sans\ Mono:h10
else
    set gfn=Monospace\ 10
    set shell=/bin/bash
endif

if has("gui_running")
    set guioptions-=m
    set guioptions-=T
    set background=dark
    set t_Co=256
    set background=dark
    colorscheme default

    set nu
else
    colorscheme zellner
    set background=dark

    set nu
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files and backups
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Turn backup off, since most stuff is in SVN, git anyway...
" 不要生成swap文件，当buffer被丢弃的时候隐藏它
set nobackup
set nowb
set noswapfile
set bufhidden=hide

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 用空格代替制表符
set expandtab
" 统一缩进为2
set tabstop=2
set softtabstop=2
set shiftwidth=2
set smarttab
"指定文件类型,这样.mak和Makefile文件将都会使用真实tab
autocmd FileType Makefile set noexpandtab

set lbr
set tw=500

set ai "Auto indent
set si "Smart indet
set wrap "Wrap lines

map <leader>t2 :setlocal shiftwidth=2<cr>
map <leader>t4 :setlocal shiftwidth=4<cr>
map <leader>t8 :setlocal shiftwidth=4<cr>

""""""""""""""""""""""""""""""
" => Visual mode related
""""""""""""""""""""""""""""""
" Really useful!
"  In visual mode when you press * or # to search for the current selection
vnoremap <silent> * :call VisualSearch('f')<CR>
vnoremap <silent> # :call VisualSearch('b')<CR>

" When you press gv you vimgrep after the selected text
vnoremap <silent> gv :call VisualSearch('gv')<CR>
map <leader>g :vimgrep // **/*.<left><left><left><left><left><left><left>


function! CmdLine(str)
    exe "menu Foo.Bar :" . a:str
    emenu Foo.Bar
    unmenu Foo
endfunction 

" From an idea by Michael Naumann
function! VisualSearch(direction) range
    let l:saved_reg = @"
    execute "normal! vgvy"

    let l:pattern = escape(@", '\\/.*$^~[]')
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    if a:direction == 'b'
        execute "normal ?" . l:pattern . "^M"
    elseif a:direction == 'gv'
        call CmdLine("vimgrep " . '/'. l:pattern . '/' . ' **/*.')
    elseif a:direction == 'f'
        execute "normal /" . l:pattern . "^M"
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Command mode related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Smart mappings on the command line
cno $h e ~/
cno $d e ~/Desktop/
cno $j e ./
cno $c e <C-\>eCurrentFileDir("e")<cr>

" $q is super useful when browsing on the command line
cno $q <C-\>eDeleteTillSlash()<cr>

" Bash like keys for the command line
cnoremap <C-A>      <Home>
cnoremap <C-E>      <End>
cnoremap <C-K>      <C-U>

cnoremap <C-P> <Up>
cnoremap <C-N> <Down>

func! Cwd()
    let cwd = getcwd()
    return "e " . cwd
endfunc

func! DeleteTillSlash()
    let g:cmd = getcmdline()
    if MySys() == "linux" || MySys() == "mac"
        let g:cmd_edited = substitute(g:cmd, "\\(.*\[/\]\\).*", "\\1", "")
    else
        let g:cmd_edited = substitute(g:cmd, "\\(.*\[\\\\]\\).*", "\\1", "")
    endif
    if g:cmd == g:cmd_edited
        if MySys() == "linux" || MySys() == "mac"
            let g:cmd_edited = substitute(g:cmd, "\\(.*\[/\]\\).*/", "\\1", "")
        else
            let g:cmd_edited = substitute(g:cmd, "\\(.*\[\\\\\]\\).*\[\\\\\]", "\\1", "")
        endif
    endif  
    return g:cmd_edited
endfunc

func! CurrentFileDir(cmd)
    return a:cmd . " " . expand("%:p:h") . "/"
endfunc

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Moving around, tabs and buffers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <silent> <leader><cr> :noh<cr>

" Smart way to move btw. windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" ---常规模式下 窗口大小调整
" 使用说明："shift + ="变为"+" Y轴扩大窗口
"     "shift + -"变为"_" Y轴缩小窗口
"     "shift + ."变为">" X轴扩大窗口
"     "shift + ,"变为"<" X轴缩小窗口
nmap + <c-w>+
nmap _ <c-w>-
nmap > <c-w>>
nmap < <c-w><

" Close the current buffer
map <leader>bd :Bclose<cr>

" Close all the buffers
map <leader>ba :1,300 bd!<cr>

" Use the number to something usefull
nmap 2 :bn<cr>
nmap 1 :bp<cr>

" Tab configuration
map <leader>tn :tabnew %<cr>
map <leader>te :tabedit
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove

" When pressing <leader>cd switch to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>


command! Bclose call <SID>BufcloseCloseIt()
function! <SID>BufcloseCloseIt()
    let l:currentBufNum = bufnr("%")
    let l:alternateBufNum = bufnr("#")

    if buflisted(l:alternateBufNum)
        buffer #
    else
        bnext
    endif

    if bufnr("%") == l:currentBufNum
        new
    endif

    if buflisted(l:currentBufNum)
        execute("bdelete! ".l:currentBufNum)
    endif
endfunction

" Specify the behavior when switching between buffers
try
    set switchbuf=usetab
    set stal=2
catch
endtry

""""""""""""""""""""""""""""""
" => Statusline
""""""""""""""""""""""""""""""
" Always hide the statusline
set laststatus=2

" Format the statusline
"set statusline=\ %F%m%r%h\ %w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ %w\ CWD:\ %r%{CurDir()}%h\ \ \ Line:\ %l/%L:%c
set statusline=\ %r%{Tlist_Get_Tagname_By_Line()}%h\ %w\ %F%m%r%h\ %w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ %w\ CWD:\ %r%{CurDir()}%h\ \ \ Line:\ %l/%L:%c

function! CurDir()
    let curdir = substitute(getcwd(), '/Users/amir/', "~/", "g")
    return curdir
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Parenthesis/bracket expanding
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
vnoremap $1 <esc>`>a)<esc>`<i(<esc>
vnoremap $2 <esc>`>a]<esc>`<i[<esc>
vnoremap $3 <esc>`>a}<esc>`<i{<esc>
vnoremap $$ <esc>`>a"<esc>`<i"<esc>
vnoremap $q <esc>`>a'<esc>`<i'<esc>
vnoremap $e <esc>`>a"<esc>`<i"<esc>

" Map auto complete of (, ", ', [
"inoremap $1 ()<esc>i
"inoremap $2 []<esc>i
"inoremap $3 {}<esc>i
"inoremap $4 {<esc>o}<esc>O
"inoremap $q ''<esc>i
"inoremap $e ""<esc>i

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General Abbrevs
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
iab xdate <c-r>=strftime("%d/%m/%y %H:%M:%S")<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Editing mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Remap VIM 0
"map 0 ^

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Cope
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Do :help cope if you are unsure what cope is. It's super useful!
map <leader>cc :botright cope<cr>
map <C-n> :cnext<cr>
map <C-p> :cprev<cr>
"nmap <C-t> :colder<CR>:cc<CR>
"nmap <C-o> :colder<CR>:cc<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Omni complete functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"autocmd FileType css set omnifunc=csscomplete#CompleteCSS


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Spell checking
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Pressing ,ss will toggle and untoggle spell checking
map <leader>ss :setlocal spell!<cr>

"Shortcuts using <leader>
map <leader>sn ]s
map <leader>sp [s
map <leader>sa zg
map <leader>s? z=


""""""""""""""""""""""""""""""
" => Python section
""""""""""""""""""""""""""""""
"Delete trailing white space, useful for Python ;)
func! DeleteTrailingWS()
    exe "normal mz"
    %s/\s\+$//ge
    exe "normal `z"
endfunc
autocmd BufWrite *.py :call DeleteTrailingWS()
au FileType python set nocindent
let python_highlight_all = 1
au FileType python syn keyword pythonDecorator True None False self
autocmd FileType python setlocal et sta sw=4 sts=4
autocmd FileType python set makeprg=python\ -u\ %
let g:pydiction_location = '/home/anders/.vim/pydiction-1.2/complete-dict'
let g:pydiction_menu_height = 20
"run the checker, the default is  cs
let g:pcs_hotkey = '<leader>cs'
"when true, the checker automaticlly run while saving, the default is true
"let g:pcs_check_when_saving = '0'

au BufNewFile,BufRead *.jinja set syntax=htmljinja
au BufNewFile,BufRead *.mako set ft=mako

au FileType python inoremap <buffer> $r return
au FileType python inoremap <buffer> $i import
au FileType python inoremap <buffer> $p print
au FileType python inoremap <buffer> $f #--- PH ----------------------------------------------<esc>FP2xi
au FileType python map <buffer> <leader>1 /class
au FileType python map <buffer> <leader>2 /def
au FileType python map <buffer> <leader>C ?class
au FileType python map <buffer> <leader>D ?def


""""""""""""""""""""""""""""""
" => JavaScript section
"""""""""""""""""""""""""""""""
au FileType javascript call JavaScriptFold()
au FileType javascript setl fen
au FileType javascript setl nocindent

au FileType javascript imap <c-t> AJS.log();<esc>hi
au FileType javascript imap <c-a> alert();<esc>hi

au FileType javascript inoremap <buffer> $r return
au FileType javascript inoremap <buffer> $f //--- PH ----------------------------------------------<esc>FP2xi

function! JavaScriptFold() 
    setl foldmethod=syntax
    setl foldlevelstart=1
    syn region foldBraces start=/{/ end=/}/ transparent fold keepend extend

    function! FoldText()
        return substitute(getline(v:foldstart), '{.*', '{...}', '')
    endfunction
    setl foldtext=FoldText()
endfunction


""""""""""""""""""""""""""""""
" => Fuzzy finder
""""""""""""""""""""""""""""""
try
    call fuf#defineLaunchCommand('FufCWD', 'file', 'fnamemodify(getcwd(), ''%:p:h'')')
    map <leader>t :FufCWD **/<CR>
catch
endtry
map <F7> :FufTag<cr>
map <C-F7> :FufTaggedFile<cr>

""""""""""""""""""""""""""""""
" => Vim grep
""""""""""""""""""""""""""""""
let Grep_Skip_Dirs = 'RCS CVS SCCS .svn generated'
set grepprg=/bin/grep\ -nH


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => MISC
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remove the Windows ^M - when the encodings gets messed up
noremap <Leader>m mmHmt:%s///ge<cr>'tzt'm

"Quickly open a buffer for scripbble
"map <leader>q :e ~/buffer<cr>

set encoding=utf-8
set fileencoding=utf-8
set fileformat=unix
try
    lang en_US
catch
endtry

set ffs=unix,dos,mac "Default file types

if has("multi_byte")
    set encoding=utf-8
    set fileencodings=ucs-bom,utf-8,chinese
    " 设定默认解码
    set fenc=utf-8
    set fencs=usc-bom,utf-8,euc-jp,gb18030,gbk,gb2312,cp936,iso-8859-1
endif

set cscopequickfix=c-,d-,e-,g-,i-,s-,t-

" 带有如下符号的单词不要被换行分割
set iskeyword+=_,$,@,%,#,-

noremap <Leader>ff :%s/$//g<cr>:%s// /g<cr>

"To hex modle
let s:hexModle = "N"
function! ToHexModle()
    if s:hexModle == "Y"
        %!xxd -r
        let s:hexModle = "N"
    else
        %!xxd
        let s:hexModle = "Y"
    endif
endfunction

map <leader>h :call ToHexModle()<cr>

set lazyredraw

" 启动的时候不显示那个援助索马里儿童的提示
" set shortmess=atI

if !(g:iswindows==1)
    autocmd BufNewFile,BufRead *.c
                \ map <F9> <Esc><Esc>:!gcc -g -Wall -lm -o %< % <CR>
    autocmd BufNewFile,BufRead *.c
                \ map <S-F9> <Esc><Esc>:!gcc -O3 -o %< % <CR>

    autocmd BufNewFile,BufRead *.cc,*.cpp,*.c++,*.cxx,*.CC
                \ map <F9> <Esc><Esc>:!g++ -g -Wall -o %< % <CR>
    autocmd BufNewFile,BufRead *.cc,*.cpp,*.c++,*.cxx,*.CC
                \ map <S-F9> <Esc><Esc>:!g++ -O3 -o %< % <CR>

    autocmd BufNewFile,BufRead *.sh
                \ map <F9> <Esc><Esc>:!./% <CR>

    autocmd BufNewFile,BufRead *.py
                \ map <F9> <Esc><Esc>:!python -u % <CR>

    map <C-F9> <Esc><Esc>:!./%<<CR>
    map <C-F8> <Esc><Esc>:!gdb ./%<<CR>
    map <C-F5> :make<CR>
endif


" 用空格键来开关折叠
"set foldenable
"set foldmethod=manual
"nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>

"长行显示，解决@@@@的问题
set display=lastline

"保存和恢复工作区状态
nmap ms :mksession! workspace.vim<CR> :wviminfo! workspace.viminfo<CR>
nmap rs :source workspace.vim<CR> :rviminfo workspace.viminfo<CR>

" ---指定数值光标移动
map H 5h
map J 5j
map K 5k
map L 5l
vmap H 5h
vmap J 5j
vmap K 5k
vmap L 5l
