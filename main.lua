if SMODS.Atlas then
  SMODS.Atlas({
      key = "modicon",
      path = "modicon.png",
      px = 32,
      py = 32
  })
end


DTM = SMODS.current_mod

DTM.save_config = function(self)
  SMODS.save_mod_config(self)
end

DTM.config_tab = function()
  return {
    n = G.UIT.ROOT,
    config = {
      r = 0.1, minw = 5, align = "cm", padding = 0.2, colour = G.C.BLACK
    },
    nodes = {
      create_toggle({
        id = "vanilla_joker_sell",
        label = "Vanilla Joker sell target",
        info = {"Use the mobile Joker sell target. Beware of accidental sells!"},
        ref_table = DTM.config,
        ref_value = "vanilla_joker_sell",
        callback = function()
          DTM:save_config()
        end,
      })
    }
  }
end
