 Test_Begin :
    addi    $16, $0, 0
    addi    $17, $0, 0
    and	$18, $0, $0
    addi    $8, $0, 10
    beq     $8, $0, Test_Err
    j       TEST_ARITHLOGIC
    
Test_Err :
    j       Test_Err
    
TEST_ARITHLOGIC :
    beq     $17, $8, TEST_STORELOAD
    add     $18, $16, $18
    addi    $16, $16, 1
    addi    $17, $17, 1
    j       TEST_ARITHLOGIC
    
TEST_STORELOAD :
    sw      $18, 0x0040($0)
    lw      $16, 0x0040($0)
    
Test_End :
    j       Test_End
