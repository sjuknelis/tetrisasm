check_lines:
  mov rax,0
  mov rbx,0
  mov rcx,209
  mov r8,0
  mov rdx,grid

.loop:
  mov byte al,[rdx + rcx]
  cmp al,0
  je .skip

  inc rbx

.skip:
  cmp rbx,10
  je .line_found

  cmp rcx,0
  je .no_line

  dec rcx
  inc r8
  cmp r8,10
  jl .loop

  mov rbx,0
  mov r8,0
  jmp .loop

.line_found:
  mov rax,rcx
  ret

.no_line:
  mov rax,0
  ret

clear_line:
  push rax
  mov r8,grid
  add r8,rax
  mov byte [r8 + 4],0
  mov byte [r8 + 5],0
  call print_grid
  call wait_unit
  mov byte [r8 + 3],0
  mov byte [r8 + 6],0
  call print_grid
  call wait_unit
  mov byte [r8 + 2],0
  mov byte [r8 + 7],0
  call print_grid
  call wait_unit
  mov byte [r8 + 1],0
  mov byte [r8 + 8],0
  call print_grid
  call wait_unit
  mov byte [r8 + 0],0
  mov byte [r8 + 9],0
  call print_grid
  call wait_unit

  pop rax
  add rax,9
  mov rcx,rax
  mov rbx,rax
  sub rbx,10
  mov rdx,grid

.loop:
  mov byte al,[rdx + rbx]
  mov byte [rdx + rcx],al

  cmp rbx,11
  jl .exit

  dec rcx
  dec rbx
  jmp .loop

.exit:
  add byte [obj_index],10

  ret

load_level:
  mov rbx,0

.loop:
  mov rdx,levels
  add rdx,[level_index]
  mov rcx,grid
  mov byte al,[rdx + rbx]
  mov byte [rcx + rbx],al

  inc rbx
  cmp rbx,210
  jl .loop

  ret

level_complete:
  mov rdx,grid
  mov rcx,0

.loop:
  mov byte al,[rdx + rcx]
  cmp al,0
  jne .fail

  inc rcx
  cmp rcx,210
  jl .loop

  mov rax,1
  ret

.fail:
  mov rax,0
  ret
