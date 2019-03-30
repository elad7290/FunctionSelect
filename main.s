    #316429653 Tom Menashe
    .data
    .section    .rodata

getString: .string "%s"
getInt:    .string "%d" 

    .text
.global     main
    .type   main, @function
#main function gets from the user two strings ,their length and a number that represents
# the function that will be run.  
main:
    movq %rsp, %rbp #for correct debugging
    pushq %rbp                      #save old rbp(callee).
    movq %rsp,%rbp                  #frame pointer.   

    #save calle registers
    pushq %r14                      #save %r14.
    pushq %r15                      #save %r15.
    pushq %rbx
     
    
    #get user input- one integer,4 bytes.
    movq $0,%rax                    #set %rax to 0.
    addq $(-4),%rsp                 #allocate 4 bytes on the stack for the input.
    movq %rsp,%rsi                  #put the address of the input to %rsi(before getting it).
    movq $getInt,%rdi               #put the format for the scanf in %rdi.
    call scanf
    
    
    movl (%rsp),%r8d                #put the user input to %r8 as 4 byte.
    addq $(4),%rsp                  #free 4 bytes from the stack.
    
    #allocate space for first string  
    movl %r8d,%r10d                 #move the integer to %r10.
    negq %r10                       #mult %r10 with -1.
    addq $-2,%r10                   #add -2 to %r10 to allocte two extra bytes-for the length and \0.
    movq %r10,%rbx                  #keep the number of bytes allocated in %rbx.     
    addq %r10,%rsp                  #allocate bytes for the first string.
    movb %r8b,(%rsp)                #put the string length to the first byte allocated.
    
    #get input- first string
    movq $0,%rax                    #set %rax to 0.
    leaq 1(%rsp),%rsi               #set rsi to the second bytes allocated for the first string.
    movq $getString,%rdi            #set %rdi to be the format for string input.    
    call scanf 
      
    leaq (%rsp),%r15                #save the address of the string in %r15.
    

    #get input- secons string length - int 4 bytes
    movq $0,%rax                    #set %rax to 0.
    addq $(-4),%rsp                 #allocate 4 bytes on the stack for the input. 
    movq %rsp,%rsi                  #put the address of the input to %rsi(before getting it).
    movq $getInt,%rdi               #put the format for the scanf in %rdi.      
    call scanf
    
    
    movl (%rsp),%r9d                #put the user input to %r9 as 4 bytes. 
    addq $(4),%rsp                  #free 4 bytes from the stack.
    
    #allocate space for second string    
    movl %r9d,%r10d                 #move the integer to %r10.
    negq %r10                       #mult %r10 with -1.
    addq $-2,%r10                   #add -2 to %r10 to allocte two extra bytes-for the length and \0.
    movq %r10,%r14                  #keep the number of bytes allocated in %r14.
    addq %r10,%rsp                  #allocate bytes for the first string.
    movb %r9b,(%rsp)                #put the string length to the first byte allocated.
    
    #get input- second string  
    movq $0,%rax                    #set %rax to 0.
    leaq 1(%rsp),%rsi               #set rsi to the second bytes allocated for the second string. 
    movq $getString,%rdi            #set %rdi to be the format for string input.
    call scanf 
        

    #get input- run option -inger 4 bytes
    movq $0,%rax                    #set %rax to 0.
    addq $(-4),%rsp                 #allocate 4 bytes on the stack for the input.
    movq %rsp,%rsi                  #put the address of the input to %rsi(before getting it).
    movq $getInt,%rdi               #put the format for the scanf in %rdi.
    call scanf
    
    
    movl (%rsp),%r8d                #save option in %r8 -4 bytes
    addq $(4),%rsp                  #free 4 bytes from the stack
    movl %r8d,%edx                  #put the optin in %rdx,to use in the function
    

    #put the first string in %rdi and the second in %rsi and run the function. 
    leaq (%r15),%rdi
    leaq (%rsp),%rsi
    call run_func
    
    
    #clear stack
    #callee registers
    popq %rbx
    popq %r15
    popq %r14

    movq $0,%rax
    leaq (%rbp),%rsp                #free al memory in the stack
    popq %rbp                       #restore old %rbp
    ret
