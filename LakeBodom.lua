local Addon = CreateFrame("FRAME");


--localing
local _G = _G;
local UnitHealth, UnitHealthMax, UnitBuff, UnitDebuff, UnitReaction = UnitHealth, UnitHealthMax, UnitBuff, UnitDebuff, UnitReaction;

--TODO
--menu can't have focus option, add missing options (symbols, uninvite)
--workout the textures


local targetFrame, targetDropMenu, targetBuffFrame, targetDebuffFrame;

--static final values
local fWidth, fHeight, sWidth, sHeight = 512, 32, 360, 9;

local function setPosition(currentHP, maxHP)
	local x = currentHP*sWidth/maxHP;
	return (sWidth-x)/2;
end


local function updateHealthBar(self)
	local currentHP, maxHP = UnitHealth("target"), UnitHealthMax("target");
	local percentage = currentHP/maxHP;

	--it seems SetWidth(0), sets the width to the original size (256)
	if(percentage == 0) then
		targetFrame.hpBar:SetWidth(-1);
	else
		targetFrame.hpBar:SetWidth(sWidth*percentage);
	end
	targetFrame.hpBar:SetTexCoord((1-percentage), percentage, 0, 1);

	--change color according to target reaction
	if(UnitReaction("player", "target") < 4) then
		targetFrame.hpBar:SetVertexColor(1,0.1,0.1,0.9);
	elseif(UnitReaction("player", "target") == 4) then
		targetFrame.hpBar:SetVertexColor(1,1,0.1,0.9);
	else
		targetFrame.hpBar:SetVertexColor(0.1,1,0.1,0.9);
	end
end

local function updateName(self)
	local name = UnitName("target");
	self.name:SetText(name);
end

local function updateNameSideTextures(self)

	local length = self.name:GetStringWidth();
	self.rightStart:SetPoint("CENTER", length/2+20, -14);
	self.leftStart:SetPoint("CENTER", -length/2-20, -14);


	local width = select(4, self.rightEnd:GetPoint())-select(4, self.rightStart:GetPoint());
	self.rightMid:SetWidth(width-20);
	self.rightMid:SetPoint("CENTER", length/2+23 + (width)/2, -14);

	self.leftMid:SetWidth(width-20);
	self.leftMid:SetPoint("CENTER", -(length/2+23 + (width)/2), -14);

end


--update buffs and debuffs
local function updateAuras(self)

	local maxBuffs = 9;
	local name, rank, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge;

	local frameName;
	local frame;
	local color;

	--display buffs
	for i = 1, maxBuffs do
		name, rank, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge = UnitBuff("target", i);

		frameName = "LakeBodomTargetBuffFrameBuff" .. i;
		frame = _G[frameName];
		if(not frame) then
			if(not icon) then
				break; -- no icon => next iteration
			else
				frame = CreateFrame("Button", frameName, targetBuffFrame, "TargetBuffFrameTemplate");
				frame.unit = "target";
			end
		end
		if(icon) then
			frame:SetID(i);

			--set icon
			frame.icon = _G[frameName.."Icon"];
			frame.icon:SetTexture(icon);


			--set the count
			frame.stack = _G[frameName.."Count"];
			if ( count > 1 ) then
				frame.stack:SetFont("Interface\\AddOns\\Rising\\Futura-Condensed-Normal.TTF", 14, "OUTLINE");
				frame.stack:SetTextColor(0.7, 0.7, 0.7, 1);
				frame.stack:SetText(count);
				frame.stack:Show();
			else
				frame.stack:Hide();
			end

			-- Handle cooldowns
			frame.cooldown = _G[frameName.."Cooldown"];
			if ( duration > 0 ) then
				frame.cooldown:Show();
				CooldownFrame_SetTimer(frame.cooldown, expirationTime - duration, duration, 1);
			else
				frame.cooldown:Hide();
			end


			frame:ClearAllPoints();
			frame:SetSize(28,28);
			frame:SetPoint("TOPLEFT", targetBuffFrame, math.fmod((i-1),3)*34, -math.floor((i-1)/3)*34);

			frame.border = frame:CreateTexture();
			frame.border:SetSize(34,34);
			frame.border:SetTexture("Interface\\AddOns\\LakeBodom\\RoundButton.blp");
			frame.border:SetPoint("CENTER", frame)
			frame.border:SetVertexColor(0.9,0.9,0.9,1)


			frame:Show();
		else
			frame:Hide();
		end
	end


	--display debuffs
	for i = 1, maxBuffs do
		name, rank, icon, count, debuffType, duration, expirationTime, caster = UnitDebuff("target", i);
		frameName = "LakeBodomTargetDebuffFrameDebuff" .. i;
		frame = _G[frameName];
		if(not frame) then
			if(not icon) then
				break; -- no icon => next iteration
			else
				frame = CreateFrame("Button", frameName, targetDebuffFrame, "TargetDebuffFrameTemplate");
				frame.unit = "target";
			end
		end
		if(icon) then

			frame:SetID(i);

			--set icon
			frame.icon = _G[frameName.."Icon"];
			frame.icon:SetTexture(icon);


			--set the count
			frame.stack = _G[frameName.."Count"];
			if ( count > 1 ) then
				frame.stack:SetFont("Interface\\AddOns\\Rising\\Futura-Condensed-Normal.TTF", 14, "OUTLINE");
				frame.stack:SetTextColor(0.7, 0.7, 0.7, 1);
				frame.stack:SetText(count);
				frame.stack:Show();
			else
				frame.stack:Hide();
			end

			-- Handle cooldowns
			frame.cooldown = _G[frameName.."Cooldown"];
			if ( duration > 0 ) then
				frame.cooldown:Show();
				CooldownFrame_SetTimer(frame.cooldown, expirationTime - duration, duration, 1);
			else
				frame.cooldown:Hide();
			end

			-- set debuff type color
			if ( debuffType ) then
				color = DebuffTypeColor[debuffType];
			else
				color = DebuffTypeColor["none"];
			end

			--frame:ClearAllPoints();
			frame:SetSize(28,28);
			frame:SetPoint("TOPLEFT", targetDebuffFrame, (2-math.fmod((i-1),3))*34, -math.floor((i-1)/3)*34);

			
			frame.border = _G[frameName.."Border"]
			frame.border:ClearAllPoints();
			frame.border:SetTexCoord(0,1,0,1)
			frame.border:SetSize(34,34);
			frame.border:SetTexture("Interface\\AddOns\\LakeBodom\\RoundButton.blp");
			frame.border:SetPoint("CENTER", frame);
			frame.border:SetVertexColor(color.r, color.g, color.b);
			
			frame:Show();
		else
			frame:Hide();
		end
	end
end


local function createFontFrame(name, parent, posX, posY, onClick)
	local fontFrame = CreateFrame("FRAME", "LakeBodomTargetDropMenu" .. name, parent);
	fontFrame:SetSize(100,20);
	fontFrame:SetPoint("TOP", posX, posY);

	fontFrame.font = fontFrame:CreateFontString("LakeBodom" .. name .. "Font", "OVERLAY", "GameFontNormal");
	fontFrame.font:SetFont("Interface\\AddOns\\Rising\\Futura-Condensed-Normal.TTF", 18, "OUTLINE");
	fontFrame.font:SetTextColor(0.5, 0.5, 0.5, 1);
	fontFrame.font:SetText(name);
	fontFrame.font:SetPoint("CENTER", 0, 0);

	fontFrame:SetScript("OnEnter", function(self)
		self.font:SetTextColor(1, 1, 1, 1);
	end);
	fontFrame:SetScript("OnLeave", function(self)
		self.font:SetTextColor(0.5, 0.5, 0.5, 1);
	end);
	fontFrame:SetScript("OnMouseDown", function()
		onClick();
		targetDropMenu:Hide();
	end);

	return fontFrame;
end


local function setUpTargetDropMenu()

	targetDropMenu = CreateFrame("FRAME", "LakeBodomTargetDropMenu", targetFrame);
	targetDropMenu:SetSize(150, 150);
	targetDropMenu:SetPoint("BOTTOM", targetFrame, "BOTTOM", 0, -150);


	targetDropMenu.whisper = createFontFrame("Whisper", targetDropMenu, 0, 0, function() ChatFrame_SendTell(UnitName("target"), UIDROPDOWNMENU_INIT_MENU.chatFrame) end);
	targetDropMenu.inspect = createFontFrame("Inspect", targetDropMenu, 0, -20, function() InspectUnit("target") end);
	targetDropMenu.invite = createFontFrame("Invite", targetDropMenu, 0, -40, function() InviteUnit(UnitName("target")) end);
	targetDropMenu.compareAchiev = createFontFrame("Compare Achievements", targetDropMenu, 0, -60, function() InspectAchievements("target") end);
	targetDropMenu.trade = createFontFrame("Trade", targetDropMenu, 0, -80, function() InitiateTrade("target") end);
	targetDropMenu.follow = createFontFrame("Follow", targetDropMenu, 0, -100, function() FollowUnit(UnitName("target"), 1) end);
	targetDropMenu.duel = createFontFrame("Duel", targetDropMenu, 0, -120, function() StartDuel(UnitName("target"), 1) end);


	targetDropMenu:Hide();

end


local function toggleTargetDropDownMenu()
	if(targetDropMenu:IsShown()) then
		targetDropMenu:Hide();
	elseif(UnitIsPlayer("target") and not UnitIsUnit("player", "target")) then
		targetDropMenu:Show();
	end
end


local function setUpTargetFrame()

	targetFrame = CreateFrame("Button", "LakeBodomTarget", UIParent, "SecureUnitButtonTemplate");
	targetFrame:SetSize(fWidth, fHeight*2);
	targetFrame:SetPoint("TOP", 0, -75);
	targetFrame:SetAttribute("unit", "target");

	--[[
	SecureUnitButton_OnLoad(targetFrame, "target", function()
		ToggleDropDownMenu(1, nil, TargetFrameDropDown, "cursor")
	end)
	]]--

	--OnRightClick - MENU
	targetFrame:RegisterForClicks("AnyUp");
	targetFrame:EnableMouse(true);

	targetFrame:SetScript("OnMouseUp", function(self, button)
		if(button == "RightButton") then
			toggleTargetDropDownMenu();
		end
	end);



	RegisterUnitWatch(targetFrame);


	--health bar
	targetFrame.texture = targetFrame:CreateTexture();
	targetFrame.texture:SetSize(fWidth, fHeight);
	targetFrame.texture:SetTexture("Interface\\AddOns\\LakeBodom\\targetBar.blp");
	targetFrame.texture:SetPoint("TOP", targetFrame);
	targetFrame.texture:SetVertexColor(1,1,1,0.9);


	targetFrame.hpBar = targetFrame:CreateTexture(nil, "OVERLAY");
	targetFrame.hpBar:SetSize(sWidth, sHeight);
	targetFrame.hpBar:SetPoint("TOP", 0, -13);
	targetFrame.hpBar:SetTexture("Interface\\AddOns\\LakeBodom\\texture.blp");
	targetFrame.hpBar:SetVertexColor(1,0.1,0.1,0.9);


	--Name FontString
	targetFrame.name = targetFrame:CreateFontString("LakeBodomTargetName", "OVERLAY", "GameFontNormal");
	targetFrame.name:SetFont("Interface\\AddOns\\Rising\\Futura-Condensed-Normal.TTF", 24, "OUTLINE");
	targetFrame.name:SetTextColor(0.6, 0.6, 0.6, 1);
	targetFrame.name:SetShadowColor(0, 0, 0, 0.5);
	targetFrame.name:SetShadowOffset(2, -2);
	targetFrame.name:SetPoint("CENTER", 0, -15);


	--Name side-textures
	targetFrame.rightEnd = targetFrame:CreateTexture();
	targetFrame.rightEnd:SetSize(32, 16);
	targetFrame.rightEnd:SetTexture("Interface\\AddOns\\LakeBodom\\endTexture.blp");
	targetFrame.rightEnd:SetPoint("CENTER", 155, -14);
	targetFrame.rightEnd:SetVertexColor(1,1,1,0.9);

	targetFrame.leftEnd = targetFrame:CreateTexture();
	targetFrame.leftEnd:SetSize(32, 16);
	targetFrame.leftEnd:SetTexture("Interface\\AddOns\\LakeBodom\\endTexture.blp");
	targetFrame.leftEnd:SetPoint("CENTER", -155, -14);
	targetFrame.leftEnd:SetVertexColor(1,1,1,0.9);
	targetFrame.leftEnd:SetTexCoord(1, 0, 0, 1);


	targetFrame.rightStart = targetFrame:CreateTexture();
	targetFrame.rightStart:SetSize(64, 32);
	targetFrame.rightStart:SetTexture("Interface\\AddOns\\LakeBodom\\startTexture.blp");
	targetFrame.rightStart:SetVertexColor(1,1,1,0.9);

	targetFrame.leftStart = targetFrame:CreateTexture();
	targetFrame.leftStart:SetSize(64, 32);
	targetFrame.leftStart:SetTexture("Interface\\AddOns\\LakeBodom\\startTexture.blp");
	targetFrame.leftStart:SetVertexColor(1,1,1,0.9);
	targetFrame.leftStart:SetTexCoord(1, 0, 0, 1);


	targetFrame.rightMid = targetFrame:CreateTexture();
	targetFrame.rightMid:SetSize(32, 32);
	targetFrame.rightMid:SetTexture("Interface\\AddOns\\LakeBodom\\midTexture.blp");
	targetFrame.rightMid:SetVertexColor(1,1,1,0.9);

	targetFrame.leftMid = targetFrame:CreateTexture();
	targetFrame.leftMid:SetSize(32, 32);
	targetFrame.leftMid:SetTexture("Interface\\AddOns\\LakeBodom\\midTexture.blp");
	targetFrame.leftMid:SetVertexColor(1,1,1,0.9);


	targetFrame:SetScript("OnEvent", function(self, event, ...)
		if(event == "UNIT_HEALTH" and ... == "target") then
			updateHealthBar(self);
		elseif(event == "UNIT_AURA" and ... == "target") then
			updateAuras(self);
		elseif(event == "PLAYER_TARGET_CHANGED") then
			if(UnitExists("target")) then
				updateAuras(self);
				updateHealthBar(self);
				updateName(self);
				updateNameSideTextures(self);
			end
			targetDropMenu:Hide(); --if the menu is shown, hides it
		end
	end);

	targetFrame:RegisterEvent("UNIT_HEALTH");
	targetFrame:RegisterEvent("UNIT_AURA");
	targetFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
end


local function setUpTargetBuffFrame()
	targetBuffFrame = CreateFrame("FRAME", "LakeBodomTargetBuffFrame", targetFrame);
	targetBuffFrame:SetSize(100,100);
	targetBuffFrame:SetPoint("BOTTOMLEFT", 100, -100);

	targetDebuffFrame = CreateFrame("FRAME", "LakeBodomTargetDebuffFrame", targetFrame);
	targetDebuffFrame:SetSize(100,100);
	targetDebuffFrame:SetPoint("BOTTOMRIGHT", -100, -100);
end


Addon:SetScript("OnEvent", function(self, event, ...)
	setUpTargetFrame();
	setUpTargetBuffFrame();
	setUpTargetDropMenu();

	--removing Blizzard TargetFrame
	TargetFrame:Hide();
	TargetFrame:UnregisterAllEvents();

	Addon:UnregisterAllEvents();
end);

Addon:RegisterEvent("PLAYER_ENTERING_WORLD");
