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
			elseif tab.radius
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
local function newSystem( points, mode, serach, ... )
	mode = mode or 'centroid'
	assert( modes[mode], 'Liar Error: Mode \'' .. mode .. '\' not registered.' )
	
	search = search or 'default'
	assert( searchModes[search], 'Liar Error: Search mode \'' .. serach .. '\' not registered.' )
	
	local pointsToUpdate = modes[mode]( points )
	local getInformationFunc, _type = searchMode[search]( points )
	
	assert( getInformationFunc, 'Liar Error: Search mode \'' .. search .. '\' failed to find any data. Make sure you have formatted your data correctly.' )
	local id = getGreatestIndex( registry ) + 1
	
	tab.__liar = {
		points = pointsToUpdate, 
		getInformation = getInformationFunc, 
		type = _type, 
		onCollision = function() end, 
		id = id, 
	}
	return id
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

return {
	_VERSION = 'Liar 0.2.0', 
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
	addNewMethod = addNewMethod, 
	addNewSearchMode = addNewSearchMode, 
	
	register = newSystem, 
	new = newSystem, 
	
	removeItem = removeItem, 
	clearRegistry = clearRegistry, 
}