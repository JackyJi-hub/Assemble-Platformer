#####################################################################
#
# CSCB58 Winter 2023 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Wenduo Ji, 1008158985, jiwenduo, jacky.ji@mail.utoronto.ca
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8 (update this as needed)
# - Unit height in pixels: 8 (update this as needed)
# - Display width in pixels: 512 (update this as needed)
# - Display height in pixels: 512 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 3 (choose the one the applies)
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. Health/score 2 marks
# 2. Fail condition 1 mark
# 3. Win condition 1 mark
# 4. Moving objects 2 marks
# 5. Moving platforms 2 marks
# 6. Start menu 1 makr
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
# https://play.library.utoronto.ca/watch/dca0dce8c0e971db82ba906b155ea547
# Are you OK with us sharing the video with people outside course staff?
# - no, and please share this project github link as well!
#
# Any additional information that the TA needs to know:
# none
#
#####################################################################

.eqv BASE_ADDRESS 0x10008000
.eqv REFRESH_RATE 70
.eqv SCREEN_WIDTH 256
.eqv PIXEL_SCREEN_WIDTH 63
.eqv GROUND_LAYER 16128
.eqv TOTAL_PIXEL 4096
# background color
.eqv OCEAN_BLUE 0x9BBFFF

# heart BG color
.eqv HEART_BG_COLOR 0x000000

# platform color
.eqv GRAY 0x949494

# colors for Spongebob
.eqv WHITE 0xffffff
.eqv YELLOW 0xeede1b
.eqv BROWN 0xf7b213

# colors for Mr. Crabs
.eqv RED 0xf71613
.eqv BLUE 0x1fa8e0

# colors for Patrick
.eqv PINK 0xff90f7
.eqv GREEN 0x00ff00

# color for falling object
.eqv LIGHT_PINK 0xf772e4
.eqv DARK_PINK 0xff26e0


.eqv SPAWN_RATE 12
.eqv INCREASE_SPAWN_RATE 100
.eqv MAX_FALLING_OBJ 6
.eqv MAX_SPAWN_WIDTH_FALLING_OBJ 52

.eqv UP 0
.eqv DOWN 1
.eqv LEFT 2
.eqv RIGHT 3

.eqv PLATFORM_LEN 10
.eqv TOTAL_STATIC_PLATFORMS 7
.eqv TOTAL_MOVING_PLATFORMS 2
.eqv PLATFORM_MOVE_SPACE 10

.eqv JUMP_HEIGHT 10

.eqv LIVES_BACKGROUND_WIDTH 7
.eqv LIVES_BACKGROUND_X 15856
.eqv LIVES 3

.eqv PICKUP_FLOAT_RATE 4

.data  
#3frameBuffer:	.space	0x80000 
selectOption:	.word	0

velX:		.word	0
velY:		.word	0
posX:		.word	5
posY:		.word	50
convertX:	.word	64
convertY:	.word	4

heartPosArray:	.word	15856, 14064, 12272
currentLives:	.word	3

numPlatform:	.word	7
platformX:	.word	20,37,27,15,30,2,42	# platform's x values
platformY:	.word	56,49,42,28,9,20,14	# platform's y values

movingPlatforms:	.word	8992, 5492	# position of moving platform in bitmap
movingPlatformDirection: .word	4

numFallingObj:	.word	0
fallingObjPos:	.space	32		# 8 falling objects

jumpCounter:	.word 	0
isGrounded:	.word	0
isHit:		.word	0

maxFallingObj:	.word	5
currentFrame:	.word	1

pickUpFloatUp:	.word	1
heartPickedUp:	.word	0

bruh:		.byte 'B'
.text
.globl main
main:

drawStartMenu:
	jal startScreen

startGame:
	# initialize variables
	li	$t0, 0
	sw	$t0, velX
	sw	$t0, velY
	sw	$t0, numFallingObj
	sw	$t0, jumpCounter
	sw	$t0, isGrounded
	sw	$t0, isHit
	sw	$t0, heartPickedUp
	
	li	$t0, 5
	sw	$t0, posX
	
	li	$t0, 50
	sw	$t0, posY
	
	li	$t0, 3
	sw	$t0, currentLives
	
	li	$t0, 1
	sw	$t0, currentFrame
	
	li	$t0, 8992
	la	$t1, movingPlatforms
	sw	$t0, 0($t1)
	
	li	$t0, 5492
	sw	$t0, 4($t1)
	
	li	$t0, 4
	sw	$t0, movingPlatformDirection
		


### this section is for drawing the background

	li 	$t0, BASE_ADDRESS	# load frame buffer addres
	li 	$t1, TOTAL_PIXEL		# the screen size in bitmap
	li 	$t2, OCEAN_BLUE		# load the background color
backgroundLoop:	
	sw   	$t2, 0($t0)
	addi 	$t0, $t0, 4 		# advance to next pixel position in display
	addi 	$t1, $t1, -1		# decrement number of pixels
	bnez 	$t1, backgroundLoop	# repeat while number of pixels is not zero
	
# this section is for drawing the ground
drawGround:
	li	$t5, 0			# i counter = 0
	li 	$t0, BASE_ADDRESS	# load frame buffer address
	addi	$t0, $t0, GROUND_LAYER
drawGroundLoop:
	bgt	$t5, PIXEL_SCREEN_WIDTH, endGroundLoop
	li 	$t1, GRAY 			# load gray
	sw	$t1, 0($t0)
	addi 	$t5, $t5, 1
	addi	$t0, $t0, 4
	j 	drawGroundLoop	
endGroundLoop:

# this section is for drawing the background of the hearts
drawHeartBG:
	li	$t0, 0			# i counter = 0
	li 	$t1, BASE_ADDRESS 	# load the base address of the bitmap
drawHeartBGNextLayer:
	li	$t2, 0			# j counter = 0
	addi	$t1, $t1, 228 		# move the i position to the next row
drawHeartBGLoop:
	li	$t3, HEART_BG_COLOR		# load gray
	sw	$t3, 0($t1)		# draw in one pixel
	
	addi 	$t2, $t2, 1		# j += 1
	addi	$t1, $t1, 4		# t4 += 4
	blt	$t2, LIVES_BACKGROUND_WIDTH, drawHeartBGLoop
	
	addi 	$t0, $t0, 1		# i += 1
	blt 	$t0, PIXEL_SCREEN_WIDTH, drawHeartBGNextLayer	
endDrawHeartBG:
	
	jal	drawHeart


#-----------------------------------------------------------------------------------------------------------------
# start of game loop
#----------------------------------------------------------------------------------------------------------------
gameUpdateLoop:
	addi	$v0, $zero, 32			# syscall sleep
	addi	$a0, $zero, REFRESH_RATE	# load in the sleep duration
	syscall
	
	lw	$t0, currentFrame	# load current frame
	addi	$t0, $t0, 1		# increment total frame number by 1
	sw	$t0, currentFrame	# save the total number of frames
	
	li	$t1, SPAWN_RATE		# load spawn rate
	div 	$t0, $t1		# frame / SPAWN_RATE
	mfhi 	$t2			# t2 = frame % SPAWN_RATE
	beqz	$t2, runSwapFallingObj	# check if frame % SPAWN_RATE == 0, if it is call spawnFallingObj
	j	noSwap
	
runSwapFallingObj:
	jal	spawnFallingObj		# used to spawn in new falling objects
noSwap:
	
	li	$t1, INCREASE_SPAWN_RATE	# load increase spawn rate
	div 	$t0, $t1			# frame / INCREASE_SPAWN_RATE
	mfhi 	$t2				# t2 = frame % INCREASE_SPAWN_RATE
	beqz	$t2, increaseSpawnRate		# check if frame % INCREASE_SPAWN_RATE == 0, if it is call increaseSpawnRate
	j	noIncrease
increaseSpawnRate:
	lw	$t1, maxFallingObj			# load current maxFallingObj
	beq	$t1, MAX_FALLING_OBJ, noIncrease	# check if reached total maximum possible falling objects
	addi 	$t1, $t1, 1				# add 1 to current maxFallingObj
	sw	$t1, maxFallingObj			# save maxFallingObj
	
noIncrease:
	jal	updateFallingObj	# used to draw out each falling object
	
	jal drawPlatform		# used to draw out all static platforms
	jal drawMovingPlatforms		# used to draw out all moving platforms

checkKeyPress:
	li 	$t1, 0xffff0000		# load address of where to get if keypress happened
	lw 	$t2, 0($t1)		# get if keypress happened
	beq	$t2, 0, noNewKeyPress
	
	lw	$t3, 0xffff0004		# get key that was pressed
	beq	$t3, 112, startGame	# if key press = 'p', restart the game
	beq	$t3, 119, moveUp	# if key press = 'w', jump

noNewKeyPress:
	lw	$t3, 0xffff0004		# get key that was pressed
	
	beq	$t3, 100, moveRight	# if key press = 'd', move right
	beq	$t3, 97, moveLeft	# else if key press = 'a', move left
	
	j	moveDown		# else move the character down
		
moveUp:
	li	$s3, UP		# s3 = direction of character
	add	$a0, $s3, $zero	# a0 = direction of character
	jal	updateCharacter
	
	j	exitMoving 	

moveDown:
	li	$s3, DOWN	# s3 = direction of character
	add	$a0, $s3, $zero	# a0 = direction of character
	jal	updateCharacter
	
	j	exitMoving
	
moveLeft:
	li	$s3, LEFT	# s3 = direction of character
	add	$a0, $s3, $zero	# a0 = direction of character
	jal	updateCharacter
	
	
	j	exitMoving
	
moveRight:
	li	$s3, RIGHT	# s3 = direction of character
	add	$a0, $s3, $zero	# a0 = direction of character
	jal	updateCharacter

	j	exitMoving

exitMoving:
	j 	gameUpdateLoop		# loop back to beginning

# this section is for updating the character's velocity as well as drawing in the character
updateCharacter:
	
	### This section is for updating and drawing the character
	# calculate the position in the bitmap
	lw 	$t0, posX		# load x coord into the stack
	addi 	$sp, $sp, -4
	sw	$t0, 0($sp)
	
	lw 	$t0, posY		# load y coord into the stack
	addi 	$sp, $sp, -4
	sw	$t0, 0($sp)
	
	jal calculatePosition		# call calculatePosition function
	
	lw $s1, 0($sp)			# get return value
	addi $sp, $sp, 4
	
	# calculate characters new velocity
	beq	$a0, UP, setVelocityUp
	beq	$a0, DOWN, setVelocityDown
	beq	$a0, LEFT, setVelocityLeft
	beq	$a0, RIGHT, setVelocityRight
	
exitVelocitySet:
	
	# this section is used to check if the character is currently 
	# in the process of jumping. If so, decrease the jumpCounter
	lw	$t1, jumpCounter	# load jumpCounter
	beqz  	$t1, skipJump		# check if # of jumps > 0, if not skip jump
	addi	$t1, $t1, -1		# if it is > 0, decrease the jumpCounter
	sw	$t1, jumpCounter	# save the new jumpCounter calculated

skipJump:

# this section is used to calculate the new x, y values based on the current velocity
calculateX:
	# calculate new x coord
	lw	$t1, velX		# load in the x velocity
	lw	$t2, posX		# t2 = xPos of character
	add	$t2, $t2, $t1		# t2 += velX, so calculate new x position
	
	# check if new coord is in the screen
	bltz 	$t2, noUpdateX
	bgt	$t2, 54, noUpdateX
	
	sw	$t2, posX		# if it is valid, save the new x position
	
	# calculate the x position in bitmap and save into s2
	li	$t3, 4			# t2 = 4
	mult	$t1, $t3		# velX * 4
	mflo	$s2			# s2 = velX * 4
	j	calculateY		# move onto calculating the new Y coordinate

# jump here if the x coordinate is not valid
noUpdateX:
	li	$s2, 0	# set the delta x to 0
	
# this section here is used to calculate the new Y coordinate based on the current velocity
calculateY:
	# calculate new Y coord
	lw 	$t1, velY		# load in the y velocity
	lw	$t2, posY		# t2 = yPos of character
	add	$t2, $t2, $t1		# t2 += velY, so calculate new y position
	
	# check if new coord is in the screen
	blt 	$t2, 4, noUpdateY
	bgt	$t2, 64, noUpdateY
	
	lw	$t3, isGrounded		# t3 = isGrounded
	beq	$t3, 0, checkGrounded	# if character is already grouned updateYCoord
	beq	$a0, UP, updateYCoord

checkGrounded:
	addi 	$sp, $sp, -4
	sw	$s1, 0($sp)		# load in the current bitmap location of the character as argument
	
	jal 	checkIfGrounded		# call the function
	
	lw	$t3, 0($sp)		# return 0 if not grounded, 1 if grounded
	addi	$sp, $sp, 4
	
	beq	$t3, 1, landedOnGround
	
updateYCoord:
	sw	$t2, posY		# if it is valid, save the new y position
	
	# calculate the y position in bitmap and save into s4
	lw 	$t1, velY		# load in the y velocity
	li	$t3, SCREEN_WIDTH	# t3 = SCREEN_WIDTH
	mult	$t1, $t3		# velY * SCREEN_WIDTH
	mflo	$s4			# s4 = velY * SCREEN_WIDTH
	li	$t5, 0			# t5 = 0
	sw	$t5, isGrounded		# set isGrounded to 0
	j	undrawCharacter

landedOnGround:
	li	$t5, 1			# t5 = 1
	sw	$t5, isGrounded		# set isGrounded to 1
	
# jump here if the y coordinate is not valid
noUpdateY:
	li	$s4, 0	# set the delta y to 0
	

undrawCharacter:
	li	$t1, OCEAN_BLUE		#undraw in the character
	sw	$t1, 0($s1)		
	sw	$t1, 8($s1)
	sw	$t1, -256($s1)
	sw	$t1, -252($s1)
	sw	$t1, -248($s1)
	sw	$t1, -512($s1)
	sw	$t1, -508($s1)
	sw	$t1, -504($s1)
	sw	$t1, -768($s1)
	sw	$t1, -764($s1)
	sw	$t1, -760($s1)
	sw	$t1, -1024($s1)
	sw	$t1, -1020($s1)
	sw	$t1, -1016($s1)
	
	# update to the new position
	add	$s1, $s1, $s2		# s0 += s2
	add	$s1, $s1, $s4		# s0 += s4
	
	li	$t1, WHITE		# draw in the character
	li	$t2, BROWN
	li	$t3, YELLOW
	
	lw	$t4, isHit			# load if the character was previously hit
	beq	$t4, 0, noCharacterColorChange	# check if the character was previously hit
	
	li	$t4, 0		# t4 = 0
	sw	$t4, isHit	# change the isHit status to false
	li	$t1, RED	# change the character color to red to signify character is hit
	li	$t2, RED
	li	$t3, RED
	
noCharacterColorChange:
	sw	$t1, 0($s1)		
	sw	$t1, 8($s1)
	sw	$t2, -256($s1)
	sw	$t2, -252($s1)
	sw	$t2, -248($s1)
	sw	$t3, -512($s1)
	sw	$t3, -508($s1)
	sw	$t3, -504($s1)
	sw	$t1, -768($s1)
	sw	$t3, -764($s1)
	sw	$t1, -760($s1)
	sw	$t3, -1024($s1)
	sw	$t3, -1020($s1)
	sw	$t3, -1016($s1)
	j gameUpdateLoop		# jump back to the start of the game loop
	
setVelocityUp:
	lw	$t4, isGrounded		# load in isGrounded
	lw	$t7, jumpCounter	# load in jumpCounter
	
	bnez 	$t7, noJump		# check if jumpCounter != 0, if true jump to noJump
	
	# if jumpCounter == 0, check if isGrounded == 0
	beq	$t4, 0, setVelocityDown	# if character is not on the ground, jump to setVelocityDown 
	# if jumpCounter == 0 && isGrounded
	addi	$t7, $t7, JUMP_HEIGHT	# t7 += JUMP_HEIGHT 
	sw	$t7, jumpCounter 	# save how many pixels left to jump
	addi	$t5, $zero, 0		# set x velocity to zero
	addi	$t6, $zero, -1	 	# set y velocity to -1, ie moving up
	sw	$t5, velX		# update velX in memory
	sw	$t6, velY		# update velY in memory
	
# jump here only if there are still jumps left, ie jumpCounter > 0
noJump:
	j exitVelocitySet
	
setVelocityDown:

	lw	$t7, jumpCounter	# load how many pixels to jump left
	beqz  	$t7, noJumpD		# check if there are still jumps left
	
	addi	$t6, $zero, -1 		# set y velocity to 1, ie still jumping
	j rest
	
noJumpD:
	addi	$t6, $zero, 1 		# set y velocity to 1, ie with gravity
	j rest

rest:
	addi	$t5, $zero, 0		# set x velocity to zero
	sw	$t5, velX		# update velX in memory
	sw	$t6, velY		# update velY in memory
	j exitVelocitySet
	
setVelocityLeft:

	lw	$t7, jumpCounter	# load how many pixels to jump left
	beqz  	$t7, noJumpL		# check if there are still jumps left
	
jumpL:
	addi	$t6, $zero, -1 		# set y velocity to 1, ie still jumping
	j restL
	
noJumpL:
	addi	$t6, $zero, 1 		# set y velocity to 1, ie with gravity
	j restL

restL:
	addi	$t5, $zero, -1		# set x velocity to -1
	
	sw	$t5, velX		# update velX in memory
	sw	$t6, velY		# update velY in memory
	j exitVelocitySet
	
setVelocityRight:
	lw	$t7, jumpCounter	# load how many pixels to jump left
	beqz  	$t7, noJumpR		# check if there are still jumps left
	
jumpR:
	addi	$t6, $zero, -1 		# set y velocity to 1, ie still jumping
	j restR
	
noJumpR:
	addi	$t6, $zero, 1 		# set y velocity to 1, ie with gravity
	j restR

restR:
	addi	$t5, $zero, 1		# set x velocity to 1
	
	sw	$t5, velX		# update velX in memory
	sw	$t6, velY		# update velY in memory
	j exitVelocitySet

# this section is for calculating the character's new position	
calculatePosition:
	
	lw	$t1, 0($sp)		# t1 = yPos of character
	addi 	$sp, $sp, 4
	lw	$t0, 0($sp)		# t0 = xPos of character
	addi 	$sp, $sp, 4
	
	lw	$t2, convertX		# t2 = 64
	mult	$t1, $t2		# yPos * 64
	mflo	$t3			# t3 = yPos * 64
	add	$t3, $t3, $t0		# t3 = yPos * 64 + xPos
	lw	$t2, convertY		# t2 = 4
	mult	$t3, $t2		# (yPos * 64 + xPos) * 4
	mflo	$t0			# t0 = (yPos * 64 + xPos) * 4
	
	li 	$t1, BASE_ADDRESS	# load frame buffer address
	add	$t0, $t1, $t0		# t0 = (yPos * 64 + xPos) * 4 + frame address
	
	addi 	$sp, $sp, -4
	sw	$t0, 0($sp)
	
	jr	$ra

checkIfGrounded:
	lw 	$t0, 0($sp)	# gets the current location of the character in the bitmap
	addi	$sp, $sp, 4
	
	# check if the spaces under character is a platform
	addi 	$t0, $t0, SCREEN_WIDTH	# get location under left foot
        
        lw    	$t1, 0($t0)        #t6 = color in the spot below the character (L)
        beq   	$t1, GRAY, onGround
        
        lw    	$t1, 4($t0)        #t6 = color in the spot below the character (M)
        beq   	$t1, GRAY, onGround
        
        lw    	$t1, 8($t0)        #t6 = color in the spot below the character (R)
        beq  	$t1, GRAY, onGround
        
        li    	$t7, 0
    	sw    	$t7, isGrounded
        j    	checkIfGroundedEnd

onGround:
    	li    	$t7, 1
    	sw    	$t7, isGrounded
    	
checkIfGroundedEnd:
    	addi 	$sp, $sp, -4
    	sw	$t7, 0($sp)
    	jr	$ra
   
# this section is for drawing the platforms 
drawPlatform:
	lw 	$s0, numPlatform	# s0 = i
	addi 	$s0, $s0, -1		# subtract 1 from numPlatforms since loop start with 0 index
drawPlatformLoop:
	bltz 	$s0, endPlatformDraw	# check if i < 0
	
	li 	$t1, 4		# t1 = 4
	mult 	$s0, $t1	# 4 * i
	mflo 	$t2		# t2 = 4 * i
	
	la 	$t6, platformX	# address of x coord array
	la 	$t7, platformY	# address of y coord array
	
	addi 	$sp, $sp, -4	# reallocate stack 
    	sw	$ra, 0($sp)	# save return address
    	
	add 	$t4, $t6, $t2	# t4 = address of x coord array + i * 4
	lw     	$t5, 0($t4)	# gets the x cord from array
    	addi   	$sp, $sp, -4	# prepareing stack
    	sw    	$t5, 0($sp)	# push x cord onto stack
    
    	add 	$t4, $t7, $t2	# t4 = address of y coord array + i * 4
	lw     	$t5, 0($t4)	# gets the y cord from array
    	addi   	$sp, $sp, -4	# prepareing stack
    	sw    	$t5, 0($sp)	# push y cord onto stack
    	
    
    	jal calculatePosition
    	
    	
    	lw 	$t1, 0($sp)	# gets the position of platform in bitmap
    	addi 	$sp, $sp, 4	# reallocate stack 
    	
    	lw	$ra, 0($sp)	# restore return address
    	addi 	$sp, $sp, 4	# reallocate stack
    	
	# paint the platform	
	li 	$t5, GRAY		# load the platform color
	li 	$t6, PLATFORM_LEN	# the screen size in bitmap
drawPlatformLoop2:	
	sw   	$t5, 0($t1)		# draw the platform pixel
	addi 	$t1, $t1, 4 		# advance to next pixel position in display
	addi 	$t6, $t6, -1		# decrement number of pixels
	bnez 	$t6, drawPlatformLoop2	# repeat while number of pixels is not zero

	# check if currently drawing last platform. If so draw end point
	li	$t2, TOTAL_STATIC_PLATFORMS
	addi	$t2, $t2, -1		# since array is 0 indexed
	beq	$s0, $t2, drawGoal	# check if drawing last platform
	addi	$t2, $t2, -1		# load in the index of the second last platform
	lw	$t3, heartPickedUp	# t3 = heartPickedUP
	beq	$t3, 1, noDrawGoal	# if heart picked up, do not draw in the heart 
	beq	$s0, $t2, drawPickUp	# check if drawing the second last platform
	j	noDrawGoal
	
drawGoal:
	addi 	$sp, $sp, -4	# reallocate stack 
    	sw	$ra, 0($sp)	# save return address
    	
    	addi 	$sp, $sp, -4	# reallocate stack 
    	sw	$t1, 0($sp)	# push the position of the last platform in bitmap
    	
	jal 	drawEndPoint	# draw in the end goal of the game
	
	lw	$ra, 0($sp)	# restore return address
    	addi 	$sp, $sp, 4	# reallocate stack
    	
    	j 	noDrawGoal
    	
drawPickUp:
	addi 	$sp, $sp, -4	# reallocate stack 
    	sw	$ra, 0($sp)	# save return address
    	
    	addi 	$sp, $sp, -4	# reallocate stack 
    	sw	$t1, 0($sp)	# push the position of the second last platform in bitmap
    	
	jal 	drawHeartPickUp	# draw in the pickup item of the game
	
	lw	$ra, 0($sp)	# restore return address
    	addi 	$sp, $sp, 4	# reallocate stack
    	
noDrawGoal:
	addi 	$s0, $s0, -1	# i -= 1
	
	
	j drawPlatformLoop
	
endPlatformDraw:
	jr 	$ra

drawEndPoint:
    	lw	$t0, 0($sp)	# pop the position of the last platform in bitmap
    	addi 	$sp, $sp, 4	# reallocate stack 
    	
    	addi	$t0, $t0, -260	# move the bitmap pointer above the platform
    	
	# this section checks if character has reached the end goal
checkReachGoal:	
	lw	$t5, -512($t0)			# load the color previously held in that block
	beq	$t5, YELLOW, winScreen		# check if collided with character
	beq	$t5, WHITE, winScreen
	beq	$t5, BROWN, winScreen
	
	lw	$t5, -520($t0)			# load the color previously held in that block
	beq	$t5, YELLOW, winScreen		# check if collided with character
	beq	$t5, WHITE, winScreen
	beq	$t5, BROWN, winScreen
    	
    	# draw in end goal
    	li	$t1, PINK	
    	li	$t2, GREEN
    	sw	$t1, 0($t0)	# draw feet
    	sw	$t1, -8($t0)
    	sw	$t1, -252($t0)	# draw waist
    	sw	$t2, -256($t0)
    	sw	$t2, -260($t0)
    	sw	$t2, -264($t0)
    	sw	$t1, -268($t0)
    	sw	$t1, -512($t0)	# draw head
    	sw	$t1, -516($t0)
    	sw	$t1, -520($t0)
    	sw	$t1, -772($t0)
    	
    	jr	$ra

# draw in the heart pickup item
drawHeartPickUp:
	# calculate where the pickup item is
	lw	$t0, 0($sp)	# pop the position of the second last platform in bitmap
    	addi 	$sp, $sp, 4	# reallocate stack 
    	
    	addi	$t0, $t0, -260	# move the bitmap pointer above the platform
    	
    	# this section checks if character has collected the heart pick up
checkHeartPickUp:		
	lw	$t5, -512($t0)			# load the color previously held in that block	
	lw	$t6, -520($t0)			# load the color previously held in that block
	
    	# undraw the heart pickup
	li	$t1, OCEAN_BLUE	
    	sw	$t1, 0($t0)	# first layer
    	sw	$t1, -252($t0)	# second layer
    	sw	$t1, -256($t0)
    	sw	$t1, -260($t0)
    	sw	$t1, -504($t0)	# third layer
    	sw	$t1, -508($t0)	
    	sw	$t1, -512($t0)	
    	sw	$t1, -516($t0)
    	sw	$t1, -520($t0)
    	sw	$t1, -776($t0)	# fourth layer
    	sw	$t1, -772($t0)	
    	sw	$t1, -768($t0)	
    	sw	$t1, -764($t0)
    	sw	$t1, -760($t0)
    	sw	$t1, -1020($t0)	# fifth layer
    	sw	$t1, -1028($t0)
    	
    	beq	$t5, YELLOW, pickedUpHeart		# check if collided with character
	beq	$t5, WHITE, pickedUpHeart
	beq	$t5, BROWN, pickedUpHeart
	
	beq	$t6, YELLOW, pickedUpHeart		# check if collided with character
	beq	$t6, WHITE, pickedUpHeart
	beq	$t6, BROWN, pickedUpHeart
    	
    	li	$t1, -256		# t1 = -256
    	lw	$t2, pickUpFloatUp	# check which direction the heart is floating in
    	mult	$t1, $t2		# -256 * direction of float
    	mflo	$t1			# t1 = -256 * direction of float
    	
    	lw	$t5, currentFrame	# load current frame
	
	li	$t6, PICKUP_FLOAT_RATE		# load spawn rate
	div 	$t5, $t6			# frame / PICKUP_FLOAT_RATE
	mfhi 	$t7				# t7 = frame % PICKUP_FLOAT_RATE
	beqz	$t7, changeFloatDirection	# check if frame % PPICKUP_FLOAT_RATE == 0, if it is call changeFloatDirection
	j	endFloatAnimationCalculation

changeFloatDirection:
    	beq	$t2, 1, floatDown	# check if currently floating up
    	j	floatUp			# change driection to float up
floatDown:
	li	$t2, 0			# t2 = 0
	sw	$t2, pickUpFloatUp	# save direction to float down
	j	endFloatAnimationCalculation	# jump to end animation
floatUp:
	li	$t2, 1			# t2 = 1
	sw	$t2, pickUpFloatUp	# save direction to float up
endFloatAnimationCalculation:
    	
    	add	$t0, $t0, $t1	# move the heart up or down
    
    	# draw in the heart pickup
    	li	$t1, RED	
    	sw	$t1, 0($t0)	# first layer
    	sw	$t1, -252($t0)	# second layer
    	sw	$t1, -256($t0)
    	sw	$t1, -260($t0)
    	sw	$t1, -504($t0)	# third layer
    	sw	$t1, -508($t0)	
    	sw	$t1, -512($t0)	
    	sw	$t1, -516($t0)
    	sw	$t1, -520($t0)
    	sw	$t1, -772($t0)	# fourth layer
    	sw	$t1, -764($t0)
	j	endDrawPickUp
	
pickedUpHeart:
	li	$t1, 1			# t1 = 1
	sw	$t1, heartPickedUp	# store heart was picked up
	
	lw	$t1, currentLives	# load the current amount of lives
	addi	$t1, $t1, 1		# add 1 to the current amount of lives
	bgt	$t1, LIVES, endDrawPickUp	# check if reached max hearts
	sw	$t1, currentLives
	
	addi 	$sp, $sp, -4	# reallocate stack 
    	sw	$ra, 0($sp)	# save return address
    	
	jal 	drawHeart	# draw in the hearts restored
	
	lw	$ra, 0($sp)	# restore return address
    	addi 	$sp, $sp, 4	# reallocate stack
    	
endDrawPickUp:
    	jr	$ra

drawMovingPlatforms:
	li	$s0, 0				# used to store whether a change in direction has occured
	li	$t0 TOTAL_MOVING_PLATFORMS	# load total moving platforms
	addi	$t0, $t0, -1			# -1 since array is 0 indexed
movingPlatformLoop:
	bltz 	$t0, endDrawMovingPlatforms	# check if number of falling objects < 0, if it is end the function
	
	li 	$t2, 4		# t2 = 4
	mult 	$t0, $t2	# t0 * 4
	mflo 	$t3		# t3 = 4 * t0
	la	$t1, movingPlatforms		# get the address of the moving platform array
	add	$t2, $t1, $t3	# t2 = the index position of the current moving platform in the array	
	
	li 	$t3, BASE_ADDRESS 	# load the base address of the bitmap
	lw	$t4, 0($t2)		# t4 = the position of the current moving platform object not in bitmap
	add	$t3, $t4, $t3		# t3 = the position of the current moving platform object in bitmap
	
	# undraw the moving platform 
	
	li 	$t5, OCEAN_BLUE		# load the background color
	li 	$t6, PLATFORM_LEN	# load the platform length
	
undrawMovingPlatform:	
	sw   	$t5, 0($t3)		# undraw the pixel
	addi 	$t3, $t3, 4 		# advance to next pixel position in display
	addi 	$t6, $t6, -1		# decrement number of pixels
	bnez 	$t6, undrawMovingPlatform	# repeat while number of pixels is not zero
		
	lw	$t5, currentFrame	# load current frame
	
	li	$t6, PLATFORM_MOVE_SPACE	# load spawn rate
	div 	$t5, $t6			# frame / PLATFORM_MOVE_SPACE
	mfhi 	$t7				# t7 = frame % PLATFORM_MOVE_SPACE
	beqz	$t7, platformChangeDirection	# check if frame % PLATFORM_MOVE_SPACE == 0, if it is call platformChangeDirection
	j	platformNoChangeDirection
	
platformChangeDirection:
	beq	$s0, 1, platformNoChangeDirection
	li	$s0, 1
	li	$t3, -1				# t3 = -1
	lw	$t5, movingPlatformDirection	# t5 = movingPlatformDirection
	mult	$t3, $t5			# -1 * movingPlatformDirection
	mflo	$t5				# t5 = -1 * movingPlatformDirection
	sw	$t5, movingPlatformDirection	# save t5 into movingPlatformDirection

platformNoChangeDirection:
	lw	$t5, movingPlatformDirection	# t5 = movingPlatformDirection
	add	$t4, $t4, $t5			# move the platform based on its direction
	sw	$t4, 0($t2)			# save the new position of the platform into the array
	
	li 	$t3, BASE_ADDRESS 	# load the base address of the bitmap	
	add 	$t3, $t4, $t3		# t3 = t4, ie the position of the current moving platform object in bitmap 
	
	li 	$t5, GRAY		# load the platform color
	li 	$t6, PLATFORM_LEN	# the screen size in bitmap
drawMovingPlatform:	
	sw   	$t5, 0($t3)		# draw the platform pixel
	addi 	$t3, $t3, 4 		# advance to next pixel position in display
	addi 	$t6, $t6, -1		# decrement number of pixels
	bnez 	$t6, drawMovingPlatform	# repeat while number of pixels is not zero
	
	
	addi	$t0, $t0, -1			# t0 -= 1, decrease loop counter
	j	movingPlatformLoop
	
endDrawMovingPlatforms:
	jr	$ra
		
spawnFallingObj:
	lw 	$t6, numFallingObj		# get number of falling objects currently
	lw	$t7, maxFallingObj		# get max number of objects
	beq	$t6, $t7, exitSwapFallingObj	# exit the function if reached max number of spawns	
	
	# generate a random x value to spawn in the falling object
	li $v0, 42	# set up the system call
	li $a0, 0	# set the id of the random number generator
	li $a1, MAX_SPAWN_WIDTH_FALLING_OBJ	# set max value of the random number generator
	syscall
	
	move $t0, $a0 			# get the result of generating a random number
	addi $t0, $t0, 1		# move object over by 1 because the falling object is 
					# rendered at the bottem left corner 
					# (dont want it to bleed to the other side of screen)
	li 	$t1, 4			# t1 = 4
	li 	$t2, BASE_ADDRESS 	# $t2 stores the base address for display

	mult 	$t0, $t1		# get the x coordinate in bitmap
	mflo	$t0			# t0 = 4 * random number generated 
	add 	$t0, $t0, $t2		# to get bitmap location
		
	mult	$t6, $t1		# numFallingObj * 4
	mflo	$t3			# t3 = numFallingObj * 4
	la	$t4, fallingObjPos	# get base address of the array of falling objects
	add	$t3, $t3, $t4		# get the array index of the current falling object
	sw	$t0, 0($t3)		# save the bitmap of the spawned object into the array
	
	addi	$t6, $t6, 1		# t2 += 1
	sw	$t6, numFallingObj	# save the new number of falling objects

	
exitSwapFallingObj:
	jr	$ra

updateFallingObj:
	lw	$s0, numFallingObj		# t0 = number of falling objects
    
	addi	$s0, $s0, -1			# t0 -= 1 since array index starts at 0

fallingObjLoop:
	bltz  	$s0, endUpdateFallingObj	# check if number of falling objects < 0, if it is end the function
	
    	la	$t1, fallingObjPos		# get the address of the falling obj array
	li 	$t2, 4		# t2 = 4
	mult 	$s0, $t2	# t0 * 4
	mflo 	$t3		# t3 = 4 * t0
	add	$s2, $t1, $t3	# s2 = the index position of the current falling obj in the array
	
	lw	$t4, 0($s2)	# t4 = the position of the current falling object in bitmap
	
	
	li	$t5, OCEAN_BLUE	# undraw the falling object
	sw	$t5, 0($t4)	# first layer
	sw	$t5, 4($t4)
	sw	$t5, 8($t4)
	sw	$t5, -256($t4)	# second layer
	sw	$t5, -252($t4)
	sw	$t5, -248($t4)
	sw	$t5, -512($t4)	# third layer
	sw	$t5, -508($t4)
	sw	$t5, -504($t4)
	sw	$t5, -772($t4)	# fourth layer
	sw	$t5, -764($t4)
	sw	$t5, -756($t4)
	sw	$t5, -1024($t4)	# fifth layer
	sw	$t5, -1012($t4)
	sw	$t5, -1284($t4)	# sixth layer
	sw	$t5, -1272($t4)
	
	addi	$t4, $t4, 256			# move the falling object down by 1 pixel
	addi	$s0, $s0, -1			# s0 -= 1, decrease loop counter
	
	li	$t5, GROUND_LAYER		# check if falling obj has hit the ground
	addi	$t5, $t5, BASE_ADDRESS		# load base address for bitmap
	blt 	$t4, $t5, checkIfHit		# checks if falling object is below the ground
	j	deleteFallingObj		# if it is jump

checkIfHit:	
	lw	$t5, 0($t4)			# load the color previously held in that block
	beq	$t5, YELLOW, characterHit	# check if collided with character
	beq	$t5, WHITE, characterHit
	beq	$t5, BROWN, characterHit
	
	lw	$t5, 8($t4)			# load the color previously held in that block
	beq	$t5, YELLOW, characterHit	# check if collided with character
	beq	$t5, WHITE, characterHit
	beq	$t5, BROWN, characterHit
	
drawFallingObj:
	
	sw	$t4, 0($s2)	# save the new position of the falling object into the array
	li	$t5, LIGHT_PINK	# draw the falling object
	li	$t6, DARK_PINK
	sw	$t5, 0($t4)	# first layer
	sw	$t6, 4($t4)
	sw	$t5, 8($t4)
	sw	$t6, -256($t4)	# second layer
	sw	$t5, -252($t4)
	sw	$t5, -248($t4)
	sw	$t5, -512($t4)	# third layer
	sw	$t5, -508($t4)
	sw	$t5, -504($t4)
	sw	$t5, -772($t4)	# fourth layer
	sw	$t5, -764($t4)
	sw	$t5, -756($t4)
	sw	$t5, -1024($t4)	# fifth layer
	sw	$t5, -1012($t4)
	sw	$t5, -1284($t4)	# sixth layer
	sw	$t5, -1272($t4)
	
	
	j	fallingObjLoop

# this section response to if a character gets hit
characterHit:
	li	$t6, 1		# t6 = 1
	sw	$t6, isHit	# save the isHit status to true
	
	addi 	$sp, $sp, -4	# reallocate stack 
    	sw	$ra, 0($sp)	# save return address
    	
	jal 	decreaseHearts	# call decreaseHearts to decrease number of lives left
	
	lw	$ra, 0($sp)	# restore return address
    	addi 	$sp, $sp, 4	# reallocate stack
    
# this section deletes the falling object	
deleteFallingObj:    	
	# generate a random x value to spawn in the falling object
	li $v0, 42	# set up the system call
	li $a0, 0	# set the id of the random number generator
	li $a1, MAX_SPAWN_WIDTH_FALLING_OBJ	# set max value of the random number generator
	syscall
	
	move $t5, $a0 			# get the result of generating a random number
	addi $t5, $t5, 1		# move object over by 1 because the falling object is 
					# rendered at the bottem left corner (dont want it to bleed 
					# to the other side of screen)
	li 	$t6, 4			# t6 = 4
	li 	$t7, BASE_ADDRESS 	# $t7 stores the base address for display

	mult 	$t5, $t6		# get the x coordinate in bitmap
	mflo	$t5			# t5 = 4 * random number generated 
	add 	$t5, $t5, $t7		# to get bitmap location
	sw	$t5, 0($s2)		# save the bitmap of the spawned object into the array
	
	j	fallingObjLoop
	
endUpdateFallingObj:
	jr	$ra
	
# this section is for drawing the hearts
drawHeart:
	li	$t0, 0			# i counter = 0
	la	$t1, heartPosArray	# load address of heart positions array
	li 	$t2, BASE_ADDRESS 	# load the base address of the bitmap
	lw	$t6, currentLives	# load the current number of lives
drawHeartLoop:
	lw	$t3, 0($t1)		# t3 = the position of the current moving platform object abs in bitmap
	add	$t3, $t2, $t3		# t3 = the position of the current moving platform object relative in bitmap
	
	li 	$t4, RED 		# load red
	li	$t5, WHITE		# load white
	sw	$t4, 0($t3)		# first layer
	sw	$t4, -260($t3)		# second layer
	sw	$t4, -256($t3)
	sw	$t4, -252($t3)
	sw	$t4, -520($t3)		# third layer
	sw	$t4, -516($t3)
	sw	$t4, -512($t3)
	sw	$t4, -508($t3)
	sw	$t4, -504($t3)
	sw	$t4, -776($t3)		# fourth layer
	sw	$t5, -772($t3)
	sw	$t4, -768($t3)
	sw	$t4, -764($t3)
	sw	$t4, -760($t3)
	sw	$t4, -1028($t3)		# fifth layer
	sw	$t4, -1020($t3)	
	
	addi 	$t0, $t0, 1
	addi	$t1, $t1, 4
	blt	$t0, $t6, drawHeartLoop
	j 	endDrawHeart	
endDrawHeart:
	jr	$ra
	
# this section is for decreasing the number of hearts
decreaseHearts:
	lw	$t0, currentLives	# load number of lives
	addi	$t0, $t0, -1		# decrease number of lives by 1
	sw	$t0, currentLives	# save new number of lives

# this section is for undrawing the hearts
undrawHeart:
	la	$t1, heartPosArray	# load address of heart positions array
	li 	$t2, BASE_ADDRESS 	# load the base address of the bitmap
	li	$t3, 4
	
	mult	$t0, $t3		# # of lives * 4
	mflo	$t3			# t3 = # of lives * 4 
	add	$t3, $t3, $t1		# t3 = index of the current heart in array
	lw	$t3, 0($t3)		# t3 = position of current heart in bitmap (abs)
	add	$t3, $t3, $t2		# t3 = position of current heart in bitmap (relative)
	
	li 	$t4, GRAY 		# load red
	sw	$t4, 0($t3)		# first layer
	sw	$t4, -260($t3)		# second layer
	sw	$t4, -256($t3)
	sw	$t4, -252($t3)
	sw	$t4, -520($t3)		# third layer
	sw	$t4, -516($t3)
	sw	$t4, -512($t3)
	sw	$t4, -508($t3)
	sw	$t4, -504($t3)
	sw	$t4, -776($t3)		# fourth layer
	sw	$t4, -772($t3)
	sw	$t4, -768($t3)
	sw	$t4, -764($t3)
	sw	$t4, -760($t3)
	sw	$t4, -1028($t3)		# fifth layer
	sw	$t4, -1020($t3)	
	
	beqz	$t0, loseScreen		# check if no more lives
	
	addi	$v0, $zero, 32			# syscall sleep
	addi	$a0, $zero, REFRESH_RATE	# load in the sleep duration
	syscall
	
	jr	$ra

	
test:
li $t1, BASE_ADDRESS # $t0 stores the base address for display
li $t3, 0xff0000 # $t1 stores the red colour code
sw $t3, 0($t1) # paint the first (top-left) unit red.
jr $ra


startScreen:
### this section is for drawing the background

	li 	$t0, BASE_ADDRESS	# load frame buffer addres
	li 	$t1, TOTAL_PIXEL		# the screen size in bitmap
	li 	$t2, OCEAN_BLUE		# load the background color
backgroundLoop1:	
	sw   	$t2, 0($t0)
	addi 	$t0, $t0, 4 		# advance to next pixel position in display
	addi 	$t1, $t1, -1		# decrement number of pixels
	bnez 	$t1, backgroundLoop1	# repeat while number of pixels is not zero

        la $t0, BASE_ADDRESS
        li $t1, 0x080808	# black
        li $t2, 0xffee4b	# yellow
        
        li $t4, 0xffffff	# white

        li $t6, 0xff0000	# red
        li $t7, 0x756846	# brown

        sw $t1, 520($t0)
        sw $t1, 524($t0)
        sw $t1, 528($t0)
        sw $t1, 532($t0)
        sw $t1, 536($t0)
        sw $t1, 540($t0)
        sw $t1, 552($t0)
        sw $t1, 556($t0)
        sw $t1, 560($t0)
        sw $t1, 564($t0)
        sw $t1, 568($t0)
        sw $t1, 572($t0)
        sw $t1, 584($t0)
        sw $t1, 588($t0)
        sw $t1, 608($t0)
        sw $t1, 612($t0)
        sw $t1, 624($t0)
        sw $t1, 628($t0)
        sw $t1, 632($t0)
        sw $t1, 636($t0)
        sw $t1, 640($t0)
        sw $t1, 644($t0)
        sw $t1, 776($t0)
        sw $t1, 780($t0)
        sw $t1, 784($t0)
        sw $t1, 788($t0)
        sw $t1, 792($t0)
        sw $t1, 796($t0)
        sw $t1, 808($t0)
        sw $t1, 812($t0)
        sw $t1, 816($t0)
        sw $t1, 820($t0)
        sw $t1, 824($t0)
        sw $t1, 828($t0)
        sw $t1, 840($t0)
        sw $t1, 844($t0)
        sw $t1, 864($t0)
        sw $t1, 868($t0)
        sw $t1, 880($t0)
        sw $t1, 884($t0)
        sw $t1, 888($t0)
        sw $t1, 892($t0)
        sw $t1, 896($t0)
        sw $t1, 900($t0)
        sw $t1, 1032($t0)
        sw $t1, 1036($t0)
        sw $t1, 1072($t0)
        sw $t1, 1076($t0)
        sw $t1, 1096($t0)
        sw $t1, 1100($t0)
        sw $t1, 1104($t0)
        sw $t1, 1108($t0)
        sw $t1, 1120($t0)
        sw $t1, 1124($t0)
        sw $t1, 1136($t0)
        sw $t1, 1140($t0)
        sw $t1, 1152($t0)
        sw $t1, 1156($t0)
        sw $t1, 1160($t0)
        sw $t1, 1164($t0)
        sw $t1, 1288($t0)
        sw $t1, 1292($t0)
        sw $t1, 1328($t0)
        sw $t1, 1332($t0)
        sw $t1, 1352($t0)
        sw $t1, 1356($t0)
        sw $t1, 1360($t0)
        sw $t1, 1364($t0)
        sw $t1, 1376($t0)
        sw $t1, 1380($t0)
        sw $t1, 1392($t0)
        sw $t1, 1396($t0)
        sw $t1, 1408($t0)
        sw $t1, 1412($t0)
        sw $t1, 1416($t0)
        sw $t1, 1420($t0)
        sw $t1, 1544($t0)
        sw $t1, 1548($t0)
        sw $t1, 1552($t0)
        sw $t1, 1556($t0)
        sw $t1, 1560($t0)
        sw $t1, 1564($t0)
        sw $t1, 1584($t0)
        sw $t1, 1588($t0)
        sw $t1, 1608($t0)
        sw $t1, 1612($t0)
        sw $t1, 1616($t0)
        sw $t1, 1620($t0)
        sw $t1, 1632($t0)
        sw $t1, 1636($t0)
        sw $t1, 1648($t0)
        sw $t1, 1652($t0)
        sw $t1, 1672($t0)
        sw $t1, 1676($t0)
        sw $t1, 1800($t0)
        sw $t1, 1804($t0)
        sw $t1, 1808($t0)
        sw $t1, 1812($t0)
        sw $t1, 1816($t0)
        sw $t1, 1820($t0)
        sw $t1, 1840($t0)
        sw $t1, 1844($t0)
        sw $t1, 1864($t0)
        sw $t1, 1868($t0)
        sw $t1, 1872($t0)
        sw $t1, 1876($t0)
        sw $t1, 1888($t0)
        sw $t1, 1892($t0)
        sw $t1, 1904($t0)
        sw $t1, 1908($t0)
        sw $t1, 1928($t0)
        sw $t1, 1932($t0)
        sw $t1, 2056($t0)
        sw $t1, 2060($t0)
        sw $t1, 2096($t0)
        sw $t1, 2100($t0)
        sw $t1, 2120($t0)
        sw $t1, 2124($t0)
        sw $t1, 2128($t0)
        sw $t1, 2132($t0)
        sw $t1, 2136($t0)
        sw $t1, 2140($t0)
        sw $t1, 2144($t0)
        sw $t1, 2148($t0)
        sw $t1, 2160($t0)
        sw $t1, 2164($t0)
        sw $t1, 2184($t0)
        sw $t1, 2188($t0)
        sw $t1, 2312($t0)
        sw $t1, 2316($t0)
        sw $t1, 2352($t0)
        sw $t1, 2356($t0)
        sw $t1, 2376($t0)
        sw $t1, 2380($t0)
        sw $t1, 2384($t0)
        sw $t1, 2388($t0)
        sw $t1, 2392($t0)
        sw $t1, 2396($t0)
        sw $t1, 2400($t0)
        sw $t1, 2404($t0)
        sw $t1, 2416($t0)
        sw $t1, 2420($t0)
        sw $t1, 2440($t0)
        sw $t1, 2444($t0)
        sw $t1, 2568($t0)
        sw $t1, 2572($t0)
        sw $t1, 2608($t0)
        sw $t1, 2612($t0)
        sw $t1, 2632($t0)
        sw $t1, 2636($t0)
        sw $t1, 2648($t0)
        sw $t1, 2652($t0)
        sw $t1, 2656($t0)
        sw $t1, 2660($t0)
        sw $t1, 2672($t0)
        sw $t1, 2676($t0)
        sw $t1, 2688($t0)
        sw $t1, 2692($t0)
        sw $t1, 2696($t0)
        sw $t1, 2700($t0)
        sw $t1, 2824($t0)
        sw $t1, 2828($t0)
        sw $t1, 2864($t0)
        sw $t1, 2868($t0)
        sw $t1, 2888($t0)
        sw $t1, 2892($t0)
        sw $t1, 2904($t0)
        sw $t1, 2908($t0)
        sw $t1, 2912($t0)
        sw $t1, 2916($t0)
        sw $t1, 2928($t0)
        sw $t1, 2932($t0)
        sw $t1, 2944($t0)
        sw $t1, 2948($t0)
        sw $t1, 2952($t0)
        sw $t1, 2956($t0)
        sw $t1, 3080($t0)
        sw $t1, 3084($t0)
        sw $t1, 3112($t0)
        sw $t1, 3116($t0)
        sw $t1, 3120($t0)
        sw $t1, 3124($t0)
        sw $t1, 3128($t0)
        sw $t1, 3132($t0)
        sw $t1, 3144($t0)
        sw $t1, 3148($t0)
        sw $t1, 3168($t0)
        sw $t1, 3172($t0)
        sw $t1, 3184($t0)
        sw $t1, 3188($t0)
        sw $t1, 3192($t0)
        sw $t1, 3196($t0)
        sw $t1, 3200($t0)
        sw $t1, 3204($t0)
        sw $t1, 3336($t0)
        sw $t1, 3340($t0)
        sw $t1, 3368($t0)
        sw $t1, 3372($t0)
        sw $t1, 3376($t0)
        sw $t1, 3380($t0)
        sw $t1, 3384($t0)
        sw $t1, 3388($t0)
        sw $t1, 3400($t0)
        sw $t1, 3404($t0)
        sw $t1, 3424($t0)
        sw $t1, 3428($t0)
        sw $t1, 3440($t0)
        sw $t1, 3444($t0)
        sw $t1, 3448($t0)
        sw $t1, 3452($t0)
        sw $t1, 3456($t0)
        sw $t1, 3460($t0)
        sw $t1, 4104($t0)
        sw $t1, 4108($t0)
        sw $t1, 4112($t0)
        sw $t1, 4116($t0)
        sw $t1, 4120($t0)
        sw $t1, 4124($t0)
        sw $t1, 4136($t0)
        sw $t1, 4140($t0)
        sw $t1, 4144($t0)
        sw $t1, 4148($t0)
        sw $t1, 4152($t0)
        sw $t1, 4156($t0)
        sw $t1, 4168($t0)
        sw $t1, 4172($t0)
        sw $t1, 4176($t0)
        sw $t1, 4180($t0)
        sw $t1, 4184($t0)
        sw $t1, 4188($t0)
        sw $t1, 4200($t0)
        sw $t1, 4204($t0)
        sw $t1, 4208($t0)
        sw $t1, 4212($t0)
        sw $t1, 4216($t0)
        sw $t1, 4220($t0)
        sw $t1, 4232($t0)
        sw $t1, 4236($t0)
        sw $t1, 4240($t0)
        sw $t1, 4244($t0)
        sw $t1, 4248($t0)
        sw $t1, 4252($t0)
        sw $t1, 4264($t0)
        sw $t1, 4268($t0)
        sw $t1, 4272($t0)
        sw $t1, 4276($t0)
        sw $t1, 4280($t0)
        sw $t1, 4284($t0)
        sw $t1, 4296($t0)
        sw $t1, 4300($t0)
        sw $t1, 4312($t0)
        sw $t1, 4316($t0)
        sw $t1, 4360($t0)
        sw $t1, 4364($t0)
        sw $t1, 4368($t0)
        sw $t1, 4372($t0)
        sw $t1, 4376($t0)
        sw $t1, 4380($t0)
        sw $t1, 4392($t0)
        sw $t1, 4396($t0)
        sw $t1, 4400($t0)
        sw $t1, 4404($t0)
        sw $t1, 4408($t0)
        sw $t1, 4412($t0)
        sw $t1, 4424($t0)
        sw $t1, 4428($t0)
        sw $t1, 4432($t0)
        sw $t1, 4436($t0)
        sw $t1, 4440($t0)
        sw $t1, 4444($t0)
        sw $t1, 4456($t0)
        sw $t1, 4460($t0)
        sw $t1, 4464($t0)
        sw $t1, 4468($t0)
        sw $t1, 4472($t0)
        sw $t1, 4476($t0)
        sw $t1, 4488($t0)
        sw $t1, 4492($t0)
        sw $t1, 4496($t0)
        sw $t1, 4500($t0)
        sw $t1, 4504($t0)
        sw $t1, 4508($t0)
        sw $t1, 4520($t0)
        sw $t1, 4524($t0)
        sw $t1, 4528($t0)
        sw $t1, 4532($t0)
        sw $t1, 4536($t0)
        sw $t1, 4540($t0)
        sw $t1, 4552($t0)
        sw $t1, 4556($t0)
        sw $t1, 4568($t0)
        sw $t1, 4572($t0)
        sw $t1, 4616($t0)
        sw $t1, 4620($t0)
        sw $t1, 4632($t0)
        sw $t1, 4636($t0)
        sw $t1, 4648($t0)
        sw $t1, 4652($t0)
        sw $t1, 4664($t0)
        sw $t1, 4668($t0)
        sw $t1, 4688($t0)
        sw $t1, 4692($t0)
        sw $t1, 4712($t0)
        sw $t1, 4716($t0)
        sw $t1, 4728($t0)
        sw $t1, 4732($t0)
        sw $t1, 4752($t0)
        sw $t1, 4756($t0)
        sw $t1, 4776($t0)
        sw $t1, 4780($t0)
        sw $t1, 4808($t0)
        sw $t1, 4812($t0)
        sw $t1, 4824($t0)
        sw $t1, 4828($t0)
        sw $t1, 4872($t0)
        sw $t1, 4876($t0)
        sw $t1, 4888($t0)
        sw $t1, 4892($t0)
        sw $t1, 4904($t0)
        sw $t1, 4908($t0)
        sw $t1, 4920($t0)
        sw $t1, 4924($t0)
        sw $t1, 4944($t0)
        sw $t1, 4948($t0)
        sw $t1, 4968($t0)
        sw $t1, 4972($t0)
        sw $t1, 4984($t0)
        sw $t1, 4988($t0)
        sw $t1, 5008($t0)
        sw $t1, 5012($t0)
        sw $t1, 5032($t0)
        sw $t1, 5036($t0)
        sw $t1, 5064($t0)
        sw $t1, 5068($t0)
        sw $t1, 5080($t0)
        sw $t1, 5084($t0)
        sw $t1, 5128($t0)
        sw $t1, 5132($t0)
        sw $t1, 5144($t0)
        sw $t1, 5148($t0)
        sw $t1, 5160($t0)
        sw $t1, 5164($t0)
        sw $t1, 5176($t0)
        sw $t1, 5180($t0)
        sw $t1, 5200($t0)
        sw $t1, 5204($t0)
        sw $t1, 5224($t0)
        sw $t1, 5228($t0)
        sw $t1, 5232($t0)
        sw $t1, 5236($t0)
        sw $t1, 5240($t0)
        sw $t1, 5244($t0)
        sw $t1, 5264($t0)
        sw $t1, 5268($t0)
        sw $t1, 5288($t0)
        sw $t1, 5292($t0)
        sw $t1, 5320($t0)
        sw $t1, 5324($t0)
        sw $t1, 5328($t0)
        sw $t1, 5332($t0)
        sw $t1, 5384($t0)
        sw $t1, 5388($t0)
        sw $t1, 5400($t0)
        sw $t1, 5404($t0)
        sw $t1, 5416($t0)
        sw $t1, 5420($t0)
        sw $t1, 5432($t0)
        sw $t1, 5436($t0)
        sw $t1, 5456($t0)
        sw $t1, 5460($t0)
        sw $t1, 5480($t0)
        sw $t1, 5484($t0)
        sw $t1, 5488($t0)
        sw $t1, 5492($t0)
        sw $t1, 5496($t0)
        sw $t1, 5500($t0)
        sw $t1, 5520($t0)
        sw $t1, 5524($t0)
        sw $t1, 5544($t0)
        sw $t1, 5548($t0)
        sw $t1, 5576($t0)
        sw $t1, 5580($t0)
        sw $t1, 5584($t0)
        sw $t1, 5588($t0)
        sw $t1, 5640($t0)
        sw $t1, 5644($t0)
        sw $t1, 5648($t0)
        sw $t1, 5652($t0)
        sw $t1, 5656($t0)
        sw $t1, 5660($t0)
        sw $t1, 5672($t0)
        sw $t1, 5676($t0)
        sw $t1, 5680($t0)
        sw $t1, 5684($t0)
        sw $t1, 5688($t0)
        sw $t1, 5692($t0)
        sw $t1, 5712($t0)
        sw $t1, 5716($t0)
        sw $t1, 5736($t0)
        sw $t1, 5740($t0)
        sw $t1, 5744($t0)
        sw $t1, 5748($t0)
        sw $t1, 5776($t0)
        sw $t1, 5780($t0)
        sw $t1, 5800($t0)
        sw $t1, 5804($t0)
        sw $t1, 5832($t0)
        sw $t1, 5836($t0)
        sw $t1, 5840($t0)
        sw $t1, 5844($t0)
        sw $t1, 5896($t0)
        sw $t1, 5900($t0)
        sw $t1, 5904($t0)
        sw $t1, 5908($t0)
        sw $t1, 5912($t0)
        sw $t1, 5916($t0)
        sw $t1, 5928($t0)
        sw $t1, 5932($t0)
        sw $t1, 5936($t0)
        sw $t1, 5940($t0)
        sw $t1, 5944($t0)
        sw $t1, 5948($t0)
        sw $t1, 5968($t0)
        sw $t1, 5972($t0)
        sw $t1, 5992($t0)
        sw $t1, 5996($t0)
        sw $t1, 6000($t0)
        sw $t1, 6004($t0)
        sw $t1, 6008($t0)
        sw $t1, 6032($t0)
        sw $t1, 6036($t0)
        sw $t1, 6056($t0)
        sw $t1, 6060($t0)
        sw $t1, 6088($t0)
        sw $t1, 6092($t0)
        sw $t1, 6096($t0)
        sw $t1, 6100($t0)
        sw $t1, 6152($t0)
        sw $t1, 6156($t0)
        sw $t1, 6184($t0)
        sw $t1, 6188($t0)
        sw $t1, 6200($t0)
        sw $t1, 6204($t0)
        sw $t1, 6224($t0)
        sw $t1, 6228($t0)
        sw $t1, 6248($t0)
        sw $t1, 6252($t0)
        sw $t1, 6260($t0)
        sw $t1, 6264($t0)
        sw $t1, 6268($t0)
        sw $t1, 6288($t0)
        sw $t1, 6292($t0)
        sw $t1, 6312($t0)
        sw $t1, 6316($t0)
        sw $t1, 6344($t0)
        sw $t1, 6348($t0)
        sw $t1, 6360($t0)
        sw $t1, 6364($t0)
        sw $t1, 6408($t0)
        sw $t1, 6412($t0)
        sw $t1, 6440($t0)
        sw $t1, 6444($t0)
        sw $t1, 6456($t0)
        sw $t1, 6460($t0)
        sw $t1, 6480($t0)
        sw $t1, 6484($t0)
        sw $t1, 6504($t0)
        sw $t1, 6508($t0)
        sw $t1, 6520($t0)
        sw $t1, 6524($t0)
        sw $t1, 6544($t0)
        sw $t1, 6548($t0)
        sw $t1, 6568($t0)
        sw $t1, 6572($t0)
        sw $t1, 6600($t0)
        sw $t1, 6604($t0)
        sw $t1, 6616($t0)
        sw $t1, 6620($t0)
        sw $t1, 6664($t0)
        sw $t1, 6668($t0)
        sw $t1, 6696($t0)
        sw $t1, 6700($t0)
        sw $t1, 6712($t0)
        sw $t1, 6716($t0)
        sw $t1, 6736($t0)
        sw $t1, 6740($t0)
        sw $t1, 6760($t0)
        sw $t1, 6764($t0)
        sw $t1, 6776($t0)
        sw $t1, 6780($t0)
        sw $t1, 6792($t0)
        sw $t1, 6796($t0)
        sw $t1, 6800($t0)
        sw $t1, 6804($t0)
        sw $t1, 6808($t0)
        sw $t1, 6812($t0)
        sw $t1, 6824($t0)
        sw $t1, 6828($t0)
        sw $t1, 6832($t0)
        sw $t1, 6836($t0)
        sw $t1, 6840($t0)
        sw $t1, 6844($t0)
        sw $t1, 6856($t0)
        sw $t1, 6860($t0)
        sw $t1, 6872($t0)
        sw $t1, 6876($t0)
        sw $t1, 6920($t0)
        sw $t1, 6924($t0)
        sw $t1, 6952($t0)
        sw $t1, 6956($t0)
        sw $t1, 6968($t0)
        sw $t1, 6972($t0)
        sw $t1, 6992($t0)
        sw $t1, 6996($t0)
        sw $t1, 7016($t0)
        sw $t1, 7020($t0)
        sw $t1, 7032($t0)
        sw $t1, 7036($t0)
        sw $t1, 7048($t0)
        sw $t1, 7052($t0)
        sw $t1, 7056($t0)
        sw $t1, 7060($t0)
        sw $t1, 7064($t0)
        sw $t1, 7068($t0)
        sw $t1, 7080($t0)
        sw $t1, 7084($t0)
        sw $t1, 7088($t0)
        sw $t1, 7092($t0)
        sw $t1, 7096($t0)
        sw $t1, 7100($t0)
        sw $t1, 7112($t0)
        sw $t1, 7116($t0)
        sw $t1, 7128($t0)
        sw $t1, 7132($t0)
        sw $t2, 7560($t0)
        sw $t2, 7564($t0)
        sw $t2, 7568($t0)
        sw $t2, 7572($t0)
        sw $t2, 7576($t0)
        sw $t2, 7580($t0)
        sw $t2, 7584($t0)
        sw $t2, 7588($t0)
        sw $t2, 7592($t0)
        sw $t2, 7596($t0)
        sw $t2, 7600($t0)
        sw $t2, 7604($t0)
        sw $t2, 7608($t0)
        sw $t2, 7612($t0)
        sw $t2, 7616($t0)
        sw $t2, 7620($t0)
        sw $t2, 7624($t0)
        sw $t2, 7628($t0)
        sw $t2, 7632($t0)
        sw $t2, 7636($t0)
        sw $t2, 7640($t0)
        sw $t2, 7644($t0)
        sw $t2, 7816($t0)
        sw $t2, 7820($t0)
        sw $t2, 7824($t0)
        sw $t2, 7828($t0)
        sw $t2, 7832($t0)
        sw $t2, 7836($t0)
        sw $t2, 7840($t0)
        sw $t2, 7844($t0)
        sw $t2, 7848($t0)
        sw $t2, 7852($t0)
        sw $t2, 7856($t0)
        sw $t2, 7860($t0)
        sw $t2, 7864($t0)
        sw $t2, 7868($t0)
        sw $t2, 7872($t0)
        sw $t2, 7876($t0)
        sw $t2, 7880($t0)
        sw $t2, 7884($t0)
        sw $t2, 7888($t0)
        sw $t2, 7892($t0)
        sw $t2, 7896($t0)
        sw $t2, 7900($t0)
        sw $t2, 8072($t0)
        sw $t2, 8076($t0)
        sw $t2, 8080($t0)
        sw $t2, 8084($t0)
        sw $t2, 8088($t0)
        sw $t2, 8092($t0)
        sw $t2, 8096($t0)
        sw $t2, 8100($t0)
        sw $t2, 8104($t0)
        sw $t2, 8108($t0)
        sw $t2, 8112($t0)
        sw $t2, 8116($t0)
        sw $t2, 8120($t0)
        sw $t2, 8124($t0)
        sw $t2, 8128($t0)
        sw $t2, 8132($t0)
        sw $t2, 8136($t0)
        sw $t2, 8140($t0)
        sw $t2, 8144($t0)
        sw $t2, 8148($t0)
        sw $t2, 8152($t0)
        sw $t2, 8156($t0)
        sw $t2, 8328($t0)
        sw $t2, 8332($t0)
        sw $t2, 8336($t0)
        sw $t2, 8340($t0)
        sw $t4, 8344($t0)
        sw $t4, 8348($t0)
        sw $t4, 8352($t0)
        sw $t4, 8356($t0)
        sw $t4, 8360($t0)
        sw $t4, 8364($t0)
        sw $t2, 8368($t0)
        sw $t2, 8372($t0)
        sw $t4, 8376($t0)
        sw $t4, 8380($t0)
        sw $t4, 8384($t0)
        sw $t4, 8388($t0)
        sw $t4, 8392($t0)
        sw $t4, 8396($t0)
        sw $t2, 8400($t0)
        sw $t2, 8404($t0)
        sw $t2, 8408($t0)
        sw $t2, 8412($t0)
        sw $t4, 8464($t0)
        sw $t4, 8468($t0)
        sw $t4, 8472($t0)
        sw $t4, 8476($t0)
        sw $t4, 8480($t0)
        sw $t4, 8484($t0)
        sw $t4, 8488($t0)
        sw $t4, 8492($t0)
        sw $t4, 8496($t0)
        sw $t4, 8500($t0)
        sw $t4, 8504($t0)
        sw $t4, 8508($t0)
        sw $t4, 8512($t0)
        sw $t4, 8516($t0)
        sw $t4, 8520($t0)
        sw $t4, 8524($t0)
        sw $t4, 8528($t0)
        sw $t4, 8532($t0)
        sw $t4, 8536($t0)
        sw $t4, 8540($t0)
        sw $t4, 8544($t0)
        sw $t2, 8584($t0)
        sw $t2, 8588($t0)
        sw $t2, 8592($t0)
        sw $t2, 8596($t0)
        sw $t4, 8600($t0)
        sw $t4, 8604($t0)
        sw $t4, 8608($t0)
        sw $t4, 8612($t0)
        sw $t4, 8616($t0)
        sw $t4, 8620($t0)
        sw $t2, 8624($t0)
        sw $t2, 8628($t0)
        sw $t4, 8632($t0)
        sw $t4, 8636($t0)
        sw $t4, 8640($t0)
        sw $t4, 8644($t0)
        sw $t4, 8648($t0)
        sw $t4, 8652($t0)
        sw $t2, 8656($t0)
        sw $t2, 8660($t0)
        sw $t2, 8664($t0)
        sw $t2, 8668($t0)
        sw $t4, 8716($t0)
        sw $t4, 8720($t0)
        sw $t4, 8736($t0)
        sw $t4, 8752($t0)
        sw $t4, 8768($t0)
        sw $t4, 8784($t0)
        sw $t4, 8800($t0)
        sw $t4, 8804($t0)
        sw $t2, 8840($t0)
        sw $t2, 8844($t0)
        sw $t2, 8848($t0)
        sw $t2, 8852($t0)
        sw $t4, 8856($t0)
        sw $t4, 8860($t0)
        sw $t4, 8872($t0)
        sw $t4, 8876($t0)
        sw $t2, 8880($t0)
        sw $t2, 8884($t0)
        sw $t4, 8888($t0)
        sw $t4, 8892($t0)
        sw $t4, 8904($t0)
        sw $t4, 8908($t0)
        sw $t2, 8912($t0)
        sw $t2, 8916($t0)
        sw $t2, 8920($t0)
        sw $t2, 8924($t0)
        sw $t4, 8972($t0)
        sw $t4, 8976($t0)
        sw $t4, 8984($t0)
        sw $t4, 8988($t0)
        sw $t4, 8992($t0)
        sw $t4, 8996($t0)
        sw $t4, 9004($t0)
        sw $t4, 9008($t0)
        sw $t4, 9016($t0)
        sw $t4, 9024($t0)
        sw $t4, 9032($t0)
        sw $t4, 9040($t0)
        sw $t4, 9044($t0)
        sw $t4, 9052($t0)
        sw $t4, 9056($t0)
        sw $t4, 9060($t0)
        sw $t2, 9096($t0)
        sw $t2, 9100($t0)
        sw $t2, 9104($t0)
        sw $t2, 9108($t0)
        sw $t4, 9112($t0)
        sw $t4, 9116($t0)
        sw $t4, 9128($t0)
        sw $t4, 9132($t0)
        sw $t2, 9136($t0)
        sw $t2, 9140($t0)
        sw $t4, 9144($t0)
        sw $t4, 9148($t0)
        sw $t4, 9160($t0)
        sw $t4, 9164($t0)
        sw $t2, 9168($t0)
        sw $t2, 9172($t0)
        sw $t2, 9176($t0)
        sw $t2, 9180($t0)
        sw $t4, 9228($t0)
        sw $t4, 9232($t0)
        sw $t4, 9248($t0)
        sw $t4, 9252($t0)
        sw $t4, 9260($t0)
        sw $t4, 9264($t0)
        sw $t4, 9272($t0)
        sw $t4, 9280($t0)
        sw $t4, 9296($t0)
        sw $t4, 9300($t0)
        sw $t4, 9308($t0)
        sw $t4, 9312($t0)
        sw $t4, 9316($t0)
        sw $t2, 9352($t0)
        sw $t2, 9356($t0)
        sw $t2, 9360($t0)
        sw $t2, 9364($t0)
        sw $t4, 9368($t0)
        sw $t4, 9372($t0)
        sw $t4, 9376($t0)
        sw $t4, 9380($t0)
        sw $t4, 9384($t0)
        sw $t4, 9388($t0)
        sw $t2, 9392($t0)
        sw $t2, 9396($t0)
        sw $t4, 9400($t0)
        sw $t4, 9404($t0)
        sw $t4, 9408($t0)
        sw $t4, 9412($t0)
        sw $t4, 9416($t0)
        sw $t4, 9420($t0)
        sw $t2, 9424($t0)
        sw $t2, 9428($t0)
        sw $t2, 9432($t0)
        sw $t2, 9436($t0)
        sw $t4, 9484($t0)
        sw $t4, 9488($t0)
        sw $t4, 9492($t0)
        sw $t4, 9496($t0)
        sw $t4, 9504($t0)
        sw $t4, 9508($t0)
        sw $t4, 9516($t0)
        sw $t4, 9520($t0)
        sw $t4, 9536($t0)
        sw $t4, 9548($t0)
        sw $t4, 9552($t0)
        sw $t4, 9556($t0)
        sw $t4, 9564($t0)
        sw $t4, 9568($t0)
        sw $t4, 9572($t0)
        sw $t2, 9608($t0)
        sw $t2, 9612($t0)
        sw $t2, 9616($t0)
        sw $t2, 9620($t0)
        sw $t4, 9624($t0)
        sw $t4, 9628($t0)
        sw $t4, 9632($t0)
        sw $t4, 9636($t0)
        sw $t4, 9640($t0)
        sw $t4, 9644($t0)
        sw $t2, 9648($t0)
        sw $t2, 9652($t0)
        sw $t4, 9656($t0)
        sw $t4, 9660($t0)
        sw $t4, 9664($t0)
        sw $t4, 9668($t0)
        sw $t4, 9672($t0)
        sw $t4, 9676($t0)
        sw $t2, 9680($t0)
        sw $t2, 9684($t0)
        sw $t2, 9688($t0)
        sw $t2, 9692($t0)
        sw $t4, 9740($t0)
        sw $t4, 9744($t0)
        sw $t4, 9760($t0)
        sw $t4, 9764($t0)
        sw $t4, 9772($t0)
        sw $t4, 9776($t0)
        sw $t4, 9784($t0)
        sw $t4, 9792($t0)
        sw $t4, 9800($t0)
        sw $t4, 9808($t0)
        sw $t4, 9812($t0)
        sw $t4, 9820($t0)
        sw $t4, 9824($t0)
        sw $t4, 9828($t0)
        sw $t2, 9864($t0)
        sw $t2, 9868($t0)
        sw $t2, 9872($t0)
        sw $t2, 9876($t0)
        sw $t2, 9880($t0)
        sw $t2, 9884($t0)
        sw $t2, 9888($t0)
        sw $t2, 9892($t0)
        sw $t2, 9896($t0)
        sw $t2, 9900($t0)
        sw $t2, 9904($t0)
        sw $t2, 9908($t0)
        sw $t2, 9912($t0)
        sw $t2, 9916($t0)
        sw $t2, 9920($t0)
        sw $t2, 9924($t0)
        sw $t2, 9928($t0)
        sw $t2, 9932($t0)
        sw $t2, 9936($t0)
        sw $t2, 9940($t0)
        sw $t2, 9944($t0)
        sw $t2, 9948($t0)
        sw $t4, 10000($t0)
        sw $t4, 10004($t0)
        sw $t4, 10008($t0)
        sw $t4, 10012($t0)
        sw $t4, 10016($t0)
        sw $t4, 10020($t0)
        sw $t4, 10024($t0)
        sw $t4, 10028($t0)
        sw $t4, 10032($t0)
        sw $t4, 10036($t0)
        sw $t4, 10040($t0)
        sw $t4, 10044($t0)
        sw $t4, 10048($t0)
        sw $t4, 10052($t0)
        sw $t4, 10056($t0)
        sw $t4, 10060($t0)
        sw $t4, 10064($t0)
        sw $t4, 10068($t0)
        sw $t4, 10072($t0)
        sw $t4, 10076($t0)
        sw $t4, 10080($t0)
        sw $t2, 10120($t0)
        sw $t2, 10124($t0)
        sw $t2, 10128($t0)
        sw $t2, 10132($t0)
        sw $t2, 10136($t0)
        sw $t2, 10140($t0)
        sw $t2, 10144($t0)
        sw $t2, 10148($t0)
        sw $t2, 10152($t0)
        sw $t2, 10156($t0)
        sw $t2, 10160($t0)
        sw $t2, 10164($t0)
        sw $t2, 10168($t0)
        sw $t2, 10172($t0)
        sw $t2, 10176($t0)
        sw $t2, 10180($t0)
        sw $t2, 10184($t0)
        sw $t2, 10188($t0)
        sw $t2, 10192($t0)
        sw $t2, 10196($t0)
        sw $t2, 10200($t0)
        sw $t2, 10204($t0)
        sw $t2, 10376($t0)
        sw $t2, 10380($t0)
        sw $t2, 10384($t0)
        sw $t2, 10388($t0)
        sw $t2, 10392($t0)
        sw $t2, 10396($t0)
        sw $t2, 10400($t0)
        sw $t2, 10404($t0)
        sw $t2, 10408($t0)
        sw $t2, 10412($t0)
        sw $t2, 10416($t0)
        sw $t2, 10420($t0)
        sw $t2, 10424($t0)
        sw $t2, 10428($t0)
        sw $t2, 10432($t0)
        sw $t2, 10436($t0)
        sw $t2, 10440($t0)
        sw $t2, 10444($t0)
        sw $t2, 10448($t0)
        sw $t2, 10452($t0)
        sw $t2, 10456($t0)
        sw $t2, 10460($t0)
        sw $t2, 10632($t0)
        sw $t2, 10636($t0)
        sw $t2, 10640($t0)
        sw $t2, 10644($t0)
        sw $t2, 10648($t0)
        sw $t2, 10652($t0)
        sw $t2, 10656($t0)
        sw $t2, 10660($t0)
        sw $t2, 10664($t0)
        sw $t2, 10668($t0)
        sw $t2, 10672($t0)
        sw $t2, 10676($t0)
        sw $t2, 10680($t0)
        sw $t2, 10684($t0)
        sw $t2, 10688($t0)
        sw $t2, 10692($t0)
        sw $t2, 10696($t0)
        sw $t2, 10700($t0)
        sw $t2, 10704($t0)
        sw $t2, 10708($t0)
        sw $t2, 10712($t0)
        sw $t2, 10716($t0)
        sw $t2, 10888($t0)
        sw $t2, 10892($t0)
        sw $t2, 10896($t0)
        sw $t2, 10900($t0)
        sw $t2, 10904($t0)
        sw $t2, 10908($t0)
        sw $t2, 10912($t0)
        sw $t2, 10916($t0)
        sw $t1, 10920($t0)
        sw $t1, 10924($t0)
        sw $t1, 10928($t0)
        sw $t1, 10932($t0)
        sw $t1, 10936($t0)
        sw $t1, 10940($t0)
        sw $t2, 10944($t0)
        sw $t2, 10948($t0)
        sw $t2, 10952($t0)
        sw $t2, 10956($t0)
        sw $t2, 10960($t0)
        sw $t2, 10964($t0)
        sw $t2, 10968($t0)
        sw $t2, 10972($t0)
        sw $t2, 11144($t0)
        sw $t2, 11148($t0)
        sw $t2, 11152($t0)
        sw $t2, 11156($t0)
        sw $t2, 11160($t0)
        sw $t2, 11164($t0)
        sw $t2, 11168($t0)
        sw $t2, 11172($t0)
        sw $t1, 11176($t0)
        sw $t1, 11180($t0)
        sw $t1, 11184($t0)
        sw $t1, 11188($t0)
        sw $t1, 11192($t0)
        sw $t1, 11196($t0)
        sw $t2, 11200($t0)
        sw $t2, 11204($t0)
        sw $t2, 11208($t0)
        sw $t2, 11212($t0)
        sw $t2, 11216($t0)
        sw $t2, 11220($t0)
        sw $t2, 11224($t0)
        sw $t2, 11228($t0)
        sw $t4, 11280($t0)
        sw $t4, 11284($t0)
        sw $t4, 11288($t0)
        sw $t4, 11292($t0)
        sw $t4, 11296($t0)
        sw $t4, 11300($t0)
        sw $t4, 11304($t0)
        sw $t4, 11308($t0)
        sw $t4, 11312($t0)
        sw $t4, 11316($t0)
        sw $t4, 11320($t0)
        sw $t4, 11324($t0)
        sw $t4, 11328($t0)
        sw $t4, 11332($t0)
        sw $t4, 11336($t0)
        sw $t4, 11340($t0)
        sw $t4, 11344($t0)
        sw $t4, 11348($t0)
        sw $t4, 11352($t0)
        sw $t4, 11356($t0)
        sw $t4, 11360($t0)
        sw $t2, 11400($t0)
        sw $t2, 11404($t0)
        sw $t2, 11408($t0)
        sw $t2, 11412($t0)
        sw $t2, 11416($t0)
        sw $t2, 11420($t0)
        sw $t2, 11424($t0)
        sw $t2, 11428($t0)
        sw $t1, 11432($t0)
        sw $t1, 11436($t0)
        sw $t6, 11440($t0)
        sw $t6, 11444($t0)
        sw $t1, 11448($t0)
        sw $t1, 11452($t0)
        sw $t2, 11456($t0)
        sw $t2, 11460($t0)
        sw $t2, 11464($t0)
        sw $t2, 11468($t0)
        sw $t2, 11472($t0)
        sw $t2, 11476($t0)
        sw $t2, 11480($t0)
        sw $t2, 11484($t0)
        sw $t4, 11532($t0)
        sw $t4, 11536($t0)
        sw $t4, 11540($t0)
        sw $t4, 11560($t0)
        sw $t4, 11568($t0)
        sw $t4, 11572($t0)
        sw $t4, 11580($t0)
        sw $t4, 11596($t0)
        sw $t4, 11612($t0)
        sw $t4, 11616($t0)
        sw $t4, 11620($t0)
        sw $t2, 11656($t0)
        sw $t2, 11660($t0)
        sw $t2, 11664($t0)
        sw $t2, 11668($t0)
        sw $t2, 11672($t0)
        sw $t2, 11676($t0)
        sw $t2, 11680($t0)
        sw $t2, 11684($t0)
        sw $t1, 11688($t0)
        sw $t1, 11692($t0)
        sw $t6, 11696($t0)
        sw $t6, 11700($t0)
        sw $t1, 11704($t0)
        sw $t1, 11708($t0)
        sw $t2, 11712($t0)
        sw $t2, 11716($t0)
        sw $t2, 11720($t0)
        sw $t2, 11724($t0)
        sw $t2, 11728($t0)
        sw $t2, 11732($t0)
        sw $t2, 11736($t0)
        sw $t2, 11740($t0)
        sw $t4, 11788($t0)
        sw $t4, 11792($t0)
        sw $t4, 11796($t0)
        sw $t4, 11804($t0)
        sw $t4, 11808($t0)
        sw $t4, 11816($t0)
        sw $t4, 11824($t0)
        sw $t4, 11828($t0)
        sw $t4, 11836($t0)
        sw $t4, 11840($t0)
        sw $t4, 11848($t0)
        sw $t4, 11852($t0)
        sw $t4, 11856($t0)
        sw $t4, 11864($t0)
        sw $t4, 11868($t0)
        sw $t4, 11872($t0)
        sw $t4, 11876($t0)
        sw $t2, 11912($t0)
        sw $t2, 11916($t0)
        sw $t2, 11920($t0)
        sw $t2, 11924($t0)
        sw $t2, 11928($t0)
        sw $t2, 11932($t0)
        sw $t2, 11936($t0)
        sw $t2, 11940($t0)
        sw $t2, 11944($t0)
        sw $t2, 11948($t0)
        sw $t2, 11952($t0)
        sw $t2, 11956($t0)
        sw $t2, 11960($t0)
        sw $t2, 11964($t0)
        sw $t2, 11968($t0)
        sw $t2, 11972($t0)
        sw $t2, 11976($t0)
        sw $t2, 11980($t0)
        sw $t2, 11984($t0)
        sw $t2, 11988($t0)
        sw $t2, 11992($t0)
        sw $t2, 11996($t0)
        sw $t4, 12044($t0)
        sw $t4, 12048($t0)
        sw $t4, 12052($t0)
        sw $t4, 12060($t0)
        sw $t4, 12064($t0)
        sw $t4, 12072($t0)
        sw $t4, 12080($t0)
        sw $t4, 12084($t0)
        sw $t4, 12092($t0)
        sw $t4, 12096($t0)
        sw $t4, 12104($t0)
        sw $t4, 12108($t0)
        sw $t4, 12112($t0)
        sw $t4, 12120($t0)
        sw $t4, 12124($t0)
        sw $t4, 12128($t0)
        sw $t4, 12132($t0)
        sw $t2, 12168($t0)
        sw $t2, 12172($t0)
        sw $t2, 12176($t0)
        sw $t2, 12180($t0)
        sw $t2, 12184($t0)
        sw $t2, 12188($t0)
        sw $t2, 12192($t0)
        sw $t2, 12196($t0)
        sw $t2, 12200($t0)
        sw $t2, 12204($t0)
        sw $t2, 12208($t0)
        sw $t2, 12212($t0)
        sw $t2, 12216($t0)
        sw $t2, 12220($t0)
        sw $t2, 12224($t0)
        sw $t2, 12228($t0)
        sw $t2, 12232($t0)
        sw $t2, 12236($t0)
        sw $t2, 12240($t0)
        sw $t2, 12244($t0)
        sw $t2, 12248($t0)
        sw $t2, 12252($t0)
        sw $t4, 12300($t0)
        sw $t4, 12304($t0)
        sw $t4, 12308($t0)
        sw $t4, 12316($t0)
        sw $t4, 12320($t0)
        sw $t4, 12328($t0)
        sw $t4, 12336($t0)
        sw $t4, 12340($t0)
        sw $t4, 12348($t0)
        sw $t4, 12352($t0)
        sw $t4, 12360($t0)
        sw $t4, 12364($t0)
        sw $t4, 12368($t0)
        sw $t4, 12376($t0)
        sw $t4, 12380($t0)
        sw $t4, 12384($t0)
        sw $t4, 12388($t0)
        sw $t2, 12416($t0)
        sw $t2, 12420($t0)
        sw $t4, 12424($t0)
        sw $t4, 12428($t0)
        sw $t4, 12432($t0)
        sw $t4, 12436($t0)
        sw $t4, 12440($t0)
        sw $t4, 12444($t0)
        sw $t4, 12448($t0)
        sw $t4, 12452($t0)
        sw $t6, 12456($t0)
        sw $t6, 12460($t0)
        sw $t6, 12464($t0)
        sw $t6, 12468($t0)
        sw $t6, 12472($t0)
        sw $t6, 12476($t0)
        sw $t4, 12480($t0)
        sw $t4, 12484($t0)
        sw $t4, 12488($t0)
        sw $t4, 12492($t0)
        sw $t4, 12496($t0)
        sw $t4, 12500($t0)
        sw $t4, 12504($t0)
        sw $t4, 12508($t0)
        sw $t2, 12512($t0)
        sw $t2, 12516($t0)
        sw $t4, 12556($t0)
        sw $t4, 12560($t0)
        sw $t4, 12564($t0)
        sw $t4, 12580($t0)
        sw $t4, 12584($t0)
        sw $t4, 12604($t0)
        sw $t4, 12620($t0)
        sw $t4, 12624($t0)
        sw $t4, 12632($t0)
        sw $t4, 12636($t0)
        sw $t4, 12640($t0)
        sw $t4, 12644($t0)
        sw $t2, 12672($t0)
        sw $t2, 12676($t0)
        sw $t4, 12680($t0)
        sw $t4, 12684($t0)
        sw $t4, 12688($t0)
        sw $t4, 12692($t0)
        sw $t4, 12696($t0)
        sw $t4, 12700($t0)
        sw $t4, 12704($t0)
        sw $t4, 12708($t0)
        sw $t6, 12712($t0)
        sw $t6, 12716($t0)
        sw $t6, 12720($t0)
        sw $t6, 12724($t0)
        sw $t6, 12728($t0)
        sw $t6, 12732($t0)
        sw $t4, 12736($t0)
        sw $t4, 12740($t0)
        sw $t4, 12744($t0)
        sw $t4, 12748($t0)
        sw $t4, 12752($t0)
        sw $t4, 12756($t0)
        sw $t4, 12760($t0)
        sw $t4, 12764($t0)
        sw $t2, 12768($t0)
        sw $t2, 12772($t0)
        sw $t4, 12816($t0)
        sw $t4, 12820($t0)
        sw $t4, 12824($t0)
        sw $t4, 12828($t0)
        sw $t4, 12832($t0)
        sw $t4, 12836($t0)
        sw $t4, 12840($t0)
        sw $t4, 12844($t0)
        sw $t4, 12848($t0)
        sw $t4, 12852($t0)
        sw $t4, 12856($t0)
        sw $t4, 12860($t0)
        sw $t4, 12864($t0)
        sw $t4, 12868($t0)
        sw $t4, 12872($t0)
        sw $t4, 12876($t0)
        sw $t4, 12880($t0)
        sw $t4, 12884($t0)
        sw $t4, 12888($t0)
        sw $t4, 12892($t0)
        sw $t4, 12896($t0)
        sw $t2, 12928($t0)
        sw $t2, 12932($t0)
        sw $t7, 12936($t0)
        sw $t7, 12940($t0)
        sw $t7, 12944($t0)
        sw $t7, 12948($t0)
        sw $t7, 12952($t0)
        sw $t7, 12956($t0)
        sw $t7, 12960($t0)
        sw $t7, 12964($t0)
        sw $t7, 12968($t0)
        sw $t7, 12972($t0)
        sw $t6, 12976($t0)
        sw $t6, 12980($t0)
        sw $t7, 12984($t0)
        sw $t7, 12988($t0)
        sw $t7, 12992($t0)
        sw $t7, 12996($t0)
        sw $t7, 13000($t0)
        sw $t7, 13004($t0)
        sw $t7, 13008($t0)
        sw $t7, 13012($t0)
        sw $t7, 13016($t0)
        sw $t7, 13020($t0)
        sw $t2, 13024($t0)
        sw $t2, 13028($t0)
        sw $t2, 13184($t0)
        sw $t2, 13188($t0)
        sw $t7, 13192($t0)
        sw $t7, 13196($t0)
        sw $t7, 13200($t0)
        sw $t7, 13204($t0)
        sw $t7, 13208($t0)
        sw $t7, 13212($t0)
        sw $t7, 13216($t0)
        sw $t7, 13220($t0)
        sw $t7, 13224($t0)
        sw $t7, 13228($t0)
        sw $t6, 13232($t0)
        sw $t6, 13236($t0)
        sw $t7, 13240($t0)
        sw $t7, 13244($t0)
        sw $t7, 13248($t0)
        sw $t7, 13252($t0)
        sw $t7, 13256($t0)
        sw $t7, 13260($t0)
        sw $t7, 13264($t0)
        sw $t7, 13268($t0)
        sw $t7, 13272($t0)
        sw $t7, 13276($t0)
        sw $t2, 13280($t0)
        sw $t2, 13284($t0)
        sw $t2, 13440($t0)
        sw $t2, 13444($t0)
        sw $t7, 13448($t0)
        sw $t7, 13452($t0)
        sw $t7, 13456($t0)
        sw $t7, 13460($t0)
        sw $t7, 13464($t0)
        sw $t7, 13468($t0)
        sw $t7, 13472($t0)
        sw $t7, 13476($t0)
        sw $t7, 13480($t0)
        sw $t7, 13484($t0)
        sw $t6, 13488($t0)
        sw $t6, 13492($t0)
        sw $t7, 13496($t0)
        sw $t7, 13500($t0)
        sw $t7, 13504($t0)
        sw $t7, 13508($t0)
        sw $t7, 13512($t0)
        sw $t7, 13516($t0)
        sw $t7, 13520($t0)
        sw $t7, 13524($t0)
        sw $t7, 13528($t0)
        sw $t7, 13532($t0)
        sw $t2, 13536($t0)
        sw $t2, 13540($t0)
        sw $t2, 13696($t0)
        sw $t2, 13700($t0)
        sw $t7, 13704($t0)
        sw $t7, 13708($t0)
        sw $t7, 13712($t0)
        sw $t7, 13716($t0)
        sw $t7, 13720($t0)
        sw $t7, 13724($t0)
        sw $t7, 13728($t0)
        sw $t7, 13732($t0)
        sw $t7, 13736($t0)
        sw $t7, 13740($t0)
        sw $t6, 13744($t0)
        sw $t6, 13748($t0)
        sw $t7, 13752($t0)
        sw $t7, 13756($t0)
        sw $t7, 13760($t0)
        sw $t7, 13764($t0)
        sw $t7, 13768($t0)
        sw $t7, 13772($t0)
        sw $t7, 13776($t0)
        sw $t7, 13780($t0)
        sw $t7, 13784($t0)
        sw $t7, 13788($t0)
        sw $t2, 13792($t0)
        sw $t2, 13796($t0)
        sw $t2, 13952($t0)
        sw $t2, 13956($t0)
        sw $t7, 13960($t0)
        sw $t7, 13964($t0)
        sw $t7, 13968($t0)
        sw $t7, 13972($t0)
        sw $t7, 13976($t0)
        sw $t7, 13980($t0)
        sw $t7, 13984($t0)
        sw $t7, 13988($t0)
        sw $t7, 13992($t0)
        sw $t7, 13996($t0)
        sw $t7, 14000($t0)
        sw $t7, 14004($t0)
        sw $t7, 14008($t0)
        sw $t7, 14012($t0)
        sw $t7, 14016($t0)
        sw $t7, 14020($t0)
        sw $t7, 14024($t0)
        sw $t7, 14028($t0)
        sw $t7, 14032($t0)
        sw $t7, 14036($t0)
        sw $t7, 14040($t0)
        sw $t7, 14044($t0)
        sw $t2, 14048($t0)
        sw $t2, 14052($t0)
        sw $t2, 14208($t0)
        sw $t2, 14212($t0)
        sw $t7, 14216($t0)
        sw $t7, 14220($t0)
        sw $t7, 14224($t0)
        sw $t7, 14228($t0)
        sw $t7, 14232($t0)
        sw $t7, 14236($t0)
        sw $t7, 14240($t0)
        sw $t7, 14244($t0)
        sw $t7, 14248($t0)
        sw $t7, 14252($t0)
        sw $t7, 14256($t0)
        sw $t7, 14260($t0)
        sw $t7, 14264($t0)
        sw $t7, 14268($t0)
        sw $t7, 14272($t0)
        sw $t7, 14276($t0)
        sw $t7, 14280($t0)
        sw $t7, 14284($t0)
        sw $t7, 14288($t0)
        sw $t7, 14292($t0)
        sw $t7, 14296($t0)
        sw $t7, 14300($t0)
        sw $t2, 14304($t0)
        sw $t2, 14308($t0)
        sw $t2, 14464($t0)
        sw $t2, 14468($t0)
        sw $t7, 14496($t0)
        sw $t7, 14500($t0)
        sw $t7, 14504($t0)
        sw $t7, 14508($t0)
        sw $t7, 14512($t0)
        sw $t7, 14516($t0)
        sw $t7, 14520($t0)
        sw $t7, 14524($t0)
        sw $t7, 14528($t0)
        sw $t7, 14532($t0)
        sw $t2, 14560($t0)
        sw $t2, 14564($t0)
        sw $t2, 14720($t0)
        sw $t2, 14724($t0)
        sw $t7, 14752($t0)
        sw $t7, 14756($t0)
        sw $t7, 14760($t0)
        sw $t7, 14764($t0)
        sw $t7, 14768($t0)
        sw $t7, 14772($t0)
        sw $t7, 14776($t0)
        sw $t7, 14780($t0)
        sw $t7, 14784($t0)
        sw $t7, 14788($t0)
        sw $t2, 14816($t0)
        sw $t2, 14820($t0)
        sw $t2, 15008($t0)
        sw $t2, 15012($t0)
        sw $t2, 15016($t0)
        sw $t2, 15020($t0)
        sw $t2, 15032($t0)
        sw $t2, 15036($t0)
        sw $t2, 15040($t0)
        sw $t2, 15044($t0)
        sw $t2, 15264($t0)
        sw $t2, 15268($t0)
        sw $t2, 15272($t0)
        sw $t2, 15276($t0)
        sw $t2, 15288($t0)
        sw $t2, 15292($t0)
        sw $t2, 15296($t0)
        sw $t2, 15300($t0)
        sw $t4, 15520($t0)
        sw $t4, 15524($t0)
        sw $t4, 15528($t0)
        sw $t4, 15532($t0)
        sw $t4, 15544($t0)
        sw $t4, 15548($t0)
        sw $t4, 15552($t0)
        sw $t4, 15556($t0)
        sw $t4, 15776($t0)
        sw $t4, 15780($t0)
        sw $t4, 15784($t0)
        sw $t4, 15788($t0)
        sw $t4, 15800($t0)
        sw $t4, 15804($t0)
        sw $t4, 15808($t0)
        sw $t4, 15812($t0)
        sw $t7, 16024($t0)
        sw $t7, 16028($t0)
        sw $t7, 16032($t0)
        sw $t7, 16036($t0)
        sw $t7, 16040($t0)
        sw $t7, 16044($t0)
        sw $t7, 16056($t0)
        sw $t7, 16060($t0)
        sw $t7, 16064($t0)
        sw $t7, 16068($t0)
        sw $t7, 16072($t0)
        sw $t7, 16076($t0)
        sw $t7, 16280($t0)
        sw $t7, 16284($t0)
        sw $t7, 16288($t0)
        sw $t7, 16292($t0)
        sw $t7, 16296($t0)
        sw $t7, 16300($t0)
        sw $t7, 16312($t0)
        sw $t7, 16316($t0)
        sw $t7, 16320($t0)
        sw $t7, 16324($t0)
        sw $t7, 16328($t0)
        sw $t7, 16332($t0)
        
startMenuLoop:
        lw 	$t3, selectOption	# t3 = selected option
        beq	$t3, 0, selectStart	# check if start was selected
        j	selectQuit		# else quit was selected
        
selectStart:
        li 	$t3, 0x6ed752	# set start to green
        li 	$t5, GRAY	# set quit to gray
        j	finishColorSet
        
selectQuit:
        li 	$t3, GRAY	# set start to gray
        li 	$t5, 0xd752ca	# set quit to purple
        
finishColorSet:
        sw $t3, 8204($t0)
        sw $t3, 8208($t0)
        sw $t3, 8212($t0)
        sw $t3, 8216($t0)
        sw $t3, 8220($t0)
        sw $t3, 8224($t0)
        sw $t3, 8228($t0)
        sw $t3, 8232($t0)
        sw $t3, 8236($t0)
        sw $t3, 8240($t0)
        sw $t3, 8244($t0)
        sw $t3, 8248($t0)
        sw $t3, 8252($t0)
        sw $t3, 8256($t0)
        sw $t3, 8260($t0)
        sw $t3, 8264($t0)
        sw $t3, 8268($t0)
        sw $t3, 8272($t0)
        sw $t3, 8276($t0)
        sw $t3, 8280($t0)
        sw $t3, 8284($t0)
        sw $t3, 8288($t0)
        sw $t3, 8292($t0)
        sw $t3, 8456($t0)
        sw $t3, 8460($t0)
        sw $t3, 8548($t0)
        sw $t3, 8552($t0)
        sw $t3, 8712($t0)
        sw $t3, 8724($t0)
        sw $t3, 8728($t0)
        sw $t3, 8732($t0)
        sw $t3, 8740($t0)
        sw $t3, 8744($t0)
        sw $t3, 8748($t0)
        sw $t3, 8756($t0)
        sw $t3, 8760($t0)
        sw $t3, 8764($t0)
        sw $t3, 8772($t0)
        sw $t3, 8776($t0)
        sw $t3, 8780($t0)
        sw $t3, 8788($t0)
        sw $t3, 8792($t0)
        sw $t3, 8796($t0)
        sw $t3, 8808($t0)
        sw $t3, 8968($t0)
        sw $t3, 8980($t0)
        sw $t3, 9000($t0)
        sw $t3, 9012($t0)
        sw $t3, 9020($t0)
        sw $t3, 9028($t0)
        sw $t3, 9036($t0)
        sw $t3, 9048($t0)
        sw $t3, 9064($t0)
        sw $t3, 9224($t0)
        sw $t3, 9236($t0)
        sw $t3, 9240($t0)
        sw $t3, 9244($t0)
        sw $t3, 9256($t0)
        sw $t3, 9268($t0)
        sw $t3, 9276($t0)
        sw $t3, 9284($t0)
        sw $t3, 9288($t0)
        sw $t3, 9292($t0)
        sw $t3, 9304($t0)
        sw $t3, 9320($t0)
        sw $t3, 9480($t0)
        sw $t3, 9500($t0)
        sw $t3, 9512($t0)
        sw $t3, 9524($t0)
        sw $t3, 9528($t0)
        sw $t3, 9532($t0)
        sw $t3, 9540($t0)
        sw $t3, 9544($t0)
        sw $t3, 9560($t0)
        sw $t3, 9576($t0)
        sw $t3, 9736($t0)
        sw $t3, 9748($t0)
        sw $t3, 9752($t0)
        sw $t3, 9756($t0)
        sw $t3, 9768($t0)
        sw $t3, 9780($t0)
        sw $t3, 9788($t0)
        sw $t3, 9796($t0)
        sw $t3, 9804($t0)
        sw $t3, 9816($t0)
        sw $t3, 9832($t0)
        sw $t3, 9992($t0)
        sw $t3, 9996($t0)
        sw $t3, 10084($t0)
        sw $t3, 10088($t0)
        sw $t3, 10252($t0)
        sw $t3, 10256($t0)
        sw $t3, 10260($t0)
        sw $t3, 10264($t0)
        sw $t3, 10268($t0)
        sw $t3, 10272($t0)
        sw $t3, 10276($t0)
        sw $t3, 10280($t0)
        sw $t3, 10284($t0)
        sw $t3, 10288($t0)
        sw $t3, 10292($t0)
        sw $t3, 10296($t0)
        sw $t3, 10300($t0)
        sw $t3, 10304($t0)
        sw $t3, 10308($t0)
        sw $t3, 10312($t0)
        sw $t3, 10316($t0)
        sw $t3, 10320($t0)
        sw $t3, 10324($t0)
        sw $t3, 10328($t0)
        sw $t3, 10332($t0)
        sw $t3, 10336($t0)
        sw $t3, 10340($t0)
        sw $t5, 11020($t0)
        sw $t5, 11024($t0)
        sw $t5, 11028($t0)
        sw $t5, 11032($t0)
        sw $t5, 11036($t0)
        sw $t5, 11040($t0)
        sw $t5, 11044($t0)
        sw $t5, 11048($t0)
        sw $t5, 11052($t0)
        sw $t5, 11056($t0)
        sw $t5, 11060($t0)
        sw $t5, 11064($t0)
        sw $t5, 11068($t0)
        sw $t5, 11072($t0)
        sw $t5, 11076($t0)
        sw $t5, 11080($t0)
        sw $t5, 11084($t0)
        sw $t5, 11088($t0)
        sw $t5, 11092($t0)
        sw $t5, 11096($t0)
        sw $t5, 11100($t0)
        sw $t5, 11104($t0)
        sw $t5, 11108($t0)
        sw $t5, 11272($t0)
        sw $t5, 11276($t0)
        sw $t5, 11364($t0)
        sw $t5, 11368($t0)
        sw $t5, 11528($t0)
        sw $t5, 11544($t0)
        sw $t5, 11548($t0)
        sw $t5, 11552($t0)
        sw $t5, 11556($t0)
        sw $t5, 11564($t0)
        sw $t5, 11576($t0)
        sw $t5, 11584($t0)
        sw $t5, 11588($t0)
        sw $t5, 11592($t0)
        sw $t5, 11600($t0)
        sw $t5, 11604($t0)
        sw $t5, 11608($t0)
        sw $t5, 11624($t0)
        sw $t5, 11784($t0)
        sw $t5, 11800($t0)
        sw $t5, 11812($t0)
        sw $t5, 11820($t0)
        sw $t5, 11832($t0)
        sw $t5, 11844($t0)
        sw $t5, 11860($t0)
        sw $t5, 11880($t0)
        sw $t5, 12040($t0)
        sw $t5, 12056($t0)
        sw $t5, 12068($t0)
        sw $t5, 12076($t0)
        sw $t5, 12088($t0)
        sw $t5, 12100($t0)
        sw $t5, 12116($t0)
        sw $t5, 12136($t0)
        sw $t5, 12296($t0)
        sw $t5, 12312($t0)
        sw $t5, 12324($t0)
        sw $t5, 12332($t0)
        sw $t5, 12344($t0)
        sw $t5, 12356($t0)
        sw $t5, 12372($t0)
        sw $t5, 12392($t0)
        sw $t5, 12552($t0)
        sw $t5, 12568($t0)
        sw $t5, 12572($t0)
        sw $t5, 12576($t0)
        sw $t5, 12588($t0)
        sw $t5, 12592($t0)
        sw $t5, 12596($t0)
        sw $t5, 12600($t0)
        sw $t5, 12608($t0)
        sw $t5, 12612($t0)
        sw $t5, 12616($t0)
        sw $t5, 12628($t0)
        sw $t5, 12648($t0)
        sw $t5, 12808($t0)
        sw $t5, 12812($t0)
        sw $t5, 12900($t0)
        sw $t5, 12904($t0)
        sw $t5, 13068($t0)
        sw $t5, 13072($t0)
        sw $t5, 13076($t0)
        sw $t5, 13080($t0)
        sw $t5, 13084($t0)
        sw $t5, 13088($t0)
        sw $t5, 13092($t0)
        sw $t5, 13096($t0)
        sw $t5, 13100($t0)
        sw $t5, 13104($t0)
        sw $t5, 13108($t0)
        sw $t5, 13112($t0)
        sw $t5, 13116($t0)
        sw $t5, 13120($t0)
        sw $t5, 13124($t0)
        sw $t5, 13128($t0)
        sw $t5, 13132($t0)
        sw $t5, 13136($t0)
        sw $t5, 13140($t0)
        sw $t5, 13144($t0)
        sw $t5, 13148($t0)
        sw $t5, 13152($t0)
        sw $t5, 13156($t0)
	
	li 	$t1, 0xffff0000		# load address of where to get if keypress happened
	lw 	$t2, 0($t1)		# get if keypress happened
	beq	$t2, 0, startMenuLoop	# check if a key was pressed
	
startMenuKeypressed:
	lw	$t2, 0xffff0004		# get key that was pressed
	
	addi	$v0, $zero, 32			# syscall sleep
	addi	$a0, $zero, REFRESH_RATE	# 40 ms
	syscall
	
	beq	$t2, 119, selectStartGame	# if key press = 'w' select start the game
	beq	$t2, 115, selectQuitGame	# if key press = 's' select quit the game
	beq	$t2, 10, optionSelected	
	j startMenuLoop			# loop back again
		
selectStartGame:
	li	$t2, 0	
	sw 	$t2, selectOption	# save the new selection
	j	endSelect
	
selectQuitGame:
	li	$t2, 1	
	sw 	$t2, selectOption	# save the new selection
		
endSelect:
	j startMenuLoop			# loop back again
	
optionSelected:
	lw 	$t2, selectOption	# load the currently selected option
	beq	$t2, 1, quitGame	# if t2 == 1, quit game
	jr	$ra			# else, start game

winScreen:
### this section is for drawing the background

	li 	$t0, BASE_ADDRESS	# load frame buffer addres
	li 	$t1, TOTAL_PIXEL		# the screen size in bitmap
	li 	$t2, OCEAN_BLUE		# load the background color
backgroundLoop2:	
	sw   	$t2, 0($t0)
	addi 	$t0, $t0, 4 		# advance to next pixel position in display
	addi 	$t1, $t1, -1		# decrement number of pixels
	bnez 	$t1, backgroundLoop2	# repeat while number of pixels is not zero
	
	la $t0, BASE_ADDRESS
        li $t1, 0x080808
        li $t2, 0xff6496
        li $t3, 0xffffff
        li $t4, 0x00ae70
        li $t5, 0xb067de
        sw $t1, 1040($t0)
        sw $t1, 1044($t0)
        sw $t1, 1056($t0)
        sw $t1, 1060($t0)
        sw $t1, 1072($t0)
        sw $t1, 1076($t0)
        sw $t1, 1080($t0)
        sw $t1, 1084($t0)
        sw $t1, 1088($t0)
        sw $t1, 1092($t0)
        sw $t1, 1104($t0)
        sw $t1, 1108($t0)
        sw $t1, 1120($t0)
        sw $t1, 1124($t0)
        sw $t1, 1296($t0)
        sw $t1, 1300($t0)
        sw $t1, 1312($t0)
        sw $t1, 1316($t0)
        sw $t1, 1328($t0)
        sw $t1, 1332($t0)
        sw $t1, 1336($t0)
        sw $t1, 1340($t0)
        sw $t1, 1344($t0)
        sw $t1, 1348($t0)
        sw $t1, 1360($t0)
        sw $t1, 1364($t0)
        sw $t1, 1376($t0)
        sw $t1, 1380($t0)
        sw $t1, 1552($t0)
        sw $t1, 1556($t0)
        sw $t1, 1568($t0)
        sw $t1, 1572($t0)
        sw $t1, 1584($t0)
        sw $t1, 1588($t0)
        sw $t1, 1600($t0)
        sw $t1, 1604($t0)
        sw $t1, 1616($t0)
        sw $t1, 1620($t0)
        sw $t1, 1632($t0)
        sw $t1, 1636($t0)
        sw $t1, 1808($t0)
        sw $t1, 1812($t0)
        sw $t1, 1824($t0)
        sw $t1, 1828($t0)
        sw $t1, 1840($t0)
        sw $t1, 1844($t0)
        sw $t1, 1856($t0)
        sw $t1, 1860($t0)
        sw $t1, 1872($t0)
        sw $t1, 1876($t0)
        sw $t1, 1888($t0)
        sw $t1, 1892($t0)
        sw $t1, 2064($t0)
        sw $t1, 2068($t0)
        sw $t1, 2072($t0)
        sw $t1, 2076($t0)
        sw $t1, 2080($t0)
        sw $t1, 2084($t0)
        sw $t1, 2096($t0)
        sw $t1, 2100($t0)
        sw $t1, 2112($t0)
        sw $t1, 2116($t0)
        sw $t1, 2128($t0)
        sw $t1, 2132($t0)
        sw $t1, 2144($t0)
        sw $t1, 2148($t0)
        sw $t1, 2320($t0)
        sw $t1, 2324($t0)
        sw $t1, 2328($t0)
        sw $t1, 2332($t0)
        sw $t1, 2336($t0)
        sw $t1, 2340($t0)
        sw $t1, 2352($t0)
        sw $t1, 2356($t0)
        sw $t1, 2368($t0)
        sw $t1, 2372($t0)
        sw $t1, 2384($t0)
        sw $t1, 2388($t0)
        sw $t1, 2400($t0)
        sw $t1, 2404($t0)
        sw $t1, 2584($t0)
        sw $t1, 2588($t0)
        sw $t1, 2608($t0)
        sw $t1, 2612($t0)
        sw $t1, 2624($t0)
        sw $t1, 2628($t0)
        sw $t1, 2640($t0)
        sw $t1, 2644($t0)
        sw $t1, 2656($t0)
        sw $t1, 2660($t0)
        sw $t1, 2840($t0)
        sw $t1, 2844($t0)
        sw $t1, 2864($t0)
        sw $t1, 2868($t0)
        sw $t1, 2880($t0)
        sw $t1, 2884($t0)
        sw $t1, 2896($t0)
        sw $t1, 2900($t0)
        sw $t1, 2912($t0)
        sw $t1, 2916($t0)
        sw $t1, 3096($t0)
        sw $t1, 3100($t0)
        sw $t1, 3120($t0)
        sw $t1, 3124($t0)
        sw $t1, 3128($t0)
        sw $t1, 3132($t0)
        sw $t1, 3136($t0)
        sw $t1, 3140($t0)
        sw $t1, 3152($t0)
        sw $t1, 3156($t0)
        sw $t1, 3160($t0)
        sw $t1, 3164($t0)
        sw $t1, 3168($t0)
        sw $t1, 3172($t0)
        sw $t1, 3352($t0)
        sw $t1, 3356($t0)
        sw $t1, 3376($t0)
        sw $t1, 3380($t0)
        sw $t1, 3384($t0)
        sw $t1, 3388($t0)
        sw $t1, 3392($t0)
        sw $t1, 3396($t0)
        sw $t1, 3408($t0)
        sw $t1, 3412($t0)
        sw $t1, 3416($t0)
        sw $t1, 3420($t0)
        sw $t1, 3424($t0)
        sw $t1, 3428($t0)
        sw $t1, 4104($t0)
        sw $t1, 4108($t0)
        sw $t1, 4120($t0)
        sw $t1, 4124($t0)
        sw $t1, 4136($t0)
        sw $t1, 4140($t0)
        sw $t1, 4152($t0)
        sw $t1, 4156($t0)
        sw $t1, 4160($t0)
        sw $t1, 4164($t0)
        sw $t1, 4168($t0)
        sw $t1, 4172($t0)
        sw $t1, 4184($t0)
        sw $t1, 4188($t0)
        sw $t1, 4208($t0)
        sw $t1, 4212($t0)
        sw $t1, 4224($t0)
        sw $t1, 4228($t0)
        sw $t1, 4360($t0)
        sw $t1, 4364($t0)
        sw $t1, 4376($t0)
        sw $t1, 4380($t0)
        sw $t1, 4392($t0)
        sw $t1, 4396($t0)
        sw $t1, 4408($t0)
        sw $t1, 4412($t0)
        sw $t1, 4416($t0)
        sw $t1, 4420($t0)
        sw $t1, 4424($t0)
        sw $t1, 4428($t0)
        sw $t1, 4440($t0)
        sw $t1, 4444($t0)
        sw $t1, 4464($t0)
        sw $t1, 4468($t0)
        sw $t1, 4480($t0)
        sw $t1, 4484($t0)
        sw $t1, 4616($t0)
        sw $t1, 4620($t0)
        sw $t1, 4632($t0)
        sw $t1, 4636($t0)
        sw $t1, 4648($t0)
        sw $t1, 4652($t0)
        sw $t1, 4672($t0)
        sw $t1, 4676($t0)
        sw $t1, 4696($t0)
        sw $t1, 4700($t0)
        sw $t1, 4704($t0)
        sw $t1, 4708($t0)
        sw $t1, 4720($t0)
        sw $t1, 4724($t0)
        sw $t1, 4736($t0)
        sw $t1, 4740($t0)
        sw $t2, 4776($t0)
        sw $t2, 4780($t0)
        sw $t1, 4872($t0)
        sw $t1, 4876($t0)
        sw $t1, 4888($t0)
        sw $t1, 4892($t0)
        sw $t1, 4904($t0)
        sw $t1, 4908($t0)
        sw $t1, 4928($t0)
        sw $t1, 4932($t0)
        sw $t1, 4952($t0)
        sw $t1, 4956($t0)
        sw $t1, 4960($t0)
        sw $t1, 4964($t0)
        sw $t1, 4976($t0)
        sw $t1, 4980($t0)
        sw $t1, 4992($t0)
        sw $t1, 4996($t0)
        sw $t2, 5032($t0)
        sw $t2, 5036($t0)
        sw $t1, 5128($t0)
        sw $t1, 5132($t0)
        sw $t1, 5144($t0)
        sw $t1, 5148($t0)
        sw $t1, 5160($t0)
        sw $t1, 5164($t0)
        sw $t1, 5184($t0)
        sw $t1, 5188($t0)
        sw $t1, 5208($t0)
        sw $t1, 5212($t0)
        sw $t1, 5224($t0)
        sw $t1, 5228($t0)
        sw $t1, 5232($t0)
        sw $t1, 5236($t0)
        sw $t1, 5248($t0)
        sw $t1, 5252($t0)
        sw $t2, 5280($t0)
        sw $t2, 5284($t0)
        sw $t2, 5288($t0)
        sw $t2, 5292($t0)
        sw $t2, 5296($t0)
        sw $t2, 5300($t0)
        sw $t1, 5384($t0)
        sw $t1, 5388($t0)
        sw $t1, 5400($t0)
        sw $t1, 5404($t0)
        sw $t1, 5416($t0)
        sw $t1, 5420($t0)
        sw $t1, 5440($t0)
        sw $t1, 5444($t0)
        sw $t1, 5464($t0)
        sw $t1, 5468($t0)
        sw $t1, 5480($t0)
        sw $t1, 5484($t0)
        sw $t1, 5488($t0)
        sw $t1, 5492($t0)
        sw $t1, 5504($t0)
        sw $t1, 5508($t0)
        sw $t2, 5536($t0)
        sw $t2, 5540($t0)
        sw $t2, 5544($t0)
        sw $t2, 5548($t0)
        sw $t2, 5552($t0)
        sw $t2, 5556($t0)
        sw $t1, 5648($t0)
        sw $t1, 5652($t0)
        sw $t1, 5664($t0)
        sw $t1, 5668($t0)
        sw $t1, 5696($t0)
        sw $t1, 5700($t0)
        sw $t1, 5720($t0)
        sw $t1, 5724($t0)
        sw $t1, 5736($t0)
        sw $t1, 5740($t0)
        sw $t1, 5744($t0)
        sw $t1, 5748($t0)
        sw $t2, 5784($t0)
        sw $t2, 5788($t0)
        sw $t2, 5792($t0)
        sw $t2, 5796($t0)
        sw $t2, 5800($t0)
        sw $t2, 5804($t0)
        sw $t2, 5808($t0)
        sw $t2, 5812($t0)
        sw $t2, 5816($t0)
        sw $t2, 5820($t0)
        sw $t1, 5904($t0)
        sw $t1, 5908($t0)
        sw $t1, 5920($t0)
        sw $t1, 5924($t0)
        sw $t1, 5952($t0)
        sw $t1, 5956($t0)
        sw $t1, 5976($t0)
        sw $t1, 5980($t0)
        sw $t1, 5992($t0)
        sw $t1, 5996($t0)
        sw $t1, 6000($t0)
        sw $t1, 6004($t0)
        sw $t2, 6040($t0)
        sw $t2, 6044($t0)
        sw $t2, 6048($t0)
        sw $t2, 6052($t0)
        sw $t2, 6056($t0)
        sw $t2, 6060($t0)
        sw $t2, 6064($t0)
        sw $t2, 6068($t0)
        sw $t2, 6072($t0)
        sw $t2, 6076($t0)
        sw $t1, 6160($t0)
        sw $t1, 6164($t0)
        sw $t1, 6176($t0)
        sw $t1, 6180($t0)
        sw $t1, 6200($t0)
        sw $t1, 6204($t0)
        sw $t1, 6208($t0)
        sw $t1, 6212($t0)
        sw $t1, 6216($t0)
        sw $t1, 6220($t0)
        sw $t1, 6232($t0)
        sw $t1, 6236($t0)
        sw $t1, 6256($t0)
        sw $t1, 6260($t0)
        sw $t1, 6272($t0)
        sw $t1, 6276($t0)
        sw $t2, 6296($t0)
        sw $t2, 6300($t0)
        sw $t2, 6304($t0)
        sw $t2, 6308($t0)
        sw $t2, 6312($t0)
        sw $t2, 6316($t0)
        sw $t2, 6320($t0)
        sw $t2, 6324($t0)
        sw $t2, 6328($t0)
        sw $t2, 6332($t0)
        sw $t1, 6416($t0)
        sw $t1, 6420($t0)
        sw $t1, 6432($t0)
        sw $t1, 6436($t0)
        sw $t1, 6456($t0)
        sw $t1, 6460($t0)
        sw $t1, 6464($t0)
        sw $t1, 6468($t0)
        sw $t1, 6472($t0)
        sw $t1, 6476($t0)
        sw $t1, 6488($t0)
        sw $t1, 6492($t0)
        sw $t1, 6512($t0)
        sw $t1, 6516($t0)
        sw $t1, 6528($t0)
        sw $t1, 6532($t0)
        sw $t2, 6552($t0)
        sw $t2, 6556($t0)
        sw $t2, 6560($t0)
        sw $t2, 6564($t0)
        sw $t2, 6568($t0)
        sw $t2, 6572($t0)
        sw $t2, 6576($t0)
        sw $t2, 6580($t0)
        sw $t2, 6584($t0)
        sw $t2, 6588($t0)
        sw $t2, 6800($t0)
        sw $t2, 6804($t0)
        sw $t2, 6808($t0)
        sw $t2, 6812($t0)
        sw $t1, 6816($t0)
        sw $t1, 6820($t0)
        sw $t2, 6824($t0)
        sw $t2, 6828($t0)
        sw $t1, 6832($t0)
        sw $t1, 6836($t0)
        sw $t2, 6840($t0)
        sw $t2, 6844($t0)
        sw $t2, 6848($t0)
        sw $t2, 6852($t0)
        sw $t2, 7056($t0)
        sw $t2, 7060($t0)
        sw $t2, 7064($t0)
        sw $t2, 7068($t0)
        sw $t1, 7072($t0)
        sw $t1, 7076($t0)
        sw $t2, 7080($t0)
        sw $t2, 7084($t0)
        sw $t1, 7088($t0)
        sw $t1, 7092($t0)
        sw $t2, 7096($t0)
        sw $t2, 7100($t0)
        sw $t2, 7104($t0)
        sw $t2, 7108($t0)
        sw $t2, 7312($t0)
        sw $t2, 7316($t0)
        sw $t1, 7320($t0)
        sw $t1, 7324($t0)
        sw $t2, 7328($t0)
        sw $t2, 7332($t0)
        sw $t2, 7336($t0)
        sw $t2, 7340($t0)
        sw $t2, 7344($t0)
        sw $t2, 7348($t0)
        sw $t1, 7352($t0)
        sw $t1, 7356($t0)
        sw $t2, 7360($t0)
        sw $t2, 7364($t0)
        sw $t2, 7568($t0)
        sw $t2, 7572($t0)
        sw $t1, 7576($t0)
        sw $t1, 7580($t0)
        sw $t2, 7584($t0)
        sw $t2, 7588($t0)
        sw $t2, 7592($t0)
        sw $t2, 7596($t0)
        sw $t2, 7600($t0)
        sw $t2, 7604($t0)
        sw $t1, 7608($t0)
        sw $t1, 7612($t0)
        sw $t2, 7616($t0)
        sw $t2, 7620($t0)
        sw $t2, 7824($t0)
        sw $t2, 7828($t0)
        sw $t3, 7832($t0)
        sw $t3, 7836($t0)
        sw $t3, 7840($t0)
        sw $t3, 7844($t0)
        sw $t2, 7848($t0)
        sw $t2, 7852($t0)
        sw $t3, 7856($t0)
        sw $t3, 7860($t0)
        sw $t3, 7864($t0)
        sw $t3, 7868($t0)
        sw $t2, 7872($t0)
        sw $t2, 7876($t0)
        sw $t2, 8080($t0)
        sw $t2, 8084($t0)
        sw $t3, 8088($t0)
        sw $t3, 8092($t0)
        sw $t3, 8096($t0)
        sw $t3, 8100($t0)
        sw $t2, 8104($t0)
        sw $t2, 8108($t0)
        sw $t3, 8112($t0)
        sw $t3, 8116($t0)
        sw $t3, 8120($t0)
        sw $t3, 8124($t0)
        sw $t2, 8128($t0)
        sw $t2, 8132($t0)
        sw $t2, 8336($t0)
        sw $t2, 8340($t0)
        sw $t3, 8344($t0)
        sw $t3, 8348($t0)
        sw $t1, 8352($t0)
        sw $t1, 8356($t0)
        sw $t2, 8360($t0)
        sw $t2, 8364($t0)
        sw $t1, 8368($t0)
        sw $t1, 8372($t0)
        sw $t3, 8376($t0)
        sw $t3, 8380($t0)
        sw $t2, 8384($t0)
        sw $t2, 8388($t0)
        sw $t2, 8592($t0)
        sw $t2, 8596($t0)
        sw $t3, 8600($t0)
        sw $t3, 8604($t0)
        sw $t1, 8608($t0)
        sw $t1, 8612($t0)
        sw $t2, 8616($t0)
        sw $t2, 8620($t0)
        sw $t1, 8624($t0)
        sw $t1, 8628($t0)
        sw $t3, 8632($t0)
        sw $t3, 8636($t0)
        sw $t2, 8640($t0)
        sw $t2, 8644($t0)
        sw $t2, 8848($t0)
        sw $t2, 8852($t0)
        sw $t3, 8856($t0)
        sw $t3, 8860($t0)
        sw $t3, 8864($t0)
        sw $t3, 8868($t0)
        sw $t2, 8872($t0)
        sw $t2, 8876($t0)
        sw $t3, 8880($t0)
        sw $t3, 8884($t0)
        sw $t3, 8888($t0)
        sw $t3, 8892($t0)
        sw $t2, 8896($t0)
        sw $t2, 8900($t0)
        sw $t2, 9104($t0)
        sw $t2, 9108($t0)
        sw $t3, 9112($t0)
        sw $t3, 9116($t0)
        sw $t3, 9120($t0)
        sw $t3, 9124($t0)
        sw $t2, 9128($t0)
        sw $t2, 9132($t0)
        sw $t3, 9136($t0)
        sw $t3, 9140($t0)
        sw $t3, 9144($t0)
        sw $t3, 9148($t0)
        sw $t2, 9152($t0)
        sw $t2, 9156($t0)
        sw $t2, 9352($t0)
        sw $t2, 9356($t0)
        sw $t2, 9360($t0)
        sw $t2, 9364($t0)
        sw $t2, 9368($t0)
        sw $t2, 9372($t0)
        sw $t2, 9376($t0)
        sw $t2, 9380($t0)
        sw $t2, 9384($t0)
        sw $t2, 9388($t0)
        sw $t2, 9392($t0)
        sw $t2, 9396($t0)
        sw $t2, 9400($t0)
        sw $t2, 9404($t0)
        sw $t2, 9408($t0)
        sw $t2, 9412($t0)
        sw $t2, 9416($t0)
        sw $t2, 9420($t0)
        sw $t2, 9608($t0)
        sw $t2, 9612($t0)
        sw $t2, 9616($t0)
        sw $t2, 9620($t0)
        sw $t2, 9624($t0)
        sw $t2, 9628($t0)
        sw $t2, 9632($t0)
        sw $t2, 9636($t0)
        sw $t2, 9640($t0)
        sw $t2, 9644($t0)
        sw $t2, 9648($t0)
        sw $t2, 9652($t0)
        sw $t2, 9656($t0)
        sw $t2, 9660($t0)
        sw $t2, 9664($t0)
        sw $t2, 9668($t0)
        sw $t2, 9672($t0)
        sw $t2, 9676($t0)
        sw $t2, 9864($t0)
        sw $t2, 9868($t0)
        sw $t1, 9872($t0)
        sw $t1, 9876($t0)
        sw $t2, 9880($t0)
        sw $t2, 9884($t0)
        sw $t2, 9888($t0)
        sw $t2, 9892($t0)
        sw $t2, 9896($t0)
        sw $t2, 9900($t0)
        sw $t2, 9904($t0)
        sw $t2, 9908($t0)
        sw $t2, 9912($t0)
        sw $t2, 9916($t0)
        sw $t1, 9920($t0)
        sw $t1, 9924($t0)
        sw $t2, 9928($t0)
        sw $t2, 9932($t0)
        sw $t2, 9936($t0)
        sw $t2, 9940($t0)
        sw $t2, 10120($t0)
        sw $t2, 10124($t0)
        sw $t1, 10128($t0)
        sw $t1, 10132($t0)
        sw $t2, 10136($t0)
        sw $t2, 10140($t0)
        sw $t2, 10144($t0)
        sw $t2, 10148($t0)
        sw $t2, 10152($t0)
        sw $t2, 10156($t0)
        sw $t2, 10160($t0)
        sw $t2, 10164($t0)
        sw $t2, 10168($t0)
        sw $t2, 10172($t0)
        sw $t1, 10176($t0)
        sw $t1, 10180($t0)
        sw $t2, 10184($t0)
        sw $t2, 10188($t0)
        sw $t2, 10192($t0)
        sw $t2, 10196($t0)
        sw $t2, 10360($t0)
        sw $t2, 10364($t0)
        sw $t2, 10368($t0)
        sw $t2, 10372($t0)
        sw $t2, 10376($t0)
        sw $t2, 10380($t0)
        sw $t2, 10384($t0)
        sw $t2, 10388($t0)
        sw $t1, 10392($t0)
        sw $t1, 10396($t0)
        sw $t1, 10400($t0)
        sw $t1, 10404($t0)
        sw $t1, 10408($t0)
        sw $t1, 10412($t0)
        sw $t1, 10416($t0)
        sw $t1, 10420($t0)
        sw $t1, 10424($t0)
        sw $t1, 10428($t0)
        sw $t2, 10432($t0)
        sw $t2, 10436($t0)
        sw $t2, 10440($t0)
        sw $t2, 10444($t0)
        sw $t2, 10448($t0)
        sw $t2, 10452($t0)
        sw $t2, 10456($t0)
        sw $t2, 10460($t0)
        sw $t2, 10616($t0)
        sw $t2, 10620($t0)
        sw $t2, 10624($t0)
        sw $t2, 10628($t0)
        sw $t2, 10632($t0)
        sw $t2, 10636($t0)
        sw $t2, 10640($t0)
        sw $t2, 10644($t0)
        sw $t1, 10648($t0)
        sw $t1, 10652($t0)
        sw $t1, 10656($t0)
        sw $t1, 10660($t0)
        sw $t1, 10664($t0)
        sw $t1, 10668($t0)
        sw $t1, 10672($t0)
        sw $t1, 10676($t0)
        sw $t1, 10680($t0)
        sw $t1, 10684($t0)
        sw $t2, 10688($t0)
        sw $t2, 10692($t0)
        sw $t2, 10696($t0)
        sw $t2, 10700($t0)
        sw $t2, 10704($t0)
        sw $t2, 10708($t0)
        sw $t2, 10712($t0)
        sw $t2, 10716($t0)
        sw $t2, 10864($t0)
        sw $t2, 10868($t0)
        sw $t2, 10872($t0)
        sw $t2, 10876($t0)
        sw $t2, 10880($t0)
        sw $t2, 10884($t0)
        sw $t2, 10888($t0)
        sw $t2, 10892($t0)
        sw $t2, 10896($t0)
        sw $t2, 10900($t0)
        sw $t2, 10904($t0)
        sw $t2, 10908($t0)
        sw $t2, 10912($t0)
        sw $t2, 10916($t0)
        sw $t2, 10920($t0)
        sw $t2, 10924($t0)
        sw $t2, 10928($t0)
        sw $t2, 10932($t0)
        sw $t2, 10936($t0)
        sw $t2, 10940($t0)
        sw $t2, 10944($t0)
        sw $t2, 10948($t0)
        sw $t2, 10952($t0)
        sw $t2, 10956($t0)
        sw $t2, 10960($t0)
        sw $t2, 10964($t0)
        sw $t2, 10968($t0)
        sw $t2, 10972($t0)
        sw $t2, 10976($t0)
        sw $t2, 10980($t0)
        sw $t2, 11120($t0)
        sw $t2, 11124($t0)
        sw $t2, 11128($t0)
        sw $t2, 11132($t0)
        sw $t2, 11136($t0)
        sw $t2, 11140($t0)
        sw $t2, 11144($t0)
        sw $t2, 11148($t0)
        sw $t2, 11152($t0)
        sw $t2, 11156($t0)
        sw $t2, 11160($t0)
        sw $t2, 11164($t0)
        sw $t2, 11168($t0)
        sw $t2, 11172($t0)
        sw $t2, 11176($t0)
        sw $t2, 11180($t0)
        sw $t2, 11184($t0)
        sw $t2, 11188($t0)
        sw $t2, 11192($t0)
        sw $t2, 11196($t0)
        sw $t2, 11200($t0)
        sw $t2, 11204($t0)
        sw $t2, 11208($t0)
        sw $t2, 11212($t0)
        sw $t2, 11216($t0)
        sw $t2, 11220($t0)
        sw $t2, 11224($t0)
        sw $t2, 11228($t0)
        sw $t2, 11232($t0)
        sw $t2, 11236($t0)
        sw $t2, 11368($t0)
        sw $t2, 11372($t0)
        sw $t2, 11376($t0)
        sw $t2, 11380($t0)
        sw $t2, 11384($t0)
        sw $t2, 11388($t0)
        sw $t2, 11392($t0)
        sw $t2, 11396($t0)
        sw $t2, 11400($t0)
        sw $t2, 11404($t0)
        sw $t2, 11408($t0)
        sw $t2, 11412($t0)
        sw $t2, 11416($t0)
        sw $t2, 11420($t0)
        sw $t2, 11424($t0)
        sw $t2, 11428($t0)
        sw $t2, 11432($t0)
        sw $t2, 11436($t0)
        sw $t2, 11440($t0)
        sw $t2, 11444($t0)
        sw $t2, 11448($t0)
        sw $t2, 11452($t0)
        sw $t2, 11456($t0)
        sw $t2, 11460($t0)
        sw $t2, 11464($t0)
        sw $t2, 11468($t0)
        sw $t2, 11472($t0)
        sw $t2, 11476($t0)
        sw $t2, 11480($t0)
        sw $t2, 11484($t0)
        sw $t2, 11488($t0)
        sw $t2, 11492($t0)
        sw $t2, 11496($t0)
        sw $t2, 11500($t0)
        sw $t2, 11624($t0)
        sw $t2, 11628($t0)
        sw $t2, 11632($t0)
        sw $t2, 11636($t0)
        sw $t2, 11640($t0)
        sw $t2, 11644($t0)
        sw $t2, 11648($t0)
        sw $t2, 11652($t0)
        sw $t2, 11656($t0)
        sw $t2, 11660($t0)
        sw $t2, 11664($t0)
        sw $t2, 11668($t0)
        sw $t2, 11672($t0)
        sw $t2, 11676($t0)
        sw $t2, 11680($t0)
        sw $t2, 11684($t0)
        sw $t2, 11688($t0)
        sw $t2, 11692($t0)
        sw $t2, 11696($t0)
        sw $t2, 11700($t0)
        sw $t2, 11704($t0)
        sw $t2, 11708($t0)
        sw $t2, 11712($t0)
        sw $t2, 11716($t0)
        sw $t2, 11720($t0)
        sw $t2, 11724($t0)
        sw $t2, 11728($t0)
        sw $t2, 11732($t0)
        sw $t2, 11736($t0)
        sw $t2, 11740($t0)
        sw $t2, 11744($t0)
        sw $t2, 11748($t0)
        sw $t2, 11752($t0)
        sw $t2, 11756($t0)
        sw $t2, 11880($t0)
        sw $t2, 11884($t0)
        sw $t2, 11888($t0)
        sw $t2, 11892($t0)
        sw $t2, 11896($t0)
        sw $t2, 11900($t0)
        sw $t2, 11904($t0)
        sw $t2, 11908($t0)
        sw $t2, 11912($t0)
        sw $t2, 11916($t0)
        sw $t2, 11920($t0)
        sw $t2, 11924($t0)
        sw $t2, 11928($t0)
        sw $t2, 11932($t0)
        sw $t2, 11936($t0)
        sw $t2, 11940($t0)
        sw $t2, 11944($t0)
        sw $t2, 11948($t0)
        sw $t2, 11952($t0)
        sw $t2, 11956($t0)
        sw $t2, 11960($t0)
        sw $t2, 11964($t0)
        sw $t2, 11968($t0)
        sw $t2, 11972($t0)
        sw $t2, 11976($t0)
        sw $t2, 11980($t0)
        sw $t2, 11984($t0)
        sw $t2, 11988($t0)
        sw $t2, 11992($t0)
        sw $t2, 11996($t0)
        sw $t2, 12000($t0)
        sw $t2, 12004($t0)
        sw $t2, 12008($t0)
        sw $t2, 12012($t0)
        sw $t2, 12136($t0)
        sw $t2, 12140($t0)
        sw $t2, 12144($t0)
        sw $t2, 12148($t0)
        sw $t2, 12152($t0)
        sw $t2, 12156($t0)
        sw $t2, 12160($t0)
        sw $t2, 12164($t0)
        sw $t2, 12168($t0)
        sw $t2, 12172($t0)
        sw $t2, 12176($t0)
        sw $t2, 12180($t0)
        sw $t2, 12184($t0)
        sw $t2, 12188($t0)
        sw $t2, 12192($t0)
        sw $t2, 12196($t0)
        sw $t2, 12200($t0)
        sw $t2, 12204($t0)
        sw $t2, 12208($t0)
        sw $t2, 12212($t0)
        sw $t2, 12216($t0)
        sw $t2, 12220($t0)
        sw $t2, 12224($t0)
        sw $t2, 12228($t0)
        sw $t2, 12232($t0)
        sw $t2, 12236($t0)
        sw $t2, 12240($t0)
        sw $t2, 12244($t0)
        sw $t2, 12248($t0)
        sw $t2, 12252($t0)
        sw $t2, 12256($t0)
        sw $t2, 12260($t0)
        sw $t2, 12264($t0)
        sw $t2, 12268($t0)
        sw $t2, 12392($t0)
        sw $t2, 12396($t0)
        sw $t2, 12400($t0)
        sw $t2, 12404($t0)
        sw $t2, 12416($t0)
        sw $t2, 12420($t0)
        sw $t2, 12424($t0)
        sw $t2, 12428($t0)
        sw $t2, 12432($t0)
        sw $t2, 12436($t0)
        sw $t2, 12440($t0)
        sw $t2, 12444($t0)
        sw $t2, 12448($t0)
        sw $t2, 12452($t0)
        sw $t1, 12456($t0)
        sw $t1, 12460($t0)
        sw $t2, 12464($t0)
        sw $t2, 12468($t0)
        sw $t2, 12472($t0)
        sw $t2, 12476($t0)
        sw $t2, 12480($t0)
        sw $t2, 12484($t0)
        sw $t2, 12488($t0)
        sw $t2, 12492($t0)
        sw $t2, 12496($t0)
        sw $t2, 12500($t0)
        sw $t2, 12512($t0)
        sw $t2, 12516($t0)
        sw $t2, 12520($t0)
        sw $t2, 12524($t0)
        sw $t2, 12648($t0)
        sw $t2, 12652($t0)
        sw $t2, 12656($t0)
        sw $t2, 12660($t0)
        sw $t2, 12672($t0)
        sw $t2, 12676($t0)
        sw $t2, 12680($t0)
        sw $t2, 12684($t0)
        sw $t2, 12688($t0)
        sw $t2, 12692($t0)
        sw $t2, 12696($t0)
        sw $t2, 12700($t0)
        sw $t2, 12704($t0)
        sw $t2, 12708($t0)
        sw $t1, 12712($t0)
        sw $t1, 12716($t0)
        sw $t2, 12720($t0)
        sw $t2, 12724($t0)
        sw $t2, 12728($t0)
        sw $t2, 12732($t0)
        sw $t2, 12736($t0)
        sw $t2, 12740($t0)
        sw $t2, 12744($t0)
        sw $t2, 12748($t0)
        sw $t2, 12752($t0)
        sw $t2, 12756($t0)
        sw $t2, 12768($t0)
        sw $t2, 12772($t0)
        sw $t2, 12776($t0)
        sw $t2, 12780($t0)
        sw $t2, 12904($t0)
        sw $t2, 12908($t0)
        sw $t2, 12928($t0)
        sw $t2, 12932($t0)
        sw $t2, 12936($t0)
        sw $t2, 12940($t0)
        sw $t2, 12944($t0)
        sw $t2, 12948($t0)
        sw $t2, 12952($t0)
        sw $t2, 12956($t0)
        sw $t2, 12960($t0)
        sw $t2, 12964($t0)
        sw $t2, 12968($t0)
        sw $t2, 12972($t0)
        sw $t2, 12976($t0)
        sw $t2, 12980($t0)
        sw $t2, 12984($t0)
        sw $t2, 12988($t0)
        sw $t2, 12992($t0)
        sw $t2, 12996($t0)
        sw $t4, 13000($t0)
        sw $t4, 13004($t0)
        sw $t4, 13008($t0)
        sw $t4, 13012($t0)
        sw $t2, 13032($t0)
        sw $t2, 13036($t0)
        sw $t2, 13160($t0)
        sw $t2, 13164($t0)
        sw $t2, 13184($t0)
        sw $t2, 13188($t0)
        sw $t2, 13192($t0)
        sw $t2, 13196($t0)
        sw $t2, 13200($t0)
        sw $t2, 13204($t0)
        sw $t2, 13208($t0)
        sw $t2, 13212($t0)
        sw $t2, 13216($t0)
        sw $t2, 13220($t0)
        sw $t2, 13224($t0)
        sw $t2, 13228($t0)
        sw $t2, 13232($t0)
        sw $t2, 13236($t0)
        sw $t2, 13240($t0)
        sw $t2, 13244($t0)
        sw $t2, 13248($t0)
        sw $t2, 13252($t0)
        sw $t4, 13256($t0)
        sw $t4, 13260($t0)
        sw $t4, 13264($t0)
        sw $t4, 13268($t0)
        sw $t2, 13288($t0)
        sw $t2, 13292($t0)
        sw $t4, 13440($t0)
        sw $t4, 13444($t0)
        sw $t4, 13448($t0)
        sw $t4, 13452($t0)
        sw $t5, 13456($t0)
        sw $t5, 13460($t0)
        sw $t5, 13464($t0)
        sw $t5, 13468($t0)
        sw $t4, 13472($t0)
        sw $t4, 13476($t0)
        sw $t4, 13480($t0)
        sw $t4, 13484($t0)
        sw $t4, 13488($t0)
        sw $t4, 13492($t0)
        sw $t4, 13496($t0)
        sw $t4, 13500($t0)
        sw $t4, 13504($t0)
        sw $t4, 13508($t0)
        sw $t5, 13512($t0)
        sw $t5, 13516($t0)
        sw $t4, 13520($t0)
        sw $t4, 13524($t0)
        sw $t4, 13696($t0)
        sw $t4, 13700($t0)
        sw $t4, 13704($t0)
        sw $t4, 13708($t0)
        sw $t5, 13712($t0)
        sw $t5, 13716($t0)
        sw $t5, 13720($t0)
        sw $t5, 13724($t0)
        sw $t4, 13728($t0)
        sw $t4, 13732($t0)
        sw $t4, 13736($t0)
        sw $t4, 13740($t0)
        sw $t4, 13744($t0)
        sw $t4, 13748($t0)
        sw $t4, 13752($t0)
        sw $t4, 13756($t0)
        sw $t4, 13760($t0)
        sw $t4, 13764($t0)
        sw $t5, 13768($t0)
        sw $t5, 13772($t0)
        sw $t4, 13776($t0)
        sw $t4, 13780($t0)
        sw $t4, 13952($t0)
        sw $t4, 13956($t0)
        sw $t5, 13960($t0)
        sw $t5, 13964($t0)
        sw $t5, 13968($t0)
        sw $t5, 13972($t0)
        sw $t5, 13976($t0)
        sw $t5, 13980($t0)
        sw $t5, 13984($t0)
        sw $t5, 13988($t0)
        sw $t4, 13992($t0)
        sw $t4, 13996($t0)
        sw $t4, 14000($t0)
        sw $t4, 14004($t0)
        sw $t4, 14008($t0)
        sw $t4, 14012($t0)
        sw $t5, 14016($t0)
        sw $t5, 14020($t0)
        sw $t5, 14024($t0)
        sw $t5, 14028($t0)
        sw $t4, 14032($t0)
        sw $t4, 14036($t0)
        sw $t4, 14208($t0)
        sw $t4, 14212($t0)
        sw $t5, 14216($t0)
        sw $t5, 14220($t0)
        sw $t5, 14224($t0)
        sw $t5, 14228($t0)
        sw $t5, 14232($t0)
        sw $t5, 14236($t0)
        sw $t5, 14240($t0)
        sw $t5, 14244($t0)
        sw $t4, 14248($t0)
        sw $t4, 14252($t0)
        sw $t4, 14256($t0)
        sw $t4, 14260($t0)
        sw $t4, 14264($t0)
        sw $t4, 14268($t0)
        sw $t5, 14272($t0)
        sw $t5, 14276($t0)
        sw $t5, 14280($t0)
        sw $t5, 14284($t0)
        sw $t4, 14288($t0)
        sw $t4, 14292($t0)
        sw $t4, 14464($t0)
        sw $t4, 14468($t0)
        sw $t4, 14472($t0)
        sw $t4, 14476($t0)
        sw $t5, 14480($t0)
        sw $t5, 14484($t0)
        sw $t5, 14488($t0)
        sw $t5, 14492($t0)
        sw $t4, 14496($t0)
        sw $t4, 14500($t0)
        sw $t4, 14504($t0)
        sw $t4, 14508($t0)
        sw $t4, 14512($t0)
        sw $t4, 14516($t0)
        sw $t4, 14520($t0)
        sw $t4, 14524($t0)
        sw $t4, 14528($t0)
        sw $t4, 14532($t0)
        sw $t5, 14536($t0)
        sw $t5, 14540($t0)
        sw $t4, 14544($t0)
        sw $t4, 14548($t0)
        sw $t4, 14720($t0)
        sw $t4, 14724($t0)
        sw $t4, 14728($t0)
        sw $t4, 14732($t0)
        sw $t5, 14736($t0)
        sw $t5, 14740($t0)
        sw $t5, 14744($t0)
        sw $t5, 14748($t0)
        sw $t4, 14752($t0)
        sw $t4, 14756($t0)
        sw $t4, 14760($t0)
        sw $t4, 14764($t0)
        sw $t4, 14768($t0)
        sw $t4, 14772($t0)
        sw $t4, 14776($t0)
        sw $t4, 14780($t0)
        sw $t4, 14784($t0)
        sw $t4, 14788($t0)
        sw $t5, 14792($t0)
        sw $t5, 14796($t0)
        sw $t4, 14800($t0)
        sw $t4, 14804($t0)
        sw $t4, 14976($t0)
        sw $t4, 14980($t0)
        sw $t2, 14984($t0)
        sw $t2, 14988($t0)
        sw $t2, 14992($t0)
        sw $t2, 14996($t0)
        sw $t2, 15000($t0)
        sw $t2, 15004($t0)
        sw $t2, 15008($t0)
        sw $t2, 15012($t0)
        sw $t2, 15024($t0)
        sw $t2, 15028($t0)
        sw $t2, 15032($t0)
        sw $t2, 15036($t0)
        sw $t2, 15040($t0)
        sw $t2, 15044($t0)
        sw $t2, 15048($t0)
        sw $t2, 15052($t0)
        sw $t4, 15232($t0)
        sw $t4, 15236($t0)
        sw $t2, 15240($t0)
        sw $t2, 15244($t0)
        sw $t2, 15248($t0)
        sw $t2, 15252($t0)
        sw $t2, 15256($t0)
        sw $t2, 15260($t0)
        sw $t2, 15264($t0)
        sw $t2, 15268($t0)
        sw $t2, 15280($t0)
        sw $t2, 15284($t0)
        sw $t2, 15288($t0)
        sw $t2, 15292($t0)
        sw $t2, 15296($t0)
        sw $t2, 15300($t0)
        sw $t2, 15304($t0)
        sw $t2, 15308($t0)
        sw $t2, 15504($t0)
        sw $t2, 15508($t0)
        sw $t2, 15512($t0)
        sw $t2, 15516($t0)
        sw $t2, 15544($t0)
        sw $t2, 15548($t0)
        sw $t2, 15552($t0)
        sw $t2, 15556($t0)
        sw $t2, 15760($t0)
        sw $t2, 15764($t0)
        sw $t2, 15768($t0)
        sw $t2, 15772($t0)
        sw $t2, 15800($t0)
        sw $t2, 15804($t0)
        sw $t2, 15808($t0)
        sw $t2, 15812($t0)

	j	checkRestartLoop
	        
loseScreen:
### this section is for drawing the background

	li 	$t0, BASE_ADDRESS	# load frame buffer addres
	li 	$t1, TOTAL_PIXEL		# the screen size in bitmap
	li 	$t2, RED	# load the background color
backgroundLoop3:	
	sw   	$t2, 0($t0)
	addi 	$t0, $t0, 4 		# advance to next pixel position in display
	addi 	$t1, $t1, -1		# decrement number of pixels
	bnez 	$t1, backgroundLoop3	# repeat while number of pixels is not zero
	
	la $t0, BASE_ADDRESS
        li $t1, 0x080808
        li $t2, 0x29be1c
        li $t3, 0xffffff
        li $t4, 0xeaff00
        li $t5, 0xff0000
        sw $t1, 520($t0)
        sw $t1, 524($t0)
        sw $t1, 528($t0)
        sw $t1, 532($t0)
        sw $t1, 536($t0)
        sw $t1, 540($t0)
        sw $t1, 544($t0)
        sw $t1, 548($t0)
        sw $t1, 576($t0)
        sw $t1, 580($t0)
        sw $t1, 584($t0)
        sw $t1, 588($t0)
        sw $t1, 600($t0)
        sw $t1, 604($t0)
        sw $t1, 608($t0)
        sw $t1, 612($t0)
        sw $t1, 624($t0)
        sw $t1, 628($t0)
        sw $t1, 632($t0)
        sw $t1, 636($t0)
        sw $t1, 648($t0)
        sw $t1, 652($t0)
        sw $t1, 656($t0)
        sw $t1, 660($t0)
        sw $t1, 664($t0)
        sw $t1, 668($t0)
        sw $t1, 672($t0)
        sw $t1, 676($t0)
        sw $t1, 776($t0)
        sw $t1, 780($t0)
        sw $t1, 784($t0)
        sw $t1, 788($t0)
        sw $t1, 792($t0)
        sw $t1, 796($t0)
        sw $t1, 800($t0)
        sw $t1, 804($t0)
        sw $t1, 832($t0)
        sw $t1, 836($t0)
        sw $t1, 840($t0)
        sw $t1, 844($t0)
        sw $t1, 856($t0)
        sw $t1, 860($t0)
        sw $t1, 864($t0)
        sw $t1, 868($t0)
        sw $t1, 880($t0)
        sw $t1, 884($t0)
        sw $t1, 888($t0)
        sw $t1, 892($t0)
        sw $t1, 904($t0)
        sw $t1, 908($t0)
        sw $t1, 912($t0)
        sw $t1, 916($t0)
        sw $t1, 920($t0)
        sw $t1, 924($t0)
        sw $t1, 928($t0)
        sw $t1, 932($t0)
        sw $t1, 1032($t0)
        sw $t1, 1036($t0)
        sw $t1, 1080($t0)
        sw $t1, 1084($t0)
        sw $t1, 1096($t0)
        sw $t1, 1100($t0)
        sw $t1, 1112($t0)
        sw $t1, 1116($t0)
        sw $t1, 1120($t0)
        sw $t1, 1124($t0)
        sw $t1, 1128($t0)
        sw $t1, 1132($t0)
        sw $t1, 1136($t0)
        sw $t1, 1140($t0)
        sw $t1, 1144($t0)
        sw $t1, 1148($t0)
        sw $t1, 1160($t0)
        sw $t1, 1164($t0)
        sw $t1, 1288($t0)
        sw $t1, 1292($t0)
        sw $t1, 1336($t0)
        sw $t1, 1340($t0)
        sw $t1, 1352($t0)
        sw $t1, 1356($t0)
        sw $t1, 1368($t0)
        sw $t1, 1372($t0)
        sw $t1, 1376($t0)
        sw $t1, 1380($t0)
        sw $t1, 1384($t0)
        sw $t1, 1388($t0)
        sw $t1, 1392($t0)
        sw $t1, 1396($t0)
        sw $t1, 1400($t0)
        sw $t1, 1404($t0)
        sw $t1, 1416($t0)
        sw $t1, 1420($t0)
        sw $t1, 1544($t0)
        sw $t1, 1548($t0)
        sw $t1, 1592($t0)
        sw $t1, 1596($t0)
        sw $t1, 1608($t0)
        sw $t1, 1612($t0)
        sw $t1, 1624($t0)
        sw $t1, 1628($t0)
        sw $t1, 1640($t0)
        sw $t1, 1644($t0)
        sw $t1, 1656($t0)
        sw $t1, 1660($t0)
        sw $t1, 1672($t0)
        sw $t1, 1676($t0)
        sw $t1, 1800($t0)
        sw $t1, 1804($t0)
        sw $t1, 1848($t0)
        sw $t1, 1852($t0)
        sw $t1, 1864($t0)
        sw $t1, 1868($t0)
        sw $t1, 1880($t0)
        sw $t1, 1884($t0)
        sw $t1, 1896($t0)
        sw $t1, 1900($t0)
        sw $t1, 1912($t0)
        sw $t1, 1916($t0)
        sw $t1, 1928($t0)
        sw $t1, 1932($t0)
        sw $t1, 2056($t0)
        sw $t1, 2060($t0)
        sw $t1, 2072($t0)
        sw $t1, 2076($t0)
        sw $t1, 2080($t0)
        sw $t1, 2084($t0)
        sw $t1, 2096($t0)
        sw $t1, 2100($t0)
        sw $t1, 2120($t0)
        sw $t1, 2124($t0)
        sw $t1, 2136($t0)
        sw $t1, 2140($t0)
        sw $t1, 2152($t0)
        sw $t1, 2156($t0)
        sw $t1, 2168($t0)
        sw $t1, 2172($t0)
        sw $t1, 2184($t0)
        sw $t1, 2188($t0)
        sw $t1, 2192($t0)
        sw $t1, 2196($t0)
        sw $t1, 2200($t0)
        sw $t1, 2204($t0)
        sw $t1, 2208($t0)
        sw $t1, 2212($t0)
        sw $t1, 2312($t0)
        sw $t1, 2316($t0)
        sw $t1, 2328($t0)
        sw $t1, 2332($t0)
        sw $t1, 2336($t0)
        sw $t1, 2340($t0)
        sw $t1, 2352($t0)
        sw $t1, 2356($t0)
        sw $t1, 2376($t0)
        sw $t1, 2380($t0)
        sw $t1, 2392($t0)
        sw $t1, 2396($t0)
        sw $t1, 2408($t0)
        sw $t1, 2412($t0)
        sw $t1, 2424($t0)
        sw $t1, 2428($t0)
        sw $t1, 2440($t0)
        sw $t1, 2444($t0)
        sw $t1, 2448($t0)
        sw $t1, 2452($t0)
        sw $t1, 2456($t0)
        sw $t1, 2460($t0)
        sw $t1, 2464($t0)
        sw $t1, 2468($t0)
        sw $t1, 2568($t0)
        sw $t1, 2572($t0)
        sw $t1, 2592($t0)
        sw $t1, 2596($t0)
        sw $t1, 2608($t0)
        sw $t1, 2612($t0)
        sw $t1, 2616($t0)
        sw $t1, 2620($t0)
        sw $t1, 2624($t0)
        sw $t1, 2628($t0)
        sw $t1, 2632($t0)
        sw $t1, 2636($t0)
        sw $t1, 2648($t0)
        sw $t1, 2652($t0)
        sw $t1, 2664($t0)
        sw $t1, 2668($t0)
        sw $t1, 2680($t0)
        sw $t1, 2684($t0)
        sw $t1, 2696($t0)
        sw $t1, 2700($t0)
        sw $t1, 2824($t0)
        sw $t1, 2828($t0)
        sw $t1, 2848($t0)
        sw $t1, 2852($t0)
        sw $t1, 2864($t0)
        sw $t1, 2868($t0)
        sw $t1, 2872($t0)
        sw $t1, 2876($t0)
        sw $t1, 2880($t0)
        sw $t1, 2884($t0)
        sw $t1, 2888($t0)
        sw $t1, 2892($t0)
        sw $t1, 2904($t0)
        sw $t1, 2908($t0)
        sw $t1, 2920($t0)
        sw $t1, 2924($t0)
        sw $t1, 2936($t0)
        sw $t1, 2940($t0)
        sw $t1, 2952($t0)
        sw $t1, 2956($t0)
        sw $t1, 3080($t0)
        sw $t1, 3084($t0)
        sw $t1, 3104($t0)
        sw $t1, 3108($t0)
        sw $t1, 3120($t0)
        sw $t1, 3124($t0)
        sw $t1, 3144($t0)
        sw $t1, 3148($t0)
        sw $t1, 3160($t0)
        sw $t1, 3164($t0)
        sw $t1, 3192($t0)
        sw $t1, 3196($t0)
        sw $t1, 3208($t0)
        sw $t1, 3212($t0)
        sw $t1, 3336($t0)
        sw $t1, 3340($t0)
        sw $t1, 3360($t0)
        sw $t1, 3364($t0)
        sw $t1, 3376($t0)
        sw $t1, 3380($t0)
        sw $t1, 3400($t0)
        sw $t1, 3404($t0)
        sw $t1, 3416($t0)
        sw $t1, 3420($t0)
        sw $t1, 3448($t0)
        sw $t1, 3452($t0)
        sw $t1, 3464($t0)
        sw $t1, 3468($t0)
        sw $t1, 3592($t0)
        sw $t1, 3596($t0)
        sw $t1, 3600($t0)
        sw $t1, 3604($t0)
        sw $t1, 3608($t0)
        sw $t1, 3612($t0)
        sw $t1, 3616($t0)
        sw $t1, 3620($t0)
        sw $t1, 3632($t0)
        sw $t1, 3636($t0)
        sw $t1, 3656($t0)
        sw $t1, 3660($t0)
        sw $t1, 3672($t0)
        sw $t1, 3676($t0)
        sw $t1, 3704($t0)
        sw $t1, 3708($t0)
        sw $t1, 3720($t0)
        sw $t1, 3724($t0)
        sw $t1, 3728($t0)
        sw $t1, 3732($t0)
        sw $t1, 3736($t0)
        sw $t1, 3740($t0)
        sw $t1, 3744($t0)
        sw $t1, 3748($t0)
        sw $t1, 3848($t0)
        sw $t1, 3852($t0)
        sw $t1, 3856($t0)
        sw $t1, 3860($t0)
        sw $t1, 3864($t0)
        sw $t1, 3868($t0)
        sw $t1, 3872($t0)
        sw $t1, 3876($t0)
        sw $t1, 3888($t0)
        sw $t1, 3892($t0)
        sw $t1, 3912($t0)
        sw $t1, 3916($t0)
        sw $t1, 3928($t0)
        sw $t1, 3932($t0)
        sw $t1, 3960($t0)
        sw $t1, 3964($t0)
        sw $t1, 3976($t0)
        sw $t1, 3980($t0)
        sw $t1, 3984($t0)
        sw $t1, 3988($t0)
        sw $t1, 3992($t0)
        sw $t1, 3996($t0)
        sw $t1, 4000($t0)
        sw $t1, 4004($t0)
        sw $t1, 4304($t0)
        sw $t1, 4308($t0)
        sw $t1, 4560($t0)
        sw $t1, 4564($t0)
        sw $t1, 4624($t0)
        sw $t1, 4628($t0)
        sw $t1, 4632($t0)
        sw $t1, 4636($t0)
        sw $t1, 4656($t0)
        sw $t1, 4660($t0)
        sw $t1, 4688($t0)
        sw $t1, 4692($t0)
        sw $t1, 4704($t0)
        sw $t1, 4708($t0)
        sw $t1, 4712($t0)
        sw $t1, 4716($t0)
        sw $t1, 4720($t0)
        sw $t1, 4724($t0)
        sw $t1, 4728($t0)
        sw $t1, 4732($t0)
        sw $t1, 4744($t0)
        sw $t1, 4748($t0)
        sw $t1, 4752($t0)
        sw $t1, 4756($t0)
        sw $t1, 4760($t0)
        sw $t1, 4764($t0)
        sw $t1, 4768($t0)
        sw $t1, 4772($t0)
        sw $t1, 4808($t0)
        sw $t1, 4812($t0)
        sw $t1, 4880($t0)
        sw $t1, 4884($t0)
        sw $t1, 4888($t0)
        sw $t1, 4892($t0)
        sw $t1, 4912($t0)
        sw $t1, 4916($t0)
        sw $t1, 4944($t0)
        sw $t1, 4948($t0)
        sw $t1, 4960($t0)
        sw $t1, 4964($t0)
        sw $t1, 4968($t0)
        sw $t1, 4972($t0)
        sw $t1, 4976($t0)
        sw $t1, 4980($t0)
        sw $t1, 4984($t0)
        sw $t1, 4988($t0)
        sw $t1, 5000($t0)
        sw $t1, 5004($t0)
        sw $t1, 5008($t0)
        sw $t1, 5012($t0)
        sw $t1, 5016($t0)
        sw $t1, 5020($t0)
        sw $t1, 5024($t0)
        sw $t1, 5028($t0)
        sw $t1, 5064($t0)
        sw $t1, 5068($t0)
        sw $t1, 5128($t0)
        sw $t1, 5132($t0)
        sw $t1, 5152($t0)
        sw $t1, 5156($t0)
        sw $t1, 5168($t0)
        sw $t1, 5172($t0)
        sw $t1, 5200($t0)
        sw $t1, 5204($t0)
        sw $t1, 5216($t0)
        sw $t1, 5220($t0)
        sw $t1, 5256($t0)
        sw $t1, 5260($t0)
        sw $t1, 5280($t0)
        sw $t1, 5284($t0)
        sw $t1, 5320($t0)
        sw $t1, 5324($t0)
        sw $t1, 5384($t0)
        sw $t1, 5388($t0)
        sw $t1, 5408($t0)
        sw $t1, 5412($t0)
        sw $t1, 5424($t0)
        sw $t1, 5428($t0)
        sw $t1, 5456($t0)
        sw $t1, 5460($t0)
        sw $t1, 5472($t0)
        sw $t1, 5476($t0)
        sw $t1, 5512($t0)
        sw $t1, 5516($t0)
        sw $t1, 5536($t0)
        sw $t1, 5540($t0)
        sw $t1, 5576($t0)
        sw $t1, 5580($t0)
        sw $t1, 5640($t0)
        sw $t1, 5644($t0)
        sw $t1, 5664($t0)
        sw $t1, 5668($t0)
        sw $t1, 5680($t0)
        sw $t1, 5684($t0)
        sw $t1, 5688($t0)
        sw $t1, 5692($t0)
        sw $t1, 5704($t0)
        sw $t1, 5708($t0)
        sw $t1, 5712($t0)
        sw $t1, 5716($t0)
        sw $t1, 5728($t0)
        sw $t1, 5732($t0)
        sw $t1, 5768($t0)
        sw $t1, 5772($t0)
        sw $t1, 5792($t0)
        sw $t1, 5796($t0)
        sw $t1, 5824($t0)
        sw $t1, 5828($t0)
        sw $t1, 5896($t0)
        sw $t1, 5900($t0)
        sw $t1, 5920($t0)
        sw $t1, 5924($t0)
        sw $t1, 5936($t0)
        sw $t1, 5940($t0)
        sw $t1, 5944($t0)
        sw $t1, 5948($t0)
        sw $t1, 5960($t0)
        sw $t1, 5964($t0)
        sw $t1, 5968($t0)
        sw $t1, 5972($t0)
        sw $t1, 5984($t0)
        sw $t1, 5988($t0)
        sw $t1, 6024($t0)
        sw $t1, 6028($t0)
        sw $t1, 6048($t0)
        sw $t1, 6052($t0)
        sw $t1, 6080($t0)
        sw $t1, 6084($t0)
        sw $t1, 6152($t0)
        sw $t1, 6156($t0)
        sw $t1, 6176($t0)
        sw $t1, 6180($t0)
        sw $t1, 6200($t0)
        sw $t1, 6204($t0)
        sw $t1, 6216($t0)
        sw $t1, 6220($t0)
        sw $t1, 6240($t0)
        sw $t1, 6244($t0)
        sw $t1, 6248($t0)
        sw $t1, 6252($t0)
        sw $t1, 6256($t0)
        sw $t1, 6260($t0)
        sw $t1, 6264($t0)
        sw $t1, 6268($t0)
        sw $t1, 6280($t0)
        sw $t1, 6284($t0)
        sw $t1, 6288($t0)
        sw $t1, 6292($t0)
        sw $t1, 6296($t0)
        sw $t1, 6300($t0)
        sw $t1, 6304($t0)
        sw $t1, 6308($t0)
        sw $t1, 6336($t0)
        sw $t1, 6340($t0)
        sw $t1, 6392($t0)
        sw $t1, 6396($t0)
        sw $t1, 6408($t0)
        sw $t1, 6412($t0)
        sw $t1, 6432($t0)
        sw $t1, 6436($t0)
        sw $t1, 6456($t0)
        sw $t1, 6460($t0)
        sw $t1, 6472($t0)
        sw $t1, 6476($t0)
        sw $t1, 6496($t0)
        sw $t1, 6500($t0)
        sw $t1, 6504($t0)
        sw $t1, 6508($t0)
        sw $t1, 6512($t0)
        sw $t1, 6516($t0)
        sw $t1, 6520($t0)
        sw $t1, 6524($t0)
        sw $t1, 6536($t0)
        sw $t1, 6540($t0)
        sw $t1, 6544($t0)
        sw $t1, 6548($t0)
        sw $t1, 6552($t0)
        sw $t1, 6556($t0)
        sw $t1, 6560($t0)
        sw $t1, 6564($t0)
        sw $t1, 6592($t0)
        sw $t1, 6596($t0)
        sw $t1, 6648($t0)
        sw $t1, 6652($t0)
        sw $t1, 6664($t0)
        sw $t1, 6668($t0)
        sw $t1, 6688($t0)
        sw $t1, 6692($t0)
        sw $t1, 6712($t0)
        sw $t1, 6716($t0)
        sw $t1, 6728($t0)
        sw $t1, 6732($t0)
        sw $t1, 6752($t0)
        sw $t1, 6756($t0)
        sw $t1, 6792($t0)
        sw $t1, 6796($t0)
        sw $t1, 6808($t0)
        sw $t1, 6812($t0)
        sw $t1, 6848($t0)
        sw $t1, 6852($t0)
        sw $t1, 6888($t0)
        sw $t1, 6892($t0)
        sw $t1, 6896($t0)
        sw $t1, 6900($t0)
        sw $t1, 6920($t0)
        sw $t1, 6924($t0)
        sw $t1, 6944($t0)
        sw $t1, 6948($t0)
        sw $t1, 6968($t0)
        sw $t1, 6972($t0)
        sw $t1, 6984($t0)
        sw $t1, 6988($t0)
        sw $t1, 7008($t0)
        sw $t1, 7012($t0)
        sw $t1, 7048($t0)
        sw $t1, 7052($t0)
        sw $t1, 7064($t0)
        sw $t1, 7068($t0)
        sw $t1, 7104($t0)
        sw $t1, 7108($t0)
        sw $t1, 7144($t0)
        sw $t1, 7148($t0)
        sw $t1, 7152($t0)
        sw $t1, 7156($t0)
        sw $t1, 7176($t0)
        sw $t1, 7180($t0)
        sw $t1, 7200($t0)
        sw $t1, 7204($t0)
        sw $t1, 7224($t0)
        sw $t1, 7228($t0)
        sw $t1, 7232($t0)
        sw $t1, 7236($t0)
        sw $t1, 7240($t0)
        sw $t1, 7244($t0)
        sw $t1, 7264($t0)
        sw $t1, 7268($t0)
        sw $t1, 7304($t0)
        sw $t1, 7308($t0)
        sw $t1, 7320($t0)
        sw $t1, 7324($t0)
        sw $t1, 7328($t0)
        sw $t1, 7332($t0)
        sw $t1, 7360($t0)
        sw $t1, 7364($t0)
        sw $t1, 7392($t0)
        sw $t1, 7396($t0)
        sw $t1, 7432($t0)
        sw $t1, 7436($t0)
        sw $t1, 7456($t0)
        sw $t1, 7460($t0)
        sw $t1, 7480($t0)
        sw $t1, 7484($t0)
        sw $t1, 7488($t0)
        sw $t1, 7492($t0)
        sw $t1, 7496($t0)
        sw $t1, 7500($t0)
        sw $t1, 7520($t0)
        sw $t1, 7524($t0)
        sw $t1, 7560($t0)
        sw $t1, 7564($t0)
        sw $t1, 7576($t0)
        sw $t1, 7580($t0)
        sw $t1, 7584($t0)
        sw $t1, 7588($t0)
        sw $t1, 7616($t0)
        sw $t1, 7620($t0)
        sw $t1, 7648($t0)
        sw $t1, 7652($t0)
        sw $t1, 7696($t0)
        sw $t1, 7700($t0)
        sw $t1, 7704($t0)
        sw $t1, 7708($t0)
        sw $t1, 7744($t0)
        sw $t1, 7748($t0)
        sw $t1, 7776($t0)
        sw $t1, 7780($t0)
        sw $t1, 7784($t0)
        sw $t1, 7788($t0)
        sw $t1, 7792($t0)
        sw $t1, 7796($t0)
        sw $t1, 7800($t0)
        sw $t1, 7804($t0)
        sw $t1, 7816($t0)
        sw $t1, 7820($t0)
        sw $t1, 7840($t0)
        sw $t1, 7844($t0)
        sw $t1, 7864($t0)
        sw $t1, 7868($t0)
        sw $t1, 7872($t0)
        sw $t1, 7876($t0)
        sw $t1, 7880($t0)
        sw $t1, 7884($t0)
        sw $t1, 7896($t0)
        sw $t1, 7900($t0)
        sw $t1, 7952($t0)
        sw $t1, 7956($t0)
        sw $t1, 7960($t0)
        sw $t1, 7964($t0)
        sw $t1, 8000($t0)
        sw $t1, 8004($t0)
        sw $t1, 8032($t0)
        sw $t1, 8036($t0)
        sw $t1, 8040($t0)
        sw $t1, 8044($t0)
        sw $t1, 8048($t0)
        sw $t1, 8052($t0)
        sw $t1, 8056($t0)
        sw $t1, 8060($t0)
        sw $t1, 8072($t0)
        sw $t1, 8076($t0)
        sw $t1, 8096($t0)
        sw $t1, 8100($t0)
        sw $t1, 8120($t0)
        sw $t1, 8124($t0)
        sw $t1, 8128($t0)
        sw $t1, 8132($t0)
        sw $t1, 8136($t0)
        sw $t1, 8140($t0)
        sw $t1, 8152($t0)
        sw $t1, 8156($t0)
        sw $t1, 8368($t0)
        sw $t1, 8372($t0)
        sw $t2, 8376($t0)
        sw $t2, 8380($t0)
        sw $t2, 8384($t0)
        sw $t2, 8388($t0)
        sw $t2, 8392($t0)
        sw $t2, 8396($t0)
        sw $t1, 8400($t0)
        sw $t1, 8404($t0)
        sw $t1, 8624($t0)
        sw $t1, 8628($t0)
        sw $t2, 8632($t0)
        sw $t2, 8636($t0)
        sw $t2, 8640($t0)
        sw $t2, 8644($t0)
        sw $t2, 8648($t0)
        sw $t2, 8652($t0)
        sw $t1, 8656($t0)
        sw $t1, 8660($t0)
        sw $t1, 8872($t0)
        sw $t1, 8876($t0)
        sw $t3, 8880($t0)
        sw $t3, 8884($t0)
        sw $t1, 8888($t0)
        sw $t1, 8892($t0)
        sw $t1, 8896($t0)
        sw $t1, 8900($t0)
        sw $t2, 8904($t0)
        sw $t2, 8908($t0)
        sw $t2, 8912($t0)
        sw $t2, 8916($t0)
        sw $t1, 8920($t0)
        sw $t1, 8924($t0)
        sw $t1, 9128($t0)
        sw $t1, 9132($t0)
        sw $t3, 9136($t0)
        sw $t3, 9140($t0)
        sw $t1, 9144($t0)
        sw $t1, 9148($t0)
        sw $t1, 9152($t0)
        sw $t1, 9156($t0)
        sw $t2, 9160($t0)
        sw $t2, 9164($t0)
        sw $t2, 9168($t0)
        sw $t2, 9172($t0)
        sw $t1, 9176($t0)
        sw $t1, 9180($t0)
        sw $t1, 9376($t0)
        sw $t1, 9380($t0)
        sw $t3, 9384($t0)
        sw $t3, 9388($t0)
        sw $t3, 9392($t0)
        sw $t3, 9396($t0)
        sw $t3, 9400($t0)
        sw $t3, 9404($t0)
        sw $t4, 9408($t0)
        sw $t4, 9412($t0)
        sw $t2, 9416($t0)
        sw $t2, 9420($t0)
        sw $t2, 9424($t0)
        sw $t2, 9428($t0)
        sw $t1, 9432($t0)
        sw $t1, 9436($t0)
        sw $t1, 9632($t0)
        sw $t1, 9636($t0)
        sw $t3, 9640($t0)
        sw $t3, 9644($t0)
        sw $t3, 9648($t0)
        sw $t3, 9652($t0)
        sw $t3, 9656($t0)
        sw $t3, 9660($t0)
        sw $t4, 9664($t0)
        sw $t4, 9668($t0)
        sw $t2, 9672($t0)
        sw $t2, 9676($t0)
        sw $t2, 9680($t0)
        sw $t2, 9684($t0)
        sw $t1, 9688($t0)
        sw $t1, 9692($t0)
        sw $t1, 9888($t0)
        sw $t1, 9892($t0)
        sw $t3, 9896($t0)
        sw $t3, 9900($t0)
        sw $t5, 9904($t0)
        sw $t5, 9908($t0)
        sw $t3, 9912($t0)
        sw $t3, 9916($t0)
        sw $t4, 9920($t0)
        sw $t4, 9924($t0)
        sw $t2, 9928($t0)
        sw $t2, 9932($t0)
        sw $t2, 9936($t0)
        sw $t2, 9940($t0)
        sw $t1, 9944($t0)
        sw $t1, 9948($t0)
        sw $t1, 10144($t0)
        sw $t1, 10148($t0)
        sw $t3, 10152($t0)
        sw $t3, 10156($t0)
        sw $t5, 10160($t0)
        sw $t5, 10164($t0)
        sw $t3, 10168($t0)
        sw $t3, 10172($t0)
        sw $t4, 10176($t0)
        sw $t4, 10180($t0)
        sw $t2, 10184($t0)
        sw $t2, 10188($t0)
        sw $t2, 10192($t0)
        sw $t2, 10196($t0)
        sw $t1, 10200($t0)
        sw $t1, 10204($t0)
        sw $t1, 10392($t0)
        sw $t1, 10396($t0)
        sw $t4, 10400($t0)
        sw $t4, 10404($t0)
        sw $t3, 10408($t0)
        sw $t3, 10412($t0)
        sw $t3, 10416($t0)
        sw $t3, 10420($t0)
        sw $t4, 10424($t0)
        sw $t4, 10428($t0)
        sw $t4, 10432($t0)
        sw $t4, 10436($t0)
        sw $t2, 10440($t0)
        sw $t2, 10444($t0)
        sw $t1, 10448($t0)
        sw $t1, 10452($t0)
        sw $t1, 10648($t0)
        sw $t1, 10652($t0)
        sw $t4, 10656($t0)
        sw $t4, 10660($t0)
        sw $t3, 10664($t0)
        sw $t3, 10668($t0)
        sw $t3, 10672($t0)
        sw $t3, 10676($t0)
        sw $t4, 10680($t0)
        sw $t4, 10684($t0)
        sw $t4, 10688($t0)
        sw $t4, 10692($t0)
        sw $t2, 10696($t0)
        sw $t2, 10700($t0)
        sw $t1, 10704($t0)
        sw $t1, 10708($t0)
        sw $t1, 10904($t0)
        sw $t1, 10908($t0)
        sw $t2, 10912($t0)
        sw $t2, 10916($t0)
        sw $t4, 10920($t0)
        sw $t4, 10924($t0)
        sw $t4, 10928($t0)
        sw $t4, 10932($t0)
        sw $t4, 10936($t0)
        sw $t4, 10940($t0)
        sw $t2, 10944($t0)
        sw $t2, 10948($t0)
        sw $t2, 10952($t0)
        sw $t2, 10956($t0)
        sw $t1, 10960($t0)
        sw $t1, 10964($t0)
        sw $t1, 11160($t0)
        sw $t1, 11164($t0)
        sw $t2, 11168($t0)
        sw $t2, 11172($t0)
        sw $t4, 11176($t0)
        sw $t4, 11180($t0)
        sw $t4, 11184($t0)
        sw $t4, 11188($t0)
        sw $t4, 11192($t0)
        sw $t4, 11196($t0)
        sw $t2, 11200($t0)
        sw $t2, 11204($t0)
        sw $t2, 11208($t0)
        sw $t2, 11212($t0)
        sw $t1, 11216($t0)
        sw $t1, 11220($t0)
        sw $t1, 11384($t0)
        sw $t1, 11388($t0)
        sw $t1, 11416($t0)
        sw $t1, 11420($t0)
        sw $t2, 11424($t0)
        sw $t2, 11428($t0)
        sw $t2, 11432($t0)
        sw $t2, 11436($t0)
        sw $t2, 11440($t0)
        sw $t2, 11444($t0)
        sw $t2, 11448($t0)
        sw $t2, 11452($t0)
        sw $t2, 11456($t0)
        sw $t2, 11460($t0)
        sw $t1, 11464($t0)
        sw $t1, 11468($t0)
        sw $t1, 11640($t0)
        sw $t1, 11644($t0)
        sw $t1, 11672($t0)
        sw $t1, 11676($t0)
        sw $t2, 11680($t0)
        sw $t2, 11684($t0)
        sw $t2, 11688($t0)
        sw $t2, 11692($t0)
        sw $t2, 11696($t0)
        sw $t2, 11700($t0)
        sw $t2, 11704($t0)
        sw $t2, 11708($t0)
        sw $t2, 11712($t0)
        sw $t2, 11716($t0)
        sw $t1, 11720($t0)
        sw $t1, 11724($t0)
        sw $t1, 11904($t0)
        sw $t1, 11908($t0)
        sw $t1, 11912($t0)
        sw $t1, 11916($t0)
        sw $t1, 11920($t0)
        sw $t1, 11924($t0)
        sw $t2, 11928($t0)
        sw $t2, 11932($t0)
        sw $t2, 11936($t0)
        sw $t2, 11940($t0)
        sw $t2, 11944($t0)
        sw $t2, 11948($t0)
        sw $t2, 11952($t0)
        sw $t2, 11956($t0)
        sw $t1, 11960($t0)
        sw $t1, 11964($t0)
        sw $t2, 11968($t0)
        sw $t2, 11972($t0)
        sw $t1, 11976($t0)
        sw $t1, 11980($t0)
        sw $t1, 12008($t0)
        sw $t1, 12012($t0)
        sw $t1, 12160($t0)
        sw $t1, 12164($t0)
        sw $t1, 12168($t0)
        sw $t1, 12172($t0)
        sw $t1, 12176($t0)
        sw $t1, 12180($t0)
        sw $t2, 12184($t0)
        sw $t2, 12188($t0)
        sw $t2, 12192($t0)
        sw $t2, 12196($t0)
        sw $t2, 12200($t0)
        sw $t2, 12204($t0)
        sw $t2, 12208($t0)
        sw $t2, 12212($t0)
        sw $t1, 12216($t0)
        sw $t1, 12220($t0)
        sw $t2, 12224($t0)
        sw $t2, 12228($t0)
        sw $t1, 12232($t0)
        sw $t1, 12236($t0)
        sw $t1, 12264($t0)
        sw $t1, 12268($t0)
        sw $t1, 12432($t0)
        sw $t1, 12436($t0)
        sw $t2, 12440($t0)
        sw $t2, 12444($t0)
        sw $t2, 12448($t0)
        sw $t2, 12452($t0)
        sw $t1, 12456($t0)
        sw $t1, 12460($t0)
        sw $t1, 12464($t0)
        sw $t1, 12468($t0)
        sw $t2, 12472($t0)
        sw $t2, 12476($t0)
        sw $t2, 12480($t0)
        sw $t2, 12484($t0)
        sw $t1, 12488($t0)
        sw $t1, 12492($t0)
        sw $t1, 12496($t0)
        sw $t1, 12500($t0)
        sw $t1, 12504($t0)
        sw $t1, 12508($t0)
        sw $t1, 12512($t0)
        sw $t1, 12516($t0)
        sw $t1, 12688($t0)
        sw $t1, 12692($t0)
        sw $t2, 12696($t0)
        sw $t2, 12700($t0)
        sw $t2, 12704($t0)
        sw $t2, 12708($t0)
        sw $t1, 12712($t0)
        sw $t1, 12716($t0)
        sw $t1, 12720($t0)
        sw $t1, 12724($t0)
        sw $t2, 12728($t0)
        sw $t2, 12732($t0)
        sw $t2, 12736($t0)
        sw $t2, 12740($t0)
        sw $t1, 12744($t0)
        sw $t1, 12748($t0)
        sw $t1, 12752($t0)
        sw $t1, 12756($t0)
        sw $t1, 12760($t0)
        sw $t1, 12764($t0)
        sw $t1, 12768($t0)
        sw $t1, 12772($t0)
        sw $t1, 12944($t0)
        sw $t1, 12948($t0)
        sw $t2, 12952($t0)
        sw $t2, 12956($t0)
        sw $t2, 12960($t0)
        sw $t2, 12964($t0)
        sw $t2, 12968($t0)
        sw $t2, 12972($t0)
        sw $t2, 12976($t0)
        sw $t2, 12980($t0)
        sw $t2, 12984($t0)
        sw $t2, 12988($t0)
        sw $t1, 12992($t0)
        sw $t1, 12996($t0)
        sw $t1, 13200($t0)
        sw $t1, 13204($t0)
        sw $t2, 13208($t0)
        sw $t2, 13212($t0)
        sw $t2, 13216($t0)
        sw $t2, 13220($t0)
        sw $t2, 13224($t0)
        sw $t2, 13228($t0)
        sw $t2, 13232($t0)
        sw $t2, 13236($t0)
        sw $t2, 13240($t0)
        sw $t2, 13244($t0)
        sw $t1, 13248($t0)
        sw $t1, 13252($t0)
        sw $t1, 13456($t0)
        sw $t1, 13460($t0)
        sw $t2, 13464($t0)
        sw $t2, 13468($t0)
        sw $t2, 13472($t0)
        sw $t2, 13476($t0)
        sw $t2, 13480($t0)
        sw $t2, 13484($t0)
        sw $t2, 13488($t0)
        sw $t2, 13492($t0)
        sw $t2, 13496($t0)
        sw $t2, 13500($t0)
        sw $t1, 13504($t0)
        sw $t1, 13508($t0)
        sw $t1, 13712($t0)
        sw $t1, 13716($t0)
        sw $t2, 13720($t0)
        sw $t2, 13724($t0)
        sw $t2, 13728($t0)
        sw $t2, 13732($t0)
        sw $t2, 13736($t0)
        sw $t2, 13740($t0)
        sw $t2, 13744($t0)
        sw $t2, 13748($t0)
        sw $t2, 13752($t0)
        sw $t2, 13756($t0)
        sw $t1, 13760($t0)
        sw $t1, 13764($t0)
        sw $t1, 13968($t0)
        sw $t1, 13972($t0)
        sw $t2, 13976($t0)
        sw $t2, 13980($t0)
        sw $t2, 13984($t0)
        sw $t2, 13988($t0)
        sw $t2, 13992($t0)
        sw $t2, 13996($t0)
        sw $t2, 14000($t0)
        sw $t2, 14004($t0)
        sw $t2, 14008($t0)
        sw $t2, 14012($t0)
        sw $t1, 14016($t0)
        sw $t1, 14020($t0)
        sw $t1, 14224($t0)
        sw $t1, 14228($t0)
        sw $t2, 14232($t0)
        sw $t2, 14236($t0)
        sw $t2, 14240($t0)
        sw $t2, 14244($t0)
        sw $t2, 14248($t0)
        sw $t2, 14252($t0)
        sw $t2, 14256($t0)
        sw $t2, 14260($t0)
        sw $t2, 14264($t0)
        sw $t2, 14268($t0)
        sw $t1, 14272($t0)
        sw $t1, 14276($t0)
        sw $t1, 14488($t0)
        sw $t1, 14492($t0)
        sw $t2, 14496($t0)
        sw $t2, 14500($t0)
        sw $t2, 14504($t0)
        sw $t2, 14508($t0)
        sw $t2, 14512($t0)
        sw $t2, 14516($t0)
        sw $t2, 14520($t0)
        sw $t2, 14524($t0)
        sw $t1, 14528($t0)
        sw $t1, 14532($t0)
        sw $t1, 14744($t0)
        sw $t1, 14748($t0)
        sw $t2, 14752($t0)
        sw $t2, 14756($t0)
        sw $t2, 14760($t0)
        sw $t2, 14764($t0)
        sw $t2, 14768($t0)
        sw $t2, 14772($t0)
        sw $t2, 14776($t0)
        sw $t2, 14780($t0)
        sw $t1, 14784($t0)
        sw $t1, 14788($t0)
        sw $t1, 15008($t0)
        sw $t1, 15012($t0)
        sw $t1, 15016($t0)
        sw $t1, 15020($t0)
        sw $t1, 15024($t0)
        sw $t1, 15028($t0)
        sw $t1, 15032($t0)
        sw $t1, 15036($t0)
        sw $t1, 15264($t0)
        sw $t1, 15268($t0)
        sw $t1, 15272($t0)
        sw $t1, 15276($t0)
        sw $t1, 15280($t0)
        sw $t1, 15284($t0)
        sw $t1, 15288($t0)
        sw $t1, 15292($t0)
        sw $t1, 15520($t0)
        sw $t1, 15524($t0)
        sw $t1, 15544($t0)
        sw $t1, 15548($t0)
        sw $t1, 15776($t0)
        sw $t1, 15780($t0)
        sw $t1, 15800($t0)
        sw $t1, 15804($t0)
        sw $t1, 16032($t0)
        sw $t1, 16036($t0)
        sw $t1, 16056($t0)
        sw $t1, 16060($t0)
        sw $t1, 16288($t0)
        sw $t1, 16292($t0)
        sw $t1, 16312($t0)
        sw $t1, 16316($t0)
	
	j	checkRestartLoop


# this section is used to check whether the user wants to restart the game or to quit the game
checkRestartLoop:
	li 	$t1, 0xffff0000		# load address of where to get if keypress happened
	lw 	$t2, 0($t1)		# get if keypress happened
	beq	$t2, 0, checkRestartLoop	# check if a key was pressed
	
endScreenKeypressed:
	lw	$t2, 0xffff0004		# get key that was pressed
	
	addi	$v0, $zero, 32			# syscall sleep
	addi	$a0, $zero, REFRESH_RATE	# 40 ms
	syscall

	beq	$t2, 112, startGame	# if key press = 'p' restart the game
	beq	$t2, 113, quitGame	# if key press = 'q' quit the game
	j checkRestartLoop		# loop back again

quitGame:
        # end program:
        addi $v0, $zero, 10
        syscall

























