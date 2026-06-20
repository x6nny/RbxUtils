local ColorLibrary = {
	White = Color3.new(1, 1, 1),
	Black = Color3.new(0, 0, 0),
	Red = Color3.new(1, 0, 0),
	Green = Color3.new(0, 1, 0),
	Blue = Color3.new(0, 0, 1),
	Yellow = Color3.new(1, 1, 0),
	Cyan = Color3.new(0, 1, 1),
	Magenta = Color3.new(1, 0, 1),
	Orange = Color3.new(1, 0.5, 0),
	Gray = Color3.new(0.5, 0.5, 0.5),
}

function ColorLibrary.FromRGB(r: number, g: number, b: number): Color3
	return Color3.fromRGB(r, g, b)
end

function ColorLibrary.FromHSV(h: number, s: number, v: number): Color3
	return Color3.fromHSV(h, s, v)
end

function ColorLibrary.FromKelvin(kelvin: number): Color3
	local t = math.clamp(kelvin, 1_000, 12_000) / 100
	local r, g, b
	
	if t <= 66 then
		r = 1
		g = math.clamp((99.4708025861 * math.log(t) - 161.1195681661) / 255, 0, 1)
		b = t <= 19 and 0 or math.clamp((138.5177312231 * math.log(t - 10) - 305.0447927307) / 255, 0, 1)
	else
		r = math.clamp((329.698727446 * ((t - 60) ^ -0.1332047592)) / 255, 0, 1)
		g = math.clamp((288.1221695283 * ((t - 60) ^ -0.0755148492)) / 255, 0, 1)
		b = 1
	end
	
	return Color3.new(r, g, b)
end

function ColorLibrary.Random(): Color3
	return Color3.fromHSV(math.random(), 1, 1)
end

function ColorLibrary.RandomFull(): Color3
	return Color3.new(math.random(), math.random(), math.random())
end

function ColorLibrary.ToHex(color: Color3): string
	return color:ToHex()
end

function ColorLibrary.ToRGB(color: Color3): (number, number, number)
	return color.R, color.G, color.B
end

function ColorLibrary.ToHSV(color: Color3): (number, number, number)
	return color:ToHSV()
end

function ColorLibrary.Luminance(color: Color3): number
	return math.sqrt(0.299 * color.R ^ 2 + 0.587 * color.G ^ 2 + 0.114 * color.B ^ 2)
end

function ColorLibrary.IsDark(color: Color3): boolean
	return ColorLibrary.Luminance(color) < 0.5
end

function ColorLibrary.IsLight(color: Color3): boolean
	return ColorLibrary.Luminance(color) >= 0.5
end

function ColorLibrary.Brighten(color: Color3, amount: number): Color3
	local h, s, v = color:ToHSV()
	return Color3.fromHSV(h, s, math.clamp(v + amount, 0, 1))
end

function ColorLibrary.Darken(color: Color3, amount: number)
	local h, s, v = color:ToHSV()
	return Color3.fromHSV(h, s, math.clamp(v - amount, 0, 1))
end

function ColorLibrary.Saturate(color: Color3, amount: number): Color3
	local h, s, v = color:ToHSV()
	return Color3.fromHSV(h, math.clamp(s + amount, 0, 1), v)
end

function ColorLibrary.Desaturate(color: Color3, amount: number): Color3
	local h, s, v = color:ToHSV()
	return Color3.fromHSV(h, math.clamp(s - amount, 0, 1), v)
end

function ColorLibrary.GrayScale(color: Color3): Color3
	local l = ColorLibrary.Luminance(color)
	return Color3.new(l, l, l)
end

function ColorLibrary.ShiftHue(color: Color3, amount: number): Color3
	local h, s, v = color:ToHSV()
	return Color3.fromHSV((h + amount) % 1, s, v)
end

function ColorLibrary.Invert(color: Color3): Color3
	return Color3.new(1 - color.R, 1 - color.G, 1 - color.B)
end

function ColorLibrary.Mix(colorA: Color3, colorB: Color3): Color3
	return colorA:Lerp(colorB, 0.5)
end

function ColorLibrary.Add(colorA: Color3, colorB: Color3): Color3
	return Color3.new(
		math.clamp(colorA.R + colorB.R, 0, 1),
		math.clamp(colorA.G + colorB.G, 0, 1),
		math.clamp(colorA.B + colorB.B, 0, 1)
	)
end

function ColorLibrary.Multiply(colorA: Color3, colorB: Color3): Color3
	return Color3.new(colorA.R * colorB.R, colorA.G * colorB.G, colorA.B * colorB.B)
end

function ColorLibrary.Screen(colorA: Color3, colorB: Color3): Color3
	return Color3.new(
		1 - (1 - colorA.R) * (1 - colorB.R),
		1 - (1 - colorA.G) * (1 - colorB.G),
		1 - (1 - colorA.B) * (1 - colorB.B)
	)
end

function ColorLibrary.Complementary(color: Color3)
	return ColorLibrary.ShiftHue(color, 0.5)
end

function ColorLibrary.Analogous(color: Color3): (Color3, Color3)
	return ColorLibrary.ShiftHue(color, -1/12), ColorLibrary.ShiftHue(color, 1/12)
end

function ColorLibrary.Triadic(color: Color3): (Color3, Color3)
	return ColorLibrary.ShiftHue(color, 1/3), ColorLibrary.ShiftHue(color, 2/3)
end

function ColorLibrary.Tetradic(color: Color3): (Color3, Color3, Color3)
	return ColorLibrary.ShiftHue(color, 0.25), ColorLibrary.ShiftHue(color, 0.5), ColorLibrary.ShiftHue(color, 0.75)
end

function ColorLibrary.EvenPalette(count: number, saturation: number?, value: number?): {Color3}
	local s       = saturation or 1
	local v       = value or 1
	local palette = table.create(count)
	for i = 1, count do
		palette[i] = Color3.fromHSV((i - 1) / count, s, v)
	end
	return palette
end

function ColorLibrary.GradientPalette(from: Color3, to: Color3, count: number): {Color3}
	local palette = table.create(count)
	for i = 1, count do
		palette[i] = from:Lerp(to, (i - 1) / math.max(count - 1, 1))
	end
	return palette
end

function ColorLibrary.ToColorSequence(colors: {Color3}): ColorSequence
	if #colors == 1 then
		return ColorSequence.new(colors[1])
	end
	local keypoints = table.create(#colors)
	for i, color in ipairs(colors) do
		keypoints[i] = ColorSequenceKeypoint.new((i - 1) / (#colors - 1), color)
	end
	return ColorSequence.new(keypoints)
end

function ColorLibrary.FromBrickColor(brickColor: BrickColor)
	return brickColor.Color
end

function ColorLibrary.ToBrickColor(color: Color3): BrickColor
	return BrickColor.new(color)
end

function ColorLibrary.ContrastRatio(colorA: Color3, colorB: Color3): number
	local function relative(c: Color3): number
		local function linearize(v)
			return v <= 0.03928 and v / 12.92 or ((v + 0.055) / 1.055) ^ 2.4
		end
		return 0.2126 * linearize(c.R) + 0.7152 * linearize(c.G) + 0.0722 * linearize(c.B)
	end
	local l1 = relative(colorA) + 0.05
	local l2 = relative(colorB) + 0.05
	return (if l1 > l2 then 
				l1 / l2 
			else 
				l2 / l1)
end

function ColorLibrary.ContrastText(color: Color3): Color3
	if ColorLibrary.IsDark(color) then
		return ColorLibrary.Brighten(color, 0.8)
	elseif ColorLibrary.IsLight(color) then
		return ColorLibrary.Darken(color, 0.8)
	end
end

function ColorLibrary.Lerp(color: Color3, goal: Color3, alpha: number): Color3
	return color:Lerp(goal, alpha)
end

function ColorLibrary.LerpMulti(stops: {Color3}, alpha: number): Color3
	if #stops == 0 then error("Color_Library: LerpMulti requires at least one stop") end
	if #stops == 1 then return stops[1] end
	local scaled  = math.clamp(alpha, 0, 1) * (#stops - 1)
	local index   = math.floor(scaled)
	local t       = scaled - index
	local a       = stops[math.clamp(index + 1, 1, #stops)]
	local b       = stops[math.clamp(index + 2, 1, #stops)]
	return a:Lerp(b, t)
end

return ColorLibrary