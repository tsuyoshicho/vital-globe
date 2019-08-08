" Utilities for (IP) Location and other
" API for https://ifconfig.co/

let s:save_cpo = &cpo
set cpo&vim

function! s:_vital_loaded(V) abort
  let s:V    = a:V
  let s:http = s:V.import('Web.HTTP')
endfunction

function! s:_vital_depends() abort
  return [ 'Web.HTTP' ]
endfunction

let s:Location = {
      \ 'status'  : v:null,
      \ 'result'  : {},
      \}

let s:SITE_URL = 'https://ifconfig.co/'

function! s:new() abort
  return deepcopy(s:Location)
endfunction

function! s:Location.resolve() abort
  let format = 'json'

  let res = s:http.get(s:SITE_URL . format)

  let self.status = v:false
  let self.res = res
  if res.status == 200
    let self.status = v:true
    let self.result = json_decode(res.content)
  endif
  return self
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
