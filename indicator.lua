if not f then f = {} end
f.indicator = {}

f.indicator.func = {
	getwall = function(x, y, rot)
		repeat
			x = x + math.sin(math.rad(rot))
			y = y - math.cos(math.rad(rot))
			local tx, ty = math.floor(x / 32), math.floor(y / 32)
			if tx > map('xsize') or ty > map('ysize') or tx < 0 or ty < 0 then
				return x + math.sin(math.rad(rot)) * 1000, y - math.cos(math.rad(rot)) * 1000
			end
		until tile(math.floor(x / 32), math.floor(y / 32), 'wall')
		return x + math.sin(math.rad(rot)) * -1, y - math.cos(math.rad(rot)) * -1
	end;
	
	drawline = function(id, x1, y1, x2, y2, col)
		local dist, dir = math.sqrt((x2 - x1)^2 + (y2 - y1)^2), -math.deg(math.atan2(x1 - x2, y1 - y2))
		local x3, y3 = x1 + math.sin(math.rad(dir)) * (dist/2), y1 - math.cos(math.rad(dir)) * (dist/2)
		local img = image('gfx/factizer699.bmp', x3, y3, 1, id)
		imagepos(img, x3, y3, dir-90)
		imagescale(img, dist, 1)
		imagecolor(img, col[1], col[2], col[3])
		return img
	end;
	
	drawlines = function(id, length, col)
		if not col then col = {255, 255, 255} end
		rot = player(id, 'rot')
		for k, v in pairs(f.indicator.player[id].lines) do
			freeimage(v)
		end
		f.indicator.player[id].lines = {}
		local x, y = f.indicator.func.getwall(player(id, 'x'), player(id, 'y'), rot)
		local px, py = player(id, 'x'), player(id, 'y')
		repeat
			if math.sqrt((py - y)^2 + (px - x)^2) <= length then
				table.insert(f.indicator.player[id].lines, f.indicator.func.drawline(id, x, y, px, py, col))
				if player(id, 'weapontype') == 73 then return end
				length = length - math.sqrt((py - y)^2 + (px - x)^2)
				rot = -rot
				local nx, ny = x+math.sin(math.rad(rot)), y-math.cos(math.rad(rot))
				if tile(math.floor(nx / 32), math.floor(ny / 32), 'wall') then
					rot = rot + 180
				end
				px, py = x, y
				x, y = f.indicator.func.getwall(px, py, rot)
			else 
				table.insert(f.indicator.player[id].lines, f.indicator.func.drawline(id, px, py, px+math.sin(math.rad(rot))*length, py-math.cos(math.rad(rot))*length, col))
				length = 0
				break
			end
		until length == 0 
	end;
}

f.indicator.player = {}
f.indicator.colors = {
	[49] = {255, 0, 0};
	[51] = {255, 0, 0};
	[52] = {255, 255, 255};
	[53] = {100, 100, 100};
	[54] = {0, 0, 255};
	[72] = {0, 255, 0};
	[73] = {255, 255, 50};
	[76] = {255, 255, 0};
}

addhook('ms100', 'f.indicator.hook.ms100')
addhook('join', 'f.indicator.hook.join')
addhook('clientdata', 'f.indicator.hook.clientdata')
addhook('minute', 'f.indicator.hook.minute')
addhook('say', 'f.indicator.hook.say')

f.indicator.hook = {
	ms100 = function()
		for _, id in pairs(player(0, 'tableliving')) do
			if not player(id, 'bot') then
				reqcld(id, 0)
			end
		end
	end;
	
	join = function(id)
		f.indicator.player[id] = {
			lines = {};
			constant = false;
		}
	end;
	
	clientdata = function(id, mode, data1, data2)
		if data1 > 640 then data1 = 640 end
		if data1 < 0 then data1 = 0 end
		if data2 > 480 then data2 = 480 end
		if data2 < 0 then data2 = 0 end
		if player(id, 'weapontype') == 51 or player(id, 'weapontype') == 52 or player(id, 'weapontype') == 53 or player(id, 'weapontype') == 54 or player(id, 'weapontype') == 72 or player(id, 'weapontype') == 73 or player(id, 'weapontype') == 76 or player(id, 'weapontype') == 49 then
			if not f.indicator.player[id].constant then
				f.indicator.func.drawlines(id, math.sqrt((240 - data2)^2 + (320 - data1)^2), f.indicator.colors[player(id, 'weapontype')])	
			else
				f.indicator.func.drawlines(id, 240, f.indicator.colors[player(id, 'weapontype')])	
			end
		else
			for k, v in pairs(f.indicator.player[id].lines) do
				freeimage(v)
			end
			f.indicator.player[id].lines = {}
		end
	end;
	
	minute = function()
		msg(string.char(169) ..'255255255If your \'Grenade Distance\' option is set to \'Constant\', then say \'!indicator.toggle\'.')
		msg(string.char(169) ..'255255255That command will make your indicator work properly.')
	end;
	
	say = function(id, text)
		if text == '!indicator.toggle' then
			f.indicator.player[id].constant = not f.indicator.player[id].constant
			return 1
		end
	end;
}
