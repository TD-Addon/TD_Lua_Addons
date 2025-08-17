if not tes3.isModActive("Tamriel_Data.esm") then return end

event.register(tes3.event.initialized, function()
    local glowInTheDahrk = include("GlowInTheDahrk.interop")

    if glowInTheDahrk then
        glowInTheDahrk.addProfileToCell("Almas Thirr, Plaza", "Force Exterior Sources On")
    end
end)