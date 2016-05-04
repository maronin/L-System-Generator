-- Mark Aronin 
-- Assignment 1
-- DPS917 - Procedural Programming
-- February 27, 2013

-- My state class
struct State(
	public
	x_, -- x coordinate
	y_, -- y coordinate
	z_, -- z coordinate
	a_, -- alpha bend (i think i didn't use this )
	b_, -- the bend angle
	r1_,-- base raduis of the cylinder
	r2_,-- top raduis of the cylinder
	m_, -- the transofrmation matrix of the prevoius shape
	h_, -- the hieght of the cylinder
	
	--Update method for x, y, z, and the bend angle
	fn updateXYZB x y z b= (
	x_ = x
	y_ = y
	z_ = z
	b_ = b
	),
	
	-- method to update the transformation matrix
	fn updateMatrix m =(
		m_ = m
	),
	
	-- method of updating the hieght of the cylinder
	fn updateHeight h = (
	h_ = h
	),
	
	-- method of updating the base raduis of the cylinder
	fn updateRadius r1= (
	r1_ = r1
	),
	
	--update method for alpha
	fn updateAlpha a =(
	a_ = (a_ + a)
	),
	
	-- method to clear and reset the values for the state
	fn clear = (
	x_ = 0 
	y_ = 0
	z_ = 0
	a_ = 0
	b_ = 0
	r1_ = 30
	r2_ = 15.5 
	m_ = (matrix3[1,0,0][0,1,0][0,0,1][0,0,0])
	h_ = 100
	)

)
--This is my custom stack I made which stores the states
struct myStack(
	public
	stack_ = #(), -- used an array to store states
	top_ = 1, -- the top of the stack starts at 1
	
	-- intializing my empty stack
	fn myStack = (
		stack_ = #()
		top_ = 1

	),
	-- method for push states on to the stack. I used a 2D array since maxscript does not support object storing in arrays
	fn pushOntoStack x y z a b r1 r2 m h= (
		join stack_ #(#(x,y,z,a,b,r1, r2, m, h))
		top_ = top_ + 1
	),
	-- method to pop a state of the stack
	fn pop = (
		
		if(top_ > 0) do(
			
			deleteItem stack_ (top_-1)
			top_ = top_ - 1	
		
		)
	
	),
	-- method to get whats currently on top of the stack
	fn top = (
		
		if(top_ > 1) do(
		
			return stack_[top_-1]
		
		)
		
	),
	-- method to check if the stack is empty
	fn isEmpty = (
	
		if(top_>1) then(
			
			return false
		)
		
		else(
				
			return true
		)
		
	),
	
	-- a method to clear the stack after I want to remake the tree
	fn clearStack = (
	
		for i=1 to top_-1 do(	
			deleteItem stack_ (i)
		
		)
	)
	
)
-- intialize these varaibles and state
--							  x y z a b r1 r2         matrix 										   hieght
global state = State 0 0 0 0 0 10 15.5 (matrix3[1,0,0][0,1,0][0,0,1][0,0,0]) 100
branchColor = Color 87 45 0 -- default color of branch
leafColor = Color 43 67 0 -- default color of leaf
firstTime = true -- set this value to true since you are running for the first time
isTextured = false
hasLeafs = true
global theLeaf
fn deleteTree = (
		
	)
-- method to initialize my state based on the fchange put in by the user as well as the raduis and starting string
fn init fchange bchange startString radius
	= (
	
	state.clear()
	state.r1_ = radius
	state.r2_ = radius/2 
	global s = startString
	global fChange = fchange
	global bChange = bchange
	global angleChange = 5
	global curr = 0
	global bModifier = 0.80
	global theStack = myStack()
	global windowWidth = 300
	global windowHeight = 300
	--meditMaterials[1].diffuseMap = Bitmaptexture fileName:"C:\Users\Mark\Documents\3dsMax\sceneassets\images\texture-wood-purgo.jpg"

	)
-- method for using to clear the tree, unused at the moment
fn clearTree = (
	state.clear()
	theStack.clearStack()
	select $*
			if ($ != undefined )then(
					for each in $ do
					(
						if($ != leaf)then(
							--delete $
						)
					)

			)
)

-- create the next generatation based on the grammer
fn nextGeneration original = (

	tmp = ""
	for i=1 to original.count do(		
		if(original[i] == "F") then
			(
			tmp = tmp + fChange
				
			)
		else if(original[i] == "B") then
			(
			tmp = tmp + bChange
				
			)
			else(
			tmp = tmp + original[i]
				
			)
			
		
		)
	s = tmp
)
-- do each generation based on how many generations the user asked for
function setup iterations= (

	for i=1 to iterations do(
			nextGeneration s
	)

)

--rounds a float to a set number of decimal places
function roundFloat val dp =(
a = val * (10^dp)
b = a as integer
a = b as float / (10^dp)
return a
)
-- draws the F with the colour specified and the min/max angle bends
fn drawF colour minAngle maxAngle segLength= (
	
	bending = (random minAngle maxAngle)
    -- draw the cone	
	Cone smooth:on heightsegs:15 capsegs:1 sides:10 height:segLength radius1:state.r1_ radius2:state.r2_ mapcoords:on transform:(state.m_) isSelected:on
	if(isTextured)then (
	$.material = meditMaterials[1]
	)
	$.wirecolor = colour -- set the colour 
	addmodifier $ (bend angle:(bending) direction:(random 0 360))
	state.m_[1]
	select $.verts[#{$.verts.count}]
	$.selectedVerts[1].pos[3]	- 1
	mPrime = matrixFromNormal (getFaceNormal $ $.faces.count) -- store the matrix normal into a transoframtion matrix used later on for the next branch
	
		-- store the new values for the next state to be used
	mPrime[4] = $.selectedVerts[1].pos
	posXPrime = $.verts[$.verts.count].pos[1]
	posYPrime = $.verts[$.verts.count].pos[2]
	posZPrime = $.verts[$.verts.count].pos[3]
	posBPrime = bending
	-- update the state with the new values 
	state.updateXYZB posXPrime posYPrime posZPrime posBPrime
	state.updateMatrix mPrime
	state.updateRadius  state.r2_ 

)
-- draws the leaf, c used to be used for color
fn drawLeaf c= (

	rad = state.r2_ * 10 /4 
	--Sphere radius:rad smooth:on segs:20 chop:0 slice:off sliceFrom:0 sliceTo:0 mapcoords:on recenter:off transform:(state.m_) isSelected:on

	if(theLeaf != undefined )then(
	select theLeaf
	maxOps.cloneNodes $ cloneType:#instance newNodes:&nnl
	select nnl
	--theLeaf = nnl
	nnl.transform = state.m_
	)
	
	if(isTextured)then (
	$.material = meditMaterials[2]
	)
	$.wirecolor = c
)

-- change the angleChange, unused 
fn drawPlus = (
	
	state.updateAlpha (-angleChange)
	
)
-- change the angleChange, unused 
fn drawMinus = (
	
	state.updateAlpha (angleChange)
	
)
-- shrink the next branch raduis
fn shrinkBranch =(

		state.r1_ = state.r1_ - 0.5
)

-- method used to go through the grammer and execute the correct methods based on the string
fn draw p lbl colour minAngle maxAngle segLength leafC= (

	count = 0
	while (curr < s.count + 1) do (
		-- draw the branch
		if(s[curr] == "F") then
		(
			drawF colour minAngle maxAngle segLength 
			
		)
		-- unused angle change
		else if(s[curr] == "+") then
		(
			drawPlus()
		)
		-- unused angle change
		else if (s[curr] == "-") then
		(
			drawMinus()
		)
		-- pushes the state onto the stack
		else if(s[curr] == "[")then
		(
			theStack.pushOntoStack state.x_ state.y_ state.z_ state.a_ state.b_ state.r1_ state.r2_ state.m_ state.h_
		)
		-- used to use this one, but decided to take it out. Was used to increase the hieght of the branch
		else if(s[curr] == ">") then
		(
				hPrime = (state.h_)/1.5
		state.updateHeight hPrime	
		)
		-- this makes the next branch thinner
		else if(s[curr] == "v") then
		(
			state.r2_ = state.r2_ * bModifier
		)
		-- pushes the state off the stack
		else if(s[curr] == "]")then
		(
			
			tempState = theStack.stack_[theStack.top_-1]
			state.x_ = tempState[1]
			state.y_ = tempState[2]
			state.z_ = tempState[3]
			state.a_ = tempState[4]
			state.b_ = tempState[5]
			state.r1_ = tempState[6]
			state.r2_ = tempState[7]
			state.m_ = tempState[8]
			state.h_ = tempState[9]
			theStack.pop()
		)
		-- draw the leaf
		else if(s[curr] == "L")then(
		-- draw it if the user specified leafs
			if(hasLeafs)then(drawLeaf leafC)
		)
		
		
		curr = curr + 1
		count = count + 1
		percentage = roundFloat (100.*curr/s.count) 2
		p.value = percentage
		
		if(percentage > 100)then
		(
			lbl.text = "100.00%"
		
		)
		else(
			percentage = percentage as string
			lbl.text = percentage + "%"
		)
		)

)

rollout LSystem "Mark's Lsystem Generator"
(
	-- Options for the branch
	colorpicker bColor "Tree color:" color:branchColor pos:[11,8]
	mapbutton treeMap "Tree Texture" tooltip:"Select Background Map" width:100 pos:[120,8]
	checkbox texOnOff "Textured" checked:false pos:[235,8]
	
	-- Options for the leaf
	colorpicker lColor "Leaf color:" color:leafColor pos:[12,35]
	mapbutton leafMap "Leaf Texture" tooltip:"Select Background Map" width:100 pos:[120,35]
	checkbox leafBox "Leafs" checked:false pos:[235,34]

	-- Options for the grammer 
	edittext SgrammerTxt "Initial String:" fieldWidth:150 labelOnTop:true align:#left text:"FB" pos:[12,65]
	edittext FgrammerTxt "F Grammer Rule:" fieldWidth:150 labelOnTop:true align:#left text:"Fv[vF[v[FL]Fv[FL][vFL]]]"
	edittext BgrammerTxt "B Grammer Rule:" fieldWidth:150 labelOnTop:true align:#left text:"F[F[FFL]FL]"
	
	-- Options for the modifiers, min angle, max angle, segment length, iterations, and base raduis of the starting branch
	spinner minAngle "Min Bend Angle: " range:[0,90,30] type:#integer pos:[172,80]  fieldWidth:30
	spinner maxAngle "Max Bend Angle: " range:[0,90,30] type:#integer fieldWidth:30 
	spinner segLength "Segment Length: " range:[30,400,100] type:#integer fieldWidth:30
	spinner iterations "Iterations: " range:[1,4,2] type:#integer fieldWidth:30
	spinner baseRaduis "Base Raduis: " range:[1,100,10] type:#integer fieldWidth:30
	
	-- Description of what each of the modifiers in the grammer do
	label lblF "F : The grammer for 'F'" align:#left pos:[12, 190]
	label lblB "B : The grammer for 'B'" align:#left
	label lblv "v : Shrink size of next branch(es)'" align:#left
	label lblPush "[ : push the state onto the stack'" align:#left
	label lblPop "] : pop the state off the stack'" align:#left
	label lblLeaf "L : Draw a leaf on the next branch'" align:#left
	
	-- button and progress bar to start the generation and show how much of it is compelte
	button generate "Generate" width:100 height:25 toolTip:"" 
	progressBar progress "" height:20 align:#center color:[110,10,10] width:200
	label lblProgress "" align:#center pos:[145, 385]
	
	-- check if the user wants texture
	on texOnOff changed theState  do(
	
		if(theState == true) then(
		isTextured = true
		showTextureMap meditMaterials[1] true
		showTextureMap meditMaterials[2] true
		)
		else (
		isTextured = false
		showTextureMap meditMaterials[1] false
		showTextureMap meditMaterials[2] false
		)
		
	)		
	
	-- change the texture based on what the user specified 
  on treeMap picked texmap do
  (    
	environmentmap = texmap
	meditMaterials[1].diffuseMap = texmap
	if(classof texmap as string == "Bitmaptexture")then(
		-- get the name of the texture and apply it to the treeMap text
		treeMap.text = filenameFromPath  meditMaterials[1].diffuseMap.filename as string
	)
	else (
		treeMap.text = classof texmap as string
	)
		-- if its not a bitmap, say what kind of texture it is or what material
		meditMaterials[1].diffuseMap = texmap
  )
  
  -- change the texture based on what the user specified for the leaf
  -- same as above but for leafs
    on leafMap picked texmap2 do
  (    
	environmentmap = texmap2
	meditMaterials[2].diffuseMap = texmap2
	if(classof texmap2 as string == "Bitmaptexture")then(
		leafMap.text = filenameFromPath  meditMaterials[2].diffuseMap.filename as string
	)
	else (
		leafMap.text = classof texmap as string
	)
		
		meditMaterials[2].diffuseMap = texmap2
  )
  
   -- check if the branch color got changed
	on bColor changed new_col do(
		branchColor = new_col

	)
	
	-- check if the leaf color got changed 
	on  lColor changed new_col do (
		leafColor = new_col 	
	)
	
	-- execute when the generate button gets pressed 
	on generate pressed do(
		-- check if leafs are enabled 
		if(leafBox.checked == true)then(
		hasLeafs = true
			
		)
		else (
		hasLeafs = false
		)
		-- force user to pick a leaf if they wanted leafs
		if( $ == undefined and hasLeafs == true) then(
			
				messagebox "Please select a leaf"
			)
		else (	
			-- delete all objects but the leaf
				if(hasLeafs == true)then(
				theLeaf = $	
				select $*
				if(theLeaf != undefined)then(
					deselect theLeaf
				)
				
				if($ != undefined) then(
								delete $
				)		
			)
			
		-- The reason I separated the code here, is to have more flexibility in the future if I decide 
		if(firstTime) then(	
			-- initialize based on the grammer and values selected
			init FgrammerTxt.text BgrammerTxt.text SgrammerTxt.text baseRaduis.value 
			-- setup the iterations based on the users value
			setup iterations.value
			-- draw the tree with the users values
			draw progress lblProgress branchColor minAngle.value maxAngle.value segLength.value leafColor
			-- clear the selection of selected objects
			clearSelection()
			generate.text = "Regenerate"
			firstTime = false
			)
		
		else (
			-- same as above
			init FgrammerTxt.text BgrammerTxt.text SgrammerTxt.text baseRaduis.value
			setup iterations.value
			draw progress lblProgress branchColor minAngle.value maxAngle.value segLength.value leafColor
			clearSelection()
		
			)
		)
	)
)
-- Create the roll out with those dimensions
theNewFloater = newRolloutFloater "Trees" 320 480
addRollout LSystem theNewFloater




