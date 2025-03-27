-- Allows compatibility with Talisman
function maybe_to_big(n)
  if to_big ~= nil then
    return to_big(n)
  end

  return n
end

G.FUNCS.check_drag_target_active = function(e)
  if e.config.args.active_check(e.config.args.card) then
    if (not e.config.pulse_border) or not e.config.args.init then
      e.config.pulse_border = true
      e.config.colour = e.config.args.colour
      e.config.args.text_colour[4] = 1
      e.config.release_func = e.config.args.release_func
    end
  else
    if (e.config.pulse_border) or not e.config.args.init then
      e.config.pulse_border = nil
      e.config.colour = adjust_alpha(G.C.L_BLACK, 0.9)
      e.config.args.text_colour[4] = 0.5
      e.config.release_func = nil
    end
  end
  e.config.args.init = true
end
