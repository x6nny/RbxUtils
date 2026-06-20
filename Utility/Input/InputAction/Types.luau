export type ContextOptions = {
	Priority: number?,
	Sink: boolean?,
}

export type Context = {
	instance: InputContext,
	actions: {
		[string]: ActionClass
	},
}

export type ContextClass = Context & {
	Enable: (ContextClass, enabled: boolean) -> (),
	Action: (ContextClass, name: string, options: ActionOptions) -> ActionClass
}

export type ActionOptions = {
	Enabled: boolean?,
	Type: Enum.InputActionType,
}

export type Action = {
	instance: InputAction,
	binds: {
		[string]: BindClass
	},
	
	listeners: {
		[number]: {
			state: any,
			callback: (state: any) -> (),
		}
	}
}

export type ActionClass = Action & {
	Enable: (ActionClass, enabled: boolean) -> (),
	
	Bind: (ActionClass, name: string, options: BindOptions) -> BindClass,
	Unbind: (ActionClass, name: string) -> (),
	
	Listen: (ActionClass, state: any, callback: (state: any) -> ()) -> () -> (),
	
	Destroy: (ActionClass) -> ()
}

export type BindOptions = {
	KeyCode: Enum.KeyCode?,
	PrimaryModifier: Enum.KeyCode?,
	SecondaryModifier: Enum.KeyCode?,
	UIButton: TextButton | ImageButton?
}

export type Bind = {
	instance: InputBinding,
	onDown: {() -> ()},
	onUp: {() -> ()},
}

export type BindClass = Bind & {
	Destroy: (BindClass) -> (),
}

return {}