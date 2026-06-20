--!strict
--!optimize 2
local MarketplaceService = game:GetService('MarketplaceService')
local DataStoreService = game:GetService('DataStoreService')
local RunService = game:GetService('RunService')
local Players = game:GetService('Players')


--[[ Types ]]--
export type Receipt = {
	PurchaseId : number,
	PlayerId : number,
	ProductId : number,
	PlaceIdWherePurchased : number,
	CurrencySpent : number,
	CurrencyType : Enum.CurrencyType,
	ProductPurchaseChannel : Enum.ProductPurchaseChannel
}
export type ProductInfo = {
	--> Basic information
	Name : string,
	Description : string,
	PriceInRobux : number,
	ProductId : number,
	ProductType : string,
	Created : string,
	Updated : string,
	ContentRatingTypeId : number,
	MinimumMembershipLevel : number,
	IsPublicDomain : boolean,
	TargetId : number,

	--> Creator Information
	Creator : {
		CreatorType : 'User' | 'Group',
		CreatorTargetId : number,
		HasVerifiedBadge : boolean,
		Name : string,
		Id : number
	},

	--> Asset Information
	AssetId : number,
	AssetTypeId : number,
	IconImageAssetId : number,
	IsForSale : boolean,
	IsLimited : boolean,
	IsLimitedUnique : boolean,
	IsNew : boolean,
	Remaining : number,
	Sales : number,

	--> Collectibles Information
	CollectibleItemId : string,
	CollectibleProductId : string,
	CollectiblesItemDetails : {
		CollectibleLowestAvailableResaleItemInstanceId : number,
		CollectibleLowestAvailableResaleProductId : number,
		CollectibleLowestResalePrice : number,
		IsForSale : boolean,
		IsLimited : boolean,
		TotalQuantity : number
	},

	--> Sale Location Settings
	CanBeSoldInThisGame : boolean,
	SalesLocation : {
		SaleLocationType : number,
		UniverseIds : {number}
	},
}

export type productFunction = (receipt : Receipt, player : Player) -> boolean
export type gamepassData = { GamepassId : number, GiftProductId : number? }
type GiftData = {ProductGifting : number?, UserGifting : Player?}
type ReceiptLog = { Date : typeof(DateTime.now():ToUniversalTime()), receipt : Receipt, GiftedTo : number? }
type ReceiptLogs = { ReceiptLog }
type userData = {
	Gamepasses : { number },
	ReceiptLogs : ReceiptLogs,
}

--[[ Dependencies ]]--
local ProfileStore = require(script.Parent.Parent.Data.ProfileStore)
local playerHandler = require(script.Parent.Parent.Player.PlayerUtil.PlayerHandler)

--[[ Constants ]] --
local IS_STUDIO = RunService:IsStudio()
local SafeCall = require(script.Parent.Parent.Specials.SafeCall)

local SafeGetInfoCall = SafeCall.new(10, 0.5, warn)

local Gamepasses = { } :: { gamepassData }
local GiftingData = { } :: { [Player] : GiftData }
local Market = {}
local ProductFunctions = { } :: { [number] : productFunction }
local MarketDataStore = ProfileStore.New('Market_Data', {
	Gamepasses = { },
	ReceiptLogs = { },
})

if IS_STUDIO then
	MarketDataStore = MarketDataStore.Mock :: any
end

local Profiles = { } :: { [Player] : typeof(MarketDataStore:StartSessionAsync(...)) }


--[[ Private ]]--
local function playerAdded(player : Player)
	local profile = MarketDataStore:StartSessionAsync(tostring(player.UserId), {
		Cancel = function()
			return player:IsDescendantOf(Players) == false
		end,
	})
	
	if profile then
		profile:Reconcile()
		profile:AddUserId(player.UserId)
		
		Profiles[player] = profile
	end
end

local function playerRemoving(player : Player)
	local profile = Profiles[player]
	if profile then
		profile:EndSession()
		Profiles[player] = nil
	end
end

local function userOwnsGamepass(player : Player, pass : number) : boolean
	local profile = Profiles[player]
	local ownsViaMarketplace = MarketplaceService:UserOwnsGamePassAsync(player.UserId, pass)
	
	if ownsViaMarketplace == true then
		return true
	end
	
	if profile then
		return table.find(profile.Data.Gamepasses, pass) ~= nil
	end
	
	return false
end

local function logReceipt(receipt : Receipt, player : Player, giftTarget : Player?)
	receipt.CurrencyType = receipt.CurrencyType.Name :: any
	receipt.ProductPurchaseChannel = receipt.ProductPurchaseChannel.Name :: any
	
	local data = {
		Date = DateTime.now():ToUniversalTime(),
		receipt = receipt,
		GiftedTo = if giftTarget then giftTarget.UserId else nil
	}
	
	local profile = Profiles[player]
	if profile then
		table.insert(profile.Data.ReceiptLogs :: any, data)
	end
end

local function addGamepass(player : Player, passId : number)
	if userOwnsGamepass(player, passId) == true then
		return
	end
	
	local profile = Profiles[player]
	
	if profile then
		table.insert(profile.Data.Gamepasses, passId)
	end
end

local function processReceipt(receipt : Receipt) : Enum.ProductPurchaseDecision
	local productId = receipt.ProductId
	local playerId = receipt.PlayerId
	
	local player = Players:GetPlayerByUserId(playerId)
	local target : any = player
	
	if GiftingData[player] ~= nil then
		if productId == GiftingData[player].ProductGifting then
			target = GiftingData[player].UserGifting
		end
	end
	
	if ProductFunctions[productId] ~= nil then
		local result = ProductFunctions[productId](receipt, target)
		if result == true then
			logReceipt(receipt, player, if target ~= player then target else nil)
			if target ~= player then -- reset gifting data after gift was purchased.
				GiftingData[player] = nil
			end
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
	else
		local gamepassId = nil
		
		for i, v in Gamepasses :: {gamepassData} do
			if (v.GiftProductId ~= nil and v.GiftProductId == productId) then
				gamepassId = v.GamepassId
				break
			end
		end
		
		if gamepassId == nil then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		
		if userOwnsGamepass(target, gamepassId) == true then -- the user trying to be gifted already owns this gamepass.
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		
		if (target ~= player) then
			GiftingData[player] = nil
		end
		
		logReceipt(receipt, player, if target ~= player then target else nil)
		addGamepass(target, gamepassId)
		
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

local function processGamepass(player : Player, gamepassId : number, wasPurchased : boolean)
	if wasPurchased == true then
		addGamepass(player, gamepassId)
	end
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(processGamepass :: any)
MarketplaceService.ProcessReceipt = processReceipt

playerHandler.PlayerAdded(playerAdded)
playerHandler.PlayerRemoving(playerRemoving)

--[[ Public ]]--

function Market.getProductInfo(id : number, infoType : Enum.InfoType?) : ProductInfo?
	local succ, result: ProductInfo? = SafeCall.callWithRetry(SafeGetInfoCall, function()
		return MarketplaceService:GetProductInfoAsync(id, infoType) :: any
	end)
	
	if succ then
		return result
	end
	
	return nil
end

function Market.removeGifting(player : Player)
	GiftingData[player] = nil
end

function Market.setGifting(gifter : Player, giftTo : Player, productId : number)
	GiftingData[gifter] = {
		UserGifting = giftTo,
		ProductGifting = productId
	}
end

function Market.removeProductFunction(productId : number)
	ProductFunctions[productId] = nil
end

function Market.addProductFunction(productId : number, func : productFunction)
	ProductFunctions[productId] = func
end

function Market.setProductFunctions(productList : { [number] : productFunction })
	ProductFunctions = productList
end

function Market.userOwnsGamepass(player : Player, gamepass : number)
	return userOwnsGamepass(player, gamepass)
end

function Market.addGamepass(gamepass : gamepassData)
	table.insert(Gamepasses, gamepass)
end

function Market.setGamepasses(gamepasses : { gamepassData })
	Gamepasses = gamepasses
end

function Market.getUserMarketProfile(player : Player)
	return Profiles[player]
end

--[[ return ]]--
return Market