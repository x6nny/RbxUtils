local ReplicatedStorage = game:GetService("ReplicatedStorage")

export type Payload = {
    [number]: {
        id: number,
        schema: any,
        data: any,
    }
}

return nil