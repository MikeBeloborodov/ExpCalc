local calculateExpFrame = CreateFrame("Frame")
calculateExpFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
calculateExpFrame.IsOn = true

function calculateExpFrame:GetZD()
	local charLvl = tonumber(UnitLevel("player"))
	
	if charLvl <= 7 then return 5 end
	if charLvl <= 9 then return 6 end
	if charLvl <= 11 then return 7 end
	if charLvl <= 15 then return 8 end
	if charLvl <= 19 then return 9 end
	if charLvl <= 29 then return 11 end
	if charLvl <= 39 then return 12 end
	if charLvl <= 44 then return 13 end
	if charLvl <= 49 then return 14 end
	if charLvl <= 54 then return 15 end
	if charLvl <= 59 then return 16 end
end

function calculateExpFrame:GetExp(mobLvl, isElite)
	local charLvl = tonumber(UnitLevel("player"))
	local baseExp = (charLvl * 5) + 45
	local ZD = self.GetZD()
	local eliteBonus = isElite and 2 or 1
		
	if (charLvl - mobLvl) / ZD >= 1 then
		return 0
	end
	
	if mobLvl >= charLvl then
		local tempExp = baseExp * (1 + 0.05 * (mobLvl - charLvl))
		local tempExpCap = baseExp * 1.2
		if tempExp > tempExpCap then return math.floor(tempExpCap) * eliteBonus end
		return math.floor(tempExp) * eliteBonus
	end
	
	return math.floor(baseExp * (1 - ((charLvl - mobLvl) / ZD))) * eliteBonus
end

function calculateExpFrame:GetRestedExp(baseExp, restExp)
	if restExp >= baseExp then return baseExp * 2 end

	return math.floor(restExp + (baseExp - (restExp / 2)))
end

function calculateExpFrame:GetFullExp()
	local mobLvl = UnitLevel("mouseover")
	local isElite = (UnitClassification("mouseover") == "elite") and true or false
	local expGain = calculateExpFrame:GetExp(tonumber(mobLvl), isElite)

	local restedExp = tonumber(GetXPExhaustion())
	if restedExp then expGain = calculateExpFrame:GetRestedExp(expGain, restedExp) end

	return expGain
end

function calculateExpFrame:GetMobsToLvl(expGain)
	local currExp = UnitXP("player")
	local maxExp = UnitXPMax("player")
	local diffExp = tonumber(maxExp) - tonumber(currExp)
	local mobsToLvl = math.ceil(diffExp / expGain)

	return mobsToLvl
end

calculateExpFrame:SetScript("OnEvent",
	function()
		if UnitIsFriend("player", "mouseover") then return end

		local expGain = calculateExpFrame:GetFullExp()
		local mobsToLvl = calculateExpFrame:GetMobsToLvl(expGain)

		GameTooltip:AddLine("Exp gain: " .. expGain, 1.00, 0.95, 0.95, 1)
		GameTooltip:AddLine("Mobs to lvl: " .. mobsToLvl,  1.00, 0.95, 0.95, 1)
		GameTooltip:Show()
	end
)

function Print(msg, r, g, b)
	DEFAULT_CHAT_FRAME:AddMessage(msg, r, g, b)
end

function PrintWhite(msg)
	Print(msg, 1.0, 1.0, 1.0)
end

SLASH_EXPCALC1 = "/expcalc"
SlashCmdList["EXPCALC"] = function (msg)
	if msg == "on" and not calculateExpFrame.IsOn then
		calculateExpFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
		calculateExpFrame.IsOn = false
	elseif msg == "off" and calculateExpFrame.IsOn then
		calculateExpFrame:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
		calculateExpFrame.IsOn = true
	else
		PrintWhite("Exp Calculator:")
		PrintWhite("/expcalc on   -   show tooltip")
		PrintWhite("/expcalc off   -   hide tooltip")
	end
end