-- /////////////////////////////////////////////////////////////////////////////
-- // Name:        lide/classes/font.lua
-- // Purpose:     Font class
-- // Author:      Hernan Dario Cano [dcanohdev@gmail.com]
-- // Created:     07/07/2014
-- // Copyright:   (c) 2014  Hernan Dario Cano
-- // License:     GNU GENERAL PUBLIC LICENSE
-- /////////////////////////////////////////////////////////////////////////////

-- set font constants:
enum {

	FONT_DEFAULT       = wx.wxFONTFLAG_DEFAULT,
	FONT_BOLD          = wx.wxFONTFLAG_BOLD,
	FONT_ITALIC        = wx.wxFONTFLAG_ITALIC,
	FONT_UNDERLINED    = wx.wxFONTFLAG_UNDERLINED,
}

-- import local classes:
local Object   = lide.classes.object

-- import functions:
local isString = lide.core.base.isstring
local isNumber = lide.core.base.isnumber

-- define the class:
local Font = lide.class 'Font' : subclassof 'Object' --: global ( false )


function Font:Font ( ... )
	local Properties = {}
	
	if type(...) == "string" then
	-- for a small constructor:
		--self.FontDescription = (...)
		Properties.FaceName, Properties.Size, Properties.Flags = ...
		for value in string.delimi(Properties.Flags or '', ",") do
			value = value:gsub(" ", '') --> remove spaces
			
			Properties.Flags = tonumber(Properties.Flags) or 0

			if value == "Bold" then
				Properties.Flags = Properties.Flags + FONT_BOLD
			elseif value == "Italic" then
				Properties.Flags = Properties.Flags + FONT_ITALIC
			elseif value == "Underline" or value == "Underlined" then
				Properties.Flags = Properties.Flags + FONT_UNDERLINED
			end
		end

	elseif type(...) == "userdata" then
		local wxFontObject = (...)
		self.wxObj = wxFontObject
	--	self.FontDescription = self:getDescString()
		return true

	else
	-- for a complete constructor:
		Properties = ( ... )
	end
	
	--self.super:init( 'Font' .. lide.core.base.newid() )

	Properties.Family     = Properties.Family   or wx.wxFONTFAMILY_DEFAULT
	Properties.FaceName   = Properties.FaceName or ""
	Properties.Encoding   = Properties.Encoding or wx.wxFONTENCODING_DEFAULT
	
	-- wxFont Class
	local bindedObject = wx.wxFont.New(Properties.Size or -1, Properties.Family, Properties.Flags, Properties.FaceName, wx.wxFONTENCODING_DEFAULT)
	
	private {
		wxObj = bindedObject,
	}

end

function Font:setName ( sName )
	self._objName = isString(sName)
	self._objName = sName
	if ( self._objName == sName ) then return true else return false end
end

-- define class methods

-- Construye un string de descripción para la fuente.
function Font:getDescString( )
	local sFontFlags
	local sFaceName  = self.wxObj:GetFaceName()
	local sFontSize  = self.wxObj:GetPointSize()
	local tFontFlags = {
		Bold   = self.wxObj:GetWeight() == wx.wxFONTWEIGHT_BOLD,
		Italic = self.wxObj:GetStyle() == wx.wxFONTSTYLE_ITALIC,
		Underlined = self.wxObj:GetUnderlined()
	}
			
	for flag, value in pairs(tFontFlags) do
		if value then
			if not sFontFlags then
				sFontFlags = flag
			else
				sFontFlags = sFontFlags .. ', ' .. flag	
			end
		end
	end
	
	local sFontDesc = sFaceName .. ', '.. sFontSize 

	if sFontFlags then
		sFontDesc = sFontDesc .. ', '.. sFontFlags
	end

	return sFontDesc
end

function Font:getBind()
	return self.wxObj
end

function Font:__tostring()
	local str_address  = tostring(getmetatable(self)):gsub('table: ', '')
	local str_facename = self:getBind():GetFaceName()
	
	return ("[font: %s] %s"):format(str_address, str_facename)
end

function Font:getwxObj( ... )
	return self.wxObj
end

--Font.getwxObj = Font.getBind

-- -- enum wxFontFamily 
--  wxFONTFAMILY_DEFAULT
--  wxFONTFAMILY_DECORATIVE
--  wxFONTFAMILY_ROMAN
--  wxFONTFAMILY_SCRIPT
--  wxFONTFAMILY_SWISS
--  wxFONTFAMILY_MODERN
--  wxFONTFAMILY_TELETYPE
--  wxFONTFAMILY_MAX
--  wxFONTFAMILY_UNKNOWN
 
-- %endenum

-- %enum wxFontStyle 
--  wxFONTSTYLE_NORMAL
--  wxFONTSTYLE_ITALIC
--  wxFONTSTYLE_SLANT
--  wxFONTSTYLE_MAX
 
-- %endenum

-- %enum wxFontWeight 
--  wxFONTWEIGHT_NORMAL
--  wxFONTWEIGHT_LIGHT
--  wxFONTWEIGHT_BOLD
--  wxFONTWEIGHT_MAX
 
-- %endenum

-- %enum 
--  wxFONTFLAG_DEFAULT
--  wxFONTFLAG_ITALIC
--  wxFONTFLAG_SLANT
--  wxFONTFLAG_LIGHT
--  wxFONTFLAG_BOLD
--  wxFONTFLAG_ANTIALIASED
--  wxFONTFLAG_NOT_ANTIALIASED
--  wxFONTFLAG_UNDERLINED
--  wxFONTFLAG_STRIKETHROUGH
--  wxFONTFLAG_MASK

return Font