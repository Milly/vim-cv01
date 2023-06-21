" File: src/palette.vim
" Description: Colorscheme definitions
" Author: Milly
" License: MIT
" --------------------------------------------------------------------------

let gen_base_name = 'cv01'
let gen_desc_name = 'Colorscheme of the Vocal synthesizer 39'
let gen_author = 'Milly'
let gen_license = 'MIT'

" Color Palette:
"   <Type><Opacity> = [<cterm-color>, <gui-color>]
"
" Type:
"   n: normal (gray)
"   b: blue
"   g: green
"   y: yellow
"   r: red
"
" Opacity:
"   0 : 0% Default BG (n0 only)
"   1 : 10% Dark BG (n1 only)
"   2 : 20% BG
"   3 : 60% Middle FG
"   4 : 80% Default FG
"   5 : 100% Highlight
let gen_palette = {
\ 'n0': ['235', '#292832'],
\ 'n1': ['237', '#3b3948'],
\ 'n2': ['59',  '#4d4b5d'],
\ 'n3': ['103', '#88869e'],
\ 'n4': ['146', '#bbb9c7'],
\ 'n5': ['188', '#e5e5ea'],
\ 'b2': ['236', '#323b51'],
\ 'b3': ['24',  '#1f7088'],
\ 'b4': ['31',  '#2b99bb'],
\ 'b5': ['74',  '#59bbd9'],
\ 'g2': ['23',  '#193639'],
\ 'g3': ['30',  '#138277'],
\ 'g4': ['43',  '#11ccb6'],
\ 'g5': ['50',  '#0befd4'],
\ 'y2': ['238', '#304a4a'],
\ 'y3': ['108', '#80a789'],
\ 'y4': ['151', '#a9c3af'],
\ 'y5': ['188', '#c6d7ca'],
\ 'r2': ['52',  '#531d28'],
\ 'r3': ['126', '#a9427c'],
\ 'r4': ['169', '#d44c96'],
\ 'r5': ['205', '#ff57b0'],
\}

let gen_ansi_colors = map([
\ 'n0', 'r4', 'g3', 'y3', 'b3', 'b4', 'g4', 'n4',
\ 'n2', 'r5', 'g4', 'y5', 'b4', 'b5', 'g5', 'n5',
\], {_, n -> gen_palette[n]})
