# File: $Id$
# Author: Ryan Cervantes (rxc3202@rit.edu)
# Description: this file is the main file for the
#               cs250 project



###########################################
# ======================================= #
# ||        CONSTANTS BLOCK            || #
# ======================================= #
###########################################

# ===========================
# || param block constants ||
# ===========================

DIM_OFFSET = 0
GEN_OFFSET = 4
A_OFFSET = 8
B_OFFSET = 12
NEXT_A_OFFSET = 16
NEXT_B_OFFSET = 20
A_ARRAY_OFFSET = 24
B_ARRAY_OFFSET = 28

# syscall codes

PRINT_INT =	1
PRINT_STRING = 	4
READ_INT = 	5
READ_STRING =	8

# various frame sizes used by different routines

FRAMESIZE_8 = 	8
FRAMESIZE_24 =	24
FRAMESIZE_40 =	40
FRAMESIZE_48 =	48

        .data
        .align      2

# ====================
#    INPUT STRINGS 
# ====================

enter_board_size:
        .asciiz "\nEnter board size: "

enter_generations: 
        .asciiz "\nEnter number of generations to run: "

live_cells_A:
        .asciiz "\nEnter number of live cells for colony A: "

live_cells_B:
        .asciiz "\nEnter number of live cells for colony B: "

enter_locations:
        .asciiz "\nStart entering locations: \n"

# ====================
#    OTHER STRINGS 
# ====================

banner:
        .ascii "\n**********************\n"
        .ascii "****    Colony    ****\n"
        .asciiz "**********************\n"

gen_banner_start:
        .asciiz "====    GENERATION "

gen_banner_end:
        .asciiz "    ====\n"

newline: 
        .asciiz "\n"

space:
        .asciiz " "

# ====================
#    ERROR STRINGS 
# ====================

illegal_size:
        .asciiz "\nWARNING: illegal board size, try again: "

illegal_gens:
        .asciiz "\nWARNING: illegal number of generations, try again: "

illegal_cells:
        .asciiz "\nWARNING: illegal number of live cells, try again: "

illegal_point:
        .asciiz "\nWARNING: illegal point location: "

# ====================
#    DEBUG STRINGS  
# ====================

d_dim:
        .asciiz "\n Board Dimensions: "

d_gen:
        .asciiz "\n Generations: "

d_a_cells:
        .asciiz "\n Colony A Cells: "

d_b_cells:
        .asciiz "\n Colony B Cells: "

d_a_loc:
        .asciiz "\n A Coordinates: "

d_b_loc:
        .asciiz "\n B Coordinates: "

lp:
        .asciiz "("
comma:
        .asciiz ", "
rp:
        .asciiz ")"

# ====================
#    BOARD STRINGS  
# ====================

plus:
        .asciiz "+"

hyphen:
        .asciiz "-"

bar:
        .asciiz "|"

A:
        .asciiz "A"
B:
        .asciiz "B"

# ====================
#     GAME BUFFERS
# ====================
# These addresses will hold the values read in by the user
# if a negative one is detected in a register, the value will
# be known to not be read in correctly

board_dim:
        .word       -1

generations:
        .word       -1

A_cells:
        .word       -1

B_cells:
        .word       -1

a_next:
        .word       a_coordinates

a_coordinates:                                          
        .space      7200                            #space for 300 x's
        .align      2

b_next:
        .word       b_coordinates

b_coordinates:
        .space      7200                            #space for 300 y's
        .align      2

param_block:
        #   === 32 byte structure ===   #
        .word       board_dim                       #0 offset
        .word       generations                     #4 offset
        .word       A_cells                         #8 offset
        .word       B_cells                         #12 offset
        .word       a_next                          #16 offset
        .word       b_next                          #20 offset
        .word       a_coordinates                   #24 offset
        .word       b_coordinates                   #28


###########################################
# ======================================= #
# ||        MAIN CODE BLOCK            || #
# ======================================= #
###########################################
        .text
        .align      2
        .globl      main
        .globl      get_integer
        .globl      get_A_cells
        .globl      get_B_cells

main:       
        addi    $sp, $sp, -FRAMESIZE_48
        sw      $ra, -4+FRAMESIZE_48($sp)
        
        li      $v0, PRINT_STRING                   #print banner
        la      $a0, banner
        syscall
        
        # ---------------------------- #
        #       Get user input         #
        # ---------------------------- #

        # print and get board dimensions #

        li      $v0, PRINT_STRING                    
        la      $a0, enter_board_size
        syscall
        
        la      $a0, board_dim 
        li      $a1, 4
        li      $a2, 30
        la      $a3, illegal_size
        jal     get_integer
        
        # print and get generations #

        li      $v0, PRINT_STRING                    
        la      $a0, enter_generations
        syscall
        
        la      $a0, generations
        li      $a1, 0
        li      $a2, 20
        la      $a3, illegal_gens
        jal     get_integer

        # print and get A colony size #

        li      $v0, PRINT_STRING                    
        la      $a0, live_cells_A
        syscall
        
        la      $a0, A_cells
        li      $a1, 0
        la      $a2, board_dim
        lw      $a2, 0($a2)
        mul     $a2, $a2, $a2                       #dim^2
        la      $a3, illegal_cells
        jal     get_integer

        # print and get A colony locations #

        li      $v0, PRINT_STRING                    
        la      $a0, enter_locations
        syscall
        
        la      $a0, param_block
        jal     get_A_cells

        # print and get B colony size #

        li      $v0, PRINT_STRING                    
        la      $a0, live_cells_B
        syscall
        
        la      $a0, B_cells
        li      $a1, 0
        la      $a2, board_dim
        lw      $a2, 0($a2)
        mul     $a2, $a2, $a2                       #dim^2
        la      $a3, illegal_cells
        jal     get_integer
        
        # print and get B colony locations #

        li      $v0, PRINT_STRING                    
        la      $a0, enter_locations
        syscall
        
        la      $a0, param_block
        jal     get_B_cells
        

        # == test input grabbing == #
        la      $a0, param_block
        jal     debug_params

end_main:
        lw          $ra, -4+FRAMESIZE_48($sp)
        addi        $sp, $sp, FRAMESIZE_48
        jr          $ra



###########################################
# ======================================= #
# ||        Helper Code                || #
# ======================================= #
###########################################

# =========================================================
# Name:             print_locations
# =========================================================
# Description:      prints an array of location "structs"
#                   each structure is 8 bytes long where:
#                       - 0 -> x coordinate
#                       - 4 offset -> y coordinate
#
# Parameters:
#       a0 -        the location of array to print
#       a1 -        the size of the array
#
# T Registers:
#       t0 -        loop counter
#     
# =========================================================
print_locations:
        li      $t0, 0                              # i == 0
        move    $t1, $a0                            # pointer

print_loop:
        beq     $t0, $a1, print_done                #done if i == n 

        la      $a0, newline
        li      $v0, PRINT_STRING                   #print \n
        syscall
        
        la      $a0, lp
        li      $v0, PRINT_STRING                   #print (
        syscall
        
        lw      $a0, 0($t1)                         #get a[i].x
        li      $v0, PRINT_INT
        syscall                                     #print a[i].x

        la      $a0, comma
        li      $v0, PRINT_STRING                   #print ,
        syscall
        
        lw      $a0, 4($t1)                         #get a[i].y
        li      $v0, PRINT_INT
        syscall                                     #print a[i].y
        
        la      $a0, rp
        li      $v0, PRINT_STRING                   #print )
        syscall
        
        addi    $t1, $t1, 8                         #update pointer
        addi    $t0, $t0, 1                         #i++
        j       print_loop

print_done:
        la      $a0, newline
        li      $v0, PRINT_STRING
        syscall
        
        jr      $ra

# =========================================================
# Name:             debug_params
# =========================================================
# Description:      print the inputs in the param block
#
# Parameters:
#       a0 -        the parameter block
# S Registers:
#       s0 -        the saved parameter block
# =========================================================
debug_params:
        
        addi    $sp, $sp, -8
        sw      $ra, 4($sp)
        sw      $s0, 0($sp)
        
        move    $s0, $a0                            #save param block

        # print board dimensions #

        li      $v0, PRINT_STRING
        la      $a0, d_dim
        syscall
        li      $v0, PRINT_INT
        lw      $a0, DIM_OFFSET($s0)
        lw      $a0, 0($a0)
        syscall

        # print generations #

        li      $v0, PRINT_STRING
        la      $a0, d_gen
        syscall
        li      $v0, PRINT_INT
        lw      $a0, GEN_OFFSET($s0)
        lw      $a0, 0($a0)                         #load val at 0(label)
        syscall

        # print colony A size #

        li      $v0, PRINT_STRING
        la      $a0, d_a_cells
        syscall
        li      $v0, PRINT_INT
        lw      $a0, A_OFFSET($s0)
        lw      $a0, 0($a0)                         #load val at 0(label)
        syscall

        # print locations #
        li      $v0, PRINT_STRING
        la      $a0, d_a_loc
        syscall

        #lw      $a0, A_ARRAY_OFFSET($s0)            #load addr of arr
        #lw      $a0, 0($a0)
        la      $a0, a_coordinates
        #lw      $a0, 0($a0)
        lw      $a1, A_OFFSET($s0)
        lw      $a1, 0($a1)
        jal     print_locations


        # print colony B size#

        li      $v0, PRINT_STRING
        la      $a0, d_b_cells
        syscall

        li      $v0, PRINT_INT
        lw      $a0, B_OFFSET($s0)
        lw      $a0, 0($a0)                         #load val at 0(label)
        syscall

        # print locations#
        li      $v0, PRINT_STRING
        la      $a0, d_b_loc
        syscall

        la      $a0, b_coordinates                  #get addr of arr
        lw      $a1, B_OFFSET($s0)                  #get addr of size
        lw      $a1, 0($a1)                         #get size
        jal     print_locations

        li      $v0, PRINT_STRING
        la      $a0, newline
        syscall
        
        lw      $ra, 4($sp)
        lw      $s0, 0($sp)
        addi    $sp, $sp, 8

        jr      $ra

