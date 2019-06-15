.model small
		include macros.txt
.stack 100h
	LF equ 0ah
	CR equ 0dh
	MAX equ 100
.data
	str1 db MAX dup ('0')
	str2 db MAX dup ('0')
	str3 db MAX dup ('0')
	count db 0
	carry db 0
	
	tempStr1 db MAX dup ('0')
	tempStr2 db MAX dup ('0')
	tempStr3 db MAX dup ('0')
	tempStr4 db '1$'
	
	divisor db MAX dup ('0')
	dividend db MAX dup ('0')
	quotient db MAX dup ('0')
	remainder db MAX dup ('0')

	tempStrm1 db MAX dup ('0')
	tempStrm2 db MAX dup ('0')
	tempStrm3 db MAX dup ('0')
	product db MAX dup ('0')
	multiplier db 0

;masud	
	X db MAX dup (0)
	Y db MAX dup (0)
	Z db MAX dup (0)
	temp db MAX dup(0)
	len db 0
	length_x db 0
	length_y db 0
	minus db 0
	sign db 0
.code
main proc
	;showDs
	mov ax,@data
	mov ds,ax
	mov es,ax
	
	top_:
		printNewline	
		takeStringD str1
		printNewline

	mov bx,0
	cmp str1[bx],'e'
	jne exit_1
	jmp exit_
	
	exit_1:
	takeSign

	
	takeStringD str2
	printNewline
	mov al,sign
	
	cmp al,'-'
		je sub_
	cmp al,'+'
		je add_
	cmp al,'*'
		je mul_
	cmp al,'/'
		je div_	
	cmp al,'e'
		jne exit_1
		jmp exit_
	exit1:
	add_:
		call addProc
		printString Str3
		printNewLine
		jmp bottom_
	
	mul_:
		call mulProc
		printString Str3
		printNewline
		jmp bottom_
	
	sub_:
		call subProc
		printString Str3
		printNewLine
		jmp bottom_
		
	div_:
		call divProc
		printNewline
		jmp bottom_
	
	bottom_:		
		jmp top_
	exit_:
		returnDos
main endp

divProc proc
		registerPush
		printNewline
		
		copyString str1,dividend		; copy str to divisor and dividend
		copyString str2,divisor
		xor si,si
		clearString quotient

		mov quotient[si],'0'
		inc si
		mov quotient[si],'$'
		
	div_first_level:
			increment quotient
			
			copyString divisor,str1
			copyString quotient,str2
			call mulProc		; str3 = multiplication			
			
			copyString dividend,str1
			copyString str3,str2	; multiplication = lower;;;;;;;;;;;;;;;;;
			call subProc
			
			
			
			mov si,0
			cmp str3[si],'-'
		je exit_div_find_minus
			cmp str3[si],'0'
		je exit_div
			;printNewline
	jmp div_first_level
		
	exit_div:
		printString quotient
		printNewline
		printString str3
	jmp last_div
		
	exit_div_find_minus:

		copyString quotient,str1
		xor si,si
		mov str2[si],'1'
		inc si
		mov str2[si],'$'

		call subProc
		copyString str3,quotient
		
		copyString divisor,str1
		copyString quotient,str2
		call mulProc
		copyString dividend,str1
		copyString str3,str2
		call subProc	
	jmp exit_div
	
last_div:
		
		
				
		registerPop
		ret
divProc endp

mulProc proc
	copyString str1,tempStrm1
	copyString str2,tempStrm2
	
	reverseString tempStrm1,tempStrm3
	reverseString tempStrm2,tempStrm3
	
	call reverseMultiply
	
	reverseString tempStr3,tempStr1
	
	copyString tempStr3,str3
	removeZero str3				; 		by masud
	
	clearString tempStrm1
	clearString tempStrm2
	clearString tempStrm3
	clearString product
	mov multiplier,0
	ret
mulProc endp

reverseMultiply proc
	registerPush	
	mov cl,0
	mov bx,0
	mov str1[bx],'0'
	mov str1[bx+1],'$'
	top:
		mov al,tempStrm2[bx]
		cmp al,'$'
		jne breakp
		jmp breakq
		
		breakp:
		mov ah,0
		sub al,48
		mov multiplier,al
		multiply tempStrm1,multiplier,product
		
		shiftProduct product,cl	
		copyString product,str2
		
		reverseString str1,tempStr3
		reverseString str2,tempStr3
		call addProc
		reverseString str3,tempStr3
		copyString str3,str1
		inc cl
		inc bx
		jmp top
	
	breakq:
	
	copyString str1,tempStrm3
	registerPop
	ret
reverseMultiply endp
addProc proc
    registerPush
	
	clearString tempStr1
	clearString tempStr2
	
	reverseString str1,tempStr3
	reverseString str2,tempStr3
	
	takeString str1,tempStr1,cl
	takeString str2,tempStr2,ch
	
	;greaterInCount cl,ch,dl
	cmp cl,ch
	jg new1
	mov cl,ch
	new1:
	mov ch,0
	
	mov bx,0
	for1:
		mov dl,tempStr1[bx]
		mov dh,tempStr2[bx]
		add dl,dh
		add dl,carry
		sub dl,96
		
		cmp dl,9
		jg greater2
			mov carry,0
			jmp level2
		greater2:
			sub dl,10
			mov carry,1
		
		level2:
			add dl,48
			mov str3[bx],dl
			inc bx			
			loop for1	

	cmp carry,0
	je exit
	mov cl,carry
	add cl,48
	mov str3[bx],cl
	inc bx
	;inc count
	exit:
		mov str3[bx],'$'		
		reverseString str3,tempStr3
		registerPop
		ret
addProc endp
subProc proc
	;registerPush
	
	
	copyString str1,X
	copyString str2,Y
		
	removeZero X
	mov al,len
	mov length_x,al
	
	removeZero Y
	mov al,len
	mov length_y,al
		
	reverseString X,temp
	reverseString Y,temp


	call subtraction
	reverseString Z,temp

	copyString Z,str3
	
	;registerPop
	ret
subProc endp

subtraction proc				; look here of the procedure name
		call compare		
		xor bl,bl		;;;;;;;;; over here
		xor cl,cl
		xor si,si


subtra:
		cmp Y[si],'$'		
		je exit_sub
		mov al,X[si]
		cmp cl,1
		je have_carry
		jmp not_carry
		
	have_carry:
		sub al,1
		
		
	not_carry:
		mov cl,0
		mov dl,Y[si]
		cmp al,dl
		jl up_is_lower
		jmp down_is_lower
		
up_is_lower:
	mov cl,1
	add al,10

down_is_lower:
	sub al,dl
	mov Z[si],al
	add Z[si],48
	inc si	
		
	jmp subtra	
exit_sub:

second_cmp:
	cmp X[si],'$'
	je exit_sub2
		mov al,X[si]
		cmp cl,1
		je have_carry2
		jmp not_carry2
		
	have_carry2:
		sub al,1				
	not_carry2:
		mov cl,0
		mov Z[si],al
		inc si	
	
	jmp second_cmp

exit_sub2:
mov Z[si],'$'
reverseString Z,temp
removeZero Z
reverseString Z,temp

mov al,minus
xor bx,bx
mov bl,len			; length of Z (new string with out heading Zero)
cmp al,'-'
je has_negative
	jmp subtraction_exit

has_negative:
	mov Z[bx],al
	inc bx
subtraction_exit:
	mov Z[bx],'$'
;mov ah,2
;mov dl,0ah
;int 21h
ret
subtraction endp



compare proc				;;;;;;;;;;; compare
	push ax
	push cx
	push dx
	push si
	
	xor si,si
	xor bx,bx
	mov minus,bl
	
		
	mov al,length_x
	cmp al,length_y
	jg add_zero
	je equal1
	
end_y_string:
	cmp X[si],'$'
	je second_change
	
	mov al,X[si]
	mov cl,Y[si]
	mov X[si],cl
	mov Y[si],al
	inc si
	jmp end_y_string
	
	
second_change:
	cmp Y[si],'$'
		je exit_y_string
		mov al,Y[si]
		mov X[si],al
		mov Y[si],'0'
		inc si
		jmp second_change
	exit_y_string:
		mov ax,'$'
		mov X[si],al
		mov Y[si],al;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;******************************************here for minus
	mov al,'-'
	mov minus,al
	jmp final_exit		;; unconditional jump
	
add_zero:
	call find_last_y		; si is changed
	
add_zero_to_y:
		cmp X[si],'$'
		jne add_0
		dec si
		mov Y[si],'$'
	jmp final_exit
		
	add_0:
		mov Y[si],'0'
		inc si
	jmp add_zero_to_y
	
equal1:
		xor cx,cx
		mov cl,length_x
		mov bx,cx
		dec bl
equal:
		mov al,X[si+bx]
		cmp al,Y[si+bx]
			jl end_y_string		
			jg final_exit
		dec bx
		loop equal
final_exit:		
	;;;;;;;;;;;;;; Flag Lagbe
	pop si
	pop dx
	pop cx
	pop ax
ret
compare endp

find_last_y proc

xor si,si
L:
	cmp Y[si],'$'
		je E
	inc si
	jmp L	
E:

ret
find_last_y endp
end main