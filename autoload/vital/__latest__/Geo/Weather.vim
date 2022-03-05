" Utilities for Weather and other
" API for http://wttr.in/

let s:save_cpo = &cpo
set cpo&vim

function! s:_vital_loaded(V) abort
  let s:V    = a:V
  let s:http = s:V.import('Web.HTTP')
  let s:asynchttp = s:V.import('Async.HTTP')
  let s:Promise  =  s:V.import('Async.Promise')
endfunction

function! s:_vital_depends() abort
  return [ 'Web.HTTP', 'Async.HTTP', 'Async.Promise' ]
endfunction

let s:Weather = {
      \ 'status'  : v:null,
      \ 'result'  : {},
      \ 'message' : [],
      \}

let s:SITE_URL = 'https://wttr.in/'

function! s:new(...) abort
  let obj = deepcopy(s:Weather)
  if a:0 > 0
    let obj['client'] = a:1
  endif
  return obj
endfunction

function! s:Weather.resolveAsync(long,lat) abort
  let req = s:_request_process(self, {
        \ 'long' : a:long,
        \ 'lat'  : a:lat,
        \})

  let settings1 = {}
  if has_key(self, 'client')
    let settings1['client'] = self.client
  endif
  let settings2 = deepcopy(settings1)

  let settings1['param'] = s:http.encodeURIComponent(req.opt) . '&' . s:http.encodeURI(req.param)
  let settings2['param'] = s:http.encodeURIComponent(req.opt)

  let res_promise = s:asynchttp.request(s:SITE_URL . req.location, settings1)
  let msg_promise = s:asynchttp.request(s:SITE_URL . req.location, settings2)

  call res_promise.then({res -> s:_response_process1(self, res)})
  call msg_promise.then({res -> s:_response_process2(self, res)})

  return s:Promise.all([res_promise, msg_promise])
endfunction

function! s:Weather.resolve(long,lat) abort
  let req = s:_request_process(self, {
        \ 'long' : a:long,
        \ 'lat'  : a:lat,
        \})

  let settings1 = {}
  if has_key(self, 'client')
    let settings1['client'] = self.client
  endif
  let settings2 = deepcopy(settings1)

  let settings1['param'] = s:http.encodeURIComponent(req.opt) . '&' . s:http.encodeURI(req.param)
  let settings2['param'] = s:http.encodeURIComponent(req.opt)

  let res = s:http.request(s:SITE_URL . req.location, settings1)
  let msg = s:http.request(s:SITE_URL . req.location, settings2)

  call s:_response_process1(self, res)
  call s:_response_process2(self, msg)

  return self
endfunction


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

function! s:_request_process(obj, args) abort
  let param = {'format': '%c#%C#%h#%t#%w#%l#%m#%M#%p#%P'}
  let opt = join(['m', 'M', 'Q', '0', 'A', 'T'])

  let location = string(a:args.lat + 0.0) . ',' . string(a:args.long + 0.0)

  return {
        \ 'param'    : param,
        \ 'opt'      : opt,
        \ 'location' : location,
        \}
endfunction

function! s:_response_process1(obj, res) abort
  let obj = a:obj
  let res = a:res

  let items =  ['Weather', 'Condition',
        \ 'Humidity', 'Temperature', 'Wind',
        \ 'Location', 'Moonphase', 'Moonday',
        \ 'Precipitation', 'Pressure']

  let obj.status = v:false
  if res.status == 200
    let obj.status = v:true

    let resultraw = split(join(split(res.content, '\n', 0)), '#', 0)
    let result = {}
    for i in range(len(items))
      let result[items[i]] = resultraw[i]
    endfor
    let obj.result = result
  endif
endfunction

function! s:_response_process2(obj, res) abort
  let obj = a:obj
  let res = a:res

  let obj.status = v:false
  if res.status == 200
    let obj.message = res.content
  endif
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
