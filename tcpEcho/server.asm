global _start

section .data
sockfd: dq 0
connfd: dq 0

section .text
syscall_handler:
  syscall
  cmp rax, 0
  jnl success

  error:
    jmp r12

  success:
    ret

_start:
  ;; sock = socket(AF_INET, SOCK_STREAM, 0);
  mov rax, 41
  mov rdi, 2
  mov rsi, 1
  mov rdx, 0
  mov r12, exit
  call syscall_handler

  mov qword [sockfd], rax

  ;; sockaddr_in {
  ;;   .sin_family = AF_INET,
  ;;   .sin_port = 42069,
  ;;   .sin_addr = INADDR_LOOPBACK
  ;; }
  sub rsp, 16
  mov word [rsp], 2
  mov word [rsp+2], 21924
  mov dword [rsp+4], 0x0100007F
  mov qword [rsp+8], 0  ;; padding

  ;; bind(sock, &sockaddr_in, 16);
  mov rax, 49
  mov rdi, qword [sockfd]
  lea rsi, [rsp]
  mov rdx, 16
  mov r12, cleanup
  call syscall_handler

  ;; dealloc struct
  add rsp, 16

  ;; listen(sock, 1);
  mov rax, 50
  mov rdi, qword [sockfd]
  mov rsi, 1
  mov r12, cleanup
  call syscall_handler

  ;; conn = accept(sock, NULL, NULL);
  mov rax, 43
  mov rdi, qword [sockfd]
  mov rsi, 0
  mov rdx, 0
  mov r12, cleanup
  call syscall_handler

  mov [connfd], rax

  ;; char buf[1024];
  sub rsp, 1024

receiveSend:
  ;; recvfrom(conn, &buf, 1024, 0, NULL, NULL);
  mov rax, 45
  mov rdi, qword [connfd]
  lea rsi, [rsp]
  mov rdx, 1024
  mov r10, 0
  mov r8, 0
  mov r9, 0
  syscall

  cmp rax, 0
  jng cleanup

  mov r11, rax

  ;; sendto(conn, &buf, received, 0, NULL, NULL);
  mov rax, 44
  mov rdi, qword [connfd]
  lea rsi, [rsp]
  mov rdx, r11
  mov r10, 0
  mov r8, 0
  mov r9, 0
  syscall

  jmp receiveSend

cleanup:
  ;; close(sock);
  mov rax, 3
  mov rdi, [sockfd]
  syscall

exit:
  ;; exit(0);
  mov rax, 60
  mov rdi, 0
  syscall
