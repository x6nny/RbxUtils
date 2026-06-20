--!strict
local GroupService = game:GetService('GroupService')
local players = game:GetService('Players')

--> Class
local Groups = {}

--> types
type GroupInfo = {
	Name : string,
	Id : number,
	Owner : {Name : string, Id : number},
	EmblemUrl : string,
	Description : string,
	Roles : {
		[number] : {Name : string, Rank : number}
	},
}

type GroupsInfo = {
	[number] : {
		EmblemId : number,
		EmblemUrl : string,
		Id : number,
		IsInClan : boolean,
		IsPrimary : boolean,
		Name : string,
		Rank : number,
		Role : string
	}
}

--> Methods
function Groups.GetGroupInfo(GroupId : number) : GroupInfo
	return GroupService:GetGroupInfoAsync(GroupId) :: GroupInfo
end

function Groups.GetUserGroups(user : User) : GroupsInfo
	return GroupService:GetGroupsAsync(user) :: GroupsInfo
end

function Groups.IsInGroup(player : Player, GroupId : number) : boolean
	return player:IsInGroupAsync(GroupId)
end

function Groups.GetRolesInGroup(player : Player, GroupId): {IsMember: boolean, Roles: {[number]: {Id: number, Name: string, Rank: number}}}?
	if Groups.IsInGroup(player, GroupId) == false then return nil end
	return GroupService:GetRolesInGroupAsync(player.User, GroupId)
end


function Groups.promptJoinAsync(groupId : number) : Enum.GroupMembershipStatus
	return GroupService:PromptJoinAsync(groupId)
end

--> return
return Groups