; ---------------------------------------------------- bomb ----------------------------------------------------
draw_bomb:
; the offset of the enemy who fired the bomb will be passed as parameter 
push bp 
mov bp , sp 
push ax 
push bx 
push cx
push dx 
push si 
push di 
push es 
pushf 

mov di , [bp+4] ; offset of the enemy 
add di , 4 ; mov di to the center of the enemy 
add di , 160 ; mov di to next line 
mov word [bomboffset] , di ; storing the bomboffset for later use 
mov ax , 0xb800 
mov es , ax 
cld 
mov ah , [bombattr] 
mov al , [bombchar] 
stosw ; we drew the bomb 

popf 
pop es 
pop di 
pop si 
pop dx 
pop cx 
pop bx 
pop ax 
pop bp 
ret 2 ; 2 for the enemy parameter 

remove_bomb:
; we wil get the bomb offset as parameter 
push bp 
mov bp , sp 
push ax 
push bx 
push cx
push dx 
push si 
push di 
push es 
pushf 

mov di , [bp+4] ; point to bomb offset 
mov ax , 0xb800 
mov es , ax 
cld 
mov ax , 0x0720 ; cleaning 
stosw 

popf 
pop es 
pop di 
pop si 
pop dx 
pop cx 
pop bx 
pop ax 
pop bp 
ret 2 ; for bomb offset 

move_bomb:
; bomb offset as parameter 
; we clear previous loc , add 160 and then draw 
; also check for boundry 
push bp 
mov bp , sp 
push ax 
push bx 
push cx
push dx 
push si 
push di 
push es 
pushf

mov ax , [bp+4] 
push ax ; push to call for remove bomb
call remove_bomb

mov di , [bp+4] ; bullet offset 
add di , 160 ; next line
push di 
call bomb_collision
cmp word [bombcollisionflag] , 1 
je collision_occured 
 
cmp di , 3520 ; 22 row the boundry 
jae bomb_hasreached_floor

mov word [bomboffset] , di ; storing new offset 
mov ax , 0xb800 
mov es , ax 
mov ah , [bombattr] 
mov al , [bombchar]
cld 
stosw  
jmp bomb_moved 

bomb_hasreached_floor:
collision_occured:
; means last line so we gotta remove it 
mov word [isbombactive] , 0 
mov word [bombcollisionflag] , 0 ; reset collision flag 

bomb_moved:
popf 
pop es 
pop di 
pop si 
pop dx
pop cx 
pop bx 
pop ax 
pop bp 
ret 2 ; for 1 para 

bomb_collision:
; bomb offset at +4 
push bp 
mov bp , sp 
push ax 
push bx 
push cx
push dx 
push si 
push di 
push es 
pushf

mov di , [bp+4] ; bullet offset
mov ax , [playerY] ; the top y cord 
sub ax , 4 ; left most Y 
mov cx , enemylen ; sprite num [5] 

checkallupper_sprite: ; checks all upper sprite with bullet 
cmp di , ax 
je bomb_player_collision_detected 
add ax , 2 ; next loc 
loop checkallupper_sprite 

mov ax , [playerleftX]  ; left lower side 
cmp di , ax 
je bomb_player_collision_detected

mov ax , [playerrightX]  ; right lower side 
cmp di , ax 
je bomb_player_collision_detected 

jmp no_bombplayer_collision 

bomb_player_collision_detected:
mov word [bombcollisionflag] , 1 
; call remove_life function to reduce player life 

no_bombplayer_collision:
popf 
pop es 
pop di 
pop si 
pop dx
pop cx 
pop bx 
pop ax 
pop bp 
ret 2
