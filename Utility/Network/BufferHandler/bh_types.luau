export type cursor = {}

export type TypeStruct<T> = {
	size: number | (any) -> number,
	read: (buf: buffer, pos: number) -> (T, number),
	write: (buf: buffer, pos: number, value: T) -> number,
}

export type RegistryTypes = {
	none: nil,
	
    u8: number,
    u16: number,
    u32: number,
    i8: number,
    i16: number,
    i32: number,
    f32: number,
    f64: number,
    bool: boolean,
    
    str8: string,
    str16: string,
    str32: string,
    
    vec2: Vector2,
    vec3: Vector3,
    color3: Color3,
    cframe: CFrame,
    
    array:<S, T>(size: S, type: T) -> {[number]: T},
    struct:<T>(data: T) -> T,
	opt:<T>(data: T) -> T?
}

return nil