local currentCamera = workspace.CurrentCamera

local function getViewportSize() : Vector2
	return currentCamera.ViewportSize
end

local function setCameraSubject(subject : Instance)
	currentCamera.CameraSubject = subject
end

local function setCameraType(cameraType : Enum.CameraType)
	currentCamera.CameraType = cameraType
end

local function worldToScreenPoint(worldPoint : Vector3) : (Vector3, boolean)
	return currentCamera:WorldToScreenPoint(worldPoint)
end

local function screenPointToRay(x : number, y : number, depth : number?) : Ray
	return currentCamera:ScreenPointToRay(x, y, depth)
end

local function viewportPointToRay(x : number, y : number, depth : number?) : Ray
	return currentCamera:ViewportPointToRay(x, y, depth)
end

local function worldToViewportPoint(worldPoint : Vector3): (Vector3, boolean)
	return currentCamera:WorldToViewportPoint(worldPoint)
end

local function getRoll() : number
	return currentCamera:GetRoll()
end

local function setRoll(rollAngle : number)
	currentCamera:SetRoll(rollAngle)
end

local function setFocus(cframe : CFrame)
	currentCamera.Focus = cframe
end

local function setHeadLocked(locked : boolean)
	currentCamera.HeadLocked = locked
end

local function zoomToExtents(boundingBoxCFrame : CFrame, boundingBoxSize : Vector3)
	currentCamera:ZoomToExtents(boundingBoxCFrame, boundingBoxSize)
end

local function setFieldOfViewMode(fieldOfViewMode : Enum.FieldOfViewMode)
	currentCamera.FieldOfViewMode = fieldOfViewMode
end

local function setFieldOfView(fieldOfView : number)
	currentCamera.FieldOfView = fieldOfView
end

local function getRenderCFrame() : CFrame
	return currentCamera:GetRenderCFrame()
end

local function setMaxAxisFieldOfView(maxAxisFieldOfView : number)
	currentCamera.MaxAxisFieldOfView = maxAxisFieldOfView
end

local function setDiagonalFieldOfView(diagonalFieldOfView : number)
	currentCamera.DiagonalFieldOfView = diagonalFieldOfView
end

local function setVRTiltAndRollEnabled(VRTiltAndRollEnabled : boolean)
	currentCamera.VRTiltAndRollEnabled = VRTiltAndRollEnabled
end

local function getPartsObscuringTarget(castPoints : { Vector3 }, ignoreList : { Instance }) : { Instance }
	return currentCamera:GetPartsObscuringTarget(castPoints, ignoreList)
end

local function setHeadScale(headScale : number)
	currentCamera.HeadScale = headScale
end

local function setNearPlaneZ(nearPlaneZ : number)
	currentCamera.NearPlaneZ = nearPlaneZ
end

return { 
	getViewportSize = getViewportSize,
	setCameraSubject = setCameraSubject,
	setCameraType = setCameraType,
	worldToScreenPoint = worldToScreenPoint,
	screenPointToRay = screenPointToRay,
	viewportPointToRay = viewportPointToRay,
	worldToViewportPoint = worldToViewportPoint,
	getRoll = getRoll,
	setRoll = setRoll,
	setFocus = setFocus,
	setHeadLocked = setHeadLocked,
	zoomToExtents = zoomToExtents,
	setFieldOfViewMode = setFieldOfViewMode,
	setFieldOfView = setFieldOfView,
	getRenderCFrame = getRenderCFrame,
	setMaxAxisFieldOfView = setMaxAxisFieldOfView,
	setDiagonalFieldOfView = setDiagonalFieldOfView,
	setVRTiltAndRollEnabled = setVRTiltAndRollEnabled,
	getPartsObscuringTarget = getPartsObscuringTarget,
	setHeadScale = setHeadScale,
	setNearPlaneZ = setNearPlaneZ,
}