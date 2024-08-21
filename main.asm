global start
default rel

%macro debug_print 2 ; (value,offset)
  push rax
  push rdi
  push rsi
  push rdx
  mov rax,%1
  add rax,%2
  mov byte [debug_char],al

  mov rax,0x2000004
  mov rdi,1
  mov rsi,debug_char
  mov rdx,1
  syscall
  pop rdx
  pop rsi
  pop rdi
  pop rax
%endmacro

%macro debug_exit 2 ; (exit code,lowest valid)
  cmp %1,%2
  jl .deskip

  mov rdi,%1
  mov rax,0x2000001
  syscall
.deskip:
%endmacro

%macro print 2
  mov rax,0x2000004
  mov rdi,1
  mov rsi,%1
  mov rdx,%2
  syscall
%endmacro

section .text

start:
  mov byte [obj_index],13

  ;call rotate_tile
  mov qword [level_index],0
  mov byte [bag_index],0
.loop:
  call load_level

  call spawn_from_bag
  call render_hud

  mov byte al,[tile_color]
  mov byte [obj_mode],al
  call place_obj
  call print_grid

  call game_loop

  print win_text,win_text.len
  call multi_wait_unit

  and byte [bag_index],0xf0
  add byte [bag_index],16
  add qword [level_index],210
  mov rax,[level_max_index]
  cmp [level_index],rax
  jl .loop

  mov rax,0x2000001
  mov rdi,255
  syscall

game_loop:
  mov byte [obj_mode],0
  call place_obj

  mov rax,0x2000003
  mov rdi,0
  mov rsi,char
  mov rdx,1
  syscall

  cmp byte [char],"a"
  je .left

  cmp byte [char],"d"
  je .right

  cmp byte [char],"w"
  je .rotate

  cmp byte [char]," "
  je .drop

  cmp byte [char],"c"
  je .hold

  cmp byte [char],"q"
  je .quit

  jmp .merge

.left:
  call left_edge
  cmp rax,0
  jg .merge

  dec byte [obj_index]
  jmp .merge

.right:
  call right_edge
  cmp rax,0
  jg .merge

  inc byte [obj_index]
  jmp .merge

.rotate:
  call adjust_rotate_tile
  jmp .merge

.drop:
  call drop_tile
  mov rax,0
  mov byte al,[obj_index]
  cmp al,50
  ja .merge

  print lose_text,lose_text.len
  call multi_wait_unit

  mov rax,0x2000001
  mov rdi,253
  syscall

.hold:
  call hold_tile
  jmp .merge

.quit:
  mov rax,0x2000001
  mov rdi,0
  syscall

.merge:
  mov byte al,[tile_color]
  mov byte [obj_mode],al
  call place_obj

.line_check:
  call check_lines
  cmp rax,0
  je .exit_lines

  call clear_line
  jmp .line_check

.exit_lines:
  call render_hud
  call print_grid

  call touches_bottom
  cmp rax,0
  je .continue

  mov byte [obj_index],13
  call spawn_from_bag

  call level_complete
  cmp rax,0
  jne .return

.continue:
  jmp game_loop

.return:
  ret

wait_unit:
  mov rax,0

.loop:
  inc rax
  cmp rax,150000000
  jl .loop

  ret

multi_wait_unit:
  call wait_unit
  call wait_unit
  call wait_unit
  call wait_unit
  call wait_unit
  call wait_unit
  call wait_unit
  call wait_unit
  call wait_unit
  call wait_unit

  ret

%include "graphics.asm"
%include "tile.asm"
%include "grid.asm"

section .data

prefix: db 0x1b,"[4"
.len: equ $-prefix
suffix: db ";1m   "
.len: equ $-suffix
wall: db 0x1b,"[47;1m   "
.len: equ $-wall
floor: db 0x1b,"[47;1m                                    ",0x0a
.len: equ $-floor
reset: db 0x1b,"[0m",0x0a
.len: equ $-reset
.withoutNLLen: equ $-reset - 1
clear: db 0x1b,"c"
.len: equ $-clear

win_text: db 0x1b,"[20;16H",0x1b,"[32;1mW I N",0x1b,"[0m",0x0a
.len: equ $-win_text
lose_text: db 0x1b,"[20;15H",0x1b,"[31;1mL O S E",0x1b,"[0m",0x0a
.len: equ $-lose_text

level_max_index: dq 211

%include "tile_data.asm"
%include "levels.asm"

section .bss

obj_mode: resq 1
obj_index: resq 1
infix: resq 1
row: resq 1
hud_row: resq 1
char: resq 1
debug_char: resq 1
tile_color: resq 1
bag_index: resq 1
held_tile: resq 1

level_index: resq 1

grid: resq 210
hud_grid: resq 64
obj_grid: resq 16
copy_obj_grid: resq 16
rng_bag: resq 7
