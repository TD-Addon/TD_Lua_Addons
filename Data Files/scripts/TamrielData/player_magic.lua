local core = require('openmw.core')

if not core.magic.effects.records['T_mysticism_Passwall'] then
    return
end

local magic_passwall = require('scripts.TamrielData.player_magic_passwall')

return {
    eventHandlers = {
        T_Passwall_Cast = magic_passwall.onCastPasswall
    }
}
