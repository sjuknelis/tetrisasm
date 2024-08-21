print_grid:
  mov rax,0x2000004
  mov rdi,1
  mov rsi,clear
  mov rdx,clear.len
  syscall

  mov byte [row],10
  mov byte [hud_row],0

.loop:
  mov rcx,10
  call print_line
  mov rcx,10
  call print_line

  add byte [hud_row],4
  add byte [row],10
  cmp byte [row],210
  jne .loop

  print floor,floor.len
  print floor,floor.len
  print reset,reset.withoutNLLen

  ret

print_line:
  mov rbx,0
  mov rdx,grid
  add rdx,[row]
  push rdx

  print wall,wall.len

.loop:
  pop rdx
  push rdx
  mov byte al,[rdx + rbx]
  add byte al,"0"
  mov byte [infix],al

  print prefix,prefix.len
  print infix,1
  print suffix,suffix.len

  inc rbx
  cmp rbx,10
  jne .loop

  pop rdx
  print wall,wall.len

  cmp byte [hud_row],63
  jg .skip_hud

  mov rbx,0
  mov rdx,hud_grid
  add rdx,[hud_row]
  push rdx

.hud_loop:
  pop rdx
  push rdx
  mov byte al,[rdx + rbx]
  add byte al,"0"
  mov byte [infix],al

  print prefix,prefix.len
  print infix,1
  print suffix,suffix.len

  inc rbx
  cmp rbx,4
  jne .hud_loop

  pop rdx

.skip_hud:
  print reset,reset.len

  ret

place_obj:
  mov r8,0
  mov r9,0
  mov rcx,grid
  add rcx,[obj_index]

.loop:
  mov rax,0
  mov rdx,obj_grid
  mov byte al,[rdx + r9]
  inc r9
  cmp al,0
  je .skip

  mov byte al,[obj_mode]
  mov byte [rcx + r8],al

.skip:
  inc r8
  mov rax,r8
  mov rdx,0
  mov ebx,10
  div ebx
  cmp edx,4
  jne .loop

  add r8,6
  cmp r8,40
  jne .loop

  ret

render_hud:
  mov rcx,[held_tile]
  mov rdx,0
  call place_hud_obj

  mov rdx,bags
  mov rbx,0
  mov byte bl,[bag_index]
  mov rcx,0
  mov byte cl,[rdx + rbx]
  mov rdx,16
  call place_hud_obj

  mov rdx,bags
  mov rbx,0
  mov byte bl,[bag_index]
  inc bl
  mov rcx,0
  mov byte cl,[rdx + rbx]
  mov rdx,32
  call place_hud_obj

  mov rdx,bags
  mov rbx,0
  mov byte bl,[bag_index]
  add bl,2
  mov rcx,0
  mov byte cl,[rdx + rbx]
  mov rdx,48
  call place_hud_obj

  ret

place_hud_obj:
  mov r10,rcx
  mov r8,rdx
  shl rcx,4
  mov rdx,tiles
  add rdx,rcx
  mov rcx,hud_grid
  mov r9,0
  mov rax,0

.loop:
  mov byte al,[rdx + r9]
  cmp al,0
  je .blank

  mov byte al,r10b
  mov byte [rcx + r8],al
  jmp .merge

.blank:
  mov byte [rcx + r8],0

.merge:
  inc r8
  inc r9
  cmp r9,16
  jl .loop
  ret
