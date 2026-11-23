[org 0x0100] 
jmp start 

; writing the code here in case we need it for the TSR 

clrscreen:

; pushing normal registers 
push ax
push cx 
push di  
push es
pushf ; pushing the flags 

; opening vedio mem in es
mov ax , 0xb800
mov es , ax 
; moving ascii into ax 
mov ax , 0x0720 
mov cx , 2000 ; 2000 chars on the entire screen 
mov di , 0
 
cld ; set flag direction 
rep stosw ; repetedly putting the content of ax at di

; pops 
popf ; poping the flag  
pop es 
pop di 
pop cx 
pop ax 
ret 

drawStarsnormal:
push bp ; pushing base pointer 
mov bp , sp ; mov bp to sp 
;pushing all registers
push ax
push bx
push cx
push dx
push si
push di
push es 

mov bx , [bp + 4] ; starY array 
mov si , [bp + 6] ; starX array 
mov cx , normalstarlen ; 24 normal stars 
mov ax , 0xb800
mov es , ax 

drawing_normal_star:
; calculating cord of star 
mov ax , 80 
mul byte [bx] ; 80 * y 
xor dx , dx ; moving 0 in dx 
mov dl , [si] ; bec si was a word so we couldnt manully add ax + si bec si is pointing a db arr and will add 2 ind 
; so we first move si to dl which will only get 1 index of it and then add ax , dx 
add ax , dx ; adding x cord 
shl ax , 1 ; now ax has exact cord of star 
mov di , ax 
mov ax , 0x082E  ; moving the star attr and ascii of . 
mov [es:di] , ax 
add si , 1 ; moving si to next star x cord 
add bx , 1 ; moving bx to next star y cord 
loop drawing_normal_star ; drawing 24 normal stars 

; pop reg 
pop es
pop di
pop si
pop dx
pop cx
pop bx
pop ax 
pop bp 
ret 4 ; 4 for removing the starX and starY array from stack as well 

drawStarsblink:
push bp ; pushing base pointer 
mov bp , sp ; mov bp to sp 
;pushing all registers
push ax
push bx
push cx
push dx
push si
push di
push es 

mov bx , [bp + 4] ; blinkY array 
mov si , [bp + 6] ; blinkX array 
mov cx , blinkstarlen ; 10 blinking stars 
mov ax , 0xb800
mov es , ax 
mov di , 0 
drawing_blink_star:
; calculating cord of star 
mov ax , 80 
mul byte [bx] ; 80 * y 
xor dx , dx ; moving 0 in dx 
mov dl , [si] ; bec si was a word so we couldnt manully add ax + si bec si is pointing a db arr and will add 2 ind 
; so we first move si to dl which will only get 1 index of it and then add ax , dx 
add ax , dx ; adding x cord 
shl ax , 1 ; now ax has exact cord of star 
mov [blinkoffset + di] , ax ; stroing the calc off in the offset array 
push di ; saving di 
mov di , ax 
mov ax , 0x082E  ; moving the star attr and ascii of .  ; for now 08 will do 07 later 
mov [es:di] , ax 
pop di 
add di , 2 ; moving di for next star offset 
add si , 1 ; moving si to next star x cord 
add bx , 1 ; moving bx to next star y cord  
loop drawing_blink_star ; drawing 10 blinks 

; pop reg 
pop es
pop di
pop si
pop dx
pop cx
pop bx
pop ax 
pop bp 
ret 4 ; 4 for removing the starX and starY array from stack as well 

drawStarscolor:
push bp ; pushing base pointer 
mov bp , sp ; mov bp to sp 
;pushing all registers
push ax
push bx
push cx
push dx
push si
push di
push es
pushf  

mov bx , [bp + 4] ; colorY array 
mov si , [bp + 6] ; colorX array 
mov di , [bp + 8] ; attr array 
mov cx , colorstarlen ; 6 coloring stars 
mov ax , 0xb800
mov es , ax 

drawing_color_star:
; calculating cord of star 
mov ax , 80 
mul byte [bx] ; 80 * y 
xor dx , dx ; moving 0 in dx 
mov dl , [si] ; bec si was a word so we couldnt manully add ax + si bec si is pointing a db arr and will add 2 ind 
; so we first move si to dl which will only get 1 index of it and then add ax , dx 
add ax , dx ; adding x cord 
shl ax , 1 ; now ax has exact cord of star 
mov dx , ax ; storing ax 
mov ah , [di] ; moving attr in ah
mov al , 0x2E ; .
push di ; saving di 
mov di , dx ; cords   
mov [es:di] , ax 
pop di ; array is back in di 
add di , 1 ; mov it to next attr 
add si , 1 ; moving si to next star x cord 
add bx , 1 ; moving bx to next star y cord  
loop drawing_color_star ; drawing 10 blinks 

; pop reg 
popf 
pop es
pop di
pop si
pop dx
pop cx
pop bx
pop ax 
pop bp 
ret 6 ; 4 for removing the colorX and colorY and attr array from stack as well 

updateBlinkstars:
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

mov si , [bp + 4] ; pointing si to offsets array 
mov ax , 0xb800 
mov es , ax 
mov cx , blinkstarlen  ; for 10 stars 
 
cmp byte [blinkstate] , 1 ; cmp if state is 1 or 0, 1 means alrdy blinking 
je blink_off ; means blink should be off as they r alrdy blinking 
blink_on: ; else we need to make them blink 
mov di , [si]
mov byte [es:di+1] , 0x0F  ; mov OF to higher bits(attr) 
add si , 2 ; mov si to next star offset 
loop blink_on ; do for all stars 
mov byte [blinkstate] , 1 ; blink is now on 
jmp done 
blink_off:
mov di , [si]
mov byte [es:di+1] , 0x08 ; turn the blink off 
add si , 2 
loop blink_off ; do for all stars 
mov byte [blinkstate] , 0 ; blink is now off 

done:
popf 
pop es
pop di
pop si
pop dx
pop cx
pop bx
pop ax 
pop bp 
ret 2 ; 2 for the offset array 

draw_ground:
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
mov cx , 80
mov ax , 0x085F ; greyish background and _ char 
mov di , 3520 ; row 22 first col 
cld 
rep stosw 
mov cx , 80 
mov di , 320 ; 2nd row 
cld 
rep stosw 

popf 
pop es 
pop di 
pop si 
pop dx 
pop cx 
pop bx 
pop ax 
ret 

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
add bx , 2 ; mov bx to next offset
loop drawing_enemy_upper 
pop bp 

mov bx , [bp + 4] ; bottom enemies offset 
mov cx , enemynum 

push bp 
drawing_enemy_lower: 
mov si , enemyBottomSprite ; bottom sprites 
mov di , [bx] ; di now has first offset
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


draw_hud:
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

cld 
mov di , 160  ; 2nd row 
mov si , scoretag ; si now points to score label 
mov cx , scoretaglen  ; size of label score: if u change it change it too else wont work 
drawing_score_label:
lodsb 
mov ah , 0x0E 
stosw
loop drawing_score_label  

mov di , 290  ; 2nd row 65th colum 
mov si , lifetag ; si now points to life label 
mov cx , lifetaglen
drawing_life_label:
lodsb 
mov ah , 0x0B
stosw 
loop drawing_life_label 

mov di , [nameInd] 
mov si , gamename 
mov cx , gamenamelen
drawing_game_label:
lodsb 
mov ah , 0x0D 
stosw 
loop drawing_game_label

popf
pop es 
pop di 
pop si 
pop dx 
pop cx 
pop bx 
pop ax 
ret 


delay: ; we use big counters for delays 
    push cx
    push dx

    mov cx, 0000Fh

outer_delay:
    mov dx, 0FFFFh

inner_delay:
    dec dx
    jnz inner_delay

    loop outer_delay

    pop dx
    pop cx
    ret


start:
call clrscreen
call draw_hud 
call draw_ground ; ground drawing 
mov ax , playerleftX
push ax 
mov ax , playerrightX
push ax 
mov ax , playerY 
push ax 
call draw_player ; player drawing

mov ax , starX
push ax 
mov ax , starY 
push ax 
call drawStarsnormal
mov ax , blinkX
push ax 
mov ax , blinkY
push ax 
call drawStarsblink
mov ax , colorAttr 
push ax 
mov ax , colorX
push ax 
mov ax , colorY 
push ax 
call drawStarscolor
mov cx , 10
mov ax , enemyTopOffsets 
push ax 
mov ax , enemyBottomOffsets 
push ax 
call draw_enemies ; drawing enemies 
blinktest:
mov ax , blinkoffset 
push ax 
call updateBlinkstars
call delay 
loop blinktest 

mov ax , 0x4c00 
int 0x21

;declarations  

; stars from background 
; if u r to add any more star be sure to add the X and Y cord of it. 
; for adding in color ones make sure to add in to the attr array as well. 
starX: db  5, 14, 23, 34, 46, 57
       db 68, 76,  9, 29, 41, 63
       db 17, 37, 51, 73,  3, 20
       db 44, 60, 78, 12, 32, 54

normalstarlen: equ $ - starX 	   ; is a constant for len of stars 

starY: db  4,  5,  3,  7,  4,  6
       db  8,  5, 11, 10, 13, 12
       db 15,  9, 16, 14, 17, 12
       db 18, 10, 16,  7, 14,  9
	   
blinkX: db  8, 27, 48, 70, 16
        db 39, 61,  4, 52, 74 
		
blinkstarlen: equ $ - blinkX 		; is a constant for len of blinking stars 

blinkY: db  6,  4,  8, 11, 13
        db 16,  4,  9, 17, 14
blinkoffset: dw 0 , 0 , 0 , 0  , 0 , 0 , 0 , 0 , 0 , 0 	
blinkstate: db 0 ; state of the blinking stars 1 for high and 0 for low 	
		
colorX: db 19, 43, 65, 31, 56, 11
colorstarlen: equ $ - colorX ; is a constant for len of color stars 
colorY: db  6,  3,  9, 16, 13, 18

colorAttr: db 0Bh, 09h, 0Eh
           db 0Dh, 0Ch, 0Bh	


; player 
playerrightX: dw 3438   ; starting player offsets 
playerleftX: dw 3430
playerY: dw 3274

; enemies 
enemyTopSprite:  db '\<o>/' ; enemy top design 
enemylen: equ $ - enemyTopSprite ; constant for enemy length  
enemyBottomSprite: db '\=V=/'	  ; enemy design bottom   
enemyTopOffsets: dw 820, 840, 860, 880, 900, 920 ; enemy locations 
enemynum: equ ( $ - enemyTopOffsets ) / 2 ; constant for enemy numbers 
enemyBottomOffsets: dw 1300, 1320, 1340, 1360, 1380, 1400
enemyTopAttr:      db 0x0C, 0x0C, 0x0E, 0x0C, 0x0C
enemyBottomAttr:   db 0x0C, 0x0E, 0x0C, 0x0E, 0x0C

;hud tags
scoretag: db 'Score:'  ; 
scoretaglen: equ $ - scoretag  ; constant for score tag length 
lifetag: db 'lives:'
lifetaglen: equ $ - lifetag ; constant for life tag length 
gamename: db 'Bajwa Shooter' ; 11 length 
gamenamelen: equ $ - gamename ; constant for gamename length 
nameInd: dw 224 ; offset from where the tag starts 