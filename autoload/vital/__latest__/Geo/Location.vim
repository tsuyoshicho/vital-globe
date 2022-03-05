" Utilities for (IP) Location and other
" API for https://ifconfig.co/

let s:save_cpo = &cpo
set cpo&vim

function! s:_vital_loaded(V) abort
  let s:V    = a:V
  let s:http = s:V.import('Web.HTTP')
  let s:asynchttp = s:V.import('Async.HTTP')
endfunction

function! s:_vital_depends() abort
  return [ 'Web.HTTP', 'Async.HTTP' ]
endfunction

let s:Location = {
      \ 'status'  : v:null,
      \ 'result'  : {},
      \}

let s:SITE_URL = 'https://ifconfig.co/'

function! s:new(...) abort
  let obj = deepcopy(s:Location)
  if a:0 > 0
    let obj['client'] = a:1
  endif
  return obj
endfunction

function! s:Location.resolveAsync() abort
  let req = s:_request_process(self, {})

  let settings = {}
  if has_key(self, 'client')
    let settings['client'] = self.client
  endif

  let promise = s:asynchttp.request(s:SITE_URL . req.location, settings)

  call promise.then({res -> s:_response_process(self, res)})

  return promise
endfunction

function! s:Location.resolve() abort
  let req = s:_request_process(self, {})

  let settings = {}
  if has_key(self, 'client')
    let settings['client'] = self.client
  endif

  let res = s:http.request(s:SITE_URL . req.location, settings)

  call s:_response_process(self, res)

  return self
endfunction

function! s:_request_process(obj, args) abort
  let format = 'json'
  return { 'location' : format }
endfunction

function! s:_response_process(obj, res) abort
  let obj = a:obj
  let res = a:res

  let obj.status = v:false
  let obj.res = res
  if res.status == 200
    let obj.status = v:true
    let obj.result = json_decode(res.content)
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
