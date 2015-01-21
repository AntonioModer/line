-- Liar
-- - Line
-- - Intersection
-- - Achieved through
-- - Ray-Casting

local unpack = table.unpack or unpack

------------ Local Helper Functions ------------

-- Description: 	Get the summation given a start, stop, and function. 
-- Parameters: 
-- 		start 		number		The starting number of the summation. 
-- 		stop		number		The stopping number of the summation. 
-- 		func 		function	The method in which to add the numbers.
--					Parameters: 
-- 						number			number		The current number being added.
-- 						previousValues	table		The previous values used.
-- 					Returns: 	
-- 						value			number		The value to add.
-- Returns: 
-- 		value		number		The summation.
local function summation( start, stop, func )
	if math.abs( stop ) == math.huge then return false end
	
	local value = 0
	local returnedValue = {}
	
	for i = start, stop do
		local v = func( i, returnedValue )
		
		returnedValue[i] = v
		value = value + v
	end
	
	return value
end

-- Description: 	Gets the area of a polygon. 
-- Parameters: 
-- 		points		table		The points of the polygon in the form of { x1, y1, x2, y2, ... }
-- Returns: 
-- 		area		number		The are of the polygon. 
-- 		points		table		The new version of the table formatted properly for use of centroid.
local function getArea( points )
	local area = 0
	points[#points + 1] = points[1]
	points[#points + 1] = points[2]
	
	return ( .5 *
		summation( 1, #points / 2, 
			function( i )
				i = 2 * i - 1 -- Convert it from points[i][1] to points[i]. This is slightly faster and more memory-efficient.
				
				local x1, y1 = points[i], points[i + 1]
				local x2, y2 = points[i + 2] or points[1], points[i + 3] or points[2]
				
				return ( x1 * y2 ) - ( x2 * y1 )
			end 
		) 
	), points
end

-- Description: 	Returns a number and it's index given a function. 
-- Parameters: 
-- 		tab			table			An index-based table containing numbers only.
-- 		...			variable arguments
-- 			func		function		The function used to determine the number.
--					Parameters:
--						current			number		The current value
--						value			number		The value to be compared
-- 					Returns: 
-- 						success 		boolean		If this value is true, the current value is replaced.
-- 		or
--	 		start		number (1)		The number at which to start.
-- 			iterator	number (1)		The amount to increase. 
-- 			func		function		The function used to determine the number.
--					Parameters:
--						current			number		The current value
--						value			number		The value to be compared
-- 					Returns: 
-- 						success 		boolean		If this value is true, the current value is replaced.
-- Returns: 
-- 		value		number		The value returned.
-- 		index		number		The index of the value returned. 
local function getIndex( tab, ... ) 
	local input = { ... }
	local func, start, iterator
	if #input == 1 then 
		func = input[1]
	else
		start, iterator, func = unpack( input )
	end
	start = start or 1
	iterator = iterator or 1
	
    if #tab == 0 then return nil, nil end
    local key, v = start, tab[start]
    for i = start + iterator, #tab, iterator do
        if func( v, tab[i] ) then
            key, v = i, tab[i]
        end
    end
    return v, key
end

-- Description: 	Allows for passing tables or data as arguments to functions.
-- Parameters: 
-- 		...			variable arguments
-- 			tab 				table 		All of the data points inside of a table.
-- 		or
-- 			data1, data2, ...	anything	All of the data points passed as parameters.
-- Returns: 
-- 		input		table		A table containing all of the input. 
local function checkInput( ... )
	local input = {}
	if type( ... ) ~= 'table' then input = { ... } else input = ... end
	return input
end

-- Description: 	Deals with floats / verify false false values. 
-- Parameters: 
-- 		number1		number		The first number to compare
-- 		number2		number		The second number to compare
-- Returns:
--		success		boolean		Whether or not the numbers are close enough.
local function checkFuzzy( number1, number2 )
	return ( number1 - .00001 <= number2 and number2 <= number1 + .00001 )
end

-- Description: 	Checks if a number is really a number.
-- Parameters: 
-- 		number		number		The number to check.
-- Returns: 
--		success		boolean		If the number is actually a number.
local function checkValidity( number )
	if type( number ) ~= 'number' then return false
	elseif number ~= number then return false -- nan
	elseif number == math.huge or number == -math.huge then return false end -- -1INF
	return true
end

-- Description: 	Gets the last number-index from a table.
-- Parameters: 
-- 		tab			table		The table.
-- Returns: 
-- 		index		number		The greatest non-nil index in the table.
local function getGreatestIndex( tab )
	local index = 0
	local new = {}
	for i, _ in pairs( tab ) do
		if type( i ) == 'number' and i > index then index = i end
	end
	return index
end

------------------- Centroid -------------------

-- Description: 	Gets the centroid of a polygon. 
-- Parameters: 
-- 		points		table		The points of the polygon in the form of { x1, y1, x2, y2, ..., x1, y1 }
-- Returns: 
-- 		cx			number		The x position of the centroid of the polygon. 
-- 		cy			number		The y position of the centroid of the polygon. 
local function getPolygonCentroid( points )
	local area, points = getArea( points ) -- Completes polygon, which is why there is ", points".
	local a = ( 1 / ( 6 * area ) )
	local cx = a * ( summation( 1, #points / 2, 
		function( i )
			i = 2 * i - 1 -- Convert it from points[i][1] to points[i]. This is slightly faster and more memory-efficient.
			
			local x1, y1 = points[i], points[i + 1]
			local x2, y2 = points[i + 2] or points[1], points[i + 3] or points[2]
			
			return ( ( x1 + x2 ) * ( ( x1 * y2 ) - ( x2 * y1 ) ) )
		end
	) )
	local cy = a * ( summation( 1, #points / 2, 
		function( i )
			i = 2 * i - 1 -- Convert it from points[i][1] to points[i]. This is slightly faster and more memory-efficient.
			
			local x1, y1 = points[i], points[i + 1]
			local x2, y2 = points[i + 2] or points[1], points[i + 3] or points[2]
			
			return ( ( y1 + y2 ) * ( ( x1 * y2 ) - ( x2 * y1 ) ) )
		end
	) )
	return cx, cy
end

-- Description: 	Gives the centroid of a circle
-- Parameters: 
-- 		data		table		A table, { centerX, centerY, radius }
-- Returns: 
-- 		x			number 		The circle's centroid x
-- 		y 			number		The circle's centroid y
local function getCircleCentroid( data ) return data[1], data[2] end

-- Description: 	Gets the midpoint of a line. 
-- Parameters: 
-- 		x1			number		The first x position of the line segment. 
-- 		y1 			number		The first y position of the line segment. 
-- 		x2 			number		The second x position of the line segment. 
-- 		y2 			number		The second y position of the line segment. 
-- Returns:
-- 		x			number 		The x position of the midpoint of the line segment.
-- 		y 			number		The y position of the midpoint of the line segment. 
local function getMidpoint( x1, y1, x2, y2 )
	return ( x1 + x2 ) / 2, ( y1 + y2 ) / 2
end

--------------- Corner ---------------

-- Description: 	Gets the bounding box corners of a polygon.
-- Parameters: 
-- 		points		table		The points of the polygon in the form of { x1, y1, x2, y2, ... }
-- Returns: 
-- 		A: 			number		The x-coordinate of the top-left corner of the polygon.
-- 		B: 			number 		The y-coordinate of the top-left corner of the polygon.
-- 		C: 			number		The x-coordinate of the bottom-left corner of the polygon.
-- 		D: 			number		The y-coordinate of the bottom-left corner of the polygon.
-- 		E: 			number		The x-coordinate of the bottom-right corner of the polygon.
-- 		F: 			number		The y-coordinate of the bottom-right corner of the polygon.
-- 		G:			number		The x-coordinate of the top-right corner of the polygon.
-- 		H: 			number		The y-coordinate of the top-right corner of the polygon.
-- In other words...
-- ( A, B ) = = = = = = = = = = = ( G, H )
-- 	  [     x     x             x    ]
--    [    / \   / \     x     / \   ]
--    [   /   \ /   \   / \   /   \  ]
--    [  /     x     \ /   \ /     x ]
--    [ /             x     x      | ]
--    [x - - - - - - - - - - - - - x ]
-- ( C, D ) = = = = = = = = = = = ( E, F )
local function getPolygonBoundingBoxPoints( points )
	local left = getIndex( points, 1, 2, function( v1, v2 ) return v1 > v2 end )
	local top = getIndex( points, 2, 2, function( v1, v2 ) return v1 > v2 end )
	local right = getIndex( points, 1, 2, function( v1, v2 ) return v1 < v2 end )
	local bottom = getIndex( points, 2, 2, function( v1, v2 ) return v1 < v2 end )
	
	local width = right - left
	local height = bottom - top
	
	return left, top, left, top + height, left + width, top + height, left + width, top
end

-- Description: 	Gets the bounding box for a circle.
-- Parameters: 
-- 		points		table		A table of circle information { centerX, centerY, radius }
-- Returns: 
-- 		A: 			number		The x-coordinate of the top-left corner of the circle.
-- 		B: 			number 		The y-coordinate of the top-left corner of the circle.
-- 		C: 			number		The x-coordinate of the bottom-left corner of the circle.
-- 		D: 			number		The y-coordinate of the bottom-left corner of the circle.
-- 		E: 			number		The x-coordinate of the bottom-right corner of the circle.
-- 		F: 			number		The y-coordinate of the bottom-right corner of the circle.
-- 		G:			number		The x-coordinate of the top-right corner of the circle.
-- 		H: 			number		The y-coordinate of the top-right corner of the circle.
-- In other words...
-- ( A, B ) = = = ( G, H )
-- 	  [    - - -    ]
--    [  /       \  ]
--    [ |    x    | ]
--    [  \       /  ]
--    [    - - -    ]
-- ( C, D ) = = = ( E, F )
local function getCircleBoundingBoxPoints( points )
	local circleX, circleY = points[1], points[2]
	local r = points[3]
	return circleX - r, circleY - r, circleX - r, circleY + r, circleX + r, circleY + r, circleX + r, circleY - r
end

------------------- Midpoint -------------------

-- Description: 	Gets all of the midpoints of a polygon.
-- Parameters: 
-- 		points		table		The points of the polygon in the form of { x1, y1, x2, y2 }
-- Returns: 
-- 		midpoints	table		The midpoints of the polygon in the form of { mx1, my1, mx2, my2, ... }
local function getMidpointsOfPolygon( points )
	local midpoints = {}
	for i = 1, #points, 2 do
		local length = #midpoints
		local x1, y1 = points[i],  points[i + 1]
		local x2, y2 = points[i + 2] or points[1], points[i + 3] or points[2]
		
		local x, y = getMidpoint( x1, y1, x2, y2 )
		midpoints[length + 1] = x
		midpoints[length + 2] = y
	end
	return midpoints
end

-------------------- Tables --------------------

-- Contains creation modes.
local modes = {
	centroid = function( points, t )		
		if t == 'point' then
			return points
		elseif t == 'circle' then
			return { getCircleCentroid( points ) }
		elseif t == 'segment' then
			return { getMidpoint( unpack( points ) ) }
		elseif t == 'polygon' then
			return { getPolygonCentroid( points ) }
		end
	end, 
	boundingBox = function( points, t )		
		if t == 'point' then
			return points
		elseif t == 'circle' then
			return { getCircleBoundingBoxPoints( points ) }
		elseif t == 'segment' or t == 'polygon' then
			return { getPolygonBoundingBoxPoints( points ) }
		end
	end, 
	points = function( points, t )
		-- NOTE: this method is awful for circle, since really a circle has infinite points.
		-- To prevent this, it uses 4 points.
		if t == 'circle' then
			local cx, cy = points[1], points[2]
			local r = points[3]
			return { cx, cy - r, cx - r, cy, cx, cy + r, cx + r, cy }
		else
			return points
		end
	end, 
	midpoint = function( points, t )
		if t == 'point' then
			return points
		elseif t == 'circle' then
			return { getCircleCentroid( points ) }
		elseif t == 'segment' or t == 'polygon' then
			return getMidpointsOfPolygon( points )
		end
	end, 
}

-- Contains search modes.
local searchModes = {
	default = function( tab )
		-- Polygon
		if tab.points and #tab.points >= 6 then
			return function( tab ) return tab.points end, 'polygon'
		elseif tab.x and tab.y then
			if tab.w and tab.h then
				return function( tab ) return { tab.x, tab.y, tab.x, tab.y + tab.h, tab.x + tab.w, tab.y + tab.h, tab.x + tab.w, tab.y } end, 'polygon'
			elseif tab.width and tab.height then
				return function( tab ) return { tab.x, tab.y, tab.x, tab.y + tab.height, tab.x + tab.width, tab.y + tab.height, tab.x + tab.width, tab.y } end, 'polygon'
			end
		end
		-- Segment
		if tab.points then
			if #tab.points == 4 then
				return function( tab ) return unpack( tab.points ) end, 'segment'
			elseif tab.points.x1 and tab.points.y1 and tab.points.x2 and tab.points.y2 then
				return function( tab ) return tab.points.x1, tab.points.y1, tab.points.x2, tab.points.y2 end, 'segment'
			end
		elseif tab.x1 and tab.y1 and tab.x2 and tab.y2 then
			return function( tab ) return tab.x1, tab.y1, tab.x2, tab.y2 end, 'segment'
		end
		-- Circle
		if tab.x and tab.y then
			if tab.r then
				return function( tab ) return tab.x, tab.y, tab.r end, 'circle'
			elseif tab.radius then
				return function( tab ) return tab.x, tab.y, tab.radius end, 'circle'
			end
		elseif tab.points then
			if tab.points[1] and tab.points[2] and tab.points[3] then
				return function( tab ) return tab.points[1], tab.points[2], tab.points[3] end, 'circle'
			elseif tab.points.x and tab.points.y then
				if tab.points.r then
					return function( tab ) return tab.points.x, tab.points.y, tab.points.r end, 'circle'
				elseif tab.points.radius then
					return function( tab ) return tab.points.x, tab.points.y, tab.points.radius end, 'circle'
				end
			end
		end
		-- Point
		if tab.x and tab.y then
			return function( tab ) return tab.x, tab.y end, 'point'
		elseif tab.points then
			if #tab.points == 2 then
				return function( tab ) return unpack( tab.points ) end, 'point'
			elseif tab.points.x and tab.points.y then
				return function( tab ) return tab.points.x, tab.points.y end, 'point'
			end
		end
		-- General Case
		local length = #tab
		if length >= 6 and length % 2 == 0 then 
			return function( tab ) return tab end, 'polygon'
		elseif length == 4 then
			return function( tab ) return unpack( tab ) end, 'segment'
		elseif length == 3 then
			return function( tab ) return unpack( tab ) end, 'circle'
		elseif legth == 2 then
			return function( tab ) return unpack( tab ) end, 'point'
		end
		
		return false
	end, 
}

-- Contains all of the objects registered.
local registry = {}

-- Contains all of the movement line segments. Erased each frame.
local movementSegments = {}

------------------- Creators -------------------

-- Description: 	Adds a new method to the modes table.
-- Parameters: 
-- 		name		string		The name it will be called by.
-- 		func		function 	The method of processing the function.
--				Parameters:
-- 					points		table		The structure being passed.
--					t			string		The type of structure.
--				Returns:
-- 					structure 	table		The new structure after being processed.
-- Returns: 
-- 		Nothing.
local function addNewMethod( name, func )
	modes[name] = func
end

-- Description: 	Adds a new search mode to the serachModes table.
-- Parameters:
-- 		name		string		The name it will be called by.
-- 		func		function 	The method of processing the information. 
-- 				Parameters: 
-- 					points		table		The object being registered.
--				Returns:
--					updateFunc	
--								function 		A function that gets the information of the object.
--								boolean	(false)	No match found. 
local function addNewSearchMode( name, func )
	searchModes[name] = func
end

-- Description: 	Creates a new system. 
-- Parameters:
--		points		table		The data to use for the structure. Should have 2, 3, 4, or an even amount of entries.
-- 		mode		string		The method name used in `addNewMethod`.
-- Returns:
-- 		structure	table		The data returned by the method creator.
local function newSystem( points, mode, search, ... )
	mode = mode or 'centroid'
	assert( modes[mode], 'Liar Error: Mode \'' .. mode .. '\' not registered.' )
	
	search = search or 'default'
	assert( searchModes[search], 'Liar Error: Search mode \'' .. search .. '\' not registered.' )
	
	local getInformationFunc, _type = searchModes[search]( points )
	assert( getInformationFunc, 'Liar Error: Search mode \'' .. search .. '\' failed to find any data. Make sure you have formatted your data correctly.' )
	
	local pointsToUpdate
	if _type == 'polygon' then
		pointsToUpdate = modes[mode]( getInformationFunc( points ), _type ) -- This way I don't need to create tables for all items, just polygon. 
	else
		pointsToUpdate = modes[mode]( { getInformationFunc( points ) }, _type )
	end
	
	local id = getGreatestIndex( registry ) + 1
	
	points.__liar = {
		points = pointsToUpdate, 
		getInformation = getInformationFunc, 
		type = _type, 
		onCollision = function() end, 
		id = id, 
		intersections = {}, 
		active = true, 
	}
	registry[id] = points
	
	return id
end

local function moveTo( points, distanceX, distanceY )
	assert( points.__liar, 'Liar Error: Attempt to move object not registered.' )
	local index = #movementSegments + 1
	movementSegments[index] = { id = points.__liar.id }
	
	local length = 0
	for i = 1, #points.__liar.points, 2 do
		length = length + 1
		local currentX, currentY = points.__liar.points[i], points.__liar.points[i + 1]
		local futureX, futureY = currentX + distanceX, currentY + distanceY
		
		movementSegments[index][length] = { currentX, currentY, futureX, futureY }
	end
end

-------------- Registry Functions --------------

-- Description: 	Remove and id from the registry.
-- Parameters: 	
-- 		id			number		The id to remove from the registry. 
-- Returns: 
-- 		Nothing
local function removeItem( id )
	registry[id] = nil
end

-- Description: 	Removes all id's from the registry.
-- Parameters: 
-- 		None
-- Returns:
-- 		Nothing
local function clearRegistry()
	for i, _ in pairs( registry ) do
		removeItem( i )
	end
end

-------------- Line Intersections --------------
-- All of these functions are from mlib, made by Davis Claiborne (github.com/davisdude/mlib).

-- Description: 	Gets the slope of a line.
-- Parameters: 
-- 		x1			number		One x-point on the line. 
-- 		y1			number		One y-point on the line.
-- 		x2 			number		Another x-point on the line.
-- 		y2			number 		Another y-point on the line.
-- Returns:
-- 		slope		
-- 					number			The slope of the line.
-- 					boolean (false) Vertical line.
local function getSlope( x1, y1, x2, y2 )
	if checkFuzzy( x1, x2 ) then return false end -- Technically it's undefined, but this is easier to program.
	return ( y1 - y2 ) / ( x1 - x2 )
end

-- Description: 	Gets the y-intercept of a line.
-- Parameters:
-- 		x			number		One x-point on the line.
-- 		y			number		One y-point on the line.
-- 		...
-- 			slope	number		The slope of the line.
-- 		or
--			x2		number		Another x-point.
-- 			y2		number		Another y-point.
-- Returns: 
-- 		intercept
-- 					number			The y-intercept of the line.
-- 					boolean (false) Vertical line.
local function getIntercept( x, y, ... )
	local input = checkInput( ... )
	local slope
	
	if #input == 1 then 
		slope = input[1] 
	else
		slope = getSlope( x, y, unpack( input ) ) 
	end
	
	if not slope then return false end
	return y - slope * x
end

-- Description: 	Checks if a point lies on a line.
-- Parameters:
-- 		x			number		The x-point to check.
-- 		y			number		The y-point to check.
-- 		x1			number		One x-coordinate on the line.
-- 		y1 			number 		One y-coordinate on the line.
-- 		x2			number		Another x-coordinate on the line.
-- 		y2 			number 		Another y-coordinate on the line.
-- Returns: 
-- 		onLine		boolean 	Whether the point lies on the line or not.
local function checkLinePoint( x, y, x1, y1, x2, y2 )
	local m = getSlope( x1, y1, x2, y2 )
	local b = getIntercept( x1, y1, m )
	
	if not m then -- Vertical 
		return checkFuzzy( x, x1 )
	end
	
	return checkFuzzy( y, m * x + b )
end

-- Description: 	Checks if a point lies on a line-segment.
-- Parameters:
-- 		px			number		The x-point to check.
-- 		py			number		The y-point to check.
-- 		x1			number		One x-coordinate of an endpoint of the segment.
-- 		y1 			number 		One y-coordinate of an endpoint of the segment.
-- 		x2			number		Another x-coordinate of an endpoint of the segment.
-- 		y2 			number 		Another y-coordinate of an endpoint of the segment.
-- Returns: 
-- 		onSegment	boolean		Whether the point lies on the line segment.
local function checkSegmentPoint( px, py, x1, y1, x2, y2 )
	-- Explanation around 5:20
	-- https://www.youtube.com/watch?v=A86COO8KC58
	local x = checkLinePoint( px, py, x1, y1, x2, y2 )
	if not x then return false end
	
	local lengthX = x2 - x1
	local lengthY = y2 - y1
	
	if checkFuzzy( lengthX, 0 ) then -- Vertical line
		if checkFuzzy( px, x1 ) then
			local low, high
			if y1 > y2 then low = y2; high = y1 
			else low = y1; high = y2 end
			
			if py >= low and py <= high then return true 
			else return false end
		else
			return false
		end
	elseif checkFuzzy( lengthY, 0 ) then -- Horizontal line
		if checkFuzzy( py, y1 ) then
			local low, high
			if x1 > x2 then low = x2; high = x1 
			else low = x1; high = x2 end
			
			if px >= low and px <= high then return true 
			else return false end
		else
			return false
		end
	end
	
	local distanceToPointX = ( px - x1 )
	local distanceToPointY = ( py - y1 )
	local scaleX = distanceToPointX / lengthX
	local scaleY = distanceToPointY / lengthY
	
	if ( scaleX >= 0 and scaleX <= 1 ) and ( scaleY >= 0 and scaleY <= 1 ) then -- Intersection
		return true
	end
	return false
end

-- Gives the intersection of two lines.
-- slope1, 	slope2, 		x1, 	y1, 		x2, y2
-- slope1, 	intercept1, 	slope2, intercept2
-- x1, 		y1, 			x2, 	y2, 		x3, y3, x4, y4
local function getLineLineIntersection( ... )
	local input = checkInput( ... )
	local x1, y1, x2, y2, x3, y3, x4, y4
	local slope1, intercept1
	local slope2, intercept2
	local x, y
	
	if #input == 4 then -- Given slope1, intercept1, slope2, intercept2. 
		slope1, intercept1, slope2, intercept2 = unpack( input ) 
		
		-- Since these are lines, not segments, we can use arbitrary points, such as ( 1, y ), ( 2, y )
		y1 = slope1 * 1 + intercept1
		y2 = slope1 * 2 + intercept1
		y3 = slope2 * 1 + intercept2
		y4 = slope2 * 2 + intercept2
		x1 = ( y1 - intercept1 ) / slope1
		x2 = ( y2 - intercept1 ) / slope1
		x3 = ( y3 - intercept1 ) / slope1
		x4 = ( y4 - intercept1 ) / slope1
	elseif #input == 6 then -- Given slope1, intercept1, and 2 points on the other line. 
		slope1 = input[1]
		intercept1 = input[2]
		slope2 = getSlope( input[3], input[4], input[5], input[6] )
		intercept2 =  getIntercept( input[3], input[4], input[5], input[6] )
		
		y1 = slope1 * 1 + intercept1
		y2 = slope1 * 2 + intercept1
		y3 = input[4]
		y4 = input[6]
		x1 = ( y1 - intercept1 ) / slope1
		x2 = ( y2 - intercept1 ) / slope1
		x3 = input[3]
		x4 = input[5]
	elseif #input == 8 then -- Given 2 points on line 1 and 2 points on line 2.
		slope1 = getSlope( input[1], input[2], input[3], input[4] )
		intercept1 = getIntercept( input[1], input[2], input[3], input[4] )
		slope2 = getSlope( input[5], input[6], input[7], input[8] )
		intercept2 = getIntercept( input[5], input[6], input[7], input[8] ) 
		
		x1, y1, x2, y2, x3, y3, x4, y4 = unpack( input )
	end
	
	if not slope1 and not slope2 then -- Both are vertical lines
		if x1 == x3 then -- Have to have the same x and y positions to intersect
			return true
		else
			return false
		end
	elseif not slope1 then -- First is vertical
		x = x1 -- They have to meet at this x, since it is this line's only x
		y = slope2 * x + intercept2
	elseif not slope2 then -- Second is vertical
		x = x3 -- Vice-Versa
		y = slope1 * x + intercept1
	elseif checkFuzzy( slope1, slope2 ) then -- Parallel (not vertical)
		if checkFuzzy( intercept1, intercept2 ) then -- Same intercept
			return true
		else
			return false
		end
	else -- Regular lines
		--   y = m1 * x + b1
		-- - y = m2 * x + b2
		--   ---------------
		--   0 = x * ( m1 - m2 ) + ( b1 - b2 )
		--  -( b1 - b2 ) = x * ( m1 - m2 )
		--   x = ( -b1 + b2 ) / ( m1 - m2 )
		
		x = ( -intercept1 + intercept2 ) / ( slope1 - slope2 )
		y = slope1 * x + intercept1
	end
	
	return x, y
end

-- Description: 	Gives the point of intersection between two line segments.
-- Parameters: 
-- 		x1			number		First x-coordinate of the first line segment.
-- 		y1			number		First y-coordinate of the first line segment.
-- 		x2			number		Second x-coordinate of the first line segment.
-- 		y2			number		Second y-coordinate of the first line segment.
-- 		x3			number		First x-coordinate of the second line segment.
-- 		y3			number		First y-coordinate of the second line segment.
-- 		x4			number		Second x-coordinate of the second line segment.
-- 		y4			number		Second y-coordinate of the second line segment.
-- Returns: 
-- 		x1			
-- 					number			First x-coordinate of the intersection.
-- 					boolean (false)	If the line segments don't intersect.
-- 		y1			number			First y-coordinate of the first line segment.
-- 					number			First y-coordinate of the first line segment.
-- 					boolean (nil)	If the line segments don't intersect.
-- 		x2			
-- 					number			Second x-coordinate of the intersection (collinear lines).
-- 					boolean (nil)	Line segments don't intersect.
-- 		y2 			
-- 					number			Second y-coordinate of the intersection (collinear lines).
-- 					boolean (nil)	Line segments don't intersect.
local function getSegmentSegmentIntersection( x1, y1, x2, y2, x3, y3, x4, y4 )
	local slope1, intercept1 = getSlope( x1, y1, x2, y2 ), getIntercept( x1, y1, x2, y2 )
	local slope2, intercept2 = getSlope( x3, y3, x4, y4 ), getIntercept( x3, y3, x4, y4 )
	
	-- Add points to the table.
	local function addPoints( tab, x, y )
		tab[#tab + 1] = x
		tab[#tab + 1] = y
	end
	
	local function removeDuplicatePairs( tab )
		for i = #tab - 1, 1, -2 do
			local x1, y1 = tab[i], tab[i + 1]
			for ii = #tab - 1, 1, -2 do 
				local x2, y2 = tab[ii], tab[ii + 1]
				if i ~= ii then
					if checkFuzzy( x1, x2 ) and checkFuzzy( y1, y2 ) then
						table.remove( tab, i )
						table.remove( tab, i )
					end
				end
			end
		end
		return tab
	end
	
	if slope1 == slope2 then -- Parallel lines
		if intercept1 == intercept2 then -- The same lines, possibly in different points. 
			local points = {}
			if checkSegmentPoint( x1, y1, x3, y3, x4, y4 ) then addPoints( points, x1, y1 ) end
			if checkSegmentPoint( x2, y2, x3, y3, x4, y4 ) then addPoints( points, x2, y2 ) end
			if checkSegmentPoint( x3, y3, x1, y1, x2, y2 ) then addPoints( points, x3, y3 ) end
			if checkSegmentPoint( x4, y4, x1, y1, x2, y2 ) then addPoints( points, x4, y4 ) end
			
			points = removeDuplicatePairs( points )
			if #points == 0 then return false end
			return unpack( points )
		else
			return false
		end
	end	

	local x, y = getLineLineIntersection( x1, y1, x2, y2, x3, y3, x4, y4 )
	if x and checkSegmentPoint( x, y, x1, y1, x2, y2 ) and checkSegmentPoint( x, y, x3, y3, x4, y4 ) then
		return x, y
	end
	
	return false
end

-------------------- Update --------------------

local function update()
	for index, value in ipairs( registry ) do
		value.__liar.points = value.__liar.getInformation( registry[index] )
	end
	
	for i1, container1 in pairs( movementSegments ) do
		registry[container1.id].intersections = {}
		local register1 = registry[container1.id]
		
		for i2, container2 in pairs( movementSegments ) do
			local register2 = registry[container2.id]
			
			if i1 ~= i2 and registry[container1.id].__liar.active and registry[container2.id].__liar.active then
				for _, segment1 in ipairs( container1 ) do
					for _, segment2 in ipairs( container2 ) do
						local x1, y1, x2, y2 = unpack( segment1 )
						local x3, y3, x4, y4 = unpack( segment2 )
						if getSegmentSegmentIntersection( x1, y1, x2, y2, x3, y3, x4, y4 ) then
							register1.intersections[#register1.intersections + 1] = container2.id
							register2.intersectoins[#register2.intersections + 1] = container1.id
						end
					end
				end
			end
		end
		if #register1.intersections > 0 then
			print'Intersection'
		end
	end
	
	for index, value in ipairs( registry ) do
		value.__liar.points = value.__liar.getInformation( registry[index] )
	end
	movementSegments = {}
end

return {
	_VERSION = 'Liar 0.2.1', 
	_DESCRIPTION = 'A fast and efficient collision method based on projecting line segments.', 
	_URL = 'https://github.com/davisdude/line', 
	_LICENSE = [[
		A collision detection library made in Lua

		Copyright (C) 2014 Davis Claiborne

		This program is free software; you can redistribute it and/or modify
		it under the terms of the GNU General Public License as published by
		the Free Software Foundation; either version 2 of the License, or
		(at your option) any later version.

		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program; if not, write to the Free Software Foundation, Inc.,
		51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

		Contact me at davisclaib@gmail.com
	]], 
	register = newSystem, 
	new = newSystem, 
	
	moveTo = moveTo,
	update = update, 
	
	addNewMethod = addNewMethod, 
	addNewSearchMode = addNewSearchMode, 
	removeItem = removeItem, 
	
	clearRegistry = clearRegistry, 
}