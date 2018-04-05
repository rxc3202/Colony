
run_conway:
        addi    $sp, $sp, -REGISTERS_6
        sw      $ra, -4+REGISTERS_6($sp)
        sw      $s0, -8+REGISTERS_6($sp)
        sw      $s1, -12+REGISTERS_6($sp)
        sw      $s2, -16+REGISTERS_6($sp)
        sw      $s3, -20+REGISTERS_6($sp)
        sw      $s4, -24+REGISTERS_6($sp)
        sw      $s5, -28+REGISTERS_6($sp)
    

        li      $s5, 0                              # gen_toggle = 0
conway_loop:
        slt     $t1, $a0, $s4                       # while(i < gens)
        bne     $t1, $zero, conway_end              # {

        beq     $s5, $zero, even_generation         #if(toggle = 0) then even;
        bne     $s5, $zero, odd_generation          #else odd;

even_generation:
        jal     get_a
        move    $s2, $v0 
        la      $s1, board_1
        move    $t0, $zero                          # j = 0
        move    $s6, $zero                          # j = 0

even_a_loop:
        slt     $t1, $t0, $s2                       # while(j < a_coord)
        beq     $t1, $zero, even_b_loop

        la      $t2, a_coordinates                  # tmp1 = a_coords
        lw      $t2, 0($t2)
        mul     $t1, $t0, 8                         # offset = size(coor)*idx
        add     $t2, $t2, $t1                       # tmp1 = a_coord + offset
        
        lw      $t3, 0($t2)                         # row_val = a_coord[j].y
        lw      $t4, 4($t2)                         # col_val = a_coord[j].x
        
        addi    $t5, $t3, 1                         # top = y + 1
        addi    $t6, $t3, -1                        # bot = y - 1
        addi    $t7, $t4, -1                        # left = x - 1
        addi    $t8, $t4, 1                         # right = x + 1
        
        # do wrapping checks here #

        slti    $t1, $t6, $zero                     #if(bot < 0)
        beq     $t1, $zero, check_top
        addi    $t6, $a1, -1                        # bot = dim - 1

check_top:
        slti    $t1, $t5, $a1                       #if(top >= dim)
        bne     $t1, $zero, check_left
        move    $t5, $zero                          # top = 0

check_left:
        slti    $t1, $t7, $zero                     # if(left < 0)
        beq     $t1, $zero, check_right
        addi    $t7, $a1, -1                        # left = dim - 1

check_right:
        slti    $t1, $t8, $a1                       # if(right >= dim)
        bne     $t1, $zero, done_wrap_check
        move    $t8, $zero                          # right = 0

done_wrap_check:
        
        addi    $sp, $sp, -8
        sw      $a0, 0($sp)
        sw      $a1, 4($sp)
        
        move    $a0, $s1                            # param 1 = board addr
        
        # == check above == #

        move    $a1, $t5
        move    $a2, $t4
        jal     get_pos
        move    $s0, $v0                            # temp = board[top][x]
        
        lb      $s0, 0($s0)
        li      $t1, 65
        beq     $s0, $t1, cmp_left
        addi    $s6, $s6, 1

        # == check left == #

cmp_left:
        move    $a1, $t3
        move    $a2, $t7
        jal     get_pos
        move    $s0, $v0
        
        lb      $s0, 0($s0)
        li      $t1, 65
        beq     $s0, $t1, cmp_right
        addi    $s6, $s6, 1

        # == check right == #

cmp_right:
        move    $a1, $t3
        move    $a2, $t8
        jal     get_pos
        move    $s0, $v0

        lb      $s0, 0($s0)
        li      $t1, 65
        beq     $s0, $t1, cmp_bot
        addi    $s6, $s6, 1

        # == check below == #

cmp_bot:
        move    $a1, $t6
        move    $a2, $t4
        jal     get_pos
        move    $s0, $v0

        lb      $s0, 0($s0)
        li      $t1, 65
        beq     $s0, $t1, end_a_loop
        addi    $s6, $s6, 1

end_a_loop:
        sw      $a0, 0($sp)
        sw      $a1, 4($sp)
        addi    $sp, $sp, 8

        addi    $t0, $t0, 1
        j       even_a_loop
