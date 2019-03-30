    #316429653 Tom Menashe
    .data
    .section    .rodata
printError: .string "invalid input!\n"

    .text

#replaceChar gets 3 parameter: adress of Pstring,old char,new char -the function
#replaces every appearance of the old char in the string to the new char.
.globl replaceChar
    .type replaceChar, @function    
replaceChar:   
   #back up callee registers.
   pushq %r12
   pushq %r13
   
   
   movq %rdi,%rax                   #put the %Pstring in the retun value
   movzbq (%rdi),%r12               #put string length in %r12
   movq $0,%r13                     #the counter =0
   
   #start of while loop.
   .while:
       incq %rdi                    #move to the next character in the string. 
       cmpq %r12,%r13               #check if we got to the end of the string(counter = size)
       je .endWhile                 #if yes go to end while.
       cmpb %sil,(%rdi)             #check if the the current character is equal to old char. 
       je .changeChar               #if yes go to change char.
       incq %r13                    #increase counter. 
       jmp .while                      
   
   #change the old character in the string to the new char.            
   .changeChar:
       movb %dl,(%rdi)
       incq %r13                    #increase counter.
       jmp .while                   #retun back to the while
   #end of loop
   .endWhile:
       #restore calle registers     
       popq %r13
       popq %r12
       ret
      
#the function gets a Pstring and returns its length.
.globl pstrlen
    .type pstrlen, @function      
pstrlen:
     movb (%rdi),%al                #put pstring length in %rax.
     ret   

#gets 2 pstrings and 2 indexes and puts the pstr2[i...j] in pstr1[i...j].
#if the indexes dont match the array bounds the function will print an error.
.globl pstrijcpy
     .type pstrijcpy, @function
pstrijcpy:
    #back up callee registers before using swapCase
    pushq %r12
    pushq %r13
    
    #save strings length in %r12 and %r13
    movzbq (%rdi),%r12
    movzbq (%rsi),%r13
    
    #check if i and j are correct.
    cmpb $0,%dl                     #if i<0
    jl .eror                        #print error
    cmpb $0,%cl                     #if j <0
    jl .eror                        #print error
    cmpb %dl,%r12b                  #if i<firts string length
    jle .eror                       #print error
    cmpb %cl,%r12b                  #if j<firts string length
    jle .eror                       #print error 
    cmpb %cl,%r13b                  #if j<second string length  
    jle .eror                       #print error
    cmpb %dl,%r13b                  #if i<second string length
    jle .eror                       #print error
    cmpb %dl,%cl                    #if i<second string length
    jl .eror                        #print error
    
    
    movb %dl,%bl                    #i = counter
    
    #save pstrings first address
    pushq %rdi
    pushq %rsi
    
    #get the addres of the start of the string
    incq %rdi
    incq %rsi
    
    #move two strings to the i charactar.
    addq %rdx,%rdi
    addq %rdx,%rsi 
    
    #start of while2
   .while2: 
        cmpb %bl,%cl               #if counter>j 
        jl .endWhile2              #end loop
        
        movb (%rsi),%r12b          #save second pstring char in %r12
        movb %r12b,(%rdi)          #put the char in %r12 to the first string in the current place.
        incb %bl                   #counter++.
        incq %rdi                  #first string ++.
        incq %rsi                  #second string ++. 
        jmp .while2
    
    
    #end of loop
   .endWhile2:
        #restore pstrings
        popq %rsi
        popq %rdi
        
        
        leaq (%rdi),%rax           #put dst string in %rax.
        #restor callee registers.
        popq %r13                  
        popq %r12
        ret 
     
   #invalid input from user- print error.          
   .eror:
        pushq %rdi                 #back up %rdi before printf                   
        movq $0,%rax               #set %rax to 0.
        movq $printError,%rdi      #put print error format in %rdi. 
        call printf
        
        popq %rdi                  #restore %rdi
        
        leaq (%rdi),%rax               #put dst string in %rax.
        
        #resore callee registers 
        popq %r13 
        popq %r12
        ret

#swapCase gets one parameter- a pstring.
#swapCase replaces each lowercase letter to capital letter and 
#each capital letter to lowercae letter.
#if the char is not a letter the function will not change it.  
.globl swapCase
    .type swapCase, @function  
swapCase:
     #back up callee registers.
     pushq %r12
     pushq %r13
     movzbq (%rdi),%r12               #put string length in %r12
     movq $0,%r13                     #the counter =0
     push %rdi                        #save pstring address 
     incq %rdi                        #get string start address
     
   .while3:
        cmpq %r12,%r13               #check if we got to the end of the string(counter = size)
        je .endWhile3                #end loop
        
        movzbq (%rdi),%rbx           #move char from string to %rbx
        cmpb $65,%bl                 #if char<65 
        jl .noChange                 #no need to change
        cmpb $90,%bl                 #if char <90
        jle .ChangeFromCapital       #change from Capital letter.          
        cmpb $122,%bl                #if char>122
        jg .noChange                 #no change
        cmpb $97,%bl                 #if char<97(91-96)
        jl .noChange                 #no change
        jmp .changeToCap             #else - (97-122) change to capital letter.
   
   #end while  
   .endWhile3:
        popq %rdi                    #restore %rbi.
        
        #callee registers.
        popq %r13
        popq %r12
        
        leaq (%rdi),%rax             #new string to %rax.
        ret
    
    #no need to change letter, increase counter and string.
   .noChange:
        incq %rdi
        incq %r13
        jmp .while3
   #change from capital letter  
   .ChangeFromCapital:
        addb $32,(%rdi)             #add 32 to the char to move from capital - (A-a = 32)
        incq %rdi                   #move one char in the string. 
        incq %r13                   #counter ++.
        jmp .while3                 #go back to while. 
    
   .changeToCap:
        addb $-32,(%rdi)            #add -32 to the char to move to capital - (A-a = 32)
        incq %rdi                   #move one char in the string.
        incq %r13                   #counter ++.
        jmp .while3                 #go back to while.
    
     

