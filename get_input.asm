#----------------------------------------------------------
# File: $Id$
# Author: Ryan Cervantes (rxc3202@rit.edu)
# Description:
#               This file contains the subroutines that gets the input from the
#               user in order to run the program
#----------------------------------------------------------

# ===================
# || syscall codes ||
# ===================

PRINT_INT =	1
PRINT_STRING = 	4
READ_INT = 	5
READ_STRING =	8

# ===================

# ==========================
# || param block constants||
# ==========================

CELL_FRAMESIZE = 24
BOARD_DIM = 0
GENS = 4
A_CELLS = 8
B_CELLS = 12
NEXT_A = 16
NEXT_B  = 20
A_ARR = 24
B_ARR = 28

        .text
        .align      2
        .globl      get_integer
        .globl      get_A_cells
        .globl      get_B_cells

# ===================================================================
# Name:             get_integer
# ===================================================================
# Description:      This function loads the user input for
#                   the single integer parameters
# Parameters:                         
#       a0 -        the location where the input will be stored
#       a1 -        the lower bound
#       a2 -        the upper bound
#       a3 -        the location of the error message
# ===================================================================

get_integer:
        addi    $sp, $sp, -8                       
        sw      $ra, 4($sp)
        sw      $s0, 0($sp)                         #store s register

get_int_loop:

        li      $v0, READ_INT                       #read int
        syscall        
        
        slt     $t0, $v0, $a1                       #if(input < lower)
        slt     $t1, $a2, $v0                       #if(input > upper
        or      $t2, $t0, $t1                      
        beq     $t2, $zero,integer_store
        
        move    $s0, $a0                            #save int addr
        move    $a0, $a3                            
        li      $v0, PRINT_STRING
        syscall                                     #print error
        move    $a0, $s0                            #restore int addr
        j       get_int_loop
        


integer_store:
        sw      $v0, 0($a0)                         #store in variable

        lw      $ra, 4($sp)
        lw      $s0, 0($sp)                         #restore s register 
        addi    $sp, $sp, 8
        jr      $ra

# ===================================================================
# Name:             get_A_cells:
# ===================================================================
# Description:      This function loads the user input for the
#                   locations of the live cells for colony A
#                   
# Parameters:                         
#       a0 -        addr the parameter block
#       a1 -        the location of the illegal string
#       a2 -        addr of the copy array
# S Registers:
#       s0 -        the loop max (2xcells to place)
#       s1 -        the loop counter
#       s2 -        the location of the coord buffer
#       s3 -        the location of the copy buffer
#
# T Registers:
#       t0 -        end loop register
#       t1 -        temp for row coordinate
#       t2 -        temp for col coordinate
#
# ===================================================================

get_A_cells:
        addi    $sp, $sp, -CELL_FRAMESIZE
        sw      $ra, -4+CELL_FRAMESIZE($sp)
        sw      $s0, -8+CELL_FRAMESIZE($sp)       
        sw      $s1, -12+CELL_FRAMESIZE($sp)                       
        sw      $s2, -16+CELL_FRAMESIZE($sp)                       
        sw      $s3, -20+CELL_FRAMESIZE($sp)

        lw      $t3, BOARD_DIM($a0)                 
        lw      $t3, 0($t3)
        
        lw      $s0, A_CELLS($a0)                   #load addr of cell cnt
        lw      $s0, 0($s0)                         #load int inside addr 
    
        lw      $s2, NEXT_A($a0)                    #load addr of loc buf
        lw      $s2, 0($s2)                         #load addr of next el.
        
        move    $s3, $a2 
        move    $s1, $zero                          #i = 0
        
loc_loop_A:
        slt     $t0, $s1, $s0                       #if(i < max)
        beq     $t0, $zero, A_cells_end             #goto end
        
        # get row coordinate # 

        li      $v0, READ_INT
        syscall
        move    $t1, $v0

        # get col coordinate # 

        li      $v0, READ_INT
        syscall
        move    $t2, $v0

        # check valid x #
        slt     $t9, $t1, $zero                     #if(in < 0) set t9
        bne     $t9, $zero, get_A_error
        slt     $t8, $t1, $t3                       #if(in >= dim set t8
        beq     $t8, $zero, get_A_error

        # check valid y #
        slt     $t9, $t2, $zero                     #if(in < 0) set t9
        bne     $t9, $zero, get_A_error
        slt     $t8, $t2, $t3                       #if(in >= dim set t8
        beq     $t8, $zero, get_A_error

        # place into array #                        # 2 values placed in

        sw      $t1, 0($s2)                         # 0($s2) = x value
        sw      $t2, 4($s2)                         # 4($s2) = y value
        addi    $s2, $s2, 8                         # increment pointer

        sw      $t1, 0($s3)                         # 0($s2) = x value
        sw      $t2, 4($s3)                         # 4($s2) = y value
        addi    $s3, $s3, 8                         # increment pointer

        # increment loop counter #

        addi    $s1, $s1, 1
        j       loc_loop_A

get_A_error:
        move    $a0, $a1
        li      $v0, PRINT_STRING
        syscall

        # return false
        li      $v0, 0
        j       err_end_A

A_cells_end:
        li      $v0, 1

err_end_A:
        lw      $ra, -4+CELL_FRAMESIZE($sp)
        lw      $s0, -8+CELL_FRAMESIZE($sp)       
        lw      $s1, -12+CELL_FRAMESIZE($sp)                       
        lw      $s2, -16+CELL_FRAMESIZE($sp)                       
        lw      $s3, -20+CELL_FRAMESIZE($sp)
        addi    $sp, $sp, CELL_FRAMESIZE
        
        jr      $ra
        
# ===================================================================
# Name:             get_B_cells:
# ===================================================================
# Description:      This function loads the user input for the
#                   locations of the live cells for colony B
#                   
# Parameters:                         
#       a0 -        the parameter block
#       a1 -        the addr of error string
#       a2 -        the addr of the copy buffer
# S Registers:
#       s0 -        the loop max (2xcells to place)
#       s1 -        the loop counter
#       s2 -        the location of the location buffer
#       s3 -        the location of the copy location buffer
#
# T Registers:
#       t0 -        end loop register
#
# ===================================================================

get_B_cells:
        addi    $sp, $sp, -CELL_FRAMESIZE
        sw      $ra, -4+CELL_FRAMESIZE($sp)
        sw      $s0, -8+CELL_FRAMESIZE($sp)       
        sw      $s1, -12+CELL_FRAMESIZE($sp)                       
        sw      $s2, -16+CELL_FRAMESIZE($sp)                       
        sw      $s3, -20+CELL_FRAMESIZE($sp)

        lw      $t3, BOARD_DIM($a0)                 #get dim to compare
        lw      $t3, 0($t3)
        
        lw      $s0, B_CELLS($a0)                   #load addr of cell cnt
        lw      $s0, 0($s0)                         #load int inside addr 
    
        lw      $s2, NEXT_B($a0)                    #load addr of loc buf
        lw      $s2, 0($s2)                         #load addr of next el.
        
        move    $s1, $zero                          #i = 0
        move    $s3, $a2


loc_loop_B:
        slt     $t0, $s1, $s0
        beq     $t0, $zero, B_cells_end
        
        # get row coordinate # 

        li      $v0, READ_INT
        syscall
        move    $t1, $v0

        # get col coordinate # 

        li      $v0, READ_INT
        syscall
        move    $t2, $v0

        # check valid y #
        slt     $t9, $t1, $zero                     #if(in < 0) set t9
        bne     $t9, $zero, get_B_error
        slt     $t8, $t1, $t3                       #if(in > dim set t8
        beq     $t8, $zero, get_B_error

        # check valid x #
        slt     $t9, $t2, $zero                     #if(in < 0) set t9
        bne     $t9, $zero, get_B_error
        slt     $t8, $t2, $t3                       #if(in > dim set t8
        beq     $t8, $zero, get_B_error

        addi    $sp, $sp, -8
        sw      $a1, 0($sp)
        sw      $a2, 4($sp)
        
        move    $a1, $t1
        move    $a2, $t2
        jal     check_duplicates

        lw      $a1, 0($sp)
        lw      $a2, 4($sp)
        addi    $sp, $sp, 8

        beq     $v0, $zero, get_B_error


        # place into array #                        # 2 values placed in

        sw      $t1, 0($s2)                         # 0($s2) = x value
        sw      $t2, 4($s2)                         # 4($s2) = y value
        addi    $s2, $s2, 8                         # increment pointer

        sw      $t1, 0($s3)                         # 0($s3) = x value
        sw      $t2, 4($s3)                         # 4($s3) = y value
        addi    $s3, $s3, 8                         # increment pointer

        # increment loop counter #
        addi    $s1, $s1, 1
        j       loc_loop_B

get_B_error:
        move    $a0, $a1
        li      $v0, PRINT_STRING
        syscall

        li      $v0, 0
        j       err_end_B

B_cells_end:
        li      $v0, 1

err_end_B:
        lw      $ra, -4+CELL_FRAMESIZE($sp)
        lw      $s0, -8+CELL_FRAMESIZE($sp)       
        lw      $s1, -12+CELL_FRAMESIZE($sp)                       
        lw      $s2, -16+CELL_FRAMESIZE($sp)                       
        lw      $s3, -20+CELL_FRAMESIZE($sp)
        addi    $sp, $sp, CELL_FRAMESIZE
        jr      $ra


# ===================================================================
# Name:             check_duplicates
# ===================================================================
# Description:      function checks if there is a duplicate value
#                 
#                   
# Parameters:                         
#       a0 -        the parameter block
#       a1 -        the row coordinate
#       a2 -        the col coordinate
# S Registers:
#       s0 -        the num of a_cels
#       s1 -        the addr of the a_coordinate array
#       s2 -        the loop counter
#
# T Registers:
#
# ===================================================================

check_duplicates:
        addi    $sp, $sp, -16
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)
        sw      $s1, 8($sp)
        sw      $s2, 12($sp)
        
        lw      $s0, A_CELLS($a0)                   #load addr of cell cnt
        lw      $s0, 0($s0)                         #load int inside addr 

        lw      $s1, A_ARR($a0)
        #lw      $s1, 0($s1)

        move    $s2, $zero

duplicate_loop:
        slt     $t9, $s2, $s0                       # while(i < a_cells)
        beq     $t9, $zero, check_dup_end           # {
        
        mul     $t9, $s2, 8                         # offset = size(coor)*idx
        add     $t9, $s1, $t9                       # a_arr[i] base + offset
        lw      $t7, 0($t9)                         # get row
        lw      $t8, 4($t9)                         # get col

        beq     $t7, $a1, two_match
        j       dup_loop_end

two_match:
        beq     $t8, $a2, return_false              #if(row match) check col
        j       dup_loop_end                        # else next iteration

dup_loop_end:
        addi    $s2, $s2, 1
        j       duplicate_loop

return_false:
        move    $v0, $zero                          # there is duplicate
        j       dup_end_err
        
check_dup_end:
        li      $v0, 1                              # return no duplicates

dup_end_err:
        lw      $ra, 0($sp)
        lw      $s0, 4($sp)
        lw      $s1, 8($sp)
        lw      $s2, 12($sp)
        addi    $sp, $sp, 16
        jr      $ra


