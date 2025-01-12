G.FUNCS.check_drag_target_active = function(e)
  if e.config.args.active_check(e.config.args.card) then
    if (not e.config.pulse_border) or not e.config.args.init then
      e.config.pulse_border = true
      e.config.colour = e.config.args.colour
      e.config.args.text_colour[4] = 1
      e.config.release_func = e.config.args.release_func
    end
  else
    if (e.config.pulse_border) or not e.config.args.init  then 
      e.config.pulse_border = nil
      e.config.colour = adjust_alpha(G.C.L_BLACK, 0.9)
      e.config.args.text_colour[4] = 0.5
      e.config.release_func = nil
    end
  end
  e.config.args.init = true
end

G.FUNCS.buy_button_check = function(e)
  if not G.FUNCS.can_buy(e.config.ref_table) then
      e.config.colour = G.C.UI.BACKGROUND_INACTIVE
      e.config.button = nil
  else
      e.config.colour = G.C.ORANGE
      e.config.button = 'buy_from_shop'
  end
  if e.config.ref_parent and e.config.ref_parent.children.buy_and_use then
    if e.config.ref_parent.children.buy_and_use.states.visible then
      e.UIBox.alignment.offset.y = -0.6
    else
      e.UIBox.alignment.offset.y = 0
    end
  end
end

G.FUNCS.can_buy = function(_card)
if _card.cost > (G.GAME.dollars - G.GAME.bankrupt_at) and (_card.cost > 0) then
  return false
end
return true
end

G.FUNCS.buy_and_use_button_check = function(e)
  if not G.FUNCS.can_buy_and_use(e.config.ref_table) then
      e.UIBox.states.visible = false
      e.config.colour = G.C.UI.BACKGROUND_INACTIVE
      e.config.button = nil
  else
      if e.config.ref_table.highlighted then
        e.UIBox.states.visible = true
      end
      e.config.colour = G.C.SECONDARY_SET.Voucher
      e.config.button = 'buy_from_shop'
  end
end

G.FUNCS.can_buy_and_use = function(_card)
if (((_card.cost > G.GAME.dollars - G.GAME.bankrupt_at) and (_card.cost > 0)) or (not _card:can_use_consumeable())) then
  return false
end
return true
end

G.FUNCS.select_button_check = function(e)
  if e.config.ref_table.ability.set ~= 'Joker' or (e.config.ref_table.edition and e.config.ref_table.edition.negative) or #G.jokers.cards < G.jokers.config.card_limit then 
      e.config.colour = G.C.GREEN
      e.config.button = 'use_card'
  else
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = nil
  end
end

G.FUNCS.can_select_card = function(_card)
  if _card.ability.set ~= 'Joker' or (_card.edition and _card.edition.negative) or #G.jokers.cards < G.jokers.config.card_limit then 
    return true
  end
  return false
end