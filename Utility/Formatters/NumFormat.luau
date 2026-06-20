--> Suffixs
local Suffixes = {"k","M","B","T","qd","Qn","sx","Sp","O","N","de","Ud","DD","tdD","qdD","QnD","sxD","SpD","OcD","NvD","Vgn","UVg","DVg","TVg","qtV","QnV","SeV","SPG","OVG","NVG","TGN","UTG","DTG","tsTG","qtTG","QnTG","ssTG","SpTG","OcTG","NoTG","QdDR","uQDR","dQDR","tQDR","qdQDR","QnQDR","sxQDR","SpQDR","OQDDr","NQDDr","qQGNT","uQGNT","dQGNT","tQGNT","qdQGNT","QnQGNT","sxQGNT","SpQGNT", "OQQGNT","NQQGNT","SXGNTL", "USXGNTL", "DSXGNTL", "TSXGNTL", "QTSXGNTL", "QNSXGNTL", "SXSXGNTL", "SPSXGNTL", "OSXGNTL", "NVSXGNTL", "SPTGNTL", "USPTGNTL", "DSPTGNTL", "TSPTGNTL", "QTSPTGNTL", "QNSPTGNTL", "SXSPTGNTL", "SPSPTGNTL", "OSPTGNTL", "NVSPTGNTL", "OTGNTL", "UOTGNTL", "DOTGNTL", "TOTGNTL", "QTOTGNTL", "QNOTGNTL", "SXOTGNTL", "SPOTGNTL", "OTOTGNTL", "NVOTGNTL", "NONGNTL", "UNONGNTL", "DNONGNTL", "TNONGNTL", "QTNONGNTL", "QNNONGNTL", "SXNONGNTL", "SPNONGNTL", "OTNONGNTL", "NONONGNTL", "CENT", "UNCENT"};

--> Private
local function addCommas(number: number) : string
	local formattedNumber = tostring(number)
	if string.find(formattedNumber, 'e+') or string.find(formattedNumber, 'e-') then
		return formattedNumber
	end
	
	local reversedNumber = string.reverse(formattedNumber)
	local pattern = "(%d%d%d)"

	local formattedReversedNumber = string.gsub(reversedNumber, pattern, "%1,")
	formattedNumber = string.reverse(formattedReversedNumber)

	if formattedNumber:sub(1, 1) == "," then
		formattedNumber = formattedNumber:sub(2)
	end

	return formattedNumber
end

local function ToSuffix(number) : string
	local number = tonumber(number) or -1
	local Negative = number < 0
	number = math.abs(number)

	local Paired = false
	for i,v in pairs(Suffixes) do
		if not (number >= 10^(3*i)) then
			number = number / 10^(3*(i-1))
			local isComplex = (string.find(tostring(number),".") and string.sub(tostring(number),4,4) ~= ".")
			number = string.sub(tostring(number),1,(isComplex and 4) or 3) .. (Suffixes[i-1] or "")
			Paired = true
			break;
		end
	end
	if not Paired then
		local Rounded = math.floor(number)
		number = tostring(Rounded) :: any
	end

	if Negative then
		return "-"..number
	end

	return number :: any
end

return function(Number: number, commas : boolean?) : string
	if commas ~= nil and commas == true then
		return addCommas(Number)
	end
	
	return ToSuffix(Number)
end