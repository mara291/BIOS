[org 0x7c00]
KERNEL_LOCATION equ 0x1000

    mov [DISK], dl

    ; stack setup
    mov ax, 0                      
    mov es, ax
    mov ds, ax
    mov bp, 0x8000
    mov sp, bp

    ; read from disk
    mov bx, 0x7e00
    ;mov bx, KERNEL_LOCATION
    mov ah, 2       ; read in CHS mode
    mov al, 1       ; how many sectors to read
    mov ch, 0       ; cylinder number
    mov cl, 2       ; sector number
    mov dh, 0       ; head number
    mov dl, [DISK]
    int 0x13

    ; disk error
    jc end

    mov ah, 0x00 ; BIOS function to set video mode
    mov al, 0x13 ; Video mode 13h (320x200, 256-color)
    int 0x10     ; Call BIOS video interrupt

    ; video mode
    mov ah, 0x0
    mov al, 0x3
    int 0x10

    ; change screen color
    mov ah, 0x09    
    mov al, ' '
    mov bh, 0x00
    mov bl, byte[purple] ; color
    mov cx, 2000       ; times
    int 0x10 

    ; initialize cursor
    mov dh, 0    ; row
    mov dl, 0    ; column
    mov ah, 0x02
    int 0x10

jmp end_print
    mov byte[cnt], 16
print:
    cmp byte[cnt], 0
    je end_print
    ; update cursor
    mov dl, byte[cnt]
    mov ah, 0x02
    int 0x10
    dec byte[cnt]

    ; print character
    mov ah, 0x09
    mov al, 'B'
    mov bl, byte[purple]
    mov cx, 1 
    int 0x10
    jmp print

end_print:

    ; PRINT THE BIOS MENU
    mov dl, 31
    mov dh, 1
    ; print characters starting from this address
    mov si, 0x7e00
print_title:
    ; stop if end of string reached
    cmp byte[si], '/'
    je end_print_title
    ; cursor
    mov ah, 0x02
    int 0x10
    inc dl
    ; print
    mov ah, 0x09
    mov al, [si]
    mov bl, byte[blue]
    mov cx, 1
    int 0x10
    inc si
    jmp print_title
end_print_title:
    
    inc si
    mov dl, 4
    mov dh, 4
print_line:
    ; if end of string
    cmp byte[si], '/'
    je next_line
    ; cursor
    mov ah, 0x02
    int 0x10
    inc dl
    ; print
    mov ah, 0x09
    mov al, [si]
    mov bl, byte[blue]
    mov cx, 1
    int 0x10
    inc si
    jmp print_line

next_line:
    inc si
    cmp byte[si], '_'
    je end_print_line
    add dh, 2
    mov dl, 4
    jmp print_line

end_print_line:

    
    mov dl, 14
    mov dh, 4   
    mov ah, 0x02
    int 0x10
read:
    ; read keyboard input
    mov ah, 0
    int 0x16
    cmp al, '1'
    je key1
    cmp al, '2'
    je key2
    cmp al, '3'
    je key3
    cmp al, '4'
    je key4
    cmp al, '5'
    je key5
    cmp al, '6'
    je key6
    cmp al, '7'
    je key7
    cmp al, 0x0d
    je enter
    
    jmp read
key1:
    mov dl, 14
    mov dh, 4
    mov ah, 0x02
    int 0x10
    jmp read

key2:
    mov dl, 26
    mov dh, 6
    mov ah, 0x02
    int 0x10
    jmp read

key3:
    mov dl, 11
    mov dh, 8
    mov ah, 0x02
    int 0x10
    jmp read

key4:
    mov dl, 19
    mov dh, 10
    mov ah, 0x02
    int 0x10
    jmp read

key5:
    mov dl, 24
    mov dh, 12
    mov ah, 0x02
    int 0x10
    jmp read

key6:
    mov dl, 12
    mov dh, 14
    mov ah, 0x02
    int 0x10
    jmp read

key7:
    mov dl, 21
    mov dh, 16
    mov ah, 0x02
    int 0x10
    jmp read

enter:
    ; enter only works if current position is on exit or exit and boot
    ; if on exit
    cmp dh, 14
    je black_screen
    ; if on boot
    cmp dh, 16
    je black_screen_boot
    jmp read

black_screen_boot:
    mov byte[boot], 1

black_screen:
    ; change screen color to black
    mov dh, 0
    mov dl, 0
    mov ah, 0x02
    int 0x10
    mov ah, 0x09    
    mov al, ' '
    mov bh, 0x00
    mov bl, byte[black]
    mov cx, 2000 
    int 0x10 
    ; exit or boot
    cmp byte[boot], 0
    je end
    jne test

test:
    ; read sectors into kernel location
    mov bx, KERNEL_LOCATION
    mov ah, 2
    mov al, 2      ; number of sectors
    mov ch, 0      ; cylinder
    mov cl, 3      ; sector
    mov dh, 0      ; head
    mov dl, [DISK] ; boot disk
    int 0x13

; gdt setup
gdt:
    CODE_SEG equ GDT_code - GDT_start
    DATA_SEG equ GDT_data - GDT_start

    cli
    lgdt [GDT_descriptor]

    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp CODE_SEG:start_protected_mode

    jmp $
                                    
DISK:     db 0
cnt:      db 0
blue:     db 0x93
purple:   db 0x97
black:    db 0x00
boot:     db 0

GDT_start:
    GDT_null:
        dd 0x0
        dd 0x0

    GDT_code:
        dw 0xffff
        dw 0x0
        db 0x0
        db 0b10011010
        db 0b11001111
        db 0x0

    GDT_data:
        dw 0xffff
        dw 0x0
        db 0x0
        db 0b10010010
        db 0b11001111
        db 0x0

GDT_end:

GDT_descriptor:
    dw GDT_end - GDT_start - 1
    dd GDT_start


[bits 32]
start_protected_mode:
    mov ax, DATA_SEG
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	
	mov ebp, 0x90000
	mov esp, ebp

    jmp KERNEL_LOCATION

end:
    jmp $
; $  - current memory address
; $$ - beginning of current section
times 510-($-$$) db 0              
dw 0xaa55

data1 db "BIOS MENU - 16 BIT/1. DEVICE/2. SYSTEM INFORMATION/3. CPU/4. SECURE BOOT/5. ADVANCED OPTIONS/6. EXIT/7. EXIT AND BOOT/_"
var: times 393 db 'X'
