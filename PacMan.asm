org 0x0100

jmp start

    ; Define variables for game state

    pacman_x: db 10    ; Pac-Man's X position
    pacman_y: db 5    ; Pac-Man's Y position
    pacman_direction: db 4 ;PacMan's Direction
    pacman_previous_direction: db 0 ;PacMan's Previous Direction
    
    ghost_x: db 5     ; Ghost's X position
    ghost_y: db 5     ; Ghost's Y position
    ghost_direction: db 0 ;Ghost's Direction
    
 

    pinky_x: db 15    ; Pinky's X position
    pinky_y: db 7    ; Pinky's Y position
    pinky_direction: db 0 ;Pinky's Direction

    maze_width: db 32 ; Width of the maze
    maze_height: db 21 ; Height of the maze

    score: dw 0       ; Game score

        ; Define variables for possible movements and their distances
    up_distance: dw 9999
    down_distance: dw 9999
    left_distance: dw 9999
    right_distance: dw 9999

    ; Define constants and messages
    title: db 'PAC-MAN', 0
    pac_symbol: db 0x01  ; Pac-Man symbol
    ghost_symbol: db 'G' ; Ghost symbol
    dot_symbol: db '.'   ; Dot symbol
    wall: db '|'    ;Wall Symbol
    score_message: db 'Score: ', 0 ;Score String
    win_message: db ' You Win! ', 0 ;Win String
    ready_message: db 'Ready!', 0 ;Ready String
    game_over_message: db 'Game Over!', 0 ;Game Over String

    music_length: dw 4000
    music_data: incbin "pacman.imf"

   ; maze_layout:   
    ;db '#########################'
    ;db '#...........#...........#'
    ;db '#.#.#####.#.#.#.#####.#.#'
    ;db '#.#.#...#.#.#.#.#...#.#.#'
    ;db '#...#...#.......#...#...#'
    ;db '#.###.#.#######.#.#####.#'
    ;db '#.......#...#.......#...#'
    ;db '#######.#.#.#.#######.#.#'
    ;db '#...#...#.#.#.#.#...#.#.#'
    ;db '#.#.#.#####.#.#####.#.#.#'
    ;db '#.#.#.....#.#.#.....#.#.#'
    ;db '#.#.#####.#.#.#.#####.#.#'
    ;db '#.#.......#...#.......#.#'
    ;db '#.##########.############'
    ;db '#.......................#'
    ;db '#########################'


    maze_layout:   ;21 Rows, 32 Columns
    db '################################'    
    db '#..............##..............#'    
    db '#.####.#######.##.#######.####.#'    
    db '#..............................#'    
    db '#.####.###.##########.###.####.#'    
    db '#......###.....##.....###......#'    
    db '######.####### ## #######.######'    
    db '     #.###            ###.#     '    
    db '######.### ###    ### ###.######'    
    db '      .    #        #    .      '    
    db '######.### ########## ###.######'    
    db '     #.###            ###.#     '    
    db '######.### ########## ###.######'        
    db '#..............##..............#'        
    db '#.####.#######.##.#######.####.#'    
    db '#....#.........  .........#....#'    
    db '####.#.###..########..###.#.####'    
    db '#......###.....##.....###......#'    
    db '#.############.##.############.#'     
    db '#..............................#'    
    db '################################'

 
start:
    ; Initialize game state
    mov byte [pacman_x], 15
    mov byte [pacman_y], 15
    mov byte [ghost_x], 16
    mov byte [ghost_y], 8
    mov dword [score], 0
    call home_screen
    call clear_screen
game_loop:
    ; Display the game board

    call draw_game_board
    call check_teleport
    call ghosts
    call delay ; Change bx value inside delay to adjust game speed
    call collisions
    call get_input
    call collisions
    jmp game_loop
    
game_over:
    ; Display game over message
    xor ax, ax
    mov al, 0x0C
    push ax
    mov ax, 0x0A24
    push ax
    mov ax,10
    push ax
    mov ax, game_over_message
    push ax
    call printstr
    jmp end

win:
    xor ax, ax
    mov al, 0x0A
    push ax
    mov ax, 0x0A24
    push ax
    mov ax,10
    push ax
    mov ax, win_message
    push ax
    call printstr

end:
    mov word [music_length], 500
    call sound ; Play the game over sound
    mov ax, 0x4c00
    int 21h
    ; Handle user input and update game state
    ; Implement movement logic for Pac-Man and the ghost

    ; Check for collisions and update the score

    ; Check game over conditions and end the game if necessary

    ; Continue the game loop
    jmp game_loop

    ; ------------Code to clear the screen (platform-specific)----------------
clear_screen:

    push ax
    push es
    push di
    push cx
    mov ax, 0xb800
    mov es, ax
    xor di, di
    mov cx, 2000
    mov ax, 0x0720
    cld
    rep stosw
    pop cx
    pop di
    pop es
    pop ax
    ret
    ;--------------------------Print String--------------------------;
    ; [bp+4] = Pointer to string
    ; [bp+6] = Length of string
    ; [bp+8] = Row and column to print string
    ; [bp+10] = Color of string
printstr:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push es

     ; Display game over message
    mov ah, 0x13
    mov al, 0x01
    mov bl, [bp+10]
    mov bh, 0x00

    mov dx, [bp+8]
    push cs
    pop es
    
    mov cx, [bp+6]
    mov bp, [bp+4]
    int 0x10
    
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 8

    ; -------------------------Code to draw Home Screen------------------------;

home_screen:
    call clear_screen
    call draw_game_board
    xor ax, ax
    mov al, 0x4E
    push ax
    mov ax, 0x0626
    push ax
    mov ax, 7
    push ax
    mov ax, title
    push ax
    call printstr

    xor ax, ax
    mov al, 0x0E
    push ax
    mov ax, 0x0C26
    push ax
    mov ax, 6
    push ax
    mov ax, ready_message
    push ax
    call printstr



    call sound

    xor ax, ax
    mov ah, 0
    int 16h

    ret

    sound:
        mov si, 0 ; current index for music_data
		
	.next_note:
	
		; 3) the first byte is the opl2 register
		;    that is selected through port 388h
		mov dx, 388h
		mov al, [si + music_data + 0]
		out dx, al
		
		; 4) the second byte is the data need to
		;    be sent through the port 389h
		mov dx, 389h
		mov al, [si + music_data + 1]
		out dx, al
		
		; 5) the last 2 bytes form a word
		;    and indicate the number of waits (delay)
		mov bx, [si + music_data + 2]
		
		; 6) then we can move to next 4 bytes
		add si, 4
		
		; 7) now let's implement the delay
		
	.repeat_delay:	
		mov cx, 3200 ; <- change this value according to the speed
		              ;    of your computer / emulator
	.delay:
	
		
		loop .delay
		
		mov ah, 1
		int 16h
		jnz .exit
		dec bx
		jg .repeat_delay
		
		; 8) let's send all content of music_data
		cmp si, [music_length]
		jb .next_note

    .exit:
    ret

    ; -------------------------Code to draw Game Over Screen------------------------;



;-----------------------Screen Display and Board -----------------------;

draw_game_board:

    push ax
    push cx
    push bx
    push dx
    push di
    mov ax, 0xb800
    mov es, ax




draw_maze:
    mov ah, 01h ; Blue on Black wall

    ; Start position for maze layout
    mov di, 210 


    ; Loop through each character in the maze layout
    mov cx, 0 ; Number of rows in the maze
    mov si, maze_layout ; Pointer to maze layout string

    draw_rows:

        mov bx, 0 ; Number of columns in the maze

    draw_columns:

        lodsb ; Load the next character from maze layout
        cmp al, '#' ; Check if it's a wall
        je draw_wall ; Draw wall if it is


        ;Checking if current position is Pac man
        cmp byte [pacman_x], bl
        jne not_pacman
        cmp byte [pacman_y], cl
        jne not_pacman

        mov ah, 0x0E
        mov byte al, [pac_symbol] ; ascii code for 'C'
        jmp draw_character

not_pacman:
        ; Check if current position is the ghost
        cmp byte [ghost_x], bl
        jne not_ghost
        cmp byte [ghost_y], cl
        jne not_ghost
        mov ax, 0x04Ea ;Ghost Character
        jmp draw_character

not_ghost:
        ; Check if current position is the Pinky
        cmp byte [pinky_x], bl
        jne not_pinky
        cmp byte [pinky_y], cl
        jne not_pinky
        mov ax, 0x0CEa ;Pinky Character
        jmp draw_character

not_pinky:
        cmp al, '.' ; Check if it's a dot
        je draw_dot ; Draw dot if it is
        mov ax, 0x0020 ; ascii code for space
        jmp draw_character

draw_dot:
        ; Draw an pellet
        mov ax, 0x8EFA ;F9 for bigger Pellet, FA for Smaller
        jmp draw_character

draw_wall:
        ; Draw a wall
        mov ah, 11h ; White on blue wall
        mov al, 0xB1 ; ascii code for full space

draw_character:
    ; Draw Character on Screen

    stosw ; Draw the character on the screen
    inc bx
    cmp bl, [maze_width]  ; Number of columns in the maze
    jne draw_columns

    ; Move to the next row in the maze
    add di, 160 - 64 ; Move to the next row (160 - 46 = 114, the width of the maze)

    inc cx
    cmp cl, [maze_height]  ; Number of rows in the maze
    jne draw_rows

    mov ax, 160
    push ax
    mov ax, [score] ; Display the score
    push ax
    call printnum

    ; Restore registers
    pop di
    pop dx
    pop bx
    pop cx
    pop ax

    cmp byte [score], 150 ; Check if the game is over
    je win
ret

;------------------- Input Movement For Pac Man---------------;

get_input:
    ; Check for keyboard input
    mov ah, 1
    int 16h
    jz no_input
    mov ah, 0
    int 16h
    jnz check_arrow_key ; Check for arrow key press
no_input:

    ;No key pressed, continue moving Pac-Man in the current direction
    cmp byte [pacman_direction], 3
    je handle_left_arrow
    cmp byte [pacman_direction], 4
    je handle_right_arrow
    cmp byte [pacman_direction], 2
    je handle_down_arrow
    cmp byte [pacman_direction], 1
    je handle_up_arrow

   
    ret

check_arrow_key:

    ; Check for other arrow keys
    cmp ah, 48h
    je handle_up_arrow
    cmp ah, 50h
    je handle_down_arrow
    cmp ah, 4Bh
    je handle_left_arrow
    cmp ah, 4Dh
    je handle_right_arrow

    ; Exit if any other key is pressed
    jmp game_over

handle_up_arrow:
    ; Up arrow key pressed
    ; Implement Pac-Man upward movement logic here
    ; Update pacman_y accordingly
    mov byte al, [pacman_direction]
    mov byte [pacman_previous_direction], al
    mov byte [pacman_direction], 1
    dec byte [pacman_y]
    ret


handle_down_arrow:
    ; Down arrow key pressed
    ; Implement Pac-Man downward movement logic here
    ; Update pacman_y accordingly
    mov byte al, [pacman_direction]
    mov byte [pacman_previous_direction], al
    mov byte [pacman_direction], 2
    inc byte [pacman_y]
    ret

handle_left_arrow:
    ; Left arrow key pressed
    ; Implement Pac-Man leftward movement logic here
    ; Update pacman_x accordingly
    mov byte al, [pacman_direction]
    mov byte [pacman_previous_direction], al
    mov byte [pacman_direction], 3
    dec byte [pacman_x]
    ret

handle_right_arrow:
    ; Right arrow key pressed
    ; Implement Pac-Man rightward movement logic here
    ; Update pacman_x accordingly
    mov byte al, [pacman_direction]
    mov byte [pacman_previous_direction], al
    mov byte [pacman_direction], 4
    inc byte [pacman_x]
    ret



;------------------ Collisions -------------------;

collisions:
    ; Check for Ghost collisions

    mov di, 804
    xor ax, ax
    xor bx, bx
    mov al, [maze_width]
    mul byte [pinky_y]
    mov byte bl, [pinky_x]
    add ax, bx
    mov si, maze_layout
    add si, ax
    mov ah, 0Fh
    lodsb
    stosw



   ; push ax

    mov di, 484

    xor ax, ax
    xor bx, bx
    mov al, [maze_width]
    mul byte [pacman_y] 
    mov byte bl, [pacman_x]
    add ax, bx

    mov si, maze_layout
    add si, ax

    mov ah, 0Fh

    lodsb
    stosw
    cmp al, '#'
    je wall2
    cmp al, '.'
    je pellet

    mov bl, [pacman_x]
    cmp bl, [ghost_x]
    jne pinky_collision
    mov bl, [pacman_y]
    cmp bl, [ghost_y]
    jne pinky_collision
    ;PacMan Has Collided With the Ghost Game Over
    jmp game_over

    pinky_collision:
    mov bl, [pacman_x]
    cmp bl, [pinky_x]
    jne exit_collision
    mov bl, [pacman_y]
    cmp bl, [pinky_y]
    jne exit_collision
    ;PacMan Has Collided With the Ghost Game Over
    jmp game_over

    wall2:
    
        mov byte ah, [pacman_direction]

       ; mov byte [pacman_direction], 0
        ;This movement is not allowed
        cmp ah, 1
        je up_move
        cmp ah, 2
        je down_move
        cmp ah, 3
        je left_move

        dec byte [pacman_x] ;Right Move
        mov byte al, [pacman_previous_direction]
        mov byte [pacman_direction], al
        jmp exit_collision
    
    up_move:
        inc byte [pacman_y]
        mov byte al, [pacman_previous_direction]
        mov byte [pacman_direction], al
        jmp exit_collision
    down_move:
        dec byte [pacman_y]
        mov byte al, [pacman_previous_direction]
        mov byte [pacman_direction], al
        jmp exit_collision
    left_move:
        inc byte [pacman_x]
        mov byte al, [pacman_previous_direction]
        mov byte [pacman_direction], al
        jmp exit_collision

    pellet:
        add word [score], 1
        dec si
        mov byte [si], 20h ; ascii code for space

    exit_collision:

     ret









; Implement functions for user input, collision detection, and game over conditions here

; Implement functions for movement and AI logic for Pac-Man and the ghost

; Implement functions for updating the score and displaying game over messages

; Add additional functions as needed

;------------------ Score Printing-------------------;
printnum:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push di
    push si

    mov ax, [bp + 4] ; Storing number to display
    mov bx, 10
    mov cx, 0

nextdigit:
    mov dx, 0
    div bx
    add dl, 0x30
    push dx
    inc cx
    cmp ax, 0
    jnz nextdigit


    mov di, [bp + 6]
    mov ax, 0xb800
    mov es, ax
    xor ax, ax
    push cx
    
    mov si, score_message ;Printting store message
    mov cx, 7 ;Message length
    xor ax, ax
    mov ah, 0x0F

    cld
nextchar: 
    lodsb
    stosw
    loop nextchar

    pop cx
nextpos:

    ;Printing Store number

    pop ax
    mov ah, 0x0E
    mov [es:di], ax
    add di, 2
    loop nextpos

    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 4

delay:
    push bx
	push cx
    mov bx, 7
    dlloop1:
		mov cx,0xffff
		dlloop2:
		loop dlloop2
    dec bx
    cmp bx, 0
    jne dlloop1
	pop cx
    pop bx
ret

;------------------ Ghost Movement-------------------;

ghosts:
    ;Blinkys's Movement
    xor ax, ax
    mov al, [pacman_x]
    push ax
    mov al, [pacman_y]
    push ax
    mov al, [ghost_direction]
    push ax
    mov al, [ghost_x]
    push ax
    mov al, [ghost_y]
    push ax
    call ghost_movement
    pop ax
    mov byte [ghost_y], al
    pop ax
    mov byte [ghost_x], al
    pop ax
    mov byte [ghost_direction], al
    pop ax
    mov byte [pacman_y], al
    pop ax
    mov byte [pacman_x], al

    xor ax, ax
    ;Pinky's Movement
    cmp byte [pacman_direction], 1
    je pinky_up
    cmp byte [pacman_direction], 2
    je pinky_down
    cmp byte [pacman_direction], 3
    je pinky_left


    mov al, [pacman_x]
    add al, 6
    jmp push_pinky_x


    pinky_left:
    mov al, [pacman_x]
    sub al, 6
    jmp push_pinky_x

    pinky_up:
    mov al, [pacman_x]
    sub al, 6
    jmp push_pinky_x
    mov al, [pacman_y]
    sub al, 4
    jmp push_pinky_y

    pinky_down:
    mov al, [pacman_x]
    push ax
    mov al, [pacman_y]
    add al, 4
    jmp push_pinky_y



push_pinky_x:
    push ax
    mov al, [pacman_y]

push_pinky_y:
    push ax
    mov al, [pinky_direction]
    push ax
    mov al, [pinky_x]
    push ax
    mov al, [pinky_y]
    push ax

    call ghost_movement

    pop ax
    mov byte [pinky_y], al
    pop ax
    mov byte [pinky_x], al
    pop ax
    mov byte [pinky_direction], al
    pop ax
    pop ax

    ret

;[bp+4] = Ghost Y
;[bp+6] = Ghost X
;[bp+8] = Ghost Direction
;[bp+10] = Pacman Y
;[bp+12] = Pacman X

ghost_movement:
    push bp
    mov bp, sp
    push ax
    push bx
    push dx
    push cx

    mov al, [pacman_x]
    cmp byte al, [bp+6]
    jne continue_ghost_movement
    mov al, [pacman_y]
    cmp byte al, [bp+4]
    jne continue_ghost_movement

    ;PacMan Has Collided With the Ghost Game Over
    jmp game_over
continue_ghost_movement:


    mov word [up_distance], 9999
    mov word [down_distance], 9999
    mov word [left_distance], 9999
    mov word [right_distance], 9999


    xor cx, cx
    mov cl, [maze_width]
    xor ax, ax
    ; Check each possible direction and calculate distances
    mov al, [bp+4]
    dec al
    mul cl
    xor bx, bx
    mov bl, [bp+6]
    add ax, bx
    mov si, maze_layout
    add si, ax
    cmp byte [si], '#'
    jne calculate_up_distance

wall_check_down:
    xor ax, ax
    mov al, [bp+4]
    inc al
    mul cl
    xor bx, bx
    mov bl, [bp+6]
    add ax, bx
    mov si, maze_layout
    add si, ax
    cmp byte [si], '#'
    jne calculate_down_distance

wall_check_left:
    xor ax, ax
    mov al, [bp+4]
    mul cl
    xor bx, bx
    mov bl, [bp+6]
    add ax, bx
    dec ax
    mov si, maze_layout
    add si, ax
    cmp byte [si], '#'
    jne calculate_left_distance

wall_check_right:
    xor ax, ax
    mov al, [bp+4]
    mul cl
    xor bx, bx
    mov bl, [bp+6]
    add ax, bx
    inc ax
    mov si, maze_layout
    add si, ax
    cmp byte [si], '#'
    jne calculate_right_distance_short_jump ; This is a short jump to avoid the error That the label is too far away(out of range)
    jmp compare_distances
calculate_up_distance:
    cmp byte [bp+8], 2
    je wall_check_down
    ; Pacman Safe Places
    mov byte al, [bp+4] ;Ghost Y
    mov byte ah, [bp+6] ;Ghost X
    cmp ax, 0x0E0F
    je wall_check_down
    cmp ax, 0x110F
    je wall_check_down
    cmp ax, 0xE07
    je wall_check_down
    cmp ax, 0x1107
    je wall_check_down
    ; End of Pacman Safe Places
    xor ax, ax
    mov al, [bp+10]
    push ax
    mov al, [bp+12]
    push ax
    mov al, [bp+4]
    dec ax
    push ax
    mov al, [bp+6]
    push ax
    call distance
    mov [up_distance], ax
    jmp wall_check_down

calculate_down_distance:
    cmp byte [bp+8], 1
    je wall_check_left
    xor ax, ax
    mov al, [bp+10]
    push ax
    mov al, [bp+12]
    push ax
    mov al, [bp+4]
    inc ax
    push ax
    mov al, [bp+6]
    push ax
    call distance
    mov [down_distance], ax
    jmp wall_check_left
calculate_right_distance_short_jump:
    jmp calculate_right_distance
calculate_left_distance:
    cmp byte [bp+8], 4
    je wall_check_right
    xor ax, ax
    mov al, [bp+10]
    push ax
    mov al, [bp+12]
    push ax
    mov al, [bp+4]
    push ax
    mov al, [bp+6]
    dec ax
    push ax
    call distance
    mov [left_distance], ax
    jmp wall_check_right
calculate_right_distance:
    cmp byte [bp+8], 3
    je compare_distances
    xor ax, ax
    mov al, [bp+10]
    push ax
    mov al, [bp+12]
    push ax
    mov al, [bp+4]
    push ax
    mov al, [bp+6]
    inc ax
    push ax
    call distance
    mov [right_distance], ax


compare_distances:
    ; Compare distances and choose direction
    xor ax, ax
    mov ax, [right_distance]
    mov bx, 'r'
    cmp ax, [down_distance]
    jl check_left

    mov ax, [down_distance]
    mov bx, 'd'

check_left:
    cmp ax, [left_distance]
    jl check_up


    mov ax, [left_distance]
    mov bx, 'l'

check_up:
    cmp ax, [up_distance]
    jl move_ghost
    mov bx, 'u'

move_ghost:
    xor ax, ax
    ; Move ghost in chosen direction
    cmp bx, 'u'
    je move_ghost_up
    cmp bx, 'd'
    je move_ghost_down
    cmp bx, 'l'
    je move_ghost_left


    mov al, [bp+6]
    inc al
    mov byte [bp+6], al
    mov byte [bp+8], 4
    jmp exit_ghost_movement

    move_ghost_up:
        mov al, [bp+4]
        dec al
        mov byte [bp+4], al
        mov byte [bp+8], 1
        jmp exit_ghost_movement

    move_ghost_down:
        mov al, [bp+4]
        inc al
        mov byte [bp+4], al
        mov byte [bp+8], 2
        jmp exit_ghost_movement

    move_ghost_left:
        mov al, [bp+6]
        dec al
        mov byte [bp+6], al
        mov byte [bp+8], 3



exit_ghost_movement:
    pop cx
    pop dx
    pop bx
    pop ax
    pop bp
    ret



    distance:
    ; Calculate the distance between Pacman and Ghost
    push bp
    mov bp, sp
    push bx 
    xor ax, ax
    xor bx, bx
    mov al, [bp+8]
    sub ax, [bp + 4] ; Ghost X distance
    imul ax, ax          ; Square of the X distance
    mov bl, [bp+10]
    sub bx, [bp + 6] ; Ghost Y distance
    imul bx, bx          ; Square of the Y distance
    add ax, bx           ; Sum of squares
    ; At this point, AX contains the distance between Pacman and Ghost
    pop bx
    pop bp
    ret 8

;------------------ Teleporting-------------------;

check_teleport:
    push ax
    ; Teleport for Pacman  
    mov al, [pacman_x]
    push ax
    mov al, [pacman_y]
    push ax
    call teleport
    pop ax
    pop ax
    mov byte [pacman_x], al

    ; Teleport for Ghost
    mov al, [ghost_x]
    push ax
    mov al, [ghost_y]
    push ax
    call teleport
    pop ax
    pop ax
    mov byte [ghost_x], al

    ; Teleport for Pinky
    mov al, [pinky_x]
    push ax
    mov al, [pinky_y]
    push ax
    call teleport
    pop ax
    pop ax
    mov byte [pinky_x], al


    pop ax
    ret 

    teleport:
        push bp
        mov bp, sp
        push ax

        mov al, 9
        cmp byte [bp+4], al ; Check y position
        jne skip_teleport
        mov al, [maze_width]
        sub al , 1
        cmp byte [bp+6], al ; Check x position at the right side
        jne check_left_side
        mov byte [bp+6], 1 ; Teleport to the left side
        jmp skip_teleport

    check_left_side:
        mov al, 1
        cmp byte [bp+6], al ; Check x position at the left side
        jne skip_teleport
        mov al, [maze_width]
        sub al, 1
        mov byte [bp+6],  al; Teleport to the right side

    skip_teleport:
        pop ax
        pop bp
        ret 
