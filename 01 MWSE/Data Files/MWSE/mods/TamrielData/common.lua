local this = {}

this.i18n = mwse.loadTranslations("TamrielData")

-- Util functions
function table.contains(table, element)
	for _,v in pairs(table) do
	  if v == element then
		return true
	  end
	end
	return false
end

return this