[org 0x0100]

jmp start 

; ------------------------------------------------ player -------------------------------------------------------------
draw_player:
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

mov si , [Bp + 4] ; y location of the player 
mov di , [si] 
mov ax , 0xb800 
mov es , ax 
mov word [es:di - 4] , 0x0E21 ; engine flames ! 
mov word [es:di - 2] , 0x0B2F ; / cyan colored 
mov word [es:di] , 0x0F5E ; ^ bright white 
mov word [es:di + 2] , 0x0B5C ; \ cyan colored 
mov word [es:di + 4] , 0x0E21 ; ! 

mov si , [bp + 8] ; left X of the ship 
mov di , [si] 

mov word [es:di] ,0x0B2F ; / cyan body  
mov word [es:di + 2] , 0x0B7C ; | hull cyan colored
mov word [es:di + 4] , 0x0F3D ; = bright white    
mov word [es:di + 6] , 0x0B7C ; | cyan colored hull 
mov word [es:di + 8] , 0x0B5C ; \ cyan colored body 

popf 
pop es
pop di 
pop si 
pop dx 
pop cx 
pop bx 
pop ax 
pop bp 
ret 6 ; 6 for playerY , playerrightX and playerleftX 

remove_player:
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

; clearing of upper body 
mov si , [bp+4] ; y location of the player 
mov di , [si] 
mov ax , 0xb800 
mov es , ax 
mov word [es:di - 4] , 0x0720 ; clean ! 
mov word [es:di - 2] , 0x0720 ; clean \  
mov word [es:di] , 0x0720 ; clean ^ 
mov word [es:di + 2] , 0x0720 ; clean / 
mov word [es:di + 4] , 0x0720 ; clean !

; clearing of lower body 
mov si , [bp + 8] ; left X of the ship 
mov di , [si] 

mov word [es:di] ,0x0720 ; clears /   
mov word [es:di + 2] , 0x0720 ; clears |
mov word [es:di + 4] , 0x0720 ; clears =     
mov word [es:di + 6] , 0x0720 ; clears | 
mov word [es:di + 8] , 0x0720 ; clears \ 

popf 
pop es 
pop di 
pop si 
pop dx
pop cx
pop bx 
pop ax 
pop bp 
ret 6 ; for playerY and playerleftX and playerrightX 

; ---------------------------------------------------- drawing enemies here ----------------------------------
draw_enemies:
; at +4 we have bottom enemies and at +6 we have top enemies offsets 
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

mov ax , 0xb800
mov es , ax 

mov bx , [bp + 6] ; now bx points to array of topenemies offsets  
mov cx , enemynum ; for 6 enemies 
cld  ; clearing the flag direction 
push bp ; saving bp so that i can use it again
drawing_enemy_upper:
mov si , enemyTopSprite ; now si points to sprite of top enemies 
mov di , [bx] ; di now has first offset
cmp di , -1 ; if the enemy at this offset is dead 
je skip_draw_dead_upp
push cx  ; to save the outer timer 
mov cx , enemylen 
mov bp , enemyTopAttr 
drawing_enemy_upp1: ; draws 1 single enemy 
lodsb 
mov ah , [ds:bp]
stosw  
add bp , 1 
loop drawing_enemy_upp1
pop cx 
skip_draw_dead_upp:
add bx , 2 ; mov bx to next offset
loop drawing_enemy_upper 
pop bp 

mov bx , [bp + 4] ; bottom enemies offset 
mov cx , enemynum 

push bp 
drawing_enemy_lower: 
mov si , enemyBottomSprite ; bottom sprites 
mov di , [bx] ; di now has first offset
cmp di , -1 
je skip_draw_dead_low
push cx 
mov cx , enemylen
mov bp , enemyBottomAttr
drawing_enemy_low1: 
lodsb 
mov ah , [ds:bp] ; bec bp is with the SS so we put it to DS with segment override
stosw 
add bp , 1 
loop drawing_enemy_low1
pop cx 
skip_draw_dead_low:
add bx , 2 ; mov bx to next offset
loop drawing_enemy_lower
pop bp 

popf 
pop es 
pop di 
pop si 
pop dx 
pop cx 
pop bx 
pop ax 
pop bp 
ret 4  ; 4 is for removing bottom and top offsets array 

remove_enemies:
; +4 we have bottom +6 we have top 
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

mov ax , 0xb800
mov es , ax 

mov bx , [bp + 6] ; bx now points to array of top offets 
mov cx , enemynum ; number of enemies [6] 
remove_every_enemy_upp:
mov si , [bx] 
cmp si , -1 
je skip_remove_dead_upp
mov di , si 
push cx 
mov cx , enemylen
cld 
remove_each_upp:
mov ax , 0x0720 
stosw 
loop remove_each_upp 
pop cx 
skip_remove_dead_upp: 
add bx , 2 
loop remove_every_enemy_upp


mov bx , [bp +4] 
mov cx , enemynum
remove_every_enemy_low:
mov si , [bx]
cmp si , -1 
je skip_remove_dead_low  
mov di , si 
push cx 
mov cx , enemylen
remove_each_low:
mov ax , 0x0720 
stosw 
loop remove_each_low
pop cx
skip_remove_dead_low: 
add bx , 2 
loop remove_every_enemy_low 

popf
pop es 
pop di 
pop si 
pop dx 
pop cx 
pop bx 
pop ax 
pop bp 
ret 4 ; for 2 parameters upp and low offsets arr 

move_enemies:
; the concept i am going to use is that i will keep moving the ships right until the right most is on the last col 
; then we lower by 1 row and move left until we at the 0 col and vice versa  
; the formula i m using is AX = offset BX = 160 DIV BX will give 158 in dx if at 79 col or 0 if at first.
; +4 bottom +6 top 
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


mov si , [bp+6] ; point bx to upper offsets row 
mov cx , enemynum 
checkenemyindfirst:
mov ax , [si] ; first ind
cmp ax , -1 ; if ax is -1 means this enemy is dead so we check next 
jne save_upp_offset 
add si , 2 
dec cx 
cmp cx , 0 
jne checkenemyindfirst

jmp top_row_dead 

save_upp_offset:
mov word [firstupperalive] , ax 


mov si , [bp+4] ; lower arr offsets 
mov cx , enemynum 
checkenemyindfirstlower:
mov ax , [si] 
cmp ax , -1 
jne save_low_offset 
add si , 2 
dec cx 
cmp cx , 0 
jne checkenemyindfirstlower 
jmp bottom_row_dead 
 
save_low_offset:
mov word [firstloweralive] , ax  


aliveenemyatthisloc:
mov ax , [firstupperalive] 
xor dx , dx  
mov bx , 160 
div bx 
mov word [firstupperalivecol] , dx ; we have stored the col of the first upp 
mov ax , [firstloweralive] 
xor dx , dx 
mov bx , 160 
div bx ; now dx has col for lower and mem has col for upper we compare if low col < upp col 
cmp dx , [firstupperalivecol] ; if uper col is less greator than lower one than we use lowrr else upper 
jb lowerenemyhaslead
mov dx , [firstupperalivecol] 
lowerenemyhaslead:
cmp dx , 0 ; if dx has 0 means the enemies are on col 0 
jne checkrightedge ; means they hit the left edge 
jmp leftedgehit 

top_row_dead:


leftedgehit:
mov ax , enemyTopOffsets 
push ax 
mov ax , enemyBottomOffsets
push ax 
call remove_enemies
mov word [directionofmov] , 1 ; set the flag to indicate we going right from now 
mov di , [bp+6] ; top offsets 
mov cx , enemynum
lowenemyrowupperleft:
cmp word [di] , -1 
je skip_dead_leftedge_upp 
add word [di] , 160 
skip_dead_leftedge_upp: 
add di , 2 
loop lowenemyrowupperleft 
mov di , [bp+4] ; top offsets 
mov cx , enemynum
lowenemyrowlowerleft:
cmp word [di] , -1 
je skip_dead_leftedge_low
add word [di] , 160 
skip_dead_leftedge_low:
add di , 2 
loop lowenemyrowlowerleft

jmp move_enemies_right_edge 

checkrightedge:
mov bx , [bp+6] 
mov di , enemynum ; num of enemy [6] 
shl di , 1 
sub di , 2 ; last ind 
add bx , di ; bx is now at the last ind of the offset arr 
mov cx , enemynum ; to keep count of entries  

checkenemyindlast:
mov ax , [bx] 
cmp ax , -1 
jne save_last_upp_offset  
sub bx , 2 
dec cx 
cmp cx , 0 
jne checkenemyindlast

save_last_upp_offset:
mov word [lastuppoffset] , ax 


mov bx , [bp+4] 
mov di , enemynum ; num of enemy [6] 
shl di , 1 
sub di , 2 ; last ind 
add bx , di ; bx is now at the last ind of the offset arr 
mov cx , enemynum ; to keep count of entries  

checkenemyindlastlow:
mov ax , [bx] 
cmp ax , -1 
jne save_last_low_offset 
sub bx , 2 
dec cx 
cmp cx , 0 
jne checkenemyindlastlow
jmp enemymoved

save_last_low_offset:
mov word [lastlowoffset] , ax 

lastaliveenemythisloc:
mov ax , [lastuppoffset] 
xor dx , dx 
mov bx , 160 
div bx 
mov word [lastuppoffsetcol] , dx 
mov ax , [lastlowoffset] 
xor dx , dx 
mov bx , 160 
div bx 
cmp dx , [lastuppoffsetcol] 
ja lastlowhaslead
mov dx , [lastuppoffsetcol]  
lastlowhaslead:
cmp dx , 150 ; if dx has 158 means its on last col 
jne checkdirectionmov

rightedgehit:
mov ax , enemyTopOffsets 
push ax 
mov ax , enemyBottomOffsets
push ax 
call remove_enemies
mov word [directionofmov] , 0 ; set the flag to indicate we going right from now 
mov di , [bp+6] ; top offsets 
mov cx , enemynum
lowenemyrowupperright:
cmp word [di] , -1 
je skip_dead_rightedge_upp 
add word [di] , 160 
skip_dead_rightedge_upp: 
add di , 2 
loop lowenemyrowupperright
mov di , [bp+4] ; top offsets 
mov cx , enemynum
lowenemyrowlowerright:
cmp word [di] , -1 
je skip_dead_rightedge_low
add word [di] , 160 
skip_dead_rightedge_low:
add di , 2 
loop lowenemyrowlowerright

jmp move_enemies_left_edge

checkdirectionmov:
cmp word [directionofmov] , 1 ; means r we moving right rn or left 
jne move_enemies_left 

move_enemies_right:
mov ax , enemyTopOffsets 
push ax 
mov ax , enemyBottomOffsets
push ax 
call remove_enemies 

move_enemies_right_edge:

mov di , [bp+6] 
mov cx , enemynum
movoffsetsrightupp:
cmp word [di] , -1 
je skip_move_dead_upp_right
add word [di] , 2 
skip_move_dead_upp_right
add di , 2 
loop movoffsetsrightupp 

mov di , [bp+4] 
mov cx , enemynum
movoffsetsrightlow:
cmp word [di] , -1 
je skip_move_dead_low_right
add word [di] , 2
skip_move_dead_low_right:
add di , 2 
loop movoffsetsrightlow 

mov ax , [bp+6] 
push ax 
mov ax , [bp+4] 
push ax 
call draw_enemies 
jmp enemymoved

move_enemies_left:
mov ax , enemyTopOffsets 
push ax 
mov ax , enemyBottomOffsets
push ax 
call remove_enemies 

move_enemies_left_edge:

mov di , [bp+6] 
mov cx , enemynum
movoffsetsleftupp:
cmp word [di] , -1 
je skip_move_dead_upp_left 
sub word [di] , 2 
skip_move_dead_upp_left:
add di , 2 
loop movoffsetsleftupp 

mov di , [bp+4] 
mov cx , enemynum
movoffsetsleftlow:
cmp word [di] , -1 
je skip_move_dead_low_left 
sub word [di] , 2
skip_move_dead_low_left:
add di , 2 
loop movoffsetsleftlow 

mov ax , [bp+6] 
push ax 
mov ax , [bp+4] 
push ax 
call draw_enemies 
jmp enemymoved

enemymoved:
popf 
pop es 
pop di 
pop si 
pop dx 
pop cx 
pop bx 
pop ax 
pop bp 
ret 4 ; for 2 offsets array 

;----------------------------------------------------- collision detection ------------------------------------------

enemy_collision_detection:
; +4 has bullet offset , +6 bottom row , +8 top row of enemies 
; concept is we take the bullet offset and match it against the offsets of the enemies 
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

mov si , [bp+6] ; si points to arry of bottom enemies 
mov di , [bp +4] ; bullet offset 
mov cx , enemynum 
compare_all_enemies_low:
mov ax , [si]
cmp ax , -1 
je skip_deadenemy_check_low 
push cx 
mov cx , enemylen 
check_collisionfor_entirebody_low:
cmp di , ax 
je enemycollision_detected
add ax , 2 
loop check_collisionfor_entirebody_low 
pop cx  
skip_deadenemy_check_low:
add si , 2 ; mov si to next offset 
loop compare_all_enemies_low 

mov si , [bp+8] 
mov cx , enemynum 
compare_all_enemies_upp:
mov ax , [si] 
cmp ax , -1 
je skip_deadenemy_check_upp 
push cx 
mov cx , enemylen 
check_collisionfor_entirebody_upp:
cmp di , ax 
je enemycollision_detected
add ax , 2 
loop check_collisionfor_entirebody_upp
pop cx 
skip_deadenemy_check_upp:
add si , 2 ; mov si to next offset 
loop compare_all_enemies_upp 

jmp no_collision_detected 

enemycollision_detected:
pop cx 
; si is pointing to the place where the enemy was killed 
; ax hold the value temp 
mov ax , [si] ; we gave the enemy offset and call the function to kill it 
push ax 
mov word [si] , -1 ; we replaced its offset to -1 in the offsets array 
call kill_enemy 
push di
call remove_bullet 
mov word [isbulletactive] , 0 


no_collision_detected:
popf 
pop es 
pop di 
pop si 
pop dx 
pop cx 
pop bx 
pop ax 
pop bp 

ret 6 ; for 3 variables 


kill_enemy:
; has enemy offset at +4 
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

mov ax , 0xb800 
mov es , ax 
mov di , [bp + 4] 
mov cx , enemylen 
mov ax , 0x0720 ; cleaning 
remove_enemy_sprite:
stosw 
loop remove_enemy_sprite 

popf 
pop es 
pop di 
pop si 
pop dx 
pop cx 
pop bx 
pop ax 
pop bp 
ret 2 ; 2 is for the bullet offset pushed 


player_enemy_collision:
; +4 has bottom arr +6 has top offsets 
;checking the danger zone [ row 19 is the start of danger zone bec playerY exist in row 20 ] 
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

checkifenemyisaliveinlastrow:
mov si , [bp+4] ; bottom offset 
mov cx , enemynum 
checkall_last:
mov ax , [si] 
cmp ax , -1 
je skipthis_last 
cmp ax , 3040 ; starting offset of 19th row 
jae enemyhas_entered_dangerzone
jmp no_dangerzone 

skipthis_last:
add si , 2 ; for next element 
dec cx 
cmp cx , 0 ; do all enemies dead in lower row 
jne checkall_last 

checkifenemyisaliveintoprow:
mov si , [bp+6] ; bottom offset 
mov cx , enemynum 
checkall_top:
mov ax , [si] 
cmp ax , -1 
je skipthis_top 
cmp ax , 3040 ; starting offset of 19th row 
jae enemyhas_entered_dangerzone
jmp no_dangerzone 

skipthis_top:
add si , 2 ; for next element 
dec cx 
cmp cx , 0 ; do all enemies dead in top row 
jne checkall_top
jmp all_enemy_dead 

enemyhas_entered_dangerzone:
; now enemy is in danger zone so it might collide with player or hit the ground 

mov si , [bp+4] ; si points to arry of bottom enemies 
mov di , [playerY]  
mov bx , [playerleftX] 
mov dx , [playerrightX] 
mov cx , enemynum 

compare_player_enemies_low:
mov ax , [si]
cmp ax , -1 
je skip_deadenemyplayer_check_low
cmp ax , 3520 
jae enemyhas_hitboundry 
push cx 
mov cx , enemylen 
check_collisionfor_entirebodyplayer_low:
cmp di , ax 
je playerenemy_collision_detected
cmp bx , ax 
je playerenemy_collision_detected
cmp dx , ax 
je playerenemy_collision_detected 
add ax , 2 
loop check_collisionfor_entirebodyplayer_low 
pop cx  
skip_deadenemyplayer_check_low:
add si , 2 ; mov si to next offset 
loop compare_player_enemies_low 

mov si , [bp+6] 
mov cx , enemynum 
compare_player_enemies_upp:
mov ax , [si] 
cmp ax , -1 
je skip_deadenemyplayer_check_upp 
cmp ax , 3520 
jae enemyhas_hitboundry 
push cx 
mov cx , enemylen 
check_collisionfor_entirebodyplayer_upp:
cmp di , ax 
je playerenemy_collision_detected
cmp bx , ax 
je playerenemy_collision_detected 
cmp dx , ax 
je playerenemy_collision_detected 
add ax , 2 
loop check_collisionfor_entirebodyplayer_upp
pop cx 
skip_deadenemyplayer_check_upp:
add si , 2 ; mov si to next offset 
loop compare_player_enemies_upp 

jmp no_dangerzone  


enemyhas_hitboundry:
mov word [gameover] , 1 
jmp playerenemy_collision_done 

playerenemy_collision_detected:
pop cx ; poping the cx we stored earlier 
mov word [gameover] , 1 ; set the gameover flag 
jmp playerenemy_collision_done 

all_enemy_dead:
mov word [gameover] , 1

no_dangerzone:
playerenemy_collision_done:
popf 
pop es 
pop di 
pop si 
pop dx 
pop cx 
pop bx 
pop ax 
pop bp 
ret 4 ; for offsets 


; --------------------------------------------------clear screen -----------------------------------



clrscr:
push ax 
push es 

mov ax , 0xb800 
mov es , ax 

mov ax , 0x0720 
mov di , 0 
cld 
mov cx , 2000 
rep stosw 
pop es 
pop ax 
ret 


; ----------------------------------------------- bullets --------------------------------------

move_bullet:
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


mov si , [bp+4] ; bullet offset 
cmp si , 160 
jb lastcolumn_reached 

mov ax , [bulletoffset]
push ax 
call remove_bullet 

sub si , 160 
mov [bulletoffset] , si 
mov di , si 
mov ax , 0xb800 
mov es , ax 
mov ax , 0x0F21 
mov [es:di] , ax 
jmp bulletmoved

lastcolumn_reached:
mov word [isbulletactive] , 0 
mov ax , [bulletoffset]
push ax 
call remove_bullet

bulletmoved:
popf 
pop es 
pop di 
pop si 
pop dx 
pop cx 
pop bx 
pop ax 
pop bp 
ret 2 ; 2 for player Y  
 
 
draw_bullet:
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


mov si , [bp+4] ; player y location 
sub si , 160 ; previous line 
mov [bulletoffset] , si ; saving the bullet offset 
mov di , si 
mov ax , 0xb800 
mov es , ax 
mov ax , 0x0F21 
mov [es:di] , ax 

popf 
pop es 
pop di 
pop si 
pop dx 
pop cx 
pop bx 
pop ax 
pop bp 
ret 2 ; 2 for player Y 

remove_bullet:
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
 
mov si , [bp+4] ; bulletoffset location 
mov di , si 
mov ax , 0xb800 
mov es , ax 
mov ax , 0x0720
mov [es:di] , ax 

popf 
pop es 
pop di 
pop si 
pop dx 
pop cx 
pop bx 
pop ax 
pop bp 
ret 2 ; 2 for bulllet offset 

; --------------------------------------------------- isr -------------------------------------------------------- 
bullettimerisr:
push ax 
push ds 
push cs 
pop ds 

;cmp byte [cs:gameRunning], 1
;jne bulletintdone
cmp word [cs:gameover] , 1 
je bulletintdone 

inc word [cs:enemytick] 
cmp word [cs:enemytick] , 4       ; enemy movement tick 
jne checkbulletsection 

mov word [ cs:enemytick] , 0 
mov ax , enemyTopOffsets
push ax 
mov ax , enemyBottomOffsets
push ax 
call move_enemies
mov ax , enemyTopOffsets
push ax 
mov ax , enemyBottomOffsets
push ax
call player_enemy_collision 
cmp word [cs:gameover] , 1 
je bulletintdone 

checkbulletsection:
cmp word [cs:isbulletactive] , 1
jne bulletintdone

inc word [cs:bullettick] 
cmp word [cs:bullettick] , 1
je bulletmovingtime 
jmp bulletintdone 

bulletmovingtime:
mov ax , [cs:bulletoffset] 
push ax 
call move_bullet 
mov ax , enemyTopOffsets 
push ax 
mov ax , enemyBottomOffsets 
push ax 
mov ax , [cs:bulletoffset] 
push ax 
call enemy_collision_detection 
mov word [cs:bullettick] , 0 

bulletintdone:

pop ds 
pop ax 
jmp far [cs:oldtimer] 



movementisr:
push ax 
;cmp byte [cs:gameRunning] , 0
;jne performtask 
;jmp done 
cmp word [cs:gameover] , 1 
jne performtask 
in al , 0x60
cmp al , 0x01 
je escpressed 
jmp done 

performtask:
in al , 0x60 ; taking input
 
cmp al , 0x4B 
je moveLeft 

cmp al , 0x4D
je moveRight 

cmp al , 0x39 
je fire_bullet 

cmp al , 0x01 
je escpressed 

jmp done

escpressed:
mov word [hasesccome] , 1
jmp done 

fire_bullet:
cmp word [cs:isbulletactive] , 1 
jne nobulletrn
jmp done 

nobulletrn:
mov word [cs:isbulletactive] , 1  ; means 1 bullet is alrdy there so u cant fire more 
mov ax , [cs:playerY] 
push ax 
call draw_bullet
jmp done 


moveLeft:
mov ax , [cs:playerleftX] 
cmp ax , 3360
jbe done
mov ax , playerleftX 
push ax 
mov ax , playerrightX 
push ax 
mov ax , playerY 
push ax 
call remove_player
sub word [cs:playerrightX] , 2
sub word [cs:playerleftX] , 2 
sub word [cs:playerY] , 2
mov ax , playerleftX 
push ax 
mov ax , playerrightX 
push ax 
mov ax , playerY 
push ax 
call draw_player 
jmp done 

moveRight:
mov ax , [cs:playerrightX] 
cmp ax , 3518
jae done 
mov ax , playerleftX 
push ax 
mov ax , playerrightX 
push ax 
mov ax , playerY 
push ax 
call remove_player
add word [cs:playerrightX] , 2
add word [cs:playerleftX] , 2 
add word [cs:playerY] , 2
mov ax , playerleftX 
push ax 
mov ax , playerrightX 
push ax 
mov ax , playerY 
push ax 
call draw_player 
jmp done 


done: 
mov al , 0x20 
out 0x20 , al 

pop ax 
iret 

;----------------------------------------------main------------------------------------------------
start:

call clrscr
mov ax , playerleftX
push ax 
mov ax , playerrightX
push ax 
mov ax , playerY 
push ax 
call draw_player ; player drawing

mov ax , enemyTopOffsets 
push ax 
mov ax , enemyBottomOffsets 
push ax 
call draw_enemies ; drawing enemies 

xor ax , ax 
mov es , ax 

mov ax , [es:9*4] 
mov [oldisr] , ax 
mov ax , [es:9*4+2] 
mov [oldisr+2] , ax 

mov ax , [es:8*4] 
mov [oldtimer] , ax 
mov ax , [es:8*4+2] 
mov [oldtimer+2] , ax 


cli 
mov word [es:9*4] , movementisr 
mov [es:9*4+2] , cs 
mov word [es:8*4] , bullettimerisr 
mov [es:8*4+2] , cs 
sti 

infloop:

cmp word [hasesccome] , 1 
je break 

jmp infloop  


break:
; unhooking 
xor ax , ax 
mov es , ax 

cli 
mov byte [gameRunning] , 0 
mov ax , [oldisr] 
mov [es:9*4] , ax 
mov ax , [oldisr + 2] 
mov [es:9*4+2] , ax 

mov ax , [oldtimer] 
mov [es:8*4] , ax 
mov ax , [oldtimer + 2] 
mov [es:8*4+2] , ax 
sti 

mov ax , 0x4c00 
int 0x21 
;--------------------------------------------------declarations--------------------------------------------
; player 
playerrightX: dw 3438   ; starting player offsets 
playerleftX: dw 3430
playerY: dw 3274
oldisr: dd 0 
oldtimer: dd 0 

; bullet 
bullettick: dw 0 
bulletoffset: dw 0 
isbulletactive:dw 0 

; enemies 
enemyTopSprite:  db '\<o>/' ; enemy top design 
enemylen: equ $ - enemyTopSprite ; constant for enemy length  
enemyBottomSprite: db '\=V=/'	  ; enemy design bottom   
enemyTopOffsets: dw 820, 840, 860, 880, 900, 920 ; enemy locations 
enemynum: equ ( $ - enemyTopOffsets ) / 2 ; constant for enemy numbers 
enemycounttop: dw enemynum ; define enemycounttop with same as enemy num 
enemyBottomOffsets: dw 1300, 1320, 1340, 1360, 1380, 1400
enemyTopAttr:      db 0x0C, 0x0C, 0x0E, 0x0C, 0x0C
enemyBottomAttr:   db 0x0C, 0x0E, 0x0C, 0x0E, 0x0C
enemytick: dw 0 
firstloweralive: dw 0 
firstupperalive: dw 0 
firstupperalivecol: dw 0 
lastuppoffset: dw 0 
lastlowoffset: dw 0 
lastuppoffsetcol: dw 0 




; movment flag 
directionofmov: dw 1 ; 1 means right 0 means left 
gameRunning: db 1
hasesccome: dw 0 

gameover: dw 0 ; 1 means gameover 0 means no 
