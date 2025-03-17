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

G.FUNCS.select_button_check = function(e)
  if e.config.ref_table.ability.set ~= 'Joker' or (e.config.ref_table.edition and e.config.ref_table.edition.negative) or #G.jokers.cards < G.jokers.config.card_limit then
    e.config.colour = G.C.GREEN
    e.config.button = 'use_card'
  else
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = nil
  end
end

local base_can_select_card = function(_card)
  if _card.ability.set ~= 'Joker' or (_card.edition and _card.edition.negative) or #G.jokers.cards < G.jokers.config.card_limit then
    return true
  end
  return false
end

G.FUNCS.can_select_card = base_can_select_card

G.FUNCS.sticky_can_select_card = function(_card)
  if Cryptid then
    if
        (_card.ability.name == "cry-Negative Joker" and _card.ability.extra >= 1)
        or (_card.ability.name == "cry-soccer" and _card.ability.extra.holygrail >= 1)
        or (_card.ability.name == "cry-Tenebris" and _card.ability.extra.slots >= 1)
    then
      return true
    else
      return base_can_select_card(_card)
    end
  else
    return base_can_select_card(_card)
  end
end

G.FUNCS.cryptid_can_reserve_card = function(e)
  if Cryptid then
    local c1 = e
    return #G.consumeables.cards
        < G.consumeables.config.card_limit + (Cryptid.safe_get(c1, "edition", "negative") and 1 or 0)
  end
end

--Checks if the cost of a non voucher card is greater than what the player can afford and changes the
--buy button visuals accordingly
--
---@param e {}
--**e** Is the UIE that called this function
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
  if maybe_to_big(_card.cost) > (maybe_to_big(G.GAME.dollars) - maybe_to_big(G.GAME.bankrupt_at)) and (maybe_to_big(_card.cost) > maybe_to_big(0)) then
    return false
  end
  return true
end

--Checks if the cost of a non voucher card is greater than what the player can afford and changes the
--buy button visuals accordingly
--
---@param e {}
--**e** Is the UIE that called this function
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
  if (((maybe_to_big(_card.cost) > maybe_to_big(G.GAME.dollars) - maybe_to_big(G.GAME.bankrupt_at)) and (maybe_to_big(_card.cost) > maybe_to_big(0))) or (not _card:can_use_consumeable())) then
    return false
  end
  return true
end
