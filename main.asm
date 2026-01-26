# =========================================================
# Library Management System
# =========================================================

.data

nl:						.asciiz "\n"
arrow:					.asciiz " -> "
left_arrow:				.asciiz " <- "
empty_wl:				.asciiz "(empty)\n"
msg_full:				.asciiz "Array full!\n"
msg_id:					.asciiz "ID: "
msg_year:				.asciiz "  Year: "
msg_title:				.asciiz "Title: "
msg_status:				.asciiz "Status: "
msg_categories:			.asciiz "Categories: "
msg_nonecats:			.asciiz "(none)\n"
msg_avail:				.asciiz "Available\n"
msg_loan:				.asciiz "On Loan to "
msg_wait:				.asciiz "Waitlist: "
msg_checked_out:		.asciiz "Checked out: "
msg_returned:			.asciiz "Returned: "
msg_noholds:			.asciiz "No holds\n"
msg_already_avail:		.asciiz "Already available: "
msg_already_for:		.asciiz "Already on loan: "
msg_held_by:			.asciiz " - held by "
msg_noholds_for:		.asciiz "No holds for: "
msg_wait_added:			.asciiz "Added to waitlist: "
msg_catalog_header:		.asciiz "===== BOOK CATALOGUE ====="
msg_separator:			.asciiz "---------------------------"
msg_booklist_created:	.asciiz "Book list created (capacity=4, count=0)\n"
msg_added_prefix:		.asciiz "Book added to list: "
comma_space:			.asciiz ", "

t_clean:	.asciiz "Clean Code"
t_os:		.asciiz "Operating Systems"
t_net:		.asciiz "Computer Networks"

c_prog:		.asciiz "programming"
c_best:		.asciiz "best-practices"
c_sys:		.asciiz "systems"
c_edu:		.asciiz "education"
c_net:		.asciiz "networks"

p_Alice:	.asciiz "Alice"
p_Bob:		.asciiz "Bob"
p_Jane:		.asciiz "Jane"
p_Charlie:	.asciiz "Charlie"
p_David:	.asciiz "David"
p_Emma:		.asciiz "Emma"
p_Frank:	.asciiz "Frank"
p_Grace:	.asciiz "Grace"
p_Henry:	.asciiz "Henry"
p_Isla:		.asciiz "Isla"
p_Jack:		.asciiz "Jack"
p_Kate:		.asciiz "Kate"
p_Liam:		.asciiz "Liam"

.text


# --------------------- initBookArray ---------------------
initBookArray:
	li $a0, 12  # capacity in bytes for book catalog header 
	li $v0, 9  # syscall for sbrk
	syscall  # $v0 = address of new book catalog header
	move $t0, $v0  # $t0 = catalog header address
	li $a0, 16  # capacity in bytes for book array (4 books * 4 bytes per book pointer)
	li $v0, 9  # syscall for sbrk
	syscall  # $v0 = address of book array
	sw $v0, 0($t0)  # store address of book array at offset 0 of catalog header
	li $t1, 4  # $t1 = total capacity of book array = 4
	sw $t1, 4($t0)  # store total capacity at offset 4 of catalog header
	sw $zero, 8($t0)  # store initial number of elements as 0 at offset 8 of catalog header
	la $a0, msg_booklist_created  # print book list created message
	li $v0, 4  # syscall for print_string
	syscall
	move $v0, $t0  # return address of new book array header in $v0
	jr   $ra

# --------------------- initCategoryArray ---------------------
initCategoryArray:
	li $a0, 12  # capacity in bytes for category header
	li $v0, 9  # syscall for sbrk
	syscall  # $v0 = address of new category header
	move $t0, $v0  # $t0 = category header address
	li $a0, 16  # capacity in bytes for category array (4 categories * 4 bytes per category pointer)
	li $v0, 9  # syscall for sbrk
	syscall  # $v0 = addr of new category array
	sw $v0, 0($t0)  # store addr of category array at offset 0 of category header
	li $t1, 4  # $t1 = total capacity of category array = 4
	sw $t1, 4($t0)  # store total capacity at offset 4 of category header
	sw $zero, 8($t0)  # store initial number of elements as 0 at offset 8 of category header
	move $v0, $t0  # return address of new category array header in $v0
	jr   $ra

# --------------------- putOnCategory ---------------------
# a0 = category_hdr
# a1 = str_ptr
putOnCategory:
	lw $t0, 4($a0)  # $t0 = capacity
	lw $t1, 8($a0)  # $t1 = count 
	beq $t1, $t0, exitPutOnCategory  # if array is full (count==capacity), exit printing a message
	lw $t0, 0($a0)  # $t0 = base address of category array
	sll $t2, $t1, 2  # $t2 = count * 4 (byte offset)
	add $t0, $t0, $t2  # $t0 = base address + byte offset
	sw $a1, 0($t0)  # store str_ptr into next free slot
	addi $t1, $t1, 1  # increment count
	sw $t1, 8($a0)  # store new count into category header
	jr $ra  # exit here without executing the following 'array full case' 
	exitPutOnCategory: la $a0, msg_full  # print array full message
	li $v0, 4  # syscall for print_string
	syscall
	jr  $ra

# --------------------- createBook ---------------------
# a0 = id
# a1 = title_ptr
# a2 = year
# a3 = category_hdr
createBook:
	move $t0, $a0  # $t0 = id
	li $a0, 24  # capacity in bytes for book struct (6*4)
	li $v0, 9  # syscall for sbrk
	syscall  # $v0 = address of new book struct
	sw $t0, 0($v0)  # store id at offset 0 of book struct
	sw $a1, 4($v0)  # store title_ptr at offset 4 of book struct
	sw $a2, 8($v0)  # store year at offset 8 of book struct
	sw $zero, 12($v0)  # store status as 0 (available) at offset 12 of book struct
	sw $a3, 16($v0)  # store category_hdr at offset 16 of book struct
	sw $zero, 20($v0)  # store waitlist_head as 0 (none) at offset 20 of book struct
	jr   $ra  # return address of new book struct in $v0 (already in $v0)

# --------------------- addBook ---------------------
# a0 = catalog_hdr
# a1 = book*
addBook:
	lw $t0, 4($a0)  # $t0 = capacity
	lw $t1, 8($a0)  # $t1 = count
	li $v0, 4  # print_string
	beq $t1, $t0, exitAddBook  # if array is full (count==capacity), exit printing a message
	lw $t0, 0($a0)  # $t0 = base address of book array
	sll $t2, $t1, 2  # $t2 = count * 4 (byte offset)
	add $t0, $t0, $t2  # $t0 = base address + byte offset
	sw $a1, 0($t0)  # store book pointer into next free slot
	addi $t1, $t1, 1  # increment count
	sw $t1, 8($a0)  # store new count into catalog header
	la $a0, msg_added_prefix  # print book added message
	syscall
	lw $a0, 4($a1)  # print title
	syscall
	la $a0, nl  # print newline
	syscall
	jr $ra  # exit here without executing the following 'array full case'
	exitAddBook: la $a0, msg_full  # print array full message
	syscall
	jr  $ra

# --------------------- putOnWaitlistAt ---------------------
# a0 = catalog_hdr
# a1 = index
# a2 = name_ptr
putOnWaitlistAt:
	lw $t0, 0($a0)  # $t0 = catalog array base address
	sll $a1, $a1, 2  # $a1 = index * 4 (byte offset)
	add $t0, $t0, $a1  # $t0 = address of book pointer at the given index of catalog array (base+offset)
	lw $t0, 0($t0)  # $t0 = address of book struct ($t0 = book*)
	li $a0, 8  # capacity in bytes for waitlist node
	li $v0, 9  # syscall for sbrk
	syscall  # $v0 = address of new waitlist node
	sw $a2, 0($v0)  # store name_ptr into waitlist node
	sw $zero, 4($v0)  # set next pointer to 0 (new end node)
	addi $t1, $t0, 16  # just 1-word before waitlist head field as if it is the next ptr of a node
	loopPutOnWaitList: addi $t1, $t1, 4  # next node field address
	move $t2, $t1  # $t2 = next node field address
	lw $t1, 0($t1)  # $t1 = next node ptr
	bne $t1, $zero, loopPutOnWaitList  # loop through list until next node ptr is 0 (end node)
	sw $v0, 0($t2)  # set end node's next node ptr to new node
	li $v0, 4  # print_string
	la $a0, msg_wait_added  # print added to waitlist message
	syscall
	lw $a0, 4($t0)  # print book title
	syscall
	la $a0, left_arrow  # print left arrow
	syscall
	move $a0, $a2  # print borrower name
	syscall
	la $a0, nl  # print newline
	syscall
	jr   $ra

# --------------------- checkoutBookAt ---------------------
# a0 = catalog_hdr 
# a1 = index
checkoutBookAt:
	lw $t0, 0($a0)  # $t0 = catalog array base address
	sll $a1, $a1, 2  # $a1 = index * 4 (byte offset)
	add $t0, $t0, $a1  # $t0 = address of book pointer at the given index of catalog array (base+offset)
	lw $t0, 0($t0)  # $t0 = address of book struct
	lw $t1, 4($t0)  # $t1 = title
	lw $t2, 12($t0)  # $t2 = status
	li $v0, 4  # print_string
	bne $t2, $zero, exitCheckoutBookAt  # if status is not zero, the book is not available
	lw $t2, 20($t0)  # $t2 = waitlist_head (ptr to head node)
	beq $t2, $zero, exitCheckoutBookAt2  # if no one in waitlist, exit
	lw $t3, 4($t2)  # $t3 = next node ptr
	sw $t3, 20($t0)  # set next node as head node to delete the current head node
	sw $zero, 4($t2)  # delete the connection of previous head node
	lw $t2, 0($t2)  # $t2 = borrower name
	sw $t2, 12($t0)  # set status to borrower name
	la $a0, msg_checked_out  # print checked out message
	syscall
	move $a0, $t1  # print title
	syscall
	la $a0, arrow  # print right arrow
	syscall
	move $a0, $t2  # print person's name
	syscall
	la $a0, nl  # print newline
	syscall
	jr $ra  # exit here without executing the following cases
	exitCheckoutBookAt: la $a0, msg_already_for  # print already on loan message  
	syscall 
	move $a0, $t1  # print book title
	syscall
	la $a0, msg_held_by  # print held by message
	syscall
	move $a0, $t2  # print person's name
	syscall
	la $a0, nl  # print newline
	syscall
	jr   $ra  # exit here without executing the following case
	exitCheckoutBookAt2: la $a0, msg_noholds_for  # print no holds for message
	syscall
	move $a0, $t1  # print book title
	syscall
	la $a0, nl  # print newline
	syscall
	jr $ra


# --------------------- returnBookAt ---------------------
# a0 = catalog_hdr
# a1 = index
returnBookAt:
	lw $t0, 0($a0)  # $t0 = catalog array base address
	sll $a1, $a1, 2  # $a1 = index * 4 (byte offset)
	add $t0, $t0, $a1  # $t0 = address of book pointer at the given index of catalog array (base+offset)
	lw $t0, 0($t0)  # $t0 = address of book struct
	lw $t1, 4($t0)  # $t1 = title
	lw $t2, 12($t0)  # $t2 = status
	li $v0, 4  # for print_string
	beq $t2, $zero, exitReturnBookAt  # if available (status==0), exit with related message
	sw $zero, 12($t0)  # if not available, set status to 0 to make available
	la $a0, msg_returned  # print returned message
	syscall
	move $a0, $t1  # print book title
	syscall
	la $a0, left_arrow  # print left arrow
	syscall
	move $a0, $t2  # print borrower name
	syscall
	la $a0, nl  # print newline
	syscall
	jr $ra  # exit here not to execute the following case
	exitReturnBookAt: la $a0, msg_already_avail  # print already available message
	syscall
	move $a0, $t1  # print book title
	syscall
	la $a0, nl  # print newline
	syscall
	jr   $ra

# ====================== printBookList (calls printBook) ======================
# a0 = catalog_hdr
printBookList:
	addi $sp, $sp, -12  # allocate space on stack
	sw $ra, 0($sp)  # store $ra in memory
	sw $s0, 4($sp)  # store callee-save register $s0 in memory
	sw $s1, 8($sp)  # store callee-save register $s1 in memory
	li $v0, 4  # print_string
	move $s0, $a0  # $s0 = catalog_hdr
	la $a0, nl  # print newline
	syscall
	la $a0, msg_catalog_header  # print 'BOOK CATALOGUE'
	syscall
	la $a0, nl  # print newline
	syscall
	lw $s1, 8($s0)  # $s1 = count
	lw $s0, 0($s0)  # $s0 = catalog array base address
	loopPrintBookList: beq $s1, $zero, exitPrintBookList  # if count is not zero, loop through catalog and print books
	lw $a0, 0($s0)  # $a0 = pointer to next book to print
	jal printBook  # call printBook subroutine
	addi $s0, $s0, 4  # increment array base address 1 word (4 bytes)
	addi $s1, $s1, -1  # decrement loop counter
	li $v0, 4  # print_string
	la $a0, msg_separator  # print a separator '---------'
	syscall
	la $a0, nl  # print newline
	syscall
	j loopPrintBookList
	exitPrintBookList: la $a0, nl  # print newline
	syscall
	lw $ra, 0($sp)  # load $ra back
	lw $s0, 4($sp)  # load $s0 back
	lw $s1, 8($sp)  # load $s1 back
	addi $sp, $sp, 12  # adjust stack pointer
	jr   $ra


# ====================== printBook (calls printCategories & printWaitlist) ======================
# a0 = book*
printBook:
	addi $sp, $sp, -12  # allocate space on stack
	sw $ra, 0($sp)  # store $ra in memory
	sw $s0, 4($sp)  # store callee-save register $s0 in memory
	sw $s1, 8($sp)  # store callee-save register $s1 in memory
	li $v0, 4  # print_string
	move $s0, $a0  # $s0 = book*
	la $a0, msg_title  # print title prefix
	syscall
	lw $a0, 4($s0)  # print book title
	syscall
	la $a0, nl  # print newline
	syscall
	la $a0, msg_id  # print id prefix
	syscall
	li $v0, 1  # print_int
	lw $a0, 0($s0)  # print book id
	syscall
	li $v0, 4  # print_string
	la $a0, msg_year  # print year prefix
	syscall
	li $v0, 1  # print_int
	lw $a0, 8($s0)  # print book's year
	syscall
	li $v0, 4  # print_string
	la $a0, nl  # print newline
	syscall
	la $a0, msg_status  # print status prefix 
	syscall
	lw $s1, 12($s0)  # print book status
	beq $s1, $zero, printAvailable  # if status == 0, print available
	la $a0, msg_loan  # otherwise, print borrower's name with 'on loan to' prefix
	syscall
	move $a0, $s1
	syscall
	la $a0, nl  # print newline
	syscall
	j continuePrintBook  # borrower name printed, skip printAvailable
	printAvailable: la $a0, msg_avail
	syscall  # print available and continue
	continuePrintBook: lw $a0, 16($s0)  # $a0 = pointer to category array header
	jal printCategories  # print categories
	lw $a0, 20($s0)  # $a0 = pointer to the head of the waitlist (or 0)
	jal printWaitlist  # print waitlist
	lw $ra, 0($sp)  # load $ra back
	lw $s0, 4($sp)  # load $s0 back
	lw $s1, 8($sp)  # load $s1 back
	addi $sp, $sp, 12  # adjust stack pointer
	jr   $ra


# ====================== printCategories(category_hdr*) ======================
# a0 = category_hdr
printCategories:
	lw $t0, 0($a0)  # $t0 = category array base address
	lw $t1, 8($a0)  # $t1 = count
	li $v0, 4  # for print_string
	la $a0, msg_categories  # print categories prefix
	syscall
	beq $t1, $zero, exitPrintCategories  # if empty, exit printing the related message
	lw $a0, 0($t0)  # print category name
	syscall
	addi $t1, $t1, -1
	loopPrintCategories: slt $t2, $zero, $t1  # if $t1 <= 0 (count <= 0), exit
	beq $t2, $zero, exitPrintCategories2
	la $a0, comma_space  # print comma and space
	syscall
	lw $a0, 4($t0)  # print category name
	syscall
	addi $t1, $t1, -1  # decrement loop counter
	addi $t0, $t0, 4  # increment array base address by 1 word (4 bytes)
	j loopPrintCategories
	exitPrintCategories: la $a0, msg_nonecats  # if empty, print none message
	syscall
	jr $ra
	exitPrintCategories2: la $a0, nl  # print newline
	syscall
	jr   $ra


# ====================== printWaitlist(waitlist_head*) ======================
# a0 = head (node* or 0)
printWaitlist:
	li $v0, 4  # print_string
	beq $a0, $zero, exitPrintWaitList  # if waitlist is empty, then exit with empty message
	move $t0, $a0  # $t0 = ptr to head node
	lw $t1, 0($t0)  # $t1 = ptr to person's name
	la $a0, msg_wait  # print waitlist prefix
	syscall
	move $a0, $t1
	syscall
	lw $t0, 4($t0)  # $t0 = next node ptr
	loopPrintWaitlist: beq $t0, $zero, exitPrintWaitList2  # if no next node, exit printing a newline
	la $a0, arrow  # print right arrow
	syscall
	lw $a0, 0($t0)  # $a0 = string address
	syscall
	lw $t0, 4($t0)  # $t0 = next node ptr
	j loopPrintWaitlist
	exitPrintWaitList: la $a0, msg_wait  # print waitlist prefix
	syscall
	la $a0, empty_wl  # print empty 
	syscall
	jr $ra
	exitPrintWaitList2: la $a0, nl  # print newline
	syscall
	jr   $ra



# ====================== MAIN ======================
main:
	# Create and fill the catalog
	jal  initBookArray
	move $s0, $v0

	jal  initCategoryArray
	move $s1, $v0
	move $a0, $s1
	la   $a1, c_prog
	jal  putOnCategory
	move $a0, $s1
	la   $a1, c_best
	jal  putOnCategory
	move $a0, $s1
	la   $a1, c_edu
	jal  putOnCategory
	li   $a0, 123
	la   $a1, t_clean
	li   $a2, 1999
	move $a3, $s1
	jal  createBook
	move $a0, $s0
	move $a1, $v0
	jal  addBook

	jal  initCategoryArray
	move $s1, $v0
	move $a0, $s1
	la   $a1, c_sys
	jal  putOnCategory
	move $a0, $s1
	la   $a1, c_edu
	jal  putOnCategory
	li   $a0, 55
	la   $a1, t_os
	li   $a2, 2014
	move $a3, $s1
	jal  createBook
	move $a0, $s0
	move $a1, $v0
	jal  addBook

	jal  initCategoryArray
	move $s1, $v0
	move $a0, $s1
	la   $a1, c_net
	jal  putOnCategory
	move $a0, $s1
	la   $a1, c_edu
	jal  putOnCategory
	li   $a0, 310
	la   $a1, t_net
	li   $a2, 2011
	move $a3, $s1
	jal  createBook
	move $a0, $s0
	move $a1, $v0
	jal  addBook

	# Set up waitlists
	move $a0, $s0
	li   $a1, 0
	la   $a2, p_Alice
	jal  putOnWaitlistAt
	move $a0, $s0
	li   $a1, 0
	la   $a2, p_Bob
	jal  putOnWaitlistAt
	move $a0, $s0
	li   $a1, 0
	la   $a2, p_Charlie
	jal  putOnWaitlistAt
	move $a0, $s0
	li   $a1, 0
	la   $a2, p_David
	jal  putOnWaitlistAt
	move $a0, $s0
	li   $a1, 0
	la   $a2, p_Emma
	jal  putOnWaitlistAt

	move $a0, $s0
	li   $a1, 1
	la   $a2, p_Jane
	jal  putOnWaitlistAt
	move $a0, $s0
	li   $a1, 1
	la   $a2, p_Grace
	jal  putOnWaitlistAt
	move $a0, $s0
	li   $a1, 1
	la   $a2, p_Henry
	jal  putOnWaitlistAt

	move $a0, $s0
	li   $a1, 2
	la   $a2, p_Jack
	jal  putOnWaitlistAt
	move $a0, $s0
	li   $a1, 2
	la   $a2, p_Kate
	jal  putOnWaitlistAt
	move $a0, $s0
	li   $a1, 2
	la   $a2, p_Liam
	jal  putOnWaitlistAt
	move $a0, $s0
	li   $a1, 2
	la   $a2, p_Isla
	jal  putOnWaitlistAt
	move $a0, $s0
	li   $a1, 2
	la   $a2, p_Frank
	jal  putOnWaitlistAt

	# Initial full view
	move $a0, $s0
	jal  printBookList

	# Batch A: checkout #0, checkout #1, return #2, then print once
	move $a0, $s0
	li   $a1, 0
	jal  checkoutBookAt
	move $a0, $s0
	li   $a1, 1
	jal  checkoutBookAt
	move $a0, $s0
	li   $a1, 2
	jal  returnBookAt
	move $a0, $s0
	jal  printBookList

	# Batch B: checkout #2, checkout #0, return #1, then print once
	move $a0, $s0
	li   $a1, 2
	jal  checkoutBookAt
	move $a0, $s0
	li   $a1, 0
	jal  checkoutBookAt
	move $a0, $s0
	li   $a1, 1
	jal  returnBookAt
	move $a0, $s0
	jal  printBookList

	# Batch C: return #0, checkout #1, checkout #2, then print once
	move $a0, $s0
	li   $a1, 0
	jal  returnBookAt
	move $a0, $s0
	li   $a1, 1
	jal  checkoutBookAt
	move $a0, $s0
	li   $a1, 2
	jal  checkoutBookAt
	move $a0, $s0
	jal  printBookList

	# Batch D: return #2, checkout #0, checkout #1, return #0, then print once
	move $a0, $s0
	li   $a1, 2
	jal  returnBookAt
	move $a0, $s0
	li   $a1, 0
	jal  checkoutBookAt
	move $a0, $s0
	li   $a1, 1
	jal  checkoutBookAt
	move $a0, $s0
	li   $a1, 0
	jal  returnBookAt
	move $a0, $s0
	jal  printBookList

	# Batch E: checkout #0, return #1, checkout #2, return #2, checkout #1, then print once
	move $a0, $s0
	li   $a1, 0
	jal  checkoutBookAt
	move $a0, $s0
	li   $a1, 1
	jal  returnBookAt
	move $a0, $s0
	li   $a1, 2
	jal  checkoutBookAt
	move $a0, $s0
	li   $a1, 2
	jal  returnBookAt
	move $a0, $s0
	li   $a1, 1
	jal  checkoutBookAt
	move $a0, $s0
	jal  printBookList

	# Batch F: final shuffle — return #0, checkout #0, checkout #2, return #1, checkout #1, then print once
	move $a0, $s0
	li   $a1, 0
	jal  returnBookAt
	move $a0, $s0
	li   $a1, 0
	jal  checkoutBookAt
	move $a0, $s0
	li   $a1, 2
	jal  checkoutBookAt
	move $a0, $s0
	li   $a1, 1
	jal  returnBookAt
	move $a0, $s0
    li   $a1, 1
    jal  checkoutBookAt
	move $a0, $s0
	jal  printBookList

	li   $v0, 10
	syscall