" A ref source for info.
" Version: 0.4.2
" Author : Eiichi Sato <sato.eiichi@gmail.com>
" ref-man Author : thinca <thinca+vim@gmail.com>
" License: Creative Commons Attribution 2.1 Japan License
"          <http://creativecommons.org/licenses/by/2.1/jp/deed.en>

let s:save_cpo = &cpo
set cpo&vim

scriptencoding utf-8

" config. {{{1
if !exists('g:ref_info_cmd')  " {{{2
  let g:ref_info_cmd = executable('info') ? 'info -o -' : ''
endif

if !exists('g:ref_info_lang')  " {{{2
  let g:ref_info_lang = ''
endif

let s:source = {'name': 'info'}  " {{{1

function! s:source.available()
  return !empty(self.option('cmd'))
endfunction

function! s:source.get_body(query)
  let q = empty(a:query) ? [] : [a:query]

  let opt_lang = self.option('lang')
  if !empty(opt_lang)
    let lang = $LANG
    let $LANG = opt_lang
  endif
  try
    let use_vimproc = g:ref_use_vimproc
    let g:ref_use_vimproc = 0
    let res = ref#system(ref#to_list(self.option('cmd')) + q)
  finally
    if exists('lang')
      let $LANG = lang
    endif
    let g:ref_use_vimproc = use_vimproc
  endtry
  if !res.result
    let body = res.stdout
    if &termencoding != '' && &encoding != '' && &termencoding !=# &encoding
      let encoded = iconv(body, &termencoding, &encoding)
      if encoded != ''
        let body = encoded
      endif
    endif

    let body = substitute(body, '.\b', '', 'g')
    let body = substitute(body, '\e\[[0-9;]*m', '', 'g')
    let body = substitute(body, '‘', '`', 'g')
    let body = substitute(body, '’', "'", 'g')
    let body = substitute(body, '[−‐]', '-', 'g')
    let body = substitute(body, '·', 'o', 'g')

    return body
  endif
endfunction

function! s:source.opened(query)
	let b:current_info = s:parse(a:query)
  call s:syntax()
endfunction

function! s:source.get_keyword()
	let line = getline('.')
	let pos = col('.')

	" ex: * aclocal Options::             Options supported by aclocal
	let pat = '^\*\s\([^:]\+\)::'
	let m = ref#get_text_on_cursor(pat)
	if !empty(m)
		return s:unparse([b:current_info[0], m[2:-3]])
	endif
	unlet pat

	" ex: File: automake-1.11.info,  Node: A Shared Library,  Next: Program and Library Variables,  Prev: A Library,  Up: Programs
	let nc = '\([^,]\+\)'
	let pat = ['File: '.nc, 'Node: '.nc, 'Next: '.nc, 'Prev: '.nc, 'Up: '.nc]
	" if match(line, '^'.join(pat, ',\s\+').'$') >= 0
		for p in reverse(copy(pat))
			let m = match(line, p)
			if m >= 0 && m < pos
				if p ==# pat[0]
					return s:unparse([b:current_info[0], ''])
				endif
				if p ==# pat[4] && matchlist(line, p)[1] ==? '(dir)'
					return s:unparse(['dir', ''])
				endif
				return s:unparse([b:current_info[0], matchlist(line, p)[1]])
			endif
		endfor
	" endif
	unlet pat

	" ex: * automake: (automake-1.11)Invoking Automake.   Generating Makefile.in.
	let pat = '^\*\s[^:]\+: \(([^)]\+)[^\.]*\)\.'
	if match(line, pat) >= 0
		return matchlist(line, pat)[1]
	endif
	unlet pat

	" ex: * config: mktex configuration.
	let pat = '^\* [^:]\+: \([^\.]\+\).'
	if match(line, pat) >= 0
		return s:unparse([b:current_info[0], matchlist(line, pat)[1]])
	endif
	unlet pat

	" ex: environment variable (*note Standards conformance::).
	let pat = '\*[Nn]ote \([^:]\+\)::'
	if match(line, pat) >= 0
		return s:unparse([b:current_info[0], matchlist(line, pat)[1]])
	endif
	unlet pat

	return ''
endfunction

function! s:source.normalize(query)
	return s:unparse(s:parse(a:query))
endfunction

function! s:source.option(opt)
  return g:ref_info_{a:opt}
endfunction

function! s:parse(query)
	let l = matchlist(a:query, '^(\([^)]\+\))\s*\(.\+\)$')
  if !empty(l)
    return [l[1], l[2]]
  endif
	let l = matchlist(a:query, '^(\([^)]\+\))$')
	if !empty(l)
		return [l[1], '']
	endif
	return [a:query, '']
endfunction

function! s:unparse(query)
	if empty(a:query[0])
		return ''
	endif
	return '('.a:query[0].')'.a:query[1]
endfunction

function! s:syntax()
  if exists('b:current_syntax')
    return
  endif

  syntax clear
	runtime! syntax/info.vim
endfunction

function! ref#info#define()
  return copy(s:source)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sts=2 sw=2:
