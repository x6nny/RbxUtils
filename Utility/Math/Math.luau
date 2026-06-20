local Math = {}

function Math.safeClamp(num : number, min : number, max : number): number
	return math.clamp(num, math.min(min, max), math.max(min, max))
end

function Math.lerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end

function Math.distance(p1: Vector3, p2: Vector3): number
	return math.sqrt((p2.X - p1.X)^2 + (p2.Y - p1.Y)^2 + (p2.Z - p1.Z)^2)
end

function Math.quadraticBezier(p0, p1, p2, t): number
	local l1 = Math.lerp(p0, p1, t)
	local l2 = Math.lerp(p1, p2, t)
	return Math.lerp(l1, l2, t)
end

function Math.cubicBezier(p0, p1, p2, p3, t): number
	local q1 = Math.quadraticBezier(p0, p1, p2, t)
	local q2 = Math.quadraticBezier(p1, p2, p3, t)
	return Math.lerp(q1, q2, t)
end

function Math.getBezierPoint(p0, p1, p2, p3, t) : { x : number, y : number }
	local x = Math.cubicBezier(p0.x, p1.x, p2.x, p3.x, t)
	local y = Math.cubicBezier(p0.y, p1.y, p2.y, p3.y, t)
	return {x = x, y = y}
end

function Math.sigmoid(x: number, k: number): number
	return 1 / (1 + math.exp(-k * x))
end

return Math