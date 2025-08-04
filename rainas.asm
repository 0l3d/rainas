BITS 64 

; extern 
extern printf 
extern srand 
extern time 
extern rand 
extern usleep 
extern fflush
extern stdout

%define WIDTH 150
%define HEIGHT 43
%define ESC 0x1B 

section .bss
  xpos resd WIDTH
  ypos resd HEIGHT

section .data
  hide_cursor db 0x1B, '[?25l', 0
  clear_scr db ESC, '[2J', ESC, '[H', 0 
  cursor_move db ESC, '[%d;%dH', 0
  one_char db '\', 0 
  two_char db '\', '/', 0

section .text 
  global main


main:
  xor rdi, rdi  
  call time 
  
  mov edi, eax
  call srand
  
  mov rdi, hide_cursor
  xor rax, rax 
  call printf

  mov r12, 0


pos_loop:
 call rand 
 mov ebx, WIDTH
 xor edx, edx 
 div ebx 
 mov [xpos + r12 * 4], edx 

 call rand 
 mov ebx, HEIGHT
 xor edx, edx 
 div ebx 
 mov [ypos + r12 * 4], edx

 inc r12 
 cmp r12, WIDTH
 jl pos_loop

.outer:
 mov rdi, clear_scr
 xor rax, rax 
 call printf

 mov r12, 0 

.inner:
  mov r14, [xpos + r12 * 4] ; x 
  mov r15, [ypos + r12 * 4] ; y

  mov rdi, cursor_move
  xor rax, rax 
  mov rsi, r15  
  mov rdx, r14
  call printf
  
  mov r10, WIDTH ; x 
  sub r10, 1 
  
  cmp r14, r10
  je .con1true 

  mov r11, HEIGHT ; y
  sub r11, 1

  cmp r15, r11
  je .con1true 
  

.con1false:
 mov rdi, one_char
 xor rax, rax 
 call printf
 jmp .innerend

.con1true: 
 mov r10, WIDTH ; x 
 sub r10, 1 

 mov r11, HEIGHT ; y 
 sub r11, 1

 cmp r14, r10
 jne .con2false

 cmp r15, r11 
 jne .con3false
 
 cmp r14, r10
 je .con2elseif

 jmp .con2true  

 jmp .innerend 


.con3false:
  cmp r15, r11
  jne .con4false 

  jmp .con2false

.con4false:
  mov rdi, one_char
  xor rax, rax
  call printf
  jmp .innerend

.con2true:
 mov rdi, one_char
 xor rax, rax 
 call printf
 jmp .innerend

.con2elseif: 
 mov rdi, one_char
 xor rax, rax
 call printf
 jmp .innerend

.con2false:
  mov rdi, two_char
  xor rax, rax 
  call printf
  jmp .innerend

.innerend:
  ; r10 x 
  ; r11 y 
  
  mov eax, [xpos + r12 * 4]
  inc eax
  mov ebx, WIDTH
  xor edx, edx
  div ebx
  mov [xpos + r12 * 4], edx

  mov eax, [ypos + r12 * 4]
  inc eax
  mov ebx, HEIGHT
  xor edx, edx
  div ebx
  mov [ypos + r12 * 4], edx

  inc r12 
  cmp r12, WIDTH
  jge .outerend 

  jmp .inner


.outerend:
  mov rdi, qword [rel stdout]
  call fflush
  
  mov rdi, 50000
  call usleep


  jmp .outer
