--!native
local bh_types = require(script.Parent.bh_types)

local none: bh_types.TypeStruct<nil> = {
	size = 0,

	read = function(buf: buffer, pos: number): (nil, number)
		return nil, pos
	end,

	write = function(buf: buffer, pos: number, value: nil): number
		return pos
	end,
}

local u8: bh_types.TypeStruct<number> = {
    size = 1,

    read = function(buf: buffer, pos: number): (number, number)
        return buffer.readu8(buf, pos), pos + 1
    end,

    write = function(buf: buffer, pos: number, value: number): number
        buffer.writeu8(buf, pos, value)
        return pos + 1
    end,
}

local bool: bh_types.TypeStruct<boolean> = {
    size = 1,

    read = function(buf: buffer, pos: number): (boolean, number)
        if buffer.readu8(buf, pos) == 1 then
            return true, pos + 1
        else
            return false, pos + 1
        end
    end,

    write = function(buf: buffer, pos: number, value: boolean): number
        if value then
            buffer.writeu8(buf, pos, 1)
        else
            buffer.writeu8(buf, pos, 0)
        end
        return pos + 1
    end,
}

local u16: bh_types.TypeStruct<number> = {
    size = 2,

    read = function(buf: buffer, pos: number): (number, number)
        return buffer.readu16(buf, pos), pos + 2
    end,

    write = function(buf: buffer, pos: number, value: number): number
        buffer.writeu16(buf, pos, value)
        return pos + 2
    end,
}

local u32: bh_types.TypeStruct<number> = {
    size = 4,

    read = function(buf: buffer, pos: number): (number, number)
        return buffer.readu32(buf, pos), pos + 4
    end,

    write = function(buf: buffer, pos: number, value: number): number
        buffer.writeu32(buf, pos, value)
        return pos + 4
    end,
}

local i8: bh_types.TypeStruct<number> = {
    size = 1,

    read = function(buf: buffer, pos: number): (number, number)
        return buffer.readi8(buf, pos), pos + 1
    end,

    write = function(buf: buffer, pos: number, value: number): number
        buffer.writei8(buf, pos, value)
        return pos + 1
    end,
}

local i16: bh_types.TypeStruct<number> = {
    size = 2,

    read = function(buf: buffer, pos: number): (number, number)
        return buffer.readi16(buf, pos), pos + 2
    end,

    write = function(buf: buffer, pos: number, value: number): number
        buffer.writei16(buf, pos, value)
        return pos + 2
    end,
}

local i32: bh_types.TypeStruct<number> = {
    size = 4,

    read = function(buf: buffer, pos: number): (number, number)
        return buffer.readi32(buf, pos), pos + 4
    end,

    write = function(buf: buffer, pos: number, value: number): number
        buffer.writei32(buf, pos, value)
        return pos + 4
    end,
}

local f32: bh_types.TypeStruct<number> = {
    size = 4, 

    read = function(buf: buffer, pos: number): (number, number)
        return buffer.readf32(buf, pos), pos + 4
    end,

    write = function(buf: buffer, pos: number, value: number): number
        buffer.writef32(buf, pos, value)
        return pos + 4
    end,
}

local f64: bh_types.TypeStruct<number> = {
    size = 8,

    read = function(buf: buffer, pos: number): (number, number)
        return buffer.readf64(buf, pos), pos + 8
    end,

    write = function(buf: buffer, pos: number, value: number): number
        buffer.writef64(buf, pos, value)
        return pos + 8
    end,
}

local str8: bh_types.TypeStruct<string> = {
    size = function(v: string) return 1 + #v end,

    read = function(buf: buffer, pos: number): (string, number)
        local len = buffer.readu8(buf, pos)
        local str = buffer.readstring(buf, pos + 1, len)
        return str, pos + 1 + len
    end,

    write = function(buf: buffer, pos: number, value: string): number
        local len = #value
        buffer.writeu8(buf, pos, len)
        buffer.writestring(buf, pos + 1, value)
        return pos + 1 + len
    end,
}

local str16: bh_types.TypeStruct<string> = {
    size = function(v: string) return 2 + #v end,

    read = function(buf: buffer, pos: number): (string, number)
        local len = buffer.readu16(buf, pos)
        local str = buffer.readstring(buf, pos + 2, len)
        return str, pos + 2 + len
    end,

    write = function(buf: buffer, pos: number, value: string): number
        local len = #value
        buffer.writeu16(buf, pos, len)
        buffer.writestring(buf, pos + 2, value)
        return pos + 2 + len
    end,
}

local str32: bh_types.TypeStruct<string> = {
    size = function(v: string) return 4 + #v end,

    read = function(buf: buffer, pos: number): (string, number)
        local len = buffer.readu32(buf, pos)
        local str = buffer.readstring(buf, pos + 4, len)
        return str, pos + 4 + len
    end,

    write = function(buf: buffer, pos: number, value: string): number
        local len = #value
        buffer.writeu32(buf, pos, len)
        buffer.writestring(buf, pos + 4, value)
        return pos + 4 + len
    end,
}

local vec2: bh_types.TypeStruct<Vector2>  = {
    size = 8,
    read = function(buf: buffer, pos: number): (Vector2, number)
        return Vector2.new(
            buffer.readf32(buf, pos),
            buffer.readf32(buf, pos + 4)
        ), pos + 8 
    end,

    write = function(buf: buffer, pos: number, value: Vector2): number
        buffer.writef32(buf, pos, value.X)
        buffer.writef32(buf, pos + 4, value.Y)
        return pos + 8
    end
}

local vec3: bh_types.TypeStruct<Vector3> = {
    size = 12,
    read = function(buf: buffer, pos: number): (Vector3, number)
        return Vector3.new(
            buffer.readf32(buf, pos),
            buffer.readf32(buf, pos + 4),
            buffer.readf32(buf, pos + 8)
        ), pos + 12
    end,

    write = function(buf: buffer, pos: number, value: Vector3): number
        buffer.writef32(buf, pos, value.X)
        buffer.writef32(buf, pos + 4, value.Y)
        buffer.writef32(buf, pos + 8, value.Z)
        return pos + 12
    end
}

local color3: bh_types.TypeStruct<Color3> = {
    size = 3,
    read = function(buf: buffer, pos: number): (Color3, number)
        return Color3.fromRGB(
            buffer.readu8(buf, pos),
            buffer.readu8(buf, pos + 1),
            buffer.readu8(buf, pos + 2)
        ), pos + 3
    end,

    write = function(buf: buffer, pos: number, value: Color3): number
        buffer.writeu8(buf, pos, math.round(value.R * 255))    
        buffer.writeu8(buf, pos + 1, math.round(value.G * 255))    
        buffer.writeu8(buf, pos + 2, math.round(value.B * 255))    
        return pos + 3
    end
}

local cframe: bh_types.TypeStruct<CFrame> = {
    size = 24,

	read = function(buf: buffer, pos: number): (CFrame, number)
		
		return CFrame.new(
			buffer.readf32(buf, pos), 
			buffer.readf32(buf, pos + 4), 
			buffer.readf32(buf, pos + 8))
			* 
			CFrame.Angles(
				buffer.readf32(buf, pos + 12), 
				buffer.readf32(buf, pos + 16), 
				buffer.readf32(buf, pos + 20)), pos + 24
    end,

	write = function(buf: buffer, pos: number, value: CFrame): number

		local x, y, z = value.X, value.Y, value.Z
		local rx, ry, rz = value:ToEulerAnglesXYZ()

		buffer.writef32(buf, pos, x)
		buffer.writef32(buf, pos + 4, y)
		buffer.writef32(buf, pos + 8, z)
		
		buffer.writef32(buf, pos + 12, rx)
		buffer.writef32(buf, pos + 16, ry)
		buffer.writef32(buf, pos + 20, rz)
		
        return pos + 24
    end
}

local array = function<T>(size: bh_types.TypeStruct<number>, type: bh_types.TypeStruct<T>)

    local s_write = size.write
    local s_read = size.read
    local s_size = size.size :: number

    local t_write = type.write
    local t_read = type.read
    local t_size = type.size :: any
    local t_size_type = typeof(type.size)

    return {
        size = function(sent: {[number]: T}): number
            local n = s_size

            for i = 1, #sent do
                if t_size_type == "function" then
                    n += t_size(sent[i])
                else
                    n += t_size
                end
            end
            
            return n
        end,

        read = function(buf: buffer, pos: number): ({[number]: T}, number)
            local length, c_pos = s_read(buf, pos)
            local list = table.create(length)

            for i = 1, length do
                local val, n_pos = t_read(buf, c_pos)
                list[i] = val
                c_pos = n_pos 
            end

            return list, c_pos 
        end,

        write = function(buf: buffer, pos: number, value: {[number]: T})
           local c_pos = s_write(buf, pos, #value)

            for i = 1, #value do
                c_pos = t_write(buf, c_pos, value[i])
            end
            return c_pos
        end
    }
end

local struct = function<T>(data: {[T]: bh_types.TypeStruct<T>})
    return {
        size = function(sent): number
            local size = 0
            for key, type in data do
                if typeof(type.size) == "function" then
                    size += type.size(sent[key])
                else
                    size += type.size
                end
            end

            return size
        end,

        read = function(buf: buffer, pos: number)
            local c_pos = pos
            local tab = {}

            for key, type in data do
                local v, n_pos = type.read(buf, c_pos)
                tab[key] = v
                c_pos = n_pos
            end

            return tab, c_pos
        end,

        write = function(buf: buffer, pos: number, value: any)
            local c_pos = pos
            for key, type in data do
                c_pos = type.write(buf, c_pos, value[key])
            end
            return c_pos 
        end
    }
end

local opt = function<T>(baseType: bh_types.TypeStruct<T>): bh_types.TypeStruct<T?>
    return {
        size = function(value: T?): number
            if value == nil then
                return 1
            end
            
            if typeof(baseType.size) == "function" then
                return 1 + baseType.size(value)
            else
                return 1 + (baseType.size :: number)
            end
        end,

        read = function(buf: buffer, pos: number): (T?, number)
            local exists = buffer.readu8(buf, pos) == 1
            
            if exists then
                return baseType.read(buf, pos + 1)
            else
                return nil, pos + 1
            end
        end,

        write = function(buf: buffer, pos: number, value: T?): number
            if value ~= nil then
                buffer.writeu8(buf, pos, 1)
                return baseType.write(buf, pos + 1, value)
            else
                buffer.writeu8(buf, pos, 0)
                return pos + 1
            end
        end,
    }
end

return {
    none = none,

    u8 = u8,
    u16 = u16,
    u32 = u32,
    i8 = i8,
    i16 = i16,
    i32 = i32,
    f32 = f32,
    f64 = f64,
    str8 = str8,
    str16 = str16,
    str32 = str32,

    bool = bool,
    vec2 = vec2,
    vec3 = vec3,
    color3 = color3,
    cframe = cframe,

    array = array,
    struct = struct,
    opt = opt,
}