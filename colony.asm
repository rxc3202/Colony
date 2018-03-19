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

_BOARD_DIM = 0
_GENS = 4
_A_CELLS = 8
_B_CELLS = 12
_NEXT_X = 16
_NEXT_Y  = 20

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
        .asciiz "\nStart entering locations: "

# ====================
#    OTHER STRINGS 
# ====================

banner:
        .ascii "\n**********************\n"
        .ascii "****    Colony    ****\n"
        .asciiz "**********************"

gen_banner_start:
        .asciiz "====    GENERATION "

gen_banner_end:
        .asciiz "    ====\n"

new_line: 
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

a_next_x:
        .word       x_coordinates

a_x_coordinates:                                          
        .space      3600                            #space for 300 x's

        .align      2

a_next_y:
        .word       y_coordinates

a_y_coordinates:
        .space      3600                            #space for 300 y's
        
        .align      2

b_next_x:
        .word       x_coordinates

b_x_coordinates:                                          
        .space      3600                            #space for 300 x's

        .align      2

b_next_y:
        .word       y_coordinates

b_y_coordinates:
        .space      3600                            #space for 300 y's
        
        .align      2

param_block:
        #   === 24 byte structure ===   #
        .word       board_dim                       #0 offset
        .word       generations                     #4 offset
        .word       A_cells                         #8 offset
        .word       B_cells                         #12 offset
        .word       a_next_x                        #16 offset
        .word       a_next_y                        #20 offset
        .word       b_next_x                        #24 offset
        .word       b_next_y                        #28 offset


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
        sw      $ra, -4+FRAMESIZE_48
        
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
        jal     get_integer
        
        # print and get generations #

        li      $v0, PRINT_STRING                    
        la      $a0, enter_generations
        syscall
        
        la      $a0, generations
        jal     get_integer

        # print and get A colony size #

        li      $v0, PRINT_STRING                    
        la      $a0, live_cells_A
        syscall
        
        la      $a0, A_cells
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
        jal     get_integer
        
        # print and get B colony locations #

        li      $v0, PRINT_STRING                    
        la      $a0, enter_locations
        syscall
        
        la      $a0, param_block
        jal     get_B_cells
        

        # == test input grabbing == #
        jal     print_debug

        

end_main
        lw          $ra, -4+FRAMESIZE_48
        addi        $sp, $sp, -FRAMESIZE_48 








###########################################
# ======================================= #
# ||        Helper Code                || #
# ======================================= #
###########################################

# =========================================================
# Name:             print_array
# =========================================================
# Description:      prints an array of integers
#
# Parameters:
#       a0 -        the array to print
#       a1 -        the size of the array
#
# T Registers:
#       t0 -        loop counter
#     
# =========================================================
print_array:
        li      $t0, 0                              # i == 0
        move    $t1, $a0                            # pointer

print_loop:
        beq     $t0, $a1, print_done                #done if i == n
        
        lw      $a0, 0($t1)                         #get a[i]
        li      $v0, PRINT_INT
        syscall                                     #print a[i]
        
        la      $a0, space
        li      $v0, PRINT_STRING                   #print space
        
        addi    $t1, $t1, 4                         #update pointer
        addi    $t0, $t0, 1                         #i++
        j       print_loop

print_done:
        la      $a0, newline
        li      $v0, PRINT_STRING
        syscall
        
        jr      $ra

# =========================================================
# Name:             print_params
# =========================================================
# Description:      print the inputs in the param block
#
# Parameters:
#       a0 -        the parameter block
# S Registers:
#       s0 -        the saved parameter block
# =========================================================
debug_params:
        move    $s0, $a0                            #save param block

        # print board dimensions #

        li      $v0, PRINT_STRING
        la      $a0, d_dim
        syscall
        li      $v0, PRINT_INT
        lw      $a0, _BOARD_DIM($s0)
        syscall

        # print generations #

        li      $v0, PRINT_STRING
        la      $a0, d_gen
        syscall
        li      $v0, PRINT_INT
        lw      $a0, _GENS($s0)
        syscall

        # print colony A size #

        li      $v0, PRINT_STRING
        la      $a0, d_a_cells
        syscall
        li      $v0, PRINT_INT
        lw      $a0, _A_CELLS($s0)
        syscall

        # print locations #
        li      $v0, PRINT_STRING
        la      $a0, d_a_loc
        syscall

        la      $a0, a_x_coordinates       
        sw      $a1, _A_CELLS($s0)
        jal     print_array


        # print colony B size#

        li      $v0, PRINT_INT
        la      $a0, d_b_cells
        syscall
        li      $v0, PRINT_INT
        lw      $a0, _B_CELLS($s0)
        syscall

        # print locations#
        li      $v0, PRINT_STRING
        la      $a0, d_b_loc
        syscall

        la      $a0, a_x_coordinates       
        sw      $a1, _A_CELLS($s0)
        jal     print_array



