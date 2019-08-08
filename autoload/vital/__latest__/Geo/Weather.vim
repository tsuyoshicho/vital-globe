" Utilities for Weather and other
" API for http://wttr.in/

let s:save_cpo = &cpo
set cpo&vim

function! s:_vital_loaded(V) abort
  let s:V    = a:V
  let s:http = s:V.import('Web.HTTP')
endfunction

function! s:_vital_depends() abort
  return [ 'Web.HTTP' ]
endfunction

let s:Weather = {
      \ 'status'  : v:null,
      \ 'result'  : {},
      \ 'message' : [],
      \}

let s:SITE_URL = 'http://wttr.in/'

function! s:new() abort
  return deepcopy(s:Weather)
endfunction

function! s:Weather.resolve(long,lat) abort

   " c    Weather condition,
   " C    Weather condition textual name,
   " h    Humidity,
   " t    Temperature,
   " w    Wind,
   " l    Location,
   " m    Moonphase,
   " M    Moonday,
   " p    precipitation (mm),
   " P    pressure (hPa),

   let items =  ['Weather', 'Condition',
         \ 'Humidity', 'Temperature', 'Wind',
         \ 'Location', 'Moonphase', 'Moonday',
         \ 'Precipitation', 'Pressure']

  let param = {'format': '%c#%C#%h#%t#%w#%l#%m#%M#%p#%P'}
  let opt = join(['m', 'M', 'Q', '0', 'A', 'T'])

  let location = string(a:lat + 0.0) . ',' . string(a:long + 0.0)

  let res = s:http.get(s:SITE_URL . location,  s:http.encodeURIComponent(opt) . '&' . s:http.encodeURI(param))
  let msg = s:http.get(s:SITE_URL . location,  s:http.encodeURIComponent(opt)                                )

  let self.status = v:false
  if res.status == 200
    let self.status = v:true
    let self.message = msg.content

    let resultraw = split(join(split(res.content, '\n', 0)), '#', 0)
    let result = {}
    for i in range(len(items))
      let result[items[i]] = resultraw[i]
    endfor
    let self.result = result
  endif
  return self
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
