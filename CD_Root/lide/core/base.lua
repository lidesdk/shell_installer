-- ///////////////////////////////////////////////////////////////////
-- // Name:      lide/core/base.lua
-- // Purpose:   define functions required by framework instances
-- // Created:   2016/01/03
-- // Copyright: (c) 2016-2018 Hernan Dario Cano [dcanohdev [at] gmail.com]
-- // License:   GNU GENERAL PUBLIC LICENSE
-- ///////////////////////////////////////////////////////////////////

lide.app = lide.app or { };

function lide.app.getWorkDir( ... )
	if lide.platform.getOSName() == 'linux' then
		return io.popen 'echo $PWD' : read '*l'
	elseif lide.platform.getOSName() == 'windows' then
		return io.popen 'CD' : read '*l'
	end
end

lide.app.folders = { 
	-- sourcefolder = os.getenv 'LIDE_PATH' 
}

local framework_call_level = 4

local function istype( ValueToCompare, TypeToCompare, errmsg, fLevel )
	errmsg = errmsg or ('arg must be of type %s.'):format(TypeToCompare)
	
	if lide.core.base.type(ValueToCompare) == TypeToCompare then 
		return ValueToCompare 
	else 
		if not errmsg then 
			return false 
		else 
			error(errmsg, fLevel)
		end 
	end
end

function lide.errorf.update_constant( theConstant )
    -- "attempt to update a constant. *const:"..k)
	local errorstr = 'attempt to update a constant: "%s" (is a read only value).'
    
    lide.core.error.lperr(errorstr:format(theConstant), 1)
end

-- Don't allow modify a constant on _G

setmetatable( _G, {
	__index = function ( t,k )
		return lide.cons[k]
	end,

	__newindex = function ( t,k,v )
		if not lide.cons[k] then
			rawset(t,k,v)
		else
			lide.errorf.update_constant(k)
		end
	end
})

local base = {
	-- Funcion enum para crear constantes en la aplicacion: (Opcionalmente puede retornar una tabla de solo lectura)
	enum = function ( t )
		for k,v in pairs(t) do
			if not lide.cons[k] then
				if v == lide.newid then
					rawset(lide.cons, k, lide.newid())
				else	
					rawset(lide.cons, k,v)
				end
			else
				lide.errorf.update_constant(k) -- don't update this error without see lide.constant_update_error()
			end
		end

		local proxy = {}
		local mt ={ 
		__index= t, 
		__newindex=function (t,k,v) 	
			lide.errorf.update_constant(k) -- don't update this error without see lide.constant_update_error()
		end
		}
		
		setmetatable(proxy, mt)

		return proxy
	end,

	type = function ( value )
		local lua_type = lide.core.lua.type

		-- Obtenemos el tipo primitivo de lua
		local stype = lua_type(value)

		if (stype == 'table') then
			local mt = getmetatable(value)
			if mt and mt.__lideobj and mt.__type then
				return mt.__type

			end
			return 'table'
		else
			return stype
		end
	end,
	
	isnumber = function ( value, errmsg )
		return istype(value, 'number', errmsg, framework_call_level)
	end,

	isstring = function ( value, errmsg )
		return istype(value, 'string', errmsg, framework_call_level)
	end,

	isfunction = function ( value, errmsg )
		return istype(value, 'function', errmsg, framework_call_level)
	end,

	isobject = function ( value, errmsg )
		return istype(value, 'object', errmsg, framework_call_level)
	end,

	isboolean = function ( value, errmsg )
		return istype(value, 'boolean', errmsg, framework_call_level)
	end,

	istable = function ( value, errmsg )
		return istype(value, 'table', errmsg, framework_call_level)
	end,

	newid = function ( nLastID )
		if nLastID ~= nil then
			lide.core.base.isnumber(nLastID)
			return nLastID +1
		else
			local _MAXID = 6000 * 777
			lide.core.base.maxid = (lide.core.base.maxid or _MAXID) +1
			return tonumber(lide.core.base.maxid)
		end
	end,

	voidf = function ( ... ) end
}

base.check = {
	fields = function ( required )
		local _, self   = debug.getlocal(2,1) -- get 'self'
		local _, fields = debug.getlocal(2,2) -- get 'fields'
		
		if self and debug.getlocal(2,2):lower() == 'fields' then
			for _, fieldname in pairs(required) do
				local sp = fieldname:find(' ')
				local stype = fieldname:sub(1, sp-1)
				local sname = fieldname:gsub(stype..' ', '')
							
				if not fields[sname] then
					error(('the field "%s" is required by the constructor of %s class.'):format(sname, self:class():name()), framework_call_level)
					--lide.core.error.lperr(('the field "%s" is required by the constructor of %s class.'):format(sname, self:class():name()))
				elseif lide.core.base.type(fields[sname]) ~= stype then
					--lide.core.error.lperr(('%s class constructor: the type of field "%s" must be "%s".'):format(self:class():name(), sname, stype))
					error(('%s class constructor: the type of field "%s" must be "%s".'):format(self:class():name(), sname, stype), framework_call_level)
				end
			end
		end
	end
}

return base