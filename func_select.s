    #316429653 Tom Menashe
    .data
    .section    .rodata
    .align 8
.switch:
     .quad .switch_A # case 50: loc_A
     .quad .switch_B # case 51: loc_B
     .quad .switch_C # case 52: loc_C
     .quad .switch_D # case 53: loc_D
     .quad .switch_Def # case esle: loc_De

printLen: .string "first pstring length: %d, second pstring length: %d\n"
getDummy: .string "%c"
getChars: .string "%c %c"
printChangeChar: .string "old char: %c, new char: %c, first string: %s, second string: %s\n"
printString: .string "length: %d, string: %s\n"
printErorCase: .string "invalid option!\n"
getNumber: .string "%d"


.globl run_func
    .type run_func, @function
run_func:
#run_func is a function in funnc_select which get 3 parameters: 2 strings and an option.
#the function activates the right case using the given option from the jump-table.
run:
    #save callee registers
    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15
    
    #Set up the jump table access
    leaq -50(%rdx),%rcx             #%rcx = %rdx -50
    cmpq $3,%rcx                    #compare 3 with %rcx
    ja .switch_Def                  #if the value in %rcx > 3 go to default case 
    jmp *.switch(,%rcx,8)           #go to the right case in the jump table.      
    
    #case 50- user option input is 50.prints the strings length using pstrlen function.
    .switch_A:
        #backup registers before using pstrlen function
        pushq %rdi
        pushq %rsi
        pushq %rbx
        
        pushq %r12                  #callee register back up.
        
        movq $0,%rax                #set %rax to 0.
        call pstrlen
        movb %al,%bl                #save first string length in %bl.
        leaq (%rsi),%rdi            #put second string address in %rdi,to use it in pstrlen function.
        call pstrlen
        movb %al,%r12b              #save second string length in %r12b. 
        
        #print two strings length                    
        movq $printLen,%rdi         #move print length format to %rdi     
        movzbq %bl,%rsi             #put first length to %rsi
        movzbq %r12b,%rdx           #put second length to %rdx
        movq $0,%rax                #set %rax to 0.
        call printf
        movq $0,%rax                #set %rax to 0.
        
        #restore registers.
        popq %r12
        popq %rbx
        popq %rsi
        popq %rdi
    
        #end case.
        jmp .done
    
    
    #case 51-user option is 51-gets old char from the user and new char and replace each appearance
    #of the old char in the new char using the replaceChar function.
    .switch_B:
        #back up caller registers before using scanf
        pushq %rsi
        pushq %rdx
        pushq %rdi
        
        #get the \n to a dummy  
        movq $0,%rax                #set %rax to 0.
        addq $-1,%rsp               #allocte 1 byte on the stack.
        leaq (%rsp),%rsi            #put the address of the input to %rsi(before getting it) 
        movq $getDummy,%rdi         #put get one char as dummy format in %rdi.
        call scanf
        addq $1,%rsp                #free 1 byte from the stack.
     
     
        #get input-get to chars wit a space between them.
        movq $0,%rax                #set %rax to 0.
        addq $-2,%rsp               #allocte 2 bytes on the stack.
        leaq (%rsp),%rsi            #put the address of the input to %rsi(before getting it).
        leaq 1(%rsp),%rdx           #put the address of the input to %rdx(before getting it) second char.
        movq $getChars,%rdi         #put get two char as dummy format in %rdi.
        call scanf

          
        movzbq (%rsp),%rbx          #put first char in %rbx.
        movzbq 1(%rsp),%r12         #put second char in %r12.
        addq $2,%rsp                #free 2 bytes from stack 
    
        #restore registers original value.
        popq %rdi
        popq %rdx
        popq %rsi
     
        #back up caller registers before using replaceChar function.
        pushq %rdx
        pushq %rdi
        pushq %rsi
     
        #use replaceChar function for first string.
        movq $0,%rax                #send %rax to 0.
        movzbq %bl,%rsi             #put first char in %rsi.
        movzbq %r12b,%rdx           #put second char in %rdx.
        call replaceChar  
        leaq (%rax),%r13            #save the given string from the function in %r13.
    
        
        popq %rsi                   #get second string from back up.
        pushq %rsi                  #back up %rsi before using replaceChar.
        
        #use replaceChar function for second string.
        leaq (%rsi),%rdi            #put second string in %rdi. 
        movzbq %bl,%rsi             #put first char in %rsi.
        movzbq %r12b,%rdx           #put second char in %rdx.
        call replaceChar
        leaq (%rax),%r14            #save the given string from the function in %r13.
     
        
        #prints the given chars and the string after the changes.
        movq $0,%rax                #send %rax to 0. 
        movq $printChangeChar,%rdi  #put  print format in %rdi.
        movq %rbx,%rsi              #put first char in %rsi
        movq %r12,%rdx              #put second char in %rdx
        leaq 1(%r13),%rcx           #put first string after change in %rcx.
        leaq 1(%r14),%r8            #put second string after change in %r8.
        call printf
        movq $0,%rax                #send %rax to 0.   
     
        #restore registers original value.
        popq %rsi
        popq %rdi
        popq %rdx
     
        #end case.
        jmp .done
    
    #case 52-user option is 52-gets index i and index j from the user, the case uses the pstrijcpy function 
    #to replace the sub-string pstr1[i..j] in pstr2[i..j] in pstr1.pstr2 stayes the same.
    .switch_C:
        #back up caller registers before using scanf  
        push %rdi
        push %rsi
        
        #get input-integer 4 bytes,first one.
        movq $0,%rax                #send %rax to 0. 
        addq $(-4),%rsp             #allocate 4 bytes on the stack for the input.        
        leaq (%rsp),%rsi            #put the address of the input to %rsi(before getting it).
        movq $getNumber,%rdi        #put the format for the scanf in %rdi.
        call scanf
        movl (%rsp),%r14d           #put given integer 4 bytes in %r14.
        addq $4,%rsp                #free 4 bytes from stack.   
      
        #get input-integer 4 bytes,second one.
        movq $0,%rax                #send %rax to 0.                
        addq $(-4),%rsp             #allocate 4 bytes on the stack for the input.
        leaq (%rsp),%rsi            #put the address of the input to %rsi(before getting it).
        movq $getNumber,%rdi        #put the format for the scanf in %rdi.
        call scanf
        movl (%rsp),%r15d           #put given integer 4 bytes in %r15.
        addq $4,%rsp                #free 4 bytes from stack. 
        movq $0,%rax                #send %rax to 0.

        #restore registers after scanf
        popq %rsi
        popq %rdi
        
        #back up caller registers before using pstrijcpy function.
        pushq %rdi
        pushq %rbx
        pushq %rsi
          
        movzbq %r14b,%rdx           #put first number in %rdx
        movzbq %r15b,%rcx           #put second number in %rcx
        call pstrijcpy
      
        #print the string after changing it. 
        leaq 1(%rax),%rdx           #put the string in %rdx 
        movzbq (%rax),%rsi          #put the string length in %rsi
        movq $0,%rax                #send %rax to 0.         
        movq $printString,%rdi    #put the print format for the printf in %rdi. 
        call printf
        movq $0,%rax                #send %rax to 0. 
       
        #print second string
        popq %rsi                   #get the second string.
        pushq %rsi                  #back it up.
        leaq 1(%rsi),%rdx           #put the string in %rdx. 
        movzbq (%rsi),%r14          #put the string length in %r14.
        movq %r14,%rsi              #put the length in %rsi.
        movq $printString,%rdi    #put the print format for the printf in %rdi.
        call printf
        movq $0,%rax                #send %rax to 0. 
       
       
        #restore registers after printf
        popq %rbx                   
        popq %rdx
        popq %rsi
        
        #end case
        jmp .done
    
       
    #case 53-user option is 52- using the swapCase function that gets 2 string replaces 
    #each lower-case letter in capital letter and every capital letter to lower-case.
    .switch_D:
        #back up caller registers before using swapCase
        pushq %rdi
        pushq %rdx
        pushq %rsi
        
        #first string swap.
        call swapCase
        #first string print after swap
        movzbq (%rax),%rsi          #put first string legnth in %rsi
        leaq 1(%rax),%rdx           #put string in %rdx
        movq $0,%rax                #set %rax to 0.
        movq $printString,%rdi    #put the print format for the printf in %rdi.  
        call printf 
        movq $0,%rax                #set %rax to 0.  
        
        
        popq %rsi                   #restore %rsi value.
        pushq %rsi                  #back up %rsi.
        
        #run swapCase on the second string.
        leaq (%rsi),%rdi            #put second string in %rdi
        call swapCase
        
        #print second string after swap
        leaq 1(%rax),%rdx           #put length in %rdx.
        movzbq (%rax),%rsi          #put new string in %rsi.  
        movq $0,%rax                #set %rax to 0. 
        movq $printString,%rdi    #put the print format for the printf in %rdi.
        call printf
        movq $0,%rax                #set %rax to 0.
        
        #restore calle registers.
        popq %rsi
        popq %rdx
        popq %rdi
     
        #end case
        jmp .done
     
    #case default- the users option is not between 50-53.print an error. 
    .switch_Def:
     
        pushq %rdi                  #back up %rdi before using printf.
        movq $printErorCase,%rdi    #put the error print format for the printf in %rdi.  
        movq $0,%rax                #set %rax to 0.
        call printf
        movq $0,%rax                #set %rax to 0.
     
        popq %rdi                   #restore %rdi.
     
        #end case 
        jmp .done       
 
        #end of switch-case,restor calle registers and end the function.  
    .done:
        popq %r15
        popq %r14
        popq %r13
        popq %r12
        ret

