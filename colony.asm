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
        .asciiz "\nWARNING: illegal point location\n"

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

minus:
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

        #   === 32 byte structure ===   #

param_block:
        .word       board_dim                       #0 offset
        .word       generations                     #4 offset
        .word       A_cells                         #8 offset
        .word       B_cells                         #12 offset
        .word       a_next                          #16 offset
        .word       b_next                          #20 offset
        .word       a_coordinates                   #24 offset
        .word       b_coordinates                   #28 offset

board_1:
        .space      900                             #30x30 char array
        .align      2
        
board_2:
        .space      900                             #30x30 char array
        .align      2

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
        la      $a1, illegal_point
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
        la      $a1, illegal_point
        jal     get_B_cells
        

        # == test input grabbing == #
        la      $a0, param_block
        jal     debug_params
        
#set up board       
        jal     setup_board
        jal     print_board
        #jal     run_conway

end_main:
        lw      $ra, -4+FRAMESIZE_48($sp)
        addi    $sp, $sp, FRAMESIZE_48
        jr      $ra

# =========================================================
# Name:             print_board 
# =========================================================
# Description:      print the board as a 2D array
#                   
#
# Parameters:
#       s0 -        the dim of the board
#       s1 -        the pointer to the row to print
#       s2 -        the addr ofthe array
#
# T Registers:
#       t0 -        row loop flag
#       t1 -        row loop counter
#       t2 -        col loop counter
#       t3 -        pointer for col in row / banner counter
#       t4 -        column loop flag
#
# =========================================================

print_board: 
        addi    $sp, $sp, -16 
        sw      $ra, 12($sp)
        sw      $s0, 8($sp)
        sw      $s1, 4($sp)
        lw      $s2, 0($sp)

        # print top of board #
        jal     print_top_bottom

        # get board dim #

        jal     get_board_dim
        move    $s0, $v0

        # get board space #

        la      $s1, board_1
        la      $s2, board_1

        # calculate row to start at#

        addi    $t1, $s0, -1                        # row = dim - 1
        move    $t2, $zero                          # col = 0

        
print_row_loop:
        slt     $t0, $t1, $zero                      #while(row >= 0)
        bne     $t0, $zero, print_board_end 

        la      $a0, bar                            #print("|")
        li      $v0, PRINT_STRING 
        syscall

        # calculate row address #
        mul     $s1, $s0, 1                         # len_c = size(char) * dim
        mul     $s1, $s1, $t1                       # offset = len_c * row
        add     $s1, $s2, $s1                       # r_addr = base + offset
        
print_col_loop:
        slt     $t4, $t2, $s0                       #while(col < dim)
        beq     $t4, $zero, end_col_loop

        move    $t3, $s1                            #load addr of arr[row][0]

        mul     $t5, $t2, 1                         #sizeof(char)*col_index
        add     $t3, $t3, $t5                       #row base + offset

        lb      $a0, 0($t3)
        li      $v0, 11
        syscall                                     #print(arr[row][col])
        
        addi    $t2, $t2, 1                         #col++
        j       print_col_loop

end_col_loop:
        
        la      $a0, bar                            #print("|")
        li      $v0, PRINT_STRING 
        syscall

        la      $a0, newline                       #print("\n")
        li      $v0, PRINT_STRING 
        syscall
        
        move    $t2, $zero                          # col = 0
        addi    $t1, $t1, -1                        # row--
        j       print_row_loop


print_board_end:
        jal     print_top_bottom                    #print bottom board

        lw      $ra, 12($sp)
        lw      $s0, 8($sp)
        lw      $s1, 4($sp)
        lw      $s2, 0($sp)
        addi    $sp, $sp, 16
        jr      $ra

# =========================================================
# Name:             print_top_bottom
# =========================================================
# Description:      this prints the top banner of the board
#
# T Registers:
#       t0  -       loop counter
#       t1  -       board dimension
# =========================================================
print_top_bottom:
        addi    $sp, $sp, -4
        sw      $ra, 0($sp)

        
        jal     get_board_dim
        move    $t1, $v0

        la      $a0, plus                           #print("+")
        li      $v0, PRINT_STRING 
        syscall

        move    $t0, $zero
        
tb_loop:
        slt     $t3, $t0, $t1                       #while(i < dim)
        beq     $t3, $zero, tb_end

        la      $a0, minus                          #print("-")
        li      $v0, PRINT_STRING 
        syscall
        
        addi    $t0, $t0, 1
        j       tb_loop
tb_end:

        la      $a0, plus                           #print("+")
        li      $v0, PRINT_STRING 
        syscall

        la      $a0, newline                        #print("\n")
        li      $v0, PRINT_STRING 
        syscall
        
        lw      $ra, 0($sp)
        addi    $sp, $sp, 4
        jr      $ra


# =========================================================
# Name:             setup_board
# =========================================================
# Description:      this fills the spots in the array with 
#                   either an "A", "B", or " "(space)
#
# S Registers:
#       - s0        the board dimension
#       - s1        the pointer to pos in 2d array
#       - s2        the addr of the end 2d array
#
# T Registers:
#       - t2        addr of a_coordinates
#       - t3        addr of b_coordinates
#       - t9        pointer to curr in array
# =========================================================
setup_board:
        addi    $sp, $sp, -16
        sw      $ra, 12($sp)
        sw      $s0, 8($sp)
        sw      $s1, 4($sp)
        sw      $s2, 0($sp)

        jal     get_board_dim                       #get board dim
        move    $s0, $v0
        la      $s1, board_1                        #get board addr
        #lw      $s1, 0($s1)
    
        mul     $t0, $s0, $s0                       #dim^2
        add     $s2, $t0, $s1                       #pointer to end of array

        li      $t1, 32                             #t1 = ascii " "
load_blanks:
        slt     $t0, $s2, $s1                       # i == dim; break
        bne     $t0, $zero, fill_array
        
        sb      $t1, 0($s1)                         #arr[i] = ' ';

        addi    $s1, $s1, 1                         #i++
        j       load_blanks

fill_array:

setup_end:
        lw      $ra, 12($sp)
        lw      $s0, 8($sp)
        lw      $s1, 4($sp)
        lw      $s2, 0($sp)
        addi    $sp, $sp, 16
        jr      $ra

###########################################
# ======================================= #
# ||        Helper Code                || #
# ======================================= #
###########################################

get_board_dim:
        la      $t0, board_dim
        lw      $v0, 0($t0)
        jr      $ra

get_generations:
        la      $t0, generations
        lw      $v0, 0($t0)
        jr      $ra

get_a:
        la      $t0, A_cells
        lw      $v0, 0($t0)
        jr      $ra

get_b:
        la      $t0, B_cells
        lw      $v0, 0($t0)
        jr      $ra


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

        jal     get_board_dim                       #get the value of board dim
        move    $a0, $v0
        li      $v0, PRINT_INT                      #print board dim
        syscall

        # print generations #

        li      $v0, PRINT_STRING
        la      $a0, d_gen
        syscall
        jal     get_generations                     #value of generations
        move    $a0, $v0
        li      $v0, PRINT_INT                      #print generations
        syscall

        # print colony A size #

        li      $v0, PRINT_STRING
        la      $a0, d_a_cells
        syscall
        jal     get_a                               #get size a
        move    $a0, $v0
        li      $v0, PRINT_INT                      #print size of a
        syscall

        # print locations #
        li      $v0, PRINT_STRING
        la      $a0, d_a_loc
        syscall

        la      $a0, a_coordinates
        jal     get_a                               #get size a
        move    $a1, $v0
        jal     print_locations


        # print colony B size#

        li      $v0, PRINT_STRING
        la      $a0, d_b_cells
        syscall
        jal     get_b                               #get size b
        move    $a0, $v0
        li      $v0, PRINT_INT                      #print it
        syscall

        # print locations#
        li      $v0, PRINT_STRING
        la      $a0, d_b_loc
        syscall

        la      $a0, b_coordinates                  #get addr of arr
        jal     get_b                               #get size b
        move    $a1, $v0
        jal     print_locations

        li      $v0, PRINT_STRING
        la      $a0, newline
        syscall
        
        lw      $ra, 4($sp)
        lw      $s0, 0($sp)
        addi    $sp, $sp, 8
        jr      $ra

