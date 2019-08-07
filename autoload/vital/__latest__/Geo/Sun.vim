" Utilities for Sunset/Sunrize and other
" API for https://sunrise-sunset.org/

let s:save_cpo = &cpo
set cpo&vim

function! s:_vital_loaded(V) abort
  let s:V    = a:V
  let s:http = s:V.import('Web.HTTP')
  let s:date = s:V.import('DateTime')
endfunction

function! s:_vital_depends() abort
  return [ 'Web.HTTP', 'DateTime' ]
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

function! s:Sun.resolve(long,lat,...) abort
  if a:0 > 0
    let date = a:1
  else
    let date = s:date.now()
  endif

  let param = {
        \ 'lat'       : 0.0,
        \ 'lng'       : 0.0,
        \ 'date'      : '',
        \ 'formatted' : 0,
        \ }

  let param.lng = string(a:long + 0.0)
  let param.lat = string(a:lat  + 0.0)
  let param.formatted = 0
  let param.date = date.format('%F')

  let res = s:http.get(s:SITE_URL, s:http.encodeURI(param))

  let self.status = v:false
  if res.status == 200
    let self.json = json_decode(res.content)
    if self.json.status is? 'OK'
      let self.status = v:true

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
        let result[item] = s:date.from_format(self.json.results[item], s:PARSE_UNFORMMATED_DATETIME)
      endfor

      let result.day_length = s:date.delta(self.json.results.day_length, 'second')

      for typename in ['civil', 'nautical', 'astronomical']
        for item in ['begin', 'end']
          let result.twilight[typename][item] =
                \ s:date.from_format(self.json.results[typename . '_twilight_' . item],
                \                    s:PARSE_UNFORMMATED_DATETIME)
        endfor
      endfor

      let self.result = result
    endif
  endif

  return self
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
