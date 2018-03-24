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
# ===================================================================
get_integer:
        addi    $sp, $sp, -8                       
        sw      $ra, 4($sp)
        sw      $s0, 0($sp)                         #store s register

        move    $s0, $a0                            
        li      $v0, READ_INT                       #read int
        syscall        
        sw      $v0, 0($s0)                         #store in variable

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
#       a0 -        the parameter block
# S Registers:
#       s0 -        the loop max (2xcells to place)
#       s1 -        the loop counter
#       s2 -        the location of the x buffer
#       s3 -        the location of the y buffer
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
        
        lw      $s0, A_CELLS($a0)                   #load addr of cell cnt
        lw      $s0, 0($s0)                         #load int inside addr 
    
        lw      $s2, NEXT_A($a0)                    #load addr of loc buf
        lw      $s2, 0($s2)                         #load addr of next el.
        
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

        # place into array #                        # 2 values placed in

        sw      $t1, 0($s2)                         # 0($s2) = x value
        sw      $t2, 4($s2)                         # 4($s2) = y value
        addi    $s2, $s2, 8                         # increment pointer

        # increment loop counter #

        addi    $s1, $s1, 1
        j       loc_loop_A

A_cells_end:

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
# S Registers:
#       s0 -        the loop max (2xcells to place)
#       s1 -        the loop counter
#       s2 -        the location of the x buffer
#       s3 -        the location of the y buffer
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
        


loc_loop_B:
        slt     $t0, $s1, $s0
        bne     $t0, $zero, B_cells_end
        
        # get row coordinate # 

        li      $v0, READ_INT
        syscall

        # get col coordinate # 

        li      $v0, READ_INT
        syscall

        # increment loop counter #

        addi    $s1, $s1, 1
        j       loc_loop_B

B_cells_end:

        lw      $ra, -4+CELL_FRAMESIZE($sp)
        lw      $s0, -8+CELL_FRAMESIZE($sp)       
        lw      $s1, -12+CELL_FRAMESIZE($sp)                       
        lw      $s2, -16+CELL_FRAMESIZE($sp)                       
        lw      $s3, -20+CELL_FRAMESIZE($sp)
        addi    $sp, $sp, CELL_FRAMESIZE
        jr      $ra

