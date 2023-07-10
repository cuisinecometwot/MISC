.data
# Lenh hop ngu MIPS co ban gom Opcode va toi da 3 toan hang.
# Danh sach thanh ghi hop le: 
register: .asciiz "$zero-$at-$v0-$v1-$a0-$a1-$a2-$a3-$t0-$t1-$t2-$t3-$t4-$t5-$t6-$t7-$t8-$t9-$s0-$s1-$s2-$s3-$s4-$s5-$s6-$s7-$k0-$k1-$gp-$sp-$fp-$ra-$0-$1-$2-$3-$4-$5-$6-$7-$8-$9-$10-$11-$12-$13-$14-$15-$16-$17-$18-$19-$20-$21-$22-$23-$24-$25-$26-$27-$28-$29-$30-$31-"
# Danh sach opcode hop le:
opcode: .asciiz "add-addi-addiu-addu-and-andi-beq-bgez-bgtz-blez-bltz-bne-break-div-divu-eret-j-jal-jr-lb-lbu-lui-lw-mfc0-mfc1-mfhi-mflo-mtc0-mtc1-mthi-mtlo-mul-mult-multu-nop-nor-or-ori-sb-sll-sllv-slt-slti-sltiu-sltu-srl-srlv-sub-subu-sw-syscall-teq-xor-xori-"
# Quy uoc toan hang: 0 - null, 1 - register, 2 - number, 3 - Label, 4 - offset(base)
# 1 hop le duoc quy dinh trong chuoi register
# 2 hop le la decimal hoac hexadecimal
# 3 hop le la chuoi ky tu dung dinh dang
# 4 hop le khi offset la label hoac number, base la register
# Danh sach khuon dang toan hang tuong ung voi cac opcode tren:
operand: .asciiz "111-112-112-111-111-112-113-130-130-130-130-113-000-110-110-000-300-300-100-140-140-120-140-110-110-100-100-110-110-100-100-111-110-110-000-111-111-112-140-112-111-111-112-112-111-112-111-111-111-140-000-110-111-112-"

msg1: 	.asciiz "\nNhap lenh hop ngu MIPS: "
msg2: 	.asciiz "\nOpcode: "
msg21: 	.asciiz ", hop le.\n"
msg22: 	.asciiz ", KHONG hop le.\n"
msg3: 	.asciiz "Toan hang: "	
msg4: 	.asciiz "Lenh can kiem tra"
msg5: 	.asciiz "\nTiep tuc chuong trinh kiem tra lenh MIPS? (Y/N) \n>> "
msg6: 	.asciiz "Khuon dang lenh: "
msg7: 	.asciiz "\n"

input: 	.space 100 	# chuoi dau vao
tmp: 	.space 20 	# bien tmp luu thanh phan cat duoc cua opcode
tmp2: 	.space 20 	# luu khuon dang code 
tmp3:	.space 20 	# thanh phan cat duoc tu offset(base) 
.text
main:
Input:
	jal	refresh		# refresh gia tri thanh ghi
	li	$v0, 4
	la	$a0, msg1 	# Dua ra thong bao yeu cau nguoi dung nhap chuoi can kiem tra
	syscall
	li	$v0, 8 
	la	$a0, input 	# nhan chuoi can kiem tra
	li	$a1, 100 	# gioi han toi da 100 ki tu 
	syscall
	#tach va so sanh
	la	$s0, input 	# address(input)
	add	$s1, $zero, $zero # bien i -> dem tung ky tu trong tmp
readOpcode: 
	add	$a0, $s0, $zero # truyen tham so vao cutComponent
	add	$a1, $s1, $zero 
	la	$a2, tmp
	jal	cutComponent
	add	$s1, $v0, $zero # so ky tu cat duoc
	add	$s7, $v1, $zero # so ky tu cat duoc 
checkOpcode:	
	la	$a0, tmp
	add	$a1, $s7, $zero
	la	$a2, opcode
	jal 	compareOpcode
	add	$s2, $v0, $zero # check opcode
	add	$s3, $v1, $zero # count matching voi khuon dang toan hang
	li	$v0, 4
	la	$a0, msg2
	syscall
	li	$v0, 4
	la	$a0, tmp
	syscall
	bne	$s2, $zero, validOpcode # opcode hop le
invalidOpcode: 	#opcode khong hop le
	li	$v0, 4
	la	$a0, msg22
	syscall
	j	escape
validOpcode:	
	li	$v0, 4
	la	$a0, msg21
	syscall
	# lay khuon dang tuong ung voi opcode
	la	$a0, operand
	add	$a1, $s3, $zero 	# truyen vao count
	jal	getOperand 		# tra ve tmp2 - khuon dang
	la 	$a0, msg6
	syscall
	la	$a0, tmp2
	syscall
	la 	$a0, msg7
	syscall

	la	$s4, tmp2		# khuon dang
	add	$s5, $zero, $zero 	# toan hang 1 2 3  - dem
	add	$t9, $zero, 48 		# 0 - null
	addi	$t8, $zero, 49 		# 1 - thanh ghi  
	addi	$t7, $zero, 50 		# 2 - so
	addi	$t6, $zero, 51 		# 3 - label 
	addi	$t5, $zero, 52 		# 4 - offset
Cmp: 	# kiem tra dang cua tung toan hang va check
	slti	$t0, $s5, 3
	beq	$t0, $zero, end
	# lay toan hang 1
	add	$a0, $s0, $zero
	add	$a1, $s1, $zero
	la	$a2, tmp
	jal	cutComponent
	add	$s1, $v0, $zero
	add	$s7, $v1, $zero 	# so ky tu co trong tmp
	# so sanh toan hang 1
	add	$t0, $s5, $s4
	lb	$s6, 0($t0) 		# dang cua toan hang i
	beq	$s6, $t8, reg
	beq	$s6, $t7, number
	beq	$s6, $t6, label
	beq	$s6, $t5, offsetbase
	beq	$s6, $t9, null
reg:
	la	$a0, tmp
	add	$a1, $s7, $zero
	la	$a2, register		# kiem tra register
	# tra ve 0 -> khong hop le, 1 -> hop le
	jal	compareOpcode
	j	checkValid
number:
	la	$a0, tmp
	add	$a1, $s7, $zero
	jal 	checkNumber		# kiem tra co phai Decimal khong
	beq	$v0, $0, hexa		# neu khong phai, kiem tra co phai Hexa khong
	j	checkValid
hexa:
	la	$a0, tmp
	add	$a1, $s7, $zero
	jal	checkHex
	j	checkValid
label:
	la	$a0, tmp
	add	$a1, $s7, $zero
	jal	checkLabel		# kiem tra label
	j	checkValid
offsetbase:
	la	$a0, tmp
	add	$a1, $s7, $zero
	jal	checkOffsetBase		# kiem tra offset(base)
	j 	checkValid
null:
	j	print	
checkValid:
	add	$s2, $v0, $0
	li	$v0, 4
	la	$a0, msg3
	syscall
	li	$v0, 4
	la	$a0, tmp
	syscall
	beq	$s2, $zero, error
	j	ok
updateCheck:	# buoc lap
	addi	$s5, $s5, 1
	j	Cmp
error:	# khong hop le
	li	$v0, 4
	la	$a0, msg22
	syscall
	j	escape
ok:	# hop le
	li	$v0, 4
	la	$a0, msg21
	syscall
	j	updateCheck
end:
	add	$a0, $s0, $zero
	add	$a1, $s1, $zero
	jal	cutComponent
	add	$s1, $v0, $zero 	# i hien tai
	add	$s7, $v1, $zero 	# so ky tu co trong tmp
print:	# dua ra thong bao hop le
	li	$v0, 4
	la	$a0, msg4
	syscall
	bne	$s7, $zero, error
	nop
	li	$v0, 4
	la	$a0, msg21
	syscall
	j	repeatMain
escape:	# dua ra thong bao khong hop le
	li	$v0, 4
	la	$a0, msg4
	syscall
	la	$a0, msg22
	syscall
repeatMain:	# Tiep tuc kiem tra neu muon
	li	$v0, 4
	la	$a0, msg5
	syscall
	la	$v0, 12
	syscall			# v0 = "Y"es or "N"o
checkRepeat:		
	addi	$t2, $0, 89	# t2 = 'Y'
	beq	$v0, $t2, main
	nop
	addi	$t2, $t2, 32	# t2 = 'y'
	beq	$v0, $t2, main
	nop		
	addi	$t2, $0, 78	# t2 = 'N'
	beq	$v0, $t2, quit
	nop
	addi	$t2, $t2, 32	# t2 = 'n'
	beq	$v0, $t2, quit
	nop		
	j	repeatMain 
quit:
	li 	$v0, 10
	syscall
#--------------------------------------------------------
# Set almost all registers to zero
# Ly do: Trong mot so truong hop, khi nguoi dung chon tiep tuc kiem tra,
# neu thanh ghi van luu gia tri tu lan kiem tra lenh truoc do thi co the xay ra
# xung dot khien lan kiem tra lenh tiep theo dua ra ket qua khong dung.
#--------------------------------------------------------
refresh:
    	addi 	$at, $at, 0        # Set $at register to 0
    	addi 	$v0, $v0, 0        # Set $v0 register to 0
    	addi 	$v1, $v1, 0        # Set $v1 register to 0
    	addi 	$a0, $a0, 0        # Set $a0 register to 0
    	addi 	$a1, $a1, 0        # Set $a1 register to 0
    	addi 	$a2, $a2, 0        # Set $a2 register to 0
    	addi 	$a3, $a3, 0        # Set $a3 register to 0
    	addi 	$t0, $t0, 0        # Set $t0 register to 0
    	addi 	$t1, $t1, 0        # Set $t1 register to 0
    	addi 	$t2, $t2, 0        # Set $t2 register to 0
    	addi 	$t3, $t3, 0        # Set $t3 register to 0
    	addi 	$t4, $t4, 0        # Set $t4 register to 0
   	addi 	$t5, $t5, 0        # Set $t5 register to 0
    	addi 	$t6, $t6, 0        # Set $t6 register to 0
    	addi 	$t7, $t7, 0        # Set $t7 register to 0
    	addi 	$s0, $s0, 0        # Set $s0 register to 0
    	addi 	$s1, $s1, 0        # Set $s1 register to 0
    	addi 	$s2, $s2, 0        # Set $s2 register to 0
    	addi 	$s3, $s3, 0        # Set $s3 register to 0
    	addi 	$s4, $s4, 0        # Set $s4 register to 0
   	addi 	$s5, $s5, 0        # Set $s5 register to 0
    	addi 	$s6, $s6, 0        # Set $s6 register to 0
    	addi 	$s7, $s7, 0        # Set $s7 register to 0
    	addi 	$t8, $t8, 0        # Set $t8 register to 0
    	addi 	$t9, $t9, 0        # Set $t9 register to 0
    	addi 	$k0, $k0, 0        # Set $k0 register to 0
    	addi 	$k1, $k1, 0        # Set $k1 register to 0
    	addi 	$fp, $fp, 0        # Set $fp register to 0
    	jr	$ra
#--------------------------------------------------------	
# tach toan hang, opcode tu chuoi dau vao
# a0 address input, a1 i-> dem tmp. a2 address tmp
# v0 i = i+ strlen(tmp), v1 strlen(tmp)
#--------------------------------------------------------
cutComponent:
	addi	$sp, $sp, -20 		# Con tro stack
	sw	$ra, 16($sp) 		# Luu gia tri $ra
	sw	$s0, 12($sp) 		# Dia chi cua input
	sw	$s2, 8($sp)		# j
	sw	$s3, 4($sp) 		# input[i]
	sw	$s4, 0($sp) 		# dau phay 
	addi	$s0, $zero, 32		# space
	addi	$t2, $zero, 10 		# newline
	addi	$s4, $zero, 44 		# dau phay 
	addi	$t3, $zero, 9 		# \tab
checkSpace: 	# bo qua , \t space
	add	$t0, $a0, $a1 		# dia chi input[i]
	lb	$s3, 0($t0) 		# Luu gia cua input[i] vao thanh ghi $s3
	beq	$s3, $s0, cutSpace 	# so sanh ki tu voi space, neu dung nhay den cutSpace
	beq	$s3, $t3, cutSpace 	# so sanh voi tab, neu dung nhay den cutSpace 
	beq	$s3, $s4, cutSpace 	# so sanh voi dau phay, neu dung nhay den cutSpace
	j	cut
cutSpace: 	# neu nguoi nhap vao dau dong la ("space","xuong dong",",") se bi bo qua 
	addi	$a1, $a1, 1 		# dia chi cong them 1 
	j	checkSpace
cut:
	add	$s2, $zero, $zero 	# j = 0
loopCut:
	beq	$s3, $s0, endCut 	# space
	beq	$s3, $s4, endCut 	# dau phay
	beq	$s3, $zero, endCut 	# 0
	beq	$s3, $t2, endCut 	# xuong dong moi
	beq	$s3, $t3, endCut 	# tab
	add	$t0, $a2, $s2 		# dia chi tmp[j]
	sb	$s3, 0($t0)		# luu gia tri thanh ghi s3 vao tmp[j]
	addi	$a1, $a1, 1 		# tang dia chi cua input len 1 
	add	$t0, $a0, $a1 		# dia chi input[i]
	lb	$s3, 0($t0) 		# Luu gia tri cua input[i] vao thanh ghi $s3	
	addi	$s2, $s2, 1 		# tang dia chi cua tmp len 1 
	j	loopCut
endCut:
	add	$t0, $a2, $s2 		# dia chi tmp[j]
	sb	$zero, 0($t0) 		# luu tmp[j] = '\0'
	add	$v0, $a1, $zero 	# so ki tu cat duoc 
	add	$v1, $s2, $zero 	# so ki tu cat duoc
	lw	$ra, 16($sp) 		# Luu gia tri tu ram vao thanh ghi $ra de nhay quay lai 
	lw	$s0, 12($sp) 		# Luu lai dia chi input vao thanh ghi $s0
	lw	$s2, 8($sp) 		# Tra lai gia tri cho thanh ghi $s2
	lw	$s3, 4($sp) 		# Tra lai gia tri cho thanh ghi $s3
	lw	$s4, 0($sp) 		# Tra lai gia tri cho thanh ghi $s4
	addi	$sp, $sp, 20 		# Tra lai dia chi ban dau cho thanh ghi $sp
	jr	$ra
#--------------------------------------------------------
# so sanh toan hang, opcode voi toan hang, opcode chuan
# a0 address tmp, a1 strlen(tmp), a2 adress cua chuoi opcode, register chuan
# v0 0|1, v1 count vi tri cua opcode
#--------------------------------------------------------
compareOpcode:
	addi	$sp, $sp, -24
	sw	$ra, 20($sp)
	sw	$s1, 16($sp) 		# i -> opcode
	sw	$s2, 12($sp) 		# j -> tmp
	sw	$s3, 8($sp) 		# tmp[j]
	sw	$s4, 4($sp)		# luu opcode[i]
	sw	$s5, 0($sp) 		# - 45	
	beq	$a1, $zero, endCmp
	add	$s1, $zero, $zero
	add	$s2, $zero, $zero
	addi	$s5, $zero, 45
	addi	$v0, $zero, 1
	addi	$v1, $zero, 1
loopCmp:
	add	$t0, $a2, $s1 		# dia chi opcode[i]
	lb	$s4, 0($t0) 		# luu opcode[i]
	beq	$s4, $s5, checkCmp
	beq	$s4, $zero, endCmp
	add	$t0, $a0, $s2 		# dia chi tmp[j]
	lb	$s3, 0($t0) 		# luu tmp[j]
# if UPCASE OPCODE and $REGISTER are accepted, uncomment these lines
	#blt	$s3, 'A', loopCmp1
	#nop
	#bgt	$s3, 'Z', loopCmp1	
	#nop
	#addi	$s3, $s3, 32		# chuan hoa ky tu
#loopCmp1:
	bne	$s3, $s4, falseCmp 	# Khac nhau se nhay den falseCmp	
	addi	$s1, $s1, 1
	addi	$s2, $s2, 1
	j	loopCmp
checkCmp:
	bne	$a1, $s2, falseCmp
trueCmp:
	addi	$v0, $zero, 1
	j	endF
falseCmp:
	addi	$v0, $zero, 0
	addi	$s2, $zero, 0
loopXspace:
	beq	$s4, $s5, Xspace
	addi	$s1, $s1, 1
	add	$t0, $a2, $s1 		# dia chi opcode[i]
	lb	$s4, 0($t0) 		# luu opcode[i]
	j	loopXspace
Xspace:
	add	$v1, $v1, 1
	addi	$s1, $s1, 1
	j	loopCmp
endCmp:
	addi	$v0, $zero, 0
endF:	
	addi	$v1, $v1, -1
	lw	$ra, 20($sp)
	lw	$s1, 16($sp)
	lw	$s2, 12($sp)
	lw	$s3, 8($sp) 
	lw	$s4, 4($sp)	
	lw	$s5, 0($sp)
	addi	$sp, $sp, 24
	jr	$ra
#--------------------------------------------------------
# lay khuon dang toan hang ung voi opcode
# a0 address chuoi operand - vi tri tuong ung voi opcode, a1 count
# tra ve chuoi opcode tuong ung o tmp2 
#--------------------------------------------------------
getOperand: 
	addi	$sp, $sp, -20
	sw	$s0, 16($sp) 		# i
	sw	$s1, 12($sp) 		# op[i]
	sw	$s2, 8($sp) 		# 45
	sw	$s3, 4($sp) 		# address tmp2
	sw	$s4, 0($sp)		# j

	addi	$t0, $zero, 4 		# moi khuon dang chiem 4 byte
	mul	$s0, $a1, $t0 		# i hien tai
	addi	$s2, $zero, 45 		# -
	la	$s3, tmp2 
	add	$s4, $zero, $zero 	# j
loopGet:	
	add	$t0, $a0, $s0 		# dia chi op
	lb	$s1, 0($t0)
	beq	$s1, $s2, endGet 	# gap - -> out
	add	$t0, $s3, $s4 		# dia chi tmp[i]
	sb	$s1, 0($t0)
	
	addi	$s0, $s0, 1
	addi	$s4, $s4, 1
	j	loopGet
endGet:
	add	$t0, $s3, $s4 		# dia chi tmp[i]
	sb	$zero, 0($t0)
	lw	$s0, 16($sp) 		# i
	lw	$s1, 12($sp) 		# op[i]
	lw	$s2, 8($sp)
	lw	$s3, 4($sp)
	lw	$s4, 0($sp)
	addi	$sp, $sp, 20
	jr 	$ra
#--------------------------------------------------------
# kiem tra chuoi tmp co la so hay ko -> 0 -> sai, 1-> dung
# a0 address tmp, a1 strlen(tmp)
# v0 0|1
#--------------------------------------------------------
checkNumber:
	add	$sp, $sp, -24
	sw	$ra, 20($sp)
	sw	$s4, 16($sp) 		# +
	sw	$s3, 12($sp) 		# -
	sw	$s0, 8($sp)
	sw	$s1, 4($sp)
	sw	$s2, 0($sp) 		# 1
	add	$v0, $zero, 0
	add	$s0, $zero, $zero 	# bien dem i	
	beq	$a1, $zero, endCheckN
checkFirstN: 	# Ky tu dau tien kieu number co the la Plus(+), Minus(-)
	addi 	$s3, $zero, 45 		# -
	addi	$s4, $zero, 43 		# +
	addi	$s2, $zero, 1
	add	$t0, $a0, $s0 		# toanhang[i]
	lb	$s1, 0($t0)	
checkMinus: 
	bne	$s1, $s3, checkPlus
	beq	$a1, $s2, endCheckN
	j	update
checkPlus:
	bne	$s1, $s4, _123
	beq	$a1, $s2, endCheckN
	j	update	
checkI:
	slt	$t0, $s0, $a1
	beq	$t0, $zero, trueN
	add	$t0, $a0, $s0 		# toanhang[i]
	lb	$s1, 0($t0)
_123: 	# Kiem tra tu 0 -> 9
	slti	$t0, $s1, 48
	bne	$t0, $zero, endCheckN
	slti	$t0, $s1, 58
	beq	$t0, $zero, endCheckN
update:
	addi	$s0, $s0, 1
	j	checkI
trueN:
	addi	$v0, $v0, 1
endCheckN:
	lw	$ra, 20($sp)
	lw	$s4, 16($sp) 		# +
	lw	$s3, 12($sp) 		# -
	lw	$s0, 8($sp)
	lw	$s1, 4($sp)
	lw	$s2, 0($sp)
	add	$sp, $sp, 24
	jr	$ra
#--------------------------------------------------------
# kiem tra chuoi tmp co la hexadecimal hay ko, dinh dang 0x___
# a0 -> address tmp, a1 strlen(tmp)
# v0 0|1 
#--------------------------------------------------------
checkHex:
	add	$sp, $sp, -12
	sw	$ra, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	add	$v0, $zero, 0
	add	$s0, $zero, $zero 	# bien dem i
	blt	$a1, 3, endCheckHex
	bgt	$a1, 10, endCheckHex
check_0:
	add	$t0, $a0, $s0 		# toanhang[i]
	lb	$s1, 0($t0)
	beq 	$s1, '0', check_x
	j	endCheckHex
check_x:
	addi	$s0, $s0, 1
	add	$t0, $a0, $s0 		# toanhang[i]
	lb	$s1, 0($t0)
	beq	$s1, 'x', checkIH
	beq	$s1, 'X', checkIH
	j	endCheckHex
checkIH:
	add	$s0, $s0, 1
	slt	$t0, $s0, $a1
	beq	$t0, $zero, trueHex
	add	$t0, $a0, $s0 		# toanhang[i] 
	lb	$s1, 0($t0)	
	blt 	$s1, '0', endCheckHex
    	bgt 	$s1, 'f', endCheckHex
    	ble 	$s1, '9', checkIH
    	bge 	$s1, 'a', checkIH
    	blt 	$s1, 'A', endCheckHex
    	bgt 	$s1, 'F', endCheckHex
    	j	checkIH
trueHex:
	addi	$v0, $v0, 1
endCheckHex:
	sw	$ra, 8($sp)
	lw	$s1, 4($sp)
	lw	$s0, 0($sp)
	add	$sp, $sp, 12
	jr	$ra
#--------------------------------------------------------
# kiem tra chuoi tmp co la Label hay ko, ki tu dau tien: _ | A -> _ | A | 1 
# a0 -> address tmp, a1 strlen(tmp)
# v0 0|1 
#--------------------------------------------------------
checkLabel:
	add	$sp, $sp, -12
	sw	$ra, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	add	$v0, $zero, 0
	add	$s0, $zero, $zero 	# bien dem i
	beq	$a1, $zero, endCheckL
checkFirstChar:
	add	$t0, $a0, $s0 		# toanhang[i]
	lb	$s1, 0($t0)
	j	ABC	
checkIL:
	slt	$t0, $s0, $a1
	beq	$t0, $zero, trueL
	add	$t0, $a0, $s0 		# toanhang[i]
	lb	$s1, 0($t0)
_123L: 	# 48 -> 57
	slti	$t0, $s1, 48
	bne	$t0, $zero, endCheckL
	slti	$t0, $s1, 58
	beq	$t0, $zero, ABC
	addi	$s0, $s0, 1
	j	checkIL
ABC: 	# 65 -> 90
	slti	$t0, $s1, 65
	bne	$t0, $zero, endCheckL
	slti	$t0, $s1, 91
	beq	$t0, $zero, _
	addi	$s0, $s0, 1
	j	checkIL
_:
	add	$t0, $zero, 95
	bne	$s1, $t0, abc
	addi	$s0, $s0, 1
	j	checkIL
abc: 	#97  -> 122
	slti	$t0, $s1, 97
	bne	$t0, $zero, endCheckL
	slti	$t0, $s1, 123
	beq	$t0, $zero, endCheckL
	addi	$s0, $s0, 1
	j	checkIL
trueL:
	addi	$v0, $v0, 1
endCheckL:
	sw	$ra, 8($sp)
	lw	$s1, 4($sp)
	lw	$s0, 0($sp)
	add	$sp, $sp, 12
	jr	$ra
#--------------------------------------------------------
# kiem tra chuoi tmp co dung cau truc offset(base) hay khong 
# a0 -> address tmp, a1 strlen(tmp)
# v0 0|1 
#--------------------------------------------------------
	# a0, tmp a1 strlen
checkOffsetBase: 
	# offset(base) -> offset_base_		
	add	$sp, $sp, -28
	sw	$ra, 24($sp)
	sw	$s5, 20($sp) 		# so ki cut dk
	sw	$s4, 16($sp) 		# )
	sw	$s3, 12($sp) 		# (
	sw	$s2, 8($sp) 		# check
	sw	$s1, 4($sp)		# tmp[i]
	sw	$s0, 0($sp) 		# bien dem i
checkO:
	slti	$t0, $a1, 5 		# it nhat 5 ki tu, vd: 0($9)
	bne	$t0, $zero, falseCheck
	addi	$s3, $zero, 40
	addi	$s4, $zero, 41
	add	$s0, $zero, $zero 	# i
	add	$s2, $zero, $zero 	# check
	addi	$t2, $zero, 1
loopCheck:
	add	$t0, $a0, $s0 		# dia chi tmp[i]
	lb	$s1, 0($t0)
	beq	$s1, $zero, endLoopO
	beq	$s1, $s3, open_
	beq	$s1, $s4, close_
	j	updateO
open_:
	bne	$s2, $zero, falseCheck
	addi	$s2, $s2, 1
	addi	$t1, $zero, 32
	sb	$t1, 0($t0)
	j	updateO
close_:
	bne	$s2, $t2, falseCheck
	addi	$s2, $s2, 1
	sb	$zero, 0($t0)	
	addi	$s0, $s0, 1
	bne	$s0, $a1, falseCheck	
updateO:
	addi	$s0, $s0, 1
	j	loopCheck
endLoopO:
	addi	$t2, $t2, 1 	# =2
	bne	$s2, $t2, falseCheck
trueCheck:
	add	$s0, $zero, $zero # i
	# cut
	sw	$a0, -8($sp)
	sw	$a1, -4($sp)	
	la	$a0, tmp
	add	$a1, $s0, $zero
	la	$a2, tmp3
	jal	cutComponent
	add	$s0, $v0, $zero
	add	$s5, $v1, $zero # so ky tu co trong cutword
	lw	$a0, -8($sp)
	lw	$a1, -4($sp)
	# check number
	sw	$a0, -8($sp)
	sw	$a1, -4($sp)
	la	$a0, tmp3
	add	$a1, $s5, $zero
	jal 	checkNumber
	bne	$v0, $0, trueOffset
	jal	checkHex
	bne	$v0, $0, trueOffset
	jal	checkLabel
trueOffset:
	add	$s2, $v0, $0
	lw	$a0, -8($sp)
	lw	$a1, -4($sp)
	beq	$s2, $zero, falseCheck
	# cut
	sw	$a0, -8($sp)
	sw	$a1, -4($sp)	
	la	$a0, tmp
	add	$a1, $s0, $zero
	la	$a2, tmp3
	jal	cutComponent
	add	$s0, $v0, $zero
	add	$s5, $v1, $zero # so ky tu co trong cutword	
	lw	$a0, -8($sp)
	lw	$a1, -4($sp)
	# checkReg
	sw	$a0, -8($sp)
	sw	$a1, -4($sp)
	sw	$a2, -16($sp)
	la	$a0, tmp3
	add	$a1, $s5, $zero
	la	$a2, register
	# tra ve 0 -> error, 1 -> ok
	jal	compareOpcode
	add	$s2, $v0, $zero
	lw	$a0, -8($sp)
	lw	$a1, -4($sp)
	lw	$a2, -12($sp)
	beq	$s2, $zero, falseCheck
	# -> ket luan
	addi	$v0, $zero, 1
	j	endO
falseCheck:
	add	$v0, $zero, $zero
	j	endO
endO:
	lw	$ra, 24($sp)
	lw	$s5, 20($sp) # so ki cut dk
	lw	$s4, 16($sp) 
	lw	$s3, 12($sp) 
	lw	$s2, 8($sp)
	lw	$s1, 4($sp)
	lw	$s0, 0($sp)
	add	$sp, $sp, 28
	jr	$ra
