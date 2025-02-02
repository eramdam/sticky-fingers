DTM = SMODS.current_mod

DTM.save_config = function(self)
  SMODS.save_mod_config(self)
end

-- sendDebugMessage("enabled?" + DTM, "MyDebugLogger")
print(inspect(DTM.config))

DTM.config_tab = function()
  return {
    n = G.UIT.ROOT,
    config = {
      r = 0.1, minw = 5, align = "cm", padding = 0.2, colour = G.C.BLACK
    },
    nodes = {
      create_toggle({
        id = "harder_joker_sell",
        label = "Harder Joker sell target",
        info = {"Moves the Joker sell target further to avoid accidental sells"},
        ref_table = DTM.config,
        ref_value = "harder_joker_sell",
        callback = function()
          DTM:save_config()
        end,
      })
    }
  }
end
