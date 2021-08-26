# MARS的memory configura应选择第2个模式，即“Compact, Data at Address 0”
Test_Begin :
    lui     $t1, 0xABCD               # t1 = 0xABCD0000
    bgtz    $t1, Test_Err
    nop
    bgez    $t1, Test_Err
    nop
    slti    $t2, $t1, 0               # t2 = 0x00000001
    beq     $t2, $zero, Test_Err
    nop
    bne     $zero, $zero, Test_Err
    nop
    blez    $t1, Test_Continue
    nop

Test_Err :
    j       Test_Err
    
Test_Continue :    
    jal     TEST_ARITHLOGIC
    jal     TEST_STORELOAD
    jal     TEST_SHIFT
    j       Test_End

TEST_ARITHLOGIC :
    addi    $t0, $zero, -1          # t0 = 0xFFFFFFFF
    addiu   $t1, $zero, 1           # t1 = 0x00000001
    sub     $t2, $t0, $t1           # t2 = 0xFFFFFFFE
    subu    $t2, $t1, $t0           # t2 = 0x00000002
    slt     $t2, $t0, $t1           # t2 = 0x00000001
    addu    $t2, $t0, $t1           # t2 = 0x00000000

    lui     $t1, 0x5555             # t1 = 0x55550000
    ori     $t1, $t1, 0x5555        # t1 = 0x55555555
    or      $t1, $t1, $zero         # t1 = 0x55555555
    xori    $t2, $t0, 0x5555        # t2 = 0xFFFFAAAA
    and     $t2, $t0, $t1           # t2 = 0x55555555
    xor     $t2, $t0, $t1           # t2 = 0x55555555 
    nor     $t2, $t0, $t1           # t2 = 0xAAAAAAAA
    andi    $t2, $zero, 0x5555      # t2 = 0x00000000
    jr      $ra
    
TEST_STORELOAD :
    add     $s0, $zero,$zero        # $s0: the base address of data
    ori     $t0, $zero, 0x0000      # t0 = 0x00001280
    sw      $t0, 0($s0)             # *s0 = 0x0000001280 
    addi    $s0, $s0, 4
    sb      $t0, 0($s0)             # *(s0) = 0xxxxxxx80 
    addi    $t0, $t0, 1             # t0 = 0x00001281
    sb      $t0, 1($s0)             # *(s0+1) = 0xxxxx8180 
    sh      $t0, 2($s0)             # *(s0+2) = 0x12818180 
    lb      $t1, 0($s0)             # t1 = 0xFFFFFF80
    lbu     $t1, 0($s0)             # t1 = 0x00000080
    lh      $t1, 0($s0)             # t1 = 0xFFFF8180
    lhu     $t1, 0($s0)             # t1 = 0x00008180
    lw      $t1, 0($s0)             # t1 = 0x12818180
    sw	$zero, 0($zero)
    sw	$zero, 0($s0)
    jr      $ra


TEST_SHIFT :                        
    addi    $t0, $zero, -1          # t0 = 0xFFFFFFFF
    sll     $t1, $t0, 31            # t1 = 0x80000000
    srl     $t2, $t1, 31            # t2 = 0x00000001
    sra     $t2, $t1, 31            # t2 = 0xFFFFFFFF
    ori     $t0, $zero, 23          # t0 = 0x00000017
    sllv    $t2, $t1, $t0           # t2 = 0x00000000
    srlv    $t2, $t1, $t0           # t2 = 0x00000100
    srav    $t2, $t1, $t0           # t2 = 0xFFFFFF00
    jr      $ra
    
Test_End :
    j       Test_End

