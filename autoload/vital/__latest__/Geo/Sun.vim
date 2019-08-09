" Utilities for Sunset/Sunrize and other
" API for https://sunrise-sunset.org/

let s:save_cpo = &cpo
set cpo&vim

function! s:_vital_loaded(V) abort
  let s:V    = a:V
  let s:http = s:V.import('Web.HTTP')
  let s:date = s:V.import('DateTime')
  let s:asynchttp = s:V.import('Async.HTTP')
endfunction

function! s:_vital_depends() abort
  return [ 'Web.HTTP', 'DateTime', 'Async.HTTP' ]
endfunction

let s:Sun = {
      \ 'status' : v:null,
      \ 'result' : {},
      \ 'json'   : {},
      \}

let s:SITE_URL = 'https://api.sunrise-sunset.org/json'
let s:PARSE_UNFORMMATED_DATETIME = '%FT%T%z'

function! s:new() abort
  return deepcopy(s:Sun)
endfunction

function! s:Sun.resolveAsync(long,lat,...) abort
  let req = s:_request_process(self, {
        \ 'long' : a:long,
        \ 'lat'  : a:lat,
        \ 'date' : (a:0 > 0) ? a:1 : s:date.now(),
        \})

  let promise = s:asynchttp.get(s:SITE_URL, s:http.encodeURI(req.param))

  call promise.then({res -> s:_response_process(self, res)})

  return promise
endfunction

function! s:Sun.resolve(long,lat,...) abort
  let req = s:_request_process(self, {
        \ 'long' : a:long,
        \ 'lat'  : a:lat,
        \ 'date' : (a:0 > 0) ? a:1 : s:date.now(),
        \})

  let res = s:http.get(s:SITE_URL, s:http.encodeURI(req.param))

  call s:_response_process(self, res)

  return self
endfunction

function! s:_request_process(obj, args) abort
  let param = {
        \ 'lat'       : 0.0,
        \ 'lng'       : 0.0,
        \ 'date'      : '',
        \ 'formatted' : 0,
        \ }

  let param.lng = string(a:args.long + 0.0)
  let param.lat = string(a:args.lat  + 0.0)
  let param.formatted = 0
  let param.date = a:args.date.format('%F')

  return { 'param' : param }
endfunction

function! s:_response_process(obj, res) abort
  let obj = a:obj
  let res = a:res

  let obj.status = v:false
  if res.status == 200
    let obj.json = json_decode(res.content)
    if obj.json.status is? 'OK'
      let obj.status = v:true

      let result = {
            \ 'sunrise':    '',
            \ 'sunset':     '',
            \ 'solar_noon': '',
            \ 'day_length': '',
            \ 'twilight': {
            \   'civil': {
            \     'begin' : '',
            \     'end'   : '',
            \   },
            \   'nautical': {
            \     'begin' : '',
            \     'end'   : '',
            \   },
            \   'astronomical': {
            \     'begin' : '',
            \     'end'   : '',
            \   },
            \ },
            \}

      for item in ['sunrise', 'sunset', 'solar_noon']
        let result[item] = s:date.from_format(obj.json.results[item], s:PARSE_UNFORMMATED_DATETIME)
      endfor

      let result.day_length = s:date.delta(obj.json.results.day_length, 'second')

      for typename in ['civil', 'nautical', 'astronomical']
        for item in ['begin', 'end']
          let result.twilight[typename][item] =
                \ s:date.from_format(obj.json.results[typename . '_twilight_' . item],
                \                    s:PARSE_UNFORMMATED_DATETIME)
        endfor
      endfor

      let obj.result = result
    endif
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
