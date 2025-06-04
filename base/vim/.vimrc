"########################################################
"########################################################
"#######    _            _ _                       ######
"####  __ _| | ___  ___ (_) |_ __ _ _   _  ___  _ __ ####
"#### / _` | |/ _ \/ __|| | __/ _` | | | |/ _ \| '__| ###
"### | (_| | |  __/ (__ | | || (_| | |_| | (_) | |    ###
"###  \__,_|_|\___|\___|/ |\__\__,_|\__, |\___/|_|  #####
"######               |__/          |___/          ######
"########################################################
"########################################################

" Disable compatibility with vi which can cause unexpected issues.
set nocompatible

" Enable type file detection. Vim will be able to try to detect the type of file in use.
filetype on

" Enable plugins and load plugin for the detected file type.
filetype plugin on

" Load an indent file for the detected file type.
filetype indent on

" Turn syntax highlighting on.
syntax on

" Show partial command you type in the last line of the screen.
set showcmd

" Show the mode you are on the last line.
set showmode

" Show matching words during a search.
set showmatch

" Use highlighting when doing a search.
" set hlsearch

" Highlight cursor line underneath the cursor horizontally.
set cursorline

" turn relative line numbers on
:set relativenumber



