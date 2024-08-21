bottom_tile:
  mov rbx,rcx
  add rbx,12

.loop:
  mov rdx,obj_grid
  mov byte al,[rdx + rbx]
  cmp al,1
  je .exit

  cmp rbx,4
  jl .failExit

  sub rbx,4
  jmp .loop

.exit:
  mov rax,rbx
  mov rdx,0
  mov rbx,4
  div rbx
  ret

.failExit:
  mov rax,0xff
  ret

touches_bottom:
  mov rcx,0

.loop:
  call bottom_tile
  cmp rax,0xff
  je .skip

  mov rdx,10
  mul rdx
  mov rbx,rax
  add rbx,rcx
  add byte bl,[obj_index]
  add rbx,10

  cmp rbx,209
  jg .true

  mov rdx,grid
  mov byte al,[rdx + rbx]
  cmp al,0
  jne .true

.skip:
  inc cl
  cmp cl,4
  jne .loop

  mov rax,0
  ret

.true:
  mov rax,1
  ret

%macro transfer 2
  mov rax,[rdx + %1]
  mov byte [rbx + %2],al
%endmacro

rotate_tile:
  mov rbx,obj_grid
  mov rdx,copy_obj_grid
  mov rcx,0

.copy:
  mov rax,[rbx + rcx]
  mov byte [rdx + rcx],al

  inc rcx
  cmp rcx,16
  jne .copy

  transfer 0,3
  transfer 1,7
  transfer 2,11
  transfer 3,15

  transfer 3,15
  transfer 7,14
  transfer 11,13
  transfer 15,12

  transfer 15,12
  transfer 14,8
  transfer 13,4
  transfer 12,0

  transfer 12,0
  transfer 8,1
  transfer 4,2

  transfer 5,6
  transfer 6,10
  transfer 10,9
  transfer 9,5

  ret

adjust_rotate_tile:
  call rotate_tile

.left_test:
  call left_edge
  cmp rax,2
  jne .right_test
  inc byte [obj_index]
  jmp .left_test

.right_test:
  call right_edge
  cmp rax,2
  jne .exit
  dec byte [obj_index]
  jmp .right_test

.exit:
  ret

spawn_tile:
  mov rax,rcx

  mov byte [tile_color],al
  shl rax,4
  mov rbx,tiles
  add rbx,rax
  mov rdx,obj_grid
  mov rcx,0

.copy:
  mov rax,[rbx + rcx]
  mov byte [rdx + rcx],al

  inc rcx
  cmp rcx,16
  jne .copy

  ret

drop_tile:
  add byte [obj_index],10
  call touches_bottom
  cmp rax,0
  je drop_tile

  ret

left_edge:
  mov rdx,obj_grid
  mov rcx,0

.loop:
  mov byte al,[rdx + rcx]
  cmp al,1
  je .exit

  add rcx,4
  cmp rcx,16
  jl .loop

  sub rcx,15
  cmp rcx,3
  jl .loop

  mov rax,1
  ret

.exit:
  mov rax,rcx
  and rax,3

  mov rbx,10
  sub rbx,rax
  mov rax,0
  mov byte al,[obj_index]
  cmp rax,rbx
  je .final_valid_exit
  jl .over_exit

  mov rax,0
  ret

.final_valid_exit:
  mov rax,1
  ret

.over_exit:
  mov rax,2
  ret

right_edge:
  mov rdx,obj_grid
  mov rcx,3

.loop:
  mov byte al,[rdx + rcx]
  cmp al,1
  je .exit

  add rcx,4
  cmp rcx,16
  jl .loop

  cmp rcx,16
  je .empty_term
  sub rcx,17
  jmp .loop

.empty_term:
  mov rax,0
  ret

.exit:
  mov rax,rcx
  and rax,3

  mov rbx,19
  sub rbx,rax
  mov rax,0
  mov byte al,[obj_index]
  cmp rax,rbx
  je .final_valid_exit
  jg .over_exit

  mov rax,0
  ret

.final_valid_exit:
  mov rax,1
  ret

.over_exit:
  mov rax,2
  ret

spawn_from_bag:
  mov rdx,bags
  mov rbx,0
  mov byte bl,[bag_index]
  mov rax,0
  mov byte al,[rdx + rbx]
  inc byte [bag_index]

  cmp al,0
  je .empty_bag

  mov rcx,rax
  call spawn_tile
  ret

.empty_bag:
  cmp byte [held_tile],0
  je .empty_hold

  mov rcx,0
  mov byte cl,[held_tile]
  mov byte [held_tile],0
  call spawn_tile
  ret

.empty_hold:
  call level_complete
  cmp rax,0
  jne .return

  print lose_text,lose_text.len
  call multi_wait_unit

  mov rax,0x2000001
  mov rdi,254
  syscall

.return:
  ret

hold_tile:
  mov rcx,0
  mov byte cl,[held_tile]
  cmp cl,0
  jne .not_empty

  mov byte al,[tile_color]
  mov byte [held_tile],al
  call spawn_from_bag

  jmp .merge

.not_empty:
  mov byte cl,[held_tile]
  mov byte al,[tile_color]
  mov byte [held_tile],al
  call spawn_tile

.merge:
  ret
