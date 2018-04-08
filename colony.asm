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
PRINT_CHAR = 11 

# various frame sizes used by different routines
REGISTER_1 = 8
REGISTERS_2 = 12
REGISTERS_3 = 16
REGISTERS_4 = 20
REGISTERS_5 = 24
REGISTERS_6 = 28
REGISTERS_7 = 32
REGISTERS_8 = 36

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

a_coordinates_2:                                          
        .space      7200                            #space for 300 x's
        .align      2

b_coordinates_2:                                          
        .space      7200                            #space for 300 x's
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
        la      $a2, a_coordinates_2
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
        la      $a2, b_coordinates_2
        jal     get_B_cells
        
        # == test input grabbing == #

        la      $a0, param_block
        jal     debug_params

        # == set up board == #

        # print generation 0
        la      $a0, board_1
        jal     setup_board
        
        move    $a0, $zero
        jal     print_generation_banner

        la      $a0, board_1
        jal     print_board

        la      $a0, board_2
        jal     setup_board
        la      $a0, board_2
        #jal     print_board

        jal     get_generations
        move    $a0, $v0

        jal     get_board_dim
        move    $a1, $v0
        
        jal     run_conway

end_main:
        lw      $ra, -4+FRAMESIZE_48($sp)
        addi    $sp, $sp, FRAMESIZE_48
        jr      $ra

# =========================================================
# Name:             run_conway
# =========================================================
# Description:      this is the main function for running
#                   the game of life variation
#                   
# Parameters:
#       a0 -        generations needed to run
#       a1 -        board dimension
#
# S Registers:
#       s0 -        the generation toggle
#       s1 -        gen count
#       s2 -        the addr of the current board
#       s3 -        the curr row
#       s4 -        the current col
#       s5 -        n = number of neighbors
#       s6 -        register == 1 if at dead cell
#
# T Registers:
# =========================================================

run_conway:
        addi    $sp, $sp, -REGISTERS_7
        sw      $ra, -4+REGISTERS_7($sp)
        sw      $s0, -8+REGISTERS_7($sp)
        sw      $s1, -12+REGISTERS_7($sp)
        sw      $s2, -16+REGISTERS_7($sp)
        sw      $s3, -20+REGISTERS_7($sp)
        sw      $s4, -24+REGISTERS_7($sp)
        sw      $s5, -28+REGISTERS_7($sp)
        sw      $s6, -32+REGISTERS_7($sp)
    
        li      $s0, 0                              # gen_toggle = 0
        move    $s1, $zero                          # gen_count = 0

conway_loop:
        slt     $t1, $s1, $a0                       # while(i < gens)
        beq     $t1, $zero, conway_end              # {

        beq     $s0, $zero, even_generation         #if(toggle = 0) then even;
        bne     $s0, $zero, odd_generation          #else odd;

even_generation:
        la      $s2, board_1
        j       start_loop
odd_generation:
        la      $s2, board_2

start_loop:
        move    $s3, $zero                          # row = 0
        move    $s4, $zero                          # col = 0

        # for(i = 0; i < row; i++) {
        
even_row_loop:
        slt     $t0, $s3, $a1                       # if(row < dim)                    
        beq     $t0, $zero, end_conway_loop
        
        # for(j = 0; j < col; j++)

even_col_loop:
        slt     $t0, $s4, $a1                       #while(col < dim)
        beq     $t0, $zero, even_row_end

        # == store parameters == #

        addi    $sp, $sp, -8
        sw      $a0, 0($sp)
        sw      $a1, 4($sp)

        # == counting neighbors == #

        move    $a0, $s2                            # p1 = board addr
        move    $a1, $s3                            # p2 = row
        move    $a2, $s4                            # p3 = col
        lw      $a3, 4($sp)                         # p4 = dim
        jal     get_pos                             # get board[row][col]
        move    $t3, $v0
        lb      $t3, 0($t3)

        li      $t4, 65
        li      $t5, 66

        # == set generation i - 1 == #

        beq     $s0, $zero, set_odd_board           # if(toggle = 0)
        la      $s2, board_1                        # { set odd (board 1) }
        j       set_prev_done

set_odd_board:
        la      $s2, board_2                        # else { set board2 }

set_prev_done:
        beq     $t3, $t4, a_neighbors               #if(baord[row][col] == 'A')
        beq     $t3, $t5, b_neighbors               #if(board[row][col] == B)

        # == dead cells case == #
        
        move    $a0, $s2                            # param1 = prev_board
        move    $a1, $s3                            # param2 = curr row
        move    $a2, $s4                            # param3 = curr col
        li      $a3, 66                             # param4 = B
        jal     count_neighbors
        move    $s5, $v0                            # N = #B's

        move    $a0, $s2
        move    $a1, $s3
        move    $a2, $s4
        li      $a3, 65                             
        jal     count_neighbors                     # ret = #A's
        sub     $s5, $s5, $v0                       # N = Bs - As
        li      $s6, 1
        j       live_die_logic

b_neighbors:
        move    $a0, $s2                            # param1 = prev_board
        move    $a1, $s3                            # param2 = curr row
        move    $a2, $s4                            # param3 = curr col
        li      $a3, 66                             # param4 = B
        jal     count_neighbors
        move    $s5, $v0                            # N = #B's

        move    $a0, $s2
        move    $a1, $s3
        move    $a2, $s4
        li      $a3, 65                             
        jal     count_neighbors                     # ret = #A's
        sub     $s5, $s5, $v0                       # N = Bs - As
        j       live_die_logic

        
a_neighbors:
        move    $a0, $s2
        move    $a1, $s3
        move    $a2, $s4
        li      $a3, 65                             # param4 = A
        jal     count_neighbors
        move    $s5, $v0
        
        move    $a0, $s2
        move    $a1, $s3
        move    $a2, $s4
        li      $a3, 66                             
        jal     count_neighbors                     # ret = #Bs
        sub     $s5, $s5, $v0                       # N = As - Bs

        # now do the rest of the logic #

live_die_logic:

        #   get generation i  #

        beq     $s0, $zero, reset_to_even           #if(toggle = 0) then even;
        bne     $s0, $zero, reset_to_odd            #else odd;

reset_to_even:
        la      $s2, board_1
        move    $a0, $s2                            # set params for later use
        move    $a1, $s3
        move    $a2, $s4
        jal     get_board_dim
        move    $a3, $v0
        j       is_dead

reset_to_odd:
        la      $s2, board_2
        move    $a0, $s2                            #set params for later use
        move    $a1, $s3
        move    $a2, $s4
        jal     get_board_dim
        move    $a3, $v0
        j       is_dead

is_dead:
        bne     $s6, $zero, resurrect               # if(dead) goto resurrect
                                                    # else do normal checks
n_lt_2:

        # == if N < 2 == #

        slti    $t1, $s5, 2                       
        beq     $t1, $zero, n_gt_3
        jal     get_pos                             # get board_i[col][row]
        li      $t1, 32
        sb      $t1, 0($v0)
        j       even_col_end


n_gt_3:

        # == if N >= 4 == #

        slti    $t1, $s5, 4
        bne     $t1, $zero, n_2_or_3
        jal     get_pos
        li      $t1, 32
        sb      $t1, 0($v0)
        j       even_col_end
        
n_2_or_3:
       
        # == if N == 2 or 3 == #
        # do nothing because the cell stays alive
        j       even_col_end

resurrect:
        move    $s6, $zero                          # reset bit for next loop
        li      $t0, 3
        beq     $s5, $t0, become_B
        li      $t0, -3
        beq     $s5, $t0, become_A
        j       even_col_end

become_A:
        jal     get_pos
        li      $t1, 65
        sb      $t1, 0($v0)                         # dead cell = A
        j       even_col_end

become_B:
        jal     get_pos
        li      $t1, 66
        sb      $t1, 0($v0)                         # dead cell = B
        j       even_col_end
        
even_col_end:

        # restore original params #

        lw      $a0, 0($sp)
        lw      $a1, 4($sp)
        addi    $sp, $sp, 8


        addi    $s4, $s4, 1                         # col++
        j       even_col_loop

even_row_end:
        move    $s4, $zero                          # col = 0
        addi    $s3, $s3, 1                         # row++
        j       even_row_loop

end_conway_loop:
        
        # == print board == #
        addi    $sp, $sp, -4
        sw      $a0, 0($sp)
        
        addi    $a0, $s1, 1
        jal     print_generation_banner

        beq     $s0, $zero, prt_b_1
        la      $a0, board_1
        j       print_generation

prt_b_1:
        la      $a0, board_1

print_generation:
        jal     print_board
        lw      $a0, 0($sp)
        addi    $sp, $sp, 4

        addi    $s1, $s1, 1                         #gens ++
        rem     $s0, $s1, 2                         #toggle = gen_count % 2
        j       conway_loop
                                                    # }
conway_end:
        lw      $ra, -4+REGISTERS_7($sp)
        lw      $s0, -8+REGISTERS_7($sp)
        lw      $s1, -12+REGISTERS_7($sp)
        lw      $s2, -16+REGISTERS_7($sp)
        lw      $s3, -20+REGISTERS_7($sp)
        lw      $s4, -24+REGISTERS_7($sp)
        lw      $s5, -28+REGISTERS_7($sp)
        lw      $s6, -32+REGISTERS_7($sp)
        addi    $sp, $sp, REGISTERS_7
        jr      $ra

# =========================================================
# Name:             count_neighbors
# =========================================================
# Description:      count neihbors of cell (a2, a1) that
#                   are 'A's
#                   
# Parameters:
#       a0 -        the addr of the board to check
#       a1 -        row number
#       a2 -        col number
#       a3 -        char to check against
#
# S Registers:
#       s0 -        the board dim
#       s1 -        the current row
#       s2 -        the current col
#       s3 -        the char to check against
#       s4 -        the count
#       s5 -        the opposite char
#
# T Registers:
#       t1 -        bot
#       t2 -        top 
#       t3 -        left
#       t4 -        right
#
# =========================================================

count_neighbors:
        addi    $sp, $sp, -REGISTERS_6
        sw      $ra, -4+REGISTERS_6($sp)
        sw      $s0, -8+REGISTERS_6($sp)
        sw      $s1, -12+REGISTERS_6($sp)
        sw      $s2, -16+REGISTERS_6($sp)
        sw      $s3, -20+REGISTERS_6($sp)
        sw      $s4, -24+REGISTERS_6($sp)
        sw      $s5, -28+REGISTERS_6($sp)

        jal     get_board_dim
        move    $s0, $v0

        move    $t8, $zero

        move    $s1, $a1
        move    $s2, $a2
        move    $s3, $a3
        move    $s4, $zero                          #count = 0

        li      $t1, 65
        beq     $s3, $t1, opp_is_B                  # if(char == A) {
        li      $s5, 65                             # opp == B
        j       start_count                         # } else {

opp_is_B:                               
        li      $s5, 66                             # opp == A }

start_count: 
        addi    $t1, $a1, -1                        # bot = row - 1
        addi    $t2, $a1, 1                         # top = row + 1
        addi    $t3, $a2, -1                        # lft = col - 1
        addi    $t4, $a2, 1                         # rht = col + 1

        # if(bot < 0) bot = dim - 1 #
        slt     $t9, $t1, $zero
        beq     $t9, $zero, check_top
        addi    $t1, $s0, -1

check_top:
        slt     $t9, $t2, $s0                       
        bne     $t9, $zero, check_left              # if(top < dim) skip wrap
        move    $t2, $zero

check_left:
        slt     $t9, $t3, $zero
        beq     $t9, $zero, check_right
        addi    $t3, $s0, -1

check_right:
        slt     $t9, $t4, $s0
        bne     $t9, $zero, validate_nbrs
        move    $t4, $zero

validate_nbrs:

        move    $a3, $s0                            # param 4 = dim
        # == check above == #
        move    $a1, $t1
        move    $a2, $s2
        jal     get_pos                             # get (col, top)
        lb      $v0, 0($v0)
        
        bne     $v0, $s3, cmp_bot
        addi    $t8, $t8, 1
        
cmp_bot:
        # == check below== #
        move    $a1, $t2
        move    $a2, $s2
        jal     get_pos                             #get board[col][bot]
        lb      $v0, 0($v0)

        bne     $v0, $s3, cmp_left
        addi    $t8, $t8, 1

cmp_left:
        # == check left == #
        move    $a1, $s1
        move    $a2, $t3
        jal     get_pos
        lb      $v0, 0($v0)                         #get board[lft][row]

        bne     $v0, $s3, cmp_right
        addi    $t8, $t8, 1

cmp_right:
        # == check right == #
        move    $a1, $s1
        move    $a2, $t4
        jal     get_pos
        lb      $v0, 0($v0)                         #get board[rht][row]

        bne     $v0, $s3, cmp_top_left
        addi    $t8, $t8, 1

cmp_top_left:
        move    $a1, $t1                            #top
        move    $a2, $t3                            #left
        jal     get_pos
        lb      $v0, 0($v0)                         #get board[left][top]

        bne     $v0, $s3, cmp_top_right
        addi    $t8, $t8, 1

cmp_top_right:
        move    $a1, $t1                            #top
        move    $a2, $t4                            #right
        jal     get_pos
        lb      $v0, 0($v0)                         #get board[right][top]

        bne     $v0, $s3, cmp_bot_left
        addi    $t8, $t8, 1

cmp_bot_left:
        move    $a1, $t2                            #bot
        move    $a2, $t3                            #left
        jal     get_pos
        lb      $v0, 0($v0)                         #get board[left][bot]

        bne     $v0, $s3, cmp_bot_right
        addi    $t8, $t8, 1

cmp_bot_right:
        move    $a1, $t2                            #bot
        move    $a2, $t4                            #right
        jal     get_pos
        lb      $v0, 0($v0)                         #get board[right][bot]

        bne     $v0, $s3, count_neighbors_end
        addi    $t8, $t8, 1

count_neighbors_end:

        move    $v0, $t8    
    
        lw      $ra, -4+REGISTERS_6($sp)
        lw      $s0, -8+REGISTERS_6($sp)
        lw      $s1, -12+REGISTERS_6($sp)
        lw      $s2, -16+REGISTERS_6($sp)
        lw      $s3, -20+REGISTERS_6($sp)
        lw      $s4, -24+REGISTERS_6($sp)
        lw      $s5, -28+REGISTERS_6($sp)
        addi    $sp, $sp, REGISTERS_6
        jr      $ra

# =========================================================
# Name:             print_board 
# =========================================================
# Description:      print the board as a 2D array
#                   
# Parameters:
#       a0 -        the addr of the board to print
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

        move     $s1, $a0 
        move     $s2, $a0 

        # print top of board #

        jal     print_top_bottom

        # get board dim #

        jal     get_board_dim
        move    $s0, $v0

        # calculate row to start at#

        addi    $t1, $s0, -1                        # row = dim - 1
        move    $t2, $zero                          # col = 0

        
print_row_loop:
        slt     $t0, $t1, $zero                     #while(row >= 0)
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
        li      $v0, PRINT_CHAR
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
# Name:             print_generation_banner
# =========================================================
# Description:      this prints the generation number
#
# Parameters:
#       a0  -       the current generation number
# T Registers:
#       t0  -       gen_banner_start
#       t1  -       gen_banner_end
#       t3  -       the current generation
# =========================================================

print_generation_banner:
        move    $t3, $a0
        li      $v0, PRINT_STRING
        la      $a0, gen_banner_start
        syscall

        li      $v0, PRINT_INT
        move    $a0, $t3
        syscall

        li      $v0, PRINT_STRING
        la      $a0, gen_banner_end
        syscall
        
        jr      $ra


# =========================================================
# Name:             setup_board
# =========================================================
# Description:      this fills the spots in the array with 
#                   either an "A", "B", or " "(space)
#
# Parameters:
#       - a0        location of board to set up
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
        move    $s1, $a0
    
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
        jal     fill_positions
        

setup_end:
        lw      $ra, 12($sp)
        lw      $s0, 8($sp)
        lw      $s1, 4($sp)
        lw      $s2, 0($sp)
        addi    $sp, $sp, 16
        jr      $ra


# =========================================================
# Name:             fill_positions
# =========================================================
# Description:      this function takes the given board 
#                   passed in through a0 and fills it
#                   with positions from the a_coordinate
#                   and b_coordinate arrays
#
# Parameters:
#       - a0        location of board to set up
#
# S Registers:
#       - s0        number of values in a/b
#       - s1        current array (a or b)
#       - s2        board dimensions
#       - s3        current ascii value
#
# T Registers:
#       - t0        location of the a coordinate array
#       - t2        pointer to board[row][col]
#       - t3        x coordinate from array
#       - t4        y coordinate from array
# =========================================================

fill_positions:
        addi    $sp, $sp, -REGISTERS_5
        sw      $ra, -4+REGISTERS_5($sp)
        sw      $s0, -8+REGISTERS_5($sp)
        sw      $s1, -12+REGISTERS_5($sp)
        sw      $s2, -16+REGISTERS_5($sp)
        sw      $s3, -20+REGISTERS_5($sp)
        sw      $s4, -24+REGISTERS_5($sp)

        jal     get_board_dim
        move    $s2, $v0
    
        jal     get_a
        move    $s0, $v0

        la      $s1, a_coordinates
        li      $s3, 65
        
        move    $t2, $a0                            # pointer to boar_arr[0]
        move    $t9, $zero                          # i = 0

fill_a:
        slt     $t8, $t9, $s0                       # while(i < a_size)
        beq     $t8, $zero, fill_a_end
        
        # add values into 2d board

        lw      $a1, 0($s1)                         # get row coordinate
        lw      $a2, 4($s1)                         # get col coordinate
        move    $a3, $s2                            # get dim of board
        
        jal     get_pos
        
        sb      $s3, 0($v0)      
        
        addi    $t9, $t9, 1                         # i++
        addi    $s1, $s1, 8                         # update a_coordinates[i]
        move    $t2, $a0
        j       fill_a

fill_a_end:

        jal     get_b           
        move    $s0, $v0                            # get b address
        la      $s1, b_coordinates                  # get base of b_arr
        li      $s3, 66                             # ascii 'B'
        move    $t9, $zero                          # i = 0

fill_b:
        slt     $t8, $t9, $s0                       # while(i < b_size)
        beq     $t8, $zero, fill_positions_end
        
        # add values into 2d board

        lw      $a1, 0($s1)                         # get row coordinate
        lw      $a2, 4($s1)                         # get col coordinate
        move    $a3, $s2                            # get dim of board
        
        jal     get_pos
        
        sb      $s3, 0($v0)      
        
        addi    $t9, $t9, 1                         # i++
        addi    $s1, $s1, 8                         # update a_coordinates[i]
        move    $t2, $a0
        j       fill_b

fill_positions_end:

        lw      $ra, -4+REGISTERS_5($sp)
        lw      $s0, -8+REGISTERS_5($sp)
        lw      $s1, -12+REGISTERS_5($sp)
        lw      $s2, -16+REGISTERS_5($sp)
        sw      $s3, -20+REGISTERS_5($sp)
        sw      $s4, -24+REGISTERS_5($sp)
        addi    $sp, $sp, REGISTERS_5
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
# Name:             get_pos
# =========================================================
# Description:      gets the addr of board[row][col] in 
#                   the given array
#
# Parameters:
#       a0 -        the location of array to access
#       a1 -        the row value
#       a2 -        the col value
#       a3 -        the dim of the board
#
# Returns:
#       v0 - the addr of board[row][col]
#     
# =========================================================

get_pos:

        # calculate row address #

        mul     $v0, $a3, 1                         # len_c = size(char) * dim
        mul     $v0, $v0, $a1                       # roffset = len_c * row
        add     $v0, $a0, $v0                      # r_addr = base + roffset
        
        # calculate column address #

        add     $v0, $v0, $a2                       # addr = r_addr + col
        
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

