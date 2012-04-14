" Vim syntax file
" Language:	info page.
" Maintainer:	Eiichi Sato <sato.eiichi@gmail.com>
" Last Change:	2012 Apr 14

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn case ignore

syn match infoQuated "`[^']*'"
syn match infoSeparator "^[-=\*]*$"

syn match infoNavigation '\(File\|Node\|Next\|Prev\|Up\): [^,]\+' contains=infoNavigationKey
syn match infoNavigationKey '\(File\|Node\|Next\|Prev\|Up\): ' contained

syn match infoDirMenu '^\*\s[^:]\+: \(([^)]\+)[^\.]*\)\.'ms=s+2,me=e-1
syn match infoNote '\*[Nn]ote \([^:]\+\)::'ms=s+5,me=e-2

syn match infoSubMenu1 "^\*\s[^:]\+::"me=e-2,ms=s+2
syn match infoSubMenu2 '^\* [^:]\+: \([^\.]\+\).'ms=s+2,me=e-1

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_info_syn_inits")
  if version < 508
    let did_info_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

	HiLink infoQuated Constant
	HiLink infoSubHeading Title
	HiLink infoSeparator Comment
	HiLink infoNavigation Tag
	HiLink infoNavigationKey Normal
	HiLink infoDirMenu Tag
	HiLink infoNote Tag
	HiLink infoSubMenu1 Tag
	HiLink infoSubMenu2 Tag

  delcommand HiLink
endif

let b:current_syntax = "info"

" vim: ts=2 sts=2 sw=2:
