#!/usr/bin/env lua

local math = require("math")
local table = require("table")

local Rows = {}
local Cols = {}
local Clus = {}
local Cells = {}

local getClusIndexAt = function(r, c) return (math.floor((r - 1) / 3) * 3) + math.floor((c - 1) / 3) + 1 end

local clearGrid = function()
	Rows = {}
	Cols = {}
	Clus = {}
	Cells = {}
	for i = 1, 9 do
		Rows[i] = {}
		Cols[i] = {}
		Clus[i] = {}
	end
	for r = 1, 9 do
		for c = 1, 9 do
			local cell = {value = 0, potentials = {}}
			Rows[r][c] = cell
			Cols[c][r] = cell
			Clus[getClusIndexAt(r, c)][(((r - 1) % 3) * 3) + ((c - 1) % 3) + 1] = cell
			Cells[((r - 1) * 9) + c] = cell
		end
	end
end

local checkPuzzle = function()
	for g = 1, 9 do
		local nums = {row = {}, col = {}, clus = {}}
		for i = 1, 9 do
			if Rows[g][i].value > 0 and nums.row[Rows[g][i].value] == true then return false end
			if Cols[g][i].value > 0 and nums.col[Cols[g][i].value] == true then return false end
			if Clus[g][i].value > 0 and nums.clus[Clus[g][i].value] == true then return false end
			nums.row[Rows[g][i].value] = true
			nums.col[Cols[g][i].value] = true
			nums.clus[Clus[g][i].value] = true
		end
	end
	return true
end

local getPuzzleGrid = function()
	local getRow = function(r)
		local line = '|'
		for i = 1, 9 do
			local val = Rows[r][i].value
			if val == 0 then val = ' ' end
			line = line..' '..tostring(val)..' '
			if i % 3 == 0 and i ~= 9 then
				line = line..'‖'
			else
				line = line..'|'
			end
		end
		return line
	end
	local border = "+---+---+---+---+---+---+---+---+---+"
	local doubleBorder = "+===+===+===+===+===+===+===+===+===+"
	local grid = border
	for i = 1, 9 do
		grid = grid..'\n'..getRow(i)
		if i % 3 == 0 and i ~= 9 then
			grid = grid..'\n'..doubleBorder
		else
			grid = grid..'\n'..border
		end
	end
	return grid
end

local getPuzzle = function()
	local c = 1
	local increment = function() c = c + 1 end
	local decrement = function() if c > 1 then c = c - 1 end end
	local message = "\n\n\n"
	local draw = function()
		os.execute("clear")
		io.write("Input your Sudoku puzzle givens number by letter.\nPress the number for the space with the `X`,\nthen press RETURN to submit that number.\nSubmit no number for blank spaces.\nNumbers must be an integer in range [1, 9].\nSubmit a period `.` to go back one cell.\nSubmit an `x` to peacefully exit.\n")
		io.write(message..'\n')
		io.write(getPuzzleGrid()..'\n\n')
	end
	while true do
		while c <= 81 do
			Cells[c].value = 'X'
			draw()
			io.write("What value do you want to put in for `X`? ")
			message = "\n\n\n"
			local ans = io.read()
			if ans == nil then
				message = "\n\tPrevious input was `nil`. Submit one\n\tinteger in range [1, 9], `.`, `x`, or a blank.\n"
			elseif #ans > 1 then
				message = "\n\tPrevious input too long. Submit one\n\tinteger in range [1, 9], `.`, `x`, or a blank.\n"
			elseif string.lower(ans) == '.' then
				Cells[c].value = 0
				decrement()
			elseif string.lower(ans) == 'x' then
				return false
			else
				if #ans == 0 then ans = 0 end
				local num = tonumber(ans)
				if num == nil then
					message = "\n\tCould not interpret previous input. Submit\n\tone integer in range [1, 9], `.`, `x`, or a blank.\n"
				else
					Cells[c].value = num
					if checkPuzzle() then
						increment()
					else
						message = "\n\tCould not allow number. Submitted number\n\twould cause an unsolvable contradiction.\n"
					end
				end
			end
		end
		draw()
		io.write("This is the puzzle you input. Do you want to sumbit this? (`y` or `n`) ")
		local ans = io.read()
		if ans == nil then
			message = "\n\tPrevious input was `nil`.\n\tSubmit one letter, either `y` or `n`.\n"
		elseif string.lower(ans) == 'n' then
			decrement()
		elseif string.lower(ans) == 'y' then
			break
		else
			message = "\n\tCould not interpret previous input.\n\tSubmit one letter, either `y` or `n`.\n"
		end
	end
	return true
end

local updateAllPotentials = function()
	for r = 1, 9 do
		local row = Rows[r]
		for c = 1, 9 do
			local col = Cols[c]
			if row[c].value == 0 then
				local possibilities = {}
				for i = 1, 9 do table.insert(possibilities, true) end
				local clus = Clus[getClusIndexAt(r, c)]
				for i = 1, 9 do
					possibilities[row[i].value] = false
					possibilities[col[i].value] = false
					possibilities[clus[i].value] = false
				end
				row[c].potentials = {}
				for i = 1, 9 do if possibilities[i] then table.insert(row[c].potentials, i) end end
			end
		end
	end
end

local updateNumbers = function()
	for r = 1, 9 do
		for c = 1, 9 do
			local cell = Rows[r][c]
			if cell.value == 0 and #cell.potentials == 1 then
				cell.value = cell.potentials[1]
				cell.potentials = {}
				return true
			end
		end
	end
	local checkGroup = function(grouping)
		local potens = {}
		for i = 1, 9 do table.insert(potens, {}) end
		for i = 1, 9 do
			local cell = grouping[i]
			for x = 1, #cell.potentials do table.insert(potens[cell.potentials[x]], cell) end
		end
		for i = 1, 9 do
			if #potens[i] == 1 then
				local cell = potens[i][1]
				cell.value = i
				cell.potentials = {}
				return true
			end
		end
		return false
	end
	for i = 1, 9 do
		if checkGroup(Rows[i]) or
				checkGroup(Cols[i]) or
				checkGroup(Clus[i]) then
			return true
		end
	end
	return false
end

local solve = function()
	local changed
	repeat
		updateAllPotentials()
		changed = updateNumbers()
	until changed == false
	for c = 1, 81 do
		if Cells[c].value == 0 then
			return false
		end
	end
	return true
end

pcall(
	function()
		while true do
			clearGrid()
			if getPuzzle() then
				os.execute("clear")
				if solve() then
					io.write("This is the solution:\n\n\n")
				else
					io.write("I couldn't solve it all the way.\nThis is as far as I got:\n\n")
				end
				io.write(getPuzzleGrid().."\n\n")
				io.write("Would you like to try another puzzle? (`y` for `yes`, anything else for `no`) ")
				if string.lower(io.read() or 'n') ~= 'y' then
					break
				end
			else
				break
			end
		end
	end
)
os.execute("clear")
os.exit()

--[[

def grouping: a `grouping` for a cell is the row, column, or cluster containing that cell.

Procedure:
	update all potential numbers:
		read every grouping for a cell for conflicting numbers
		run smart algorithm to refine list of potentials
	write in values for cells:
		cells with one potential value have that as their value
		cells with the only possible value for a particular grouping have that as their value

]]