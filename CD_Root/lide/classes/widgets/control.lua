-- ///////////////////////////////////////////////////////////////////
-- // Name:      classes/widgets/control.lua
-- // Purpose:   Control class
-- // Created:   2014/07/07
-- // Copyright: (c) 2014-2018 Hernan Dario Cano [dcanohdev [at] gmail.com]
-- // License:   GNU GENERAL PUBLIC LICENSE
-- ///////////////////////////////////////////////////////////////////


-- import local functions:
local isObject  = lide.core.base.isobject
local isBoolean = lide.core.base.isboolean
local isString  = lide.core.base.isstring
local isNumber  = lide.core.base.isnumber

-- import required classes
local Font   = lide.classes.font
local Widget = lide.classes.widget


local Control = class 'Control' : subclassof 'Widget' : global ( false )

function Control:Control ( sControlName, oParent, nPosX, nPosY, nWidth, nHeight, nID )
	
	-- if Parent is a Form, reparent to self.Panel by default
	if isObject(oParent) and oParent.class and oParent:class():name() == 'Form' 
	and getmetatable(oParent.Panel).__type == 'object' then
		oParent = oParent.Panel
	end
	
	private {
		Enabled = true
	}

	-- call Widget constructor
	self.super:init( sControlName, 'control', nPosX, nPosY, nWidth, nHeight, nID, oParent )
end

Control:virtual 'getText'
function Control:getText( bMnemonic )
	if bMnemonic == nil then bMnemonic = false end; isBoolean(bMnemonic)
	
	local Text if (bMnemonic == true) then
		-- return the control's label containing mnemonics ("&" characters):
		return self.wxObj:GetLabel()
	else
		-- return the control's label without mnemonics:
		return self.wxObj:GetLabelText()
	end
end

Control:virtual 'setText'
function Control:setText ( sNewText )
	self.wxObj:SetLabel(  isString(sNewText)  )
end

Control:virtual 'setTextMarkup'
function Control:setTextMarkup ( sTextMarkup )
	self:getwxObj():SetLabelMarkup(isString(sTextMarkup));
end

-- Set the font to this control: sFontFamily is the name of font, nFontSize is the size in px,  
-- and FontFlags is a constructor string of Font class.
Control:virtual 'setFont'
function Control:setFont( sFontFamily, nFontSize, sFontFlags )
	if type(sFontFamily) == 'object' then
		self.Font = sFontFamily
	else
		self.Font = Font:new (isString(sFontFamily), isNumber(nFontSize), sFontFlags)
	end

	self.wxObj:SetFont(self.Font:getwxObj())
end

--- Returns the Font object associated to the class.
Control:virtual 'getFont'
function Control:getFont( )
	return self.Font
end

return Control
