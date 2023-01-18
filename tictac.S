.data
//
// The Game description data structure
//
.equ game_rows, 0
.equ game_cols, 4
.equ game_array, 8
.equ game_size, 16
//
// The Game cell data structure
// This is the contents of a location in the array
//

.equ cell_expected, 0
.equ cell_actual, 4
.equ cell_size, 8
//
// Display data
//
item: .asciz "  %c"
new_line: .asciz "\n"
rows: .asciz "  %d"
cols: .asciz "%d"
.text

.global create_game

//
// Create the game abstract data type
// void *create_game(int rows, int cols)
//
create_game:
	stp x29, x30, [sp, #-16]!
	stp x19, x20, [sp, #-16]!
	stp x21, x22, [sp, #-16]!
    
	mov w19, w0	// rows
	mov w20, w1	// cols

 	mov w0, #1
	mov w1, #game_size
	bl calloc	// allocate 

	//
	// Set the data structure initial values
	//
	str w19, [x0, #game_rows]
	str w20, [x0, #game_cols]	

	mov x21, x0 // game pointer

	//
	// Allocate the game array
	//
	
	mul w0, w19, w20
	mov w1, #cell_size
	bl calloc

	str x0, [x21, #game_array]

	mov x0, x21

create_game_done:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
    
    
.global destroy_game
//
// void destroy_game(void *game)
// Destroy the game, freeing all memory
//
destroy_game:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    
    mov x19, x0

    ldr x0, [x19, #game_array]
    bl free    
    
    mov x0, x19
    bl free

    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
    
    
.global get_rows

//
// Get the number of rows in the game
// int get_rows(void *game)
//
get_rows:
    ldr w0, [x0, #game_rows] 
    ret

.global get_cols

//
// Get the number of columns in the game
// int get_cols(void *game)
//
get_cols:
    ldr w0, [x0, #game_cols]
    ret

.global display_game

//
// Display the game
//
display_game:
	stp x29, x30, [sp, #-16]!
	stp x19, x20, [sp, #-16]!
	stp x21, x22, [sp, #-16]!
    
	mov x19, x0
	mov w20, #1 //row
	mov w21, #1 //col

display_header_numbers:
	ldr w0, [x19, #game_rows]
	cmp w0, w20 
	blt display_header_numbers_finished	

	ldr x0, =rows
	mov w1, w20
	bl printf

	add w20, w20, #1
	b display_header_numbers	

display_header_numbers_finished:
	ldr x0, =new_line
	bl printf

	mov w20, #1 //row
	mov w21, #1 //col

display_grid_outer_loop:
	ldr w0, [x19, #game_cols]
	cmp w0, w21
	blt display_game_done

	ldr x0, =cols
	mov w1, w21
	bl printf

display_grid_inner_loop:
	ldr w0, [x19, #game_rows]
	cmp w0, w20
	blt display_grid_inner_loop_finished

	mov x0, x19
        mov w1, w20
        mov w2, w21
        bl game_index
	
        ldr w1, [x0, #cell_actual]
	ldr x0, =item
	bl printf	

	add w20, w20, #1
	b display_grid_inner_loop

display_grid_inner_loop_finished:
	ldr x0, =new_line
	bl printf

	mov w20, #1
	add w21, w21, #1
	b display_grid_outer_loop

display_game_done:
	ldr x0, =new_line
	bl printf

    	ldp x21, x22, [sp], #16
	ldp x19, x20, [sp], #16
	ldp x29, x30, [sp], #16
	ret


.global set_cell_actual

//
// int set_cell_actual(void *game, int row, int col, char ch);
// Returns: 1 if the answer value is correct
//
set_cell_actual:
	stp x29, x30, [sp, #-16]!
	stp x19, x20, [sp, #-16]!

	mov w19, w3
	bl game_index
	
	ldr w1, [x0, #cell_expected]
	str w19, [x0, #cell_actual]
	
	cmp w1, w19
	beq correct

	mov w0, #0
	b set_cell_actual_done

correct:
	mov w0, #1
	
set_cell_actual_done:
	ldp x19, x20, [sp], #16
	ldp x29, x30, [sp], #16
    ret

.global set_cell_expected

//
// void set_cell_expected(void *game, int row, int col, char ch);
//
set_cell_expected:
	stp x29, x30, [sp, #-16]!
	stp x19, x20, [sp, #-16]!
    
        mov w19, w3
	bl game_index
        
	str w19, [x0, #cell_expected] //save ch into game

	ldp x19, x20, [sp], #16
	ldp x29, x30, [sp], #16
    ret



.global game_win

//
// int game_win(void *game)
// Returns true when the game is done/won
//
game_win:
	stp x29, x30, [sp, #-16]!
	stp x19, x20, [sp, #-16]!
	stp x21, x22, [sp, #-16]!
	
	mov x19, x0
	mov w21, #1 //col
	mov w22, #1 //row

game_win_outer_loop:
	ldr w0, [x19, #game_cols]
	cmp w0, w21
	blt game_win_completed	

game_win_inner_loop:
	ldr w0, [x19, #game_rows]
	cmp w0, w22
	blt game_win_inner_loop_finish

	mov x0, x19
        mov w1, w22
        mov w2, w21
        bl game_index

	ldr w1, [x0, #cell_expected]
	ldr w2, [x0, #cell_actual]
	
	cmp w1, w2
	bne game_win_not_completed

	add w22, w22, #1
	b game_win_inner_loop	

game_win_inner_loop_finish:
	mov w20, #1
	add w21, w21, #1
	b game_win_outer_loop 
   
game_win_not_completed:
	mov w0, #0
	b game_win_done

game_win_completed:
	mov w0, #1
	b game_win_done	

game_win_done:
	ldp x21, x22, [sp], #16
	ldp x19, x20, [sp], #16
	ldp x29, x30, [sp], #16
	ret
    

.global game_index
//
// int *game_index(void *game, int row, int col)
// Get the address of a row and column in the cells
//   
game_index:

	sub w1, w1, #1
	sub w2, w2, #1
	
	ldr w3, [x0, #game_cols]
	ldr x4, [x0, #game_array]
	mov w5, #cell_size

	// array_adress + (row * (cols) + col) * cell_size
	mul w3, w3, w1
        add w3, w3, w2
	mul w3, w3, w5
	add x4, x4, w3, uxtw
	mov x0, x4
	ret
	

