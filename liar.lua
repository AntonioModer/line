-- Liar
-- - Line
-- - Intersection
-- - Achieved through
-- - Ray-Casting

local unpack = table.unpack or unpack

------------ Local Helper Functions ------------

-- Description: 	Gets the type of structure passed to.
-- Parameters: 
-- 		length		number		The number of data points passed. 
-- Returns: 
-- 		type		string		The type of structure. 
--			2: 		'point'
--			3:		'circle'
--			4:		'segment'
--			Even #:	'Polygon'
local function getType( length )
	if length == 2 then
		return 'point'
	elseif length == 3 then
		return 'circle'
	elseif length == 4 then
		return 'segment'
	elseif length % 2 == 0 then 
		return 'polygon'
	else
		error( 'Liar Error: must be given 2, 3, 4, or an even amount of arguments.' )
	end
end

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

-------------------- Modes --------------------

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

-- Description: 	Creates a new system. 
-- Parameters:
--		points		table		The data to use for the structure. Should have 2, 3, 4, or an even amount of entries.
-- 		mode		string		The method name used in `addNewMethod`.
-- Returns:
-- 		structure	table		The data returned by the method creator.
local function newSystem( points, mode, ... )
	mode = mode or 'centroid'
	local t = getType( #points )
	assert( modes[mode], 'Liar Error: Mode \'' .. mode .. '\' not registered.' )
	return modes[mode]( { unpack( points ) }, t, ... ) -- The unpack bit makes sure not to change original table values.
end

return {
	_VERSION = 'Liar 0.0.1', 
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
	newSystem = newSystem, 
}