debug_current_card = {}
function create_drag_target_from_card_old(_card)
    if _card and G.STAGE == G.STAGES.RUN then
        debug_current_card = _card;
        G.DRAG_TARGETS = G.DRAG_TARGETS or {
            S_buy = Moveable { T = { x = G.jokers.T.x, y = G.jokers.T.y - 0.1, w = G.consumeables.T.x + G.consumeables.T.w - G.jokers.T.x, h = G.jokers.T.h + 0.6 } },
            S_buy_and_use = Moveable { T = { x = G.deck.T.x + 0.2, y = G.deck.T.y - 5.1, w = G.deck.T.w - 0.1, h = 4.5 } },
            C_sell = Moveable { T = { x = G.jokers.T.x, y = G.jokers.T.y - 0.2, w = G.jokers.T.w, h = G.jokers.T.h + 0.6 } },
            J_sell = Moveable { T = { x = G.consumeables.T.x + 0.3, y = G.consumeables.T.y - 0.2, w = G.consumeables.T.w - 0.3, h = G.consumeables.T.h + 0.6 } },
            J_sell_vanilla = Moveable { T = { x = G.consumeables.T.x + 0.3, y = G.consumeables.T.y - 0.2, w = G.consumeables.T.w - 0.3, h = G.consumeables.T.h + 0.6 } },
            C_use = Moveable { T = { x = G.deck.T.x + 0.2, y = G.deck.T.y - 5.1, w = G.deck.T.w - 0.1, h = 4.5 } },
            P_select = Moveable { T = { x = G.play.T.x, y = G.play.T.y - 2, w = G.play.T.w + 2, h = G.play.T.h + 1 } },
            -- for Cryptid code cards and Pokermon item/energy cards (middle center)
            P_save = Moveable { T = { x = G.play.T.x, y = G.play.T.y - 2, w = G.play.T.w, h = G.play.T.h + 1 } },
            -- Prism's "double cards" have a "Switch" button
            P_switch = Moveable { T = { x = G.deck.T.x + 0.2, y = G.deck.T.y - 5.1, w = G.deck.T.w - 0.1, h = 4.5 } },
        }

        if DTM.config.vanilla_joker_sell == false then
            G.DRAG_TARGETS.J_sell = Moveable { T = { x = G.deck.T.x + 0.2, y = G.deck.T.y - 5.1, w = G.deck.T.w - 0.1, h = 4.5 } }
        else
            G.DRAG_TARGETS.J_sell = G.DRAG_TARGETS.J_sell_vanilla
        end

        if _card.area and (_card.area == G.shop_jokers or _card.area == G.shop_vouchers or _card.area == G.shop_booster) then
            local is_booster = _card.ability.set == 'Booster'
            local is_voucher = _card.ability.set == 'Voucher'
            local buy_loc = copy_table(localize((is_voucher and 'ml_redeem_target') or
                (is_booster and 'ml_open_target') or 'ml_buy_target'))
            buy_loc[#buy_loc + 1] = '$' .. _card.cost
            drag_target({
                cover = G.DRAG_TARGETS.S_buy,
                colour = adjust_alpha(G.C.GREEN, 0.9),
                text = buy_loc,
                card = _card,
                active_check = (function(other)
                    return sticky_can_buy(other)
                end),
                release_func = (function(other)
                    if other.ability.set == 'Joker' and sticky_can_buy(other) then
                        if G.OVERLAY_TUTORIAL and G.OVERLAY_TUTORIAL.button_listen == 'buy_from_shop' then
                            G.FUNCS.tut_next()
                        end
                        G.FUNCS.buy_from_shop({
                            config = {
                                ref_table = other,
                                id = 'buy'
                            }
                        })
                        return
                    elseif other.ability.set == 'Voucher' and sticky_can_buy(other) then
                        G.FUNCS.use_card({ config = { ref_table = other } })
                    elseif other.ability.set == 'Booster' and sticky_can_buy(other) then
                        G.FUNCS.use_card({ config = { ref_table = other } })
                    elseif sticky_can_buy(other) then
                        G.FUNCS.buy_from_shop({
                            config = {
                                ref_table = other,
                                id = 'buy'
                            }
                        })
                    end
                end)
            })

            if sticky_can_buy_and_use(_card) then
                local buy_use_loc = copy_table(localize('ml_buy_and_use_target'))
                buy_use_loc[#buy_use_loc + 1] = '$' .. _card.cost
                drag_target({
                    cover = G.DRAG_TARGETS.S_buy_and_use,
                    colour = adjust_alpha(G.C.ORANGE, 0.9),
                    text = buy_use_loc,
                    card = _card,
                    active_check = (function(other)
                        return sticky_can_buy_and_use(other)
                    end),
                    release_func = (function(other)
                        if sticky_can_buy_and_use(other) then
                            G.FUNCS.buy_from_shop({
                                config = {
                                    ref_table = other,
                                    id = 'buy_and_use'
                                }
                            })
                            return
                        end
                    end)
                })
            end
        end

        local has_select_drag_area = false
        local is_consumeable_card_in_crazy_reverie_pack = Reverie and
            (Reverie.is_cine_or_reverie(_card) or Reverie.find_used_cine("Crazy Lucky")) and
            _card.ability.consumeable and _card.area == G.pack_cards
        print("is_card_in_crazy_reverie_pack", is_consumeable_card_in_crazy_reverie_pack)

        if _card.area and (_card.area == G.pack_cards) then
            -- Exceptions for:
            -- 1. 'Cine' cards since they can't be used while in a pack, like Planet cards.
            -- 2. Consumeables inside of Reverie's "Pack" (crazy_pack) that can contain every type of card but consumeables cannot be used from them.
            if _card.ability.consumeable and not (_card.ability.set == 'Planet' or _card.ability.set == 'Cine' or is_consumeable_card_in_crazy_reverie_pack) then
                drag_target({
                    cover = G.DRAG_TARGETS.C_use,
                    colour = adjust_alpha(G.C.RED, 0.9),
                    text = { localize('b_use') },
                    card = _card,
                    active_check = (function(other)
                        return other:can_use_consumeable()
                    end),
                    release_func = (function(other)
                        if other:can_use_consumeable() then
                            G.FUNCS.use_card({ config = { ref_table = other } })
                        end
                    end)
                })
            else
                drag_target({
                    cover = G.DRAG_TARGETS.P_select,
                    colour = adjust_alpha(G.C.GREEN, 0.9),
                    text = { localize('b_select') },
                    card = _card,
                    active_check = (function(other)
                        if is_consumeable_card_in_crazy_reverie_pack then
                            return sticky_can_select_crazy_card(other)
                        end
                        -- Bunco: Blind 'cards' in packs
                        if BUNCOMOD and _card.ability and _card.ability.blind_card then
                            return sticky_can_use_blind_card(other)
                        end
                        return sticky_can_select_card(other)
                    end),
                    release_func = (function(other)
                        if is_consumeable_card_in_crazy_reverie_pack and sticky_can_select_card(other) then
                            G.FUNCS.use_card({ config = { ref_table = other } })
                            return
                        end
                        -- Bunco: Blind 'cards' in packs
                        if BUNCOMOD and _card.ability and _card.ability.blind_card then
                            if sticky_can_use_blind_card(other) then
                                G.FUNCS.use_blind_card({ config = { ref_table = other } })
                                return
                            end
                        end
                        if sticky_can_select_card(other) then
                            G.FUNCS.use_card({ config = { ref_table = other } })
                        end
                    end)
                })
                has_select_drag_area = true
            end
        end

        if _card.area and (_card.area == G.jokers or _card.area == G.consumeables or _card.area == G.hand) then
            if _card.area == G.jokers or _card.area == G.consumeables then
                local sell_loc = copy_table(localize('ml_sell_target'))
                sell_loc[#sell_loc + 1] = '$' .. (_card.facing == 'back' and '?' or _card.sell_cost)
                drag_target({
                    cover = _card.area == G.consumeables and G.DRAG_TARGETS.C_sell or G.DRAG_TARGETS.J_sell,
                    colour = adjust_alpha(G.C.GOLD, 0.9),
                    text = sell_loc,
                    card = _card,
                    active_check = (function(other)
                        return other:can_sell_card()
                    end),
                    release_func = (function(other)
                        G.FUNCS.sell_card { config = { ref_table = other } }
                    end)
                })
            end
            if (_card.area == G.hand or _card.area == G.consumeables) and _card.ability and _card.ability.consumeable then
                drag_target({
                    cover = G.DRAG_TARGETS.C_use,
                    colour = adjust_alpha(G.C.RED, 0.9),
                    text = { localize('b_use') },
                    card = _card,
                    active_check = (function(other)
                        -- huge hack for Cryptid Code cards: since their `can_use` method might check for highlighted consumeables, we need to temporarily add the card inside the highlighted table to satisfy the check while drawing the drag_target
                        if Cryptid and _card.ability.set == 'Code' and _card.area and not is_element_in_table(_card, _card.area.highlighted) then
                            _card.area.highlighted[#_card.area.highlighted + 1] = _card
                            local can_use = other:can_use_consumeable()
                            remove_highlighted_card_from_area(_card, _card.area)
                            return can_use
                        end
                        return other:can_use_consumeable()
                    end),
                    release_func = (function(other)
                        -- this is lazy but if we're here we _should_ be good anyway
                        if Cryptid and other.ability.set == 'Code' then
                            G.FUNCS.use_card({ config = { ref_table = other } })
                        elseif other:can_use_consumeable() then
                            G.FUNCS.use_card({ config = { ref_table = other } })
                            if G.OVERLAY_TUTORIAL and G.OVERLAY_TUTORIAL.button_listen == 'use_card' then
                                G.FUNCS.tut_next()
                            end
                        end
                    end)
                })
            end
        end

        -- Prism's double cards from hand.
        if _card.area == G.hand and G.PRISM and _card.ability.set == 'Enhanced' and
            _card.ability.name == 'm_prism_double' then
            -- "Switch" area.
            drag_target({
                cover        = G.DRAG_TARGETS.P_switch,
                colour       = adjust_alpha(G.C.RED, 0.9),
                text         = { localize('prism_switch') },
                card         = _card,
                active_check = function()
                    return true
                end,
                release_func = function(other)
                    G.FUNCS.switch_button({
                        config = {
                            ref_table = other,
                        }
                    })
                end,
            })
        end

        -- Cryptid's "Code" cards inside packs.
        if _card.area and _card.area == G.pack_cards and Cryptid and _card.ability.consumeable and
            _card.ability.set == 'Code' and not has_select_drag_area then
            -- "Pull" drag target ("use" area is already covered above)
            drag_target({
                cover        = G.DRAG_TARGETS.P_save,
                colour       = adjust_alpha(G.C.GREEN, 0.9),
                text         = { localize('b_pull') },
                card         = _card,
                active_check = function(other)
                    return sticky_can_reserve_card(other)
                end,
                release_func = function(other)
                    if sticky_can_reserve_card(other) then
                        G.FUNCS.reserve_card({ config = { ref_table = other } })
                    end
                end,
            })
        end

        -- Pokermon Item/Energy cards inside packs.
        if _card.area and _card.area == G.pack_cards and pokermon and _card.ability.consumeable and
            (_card.ability.set == 'Energy' or _card.ability.set == 'Item') and not has_select_drag_area then
            -- "Save" drag target ("use" target is already covered above)
            drag_target({
                cover        = G.DRAG_TARGETS.P_save,
                colour       = adjust_alpha(G.ARGS.LOC_COLOURS.pink, 0.9),
                text         = { localize('b_save') },
                card         = _card,
                active_check = function()
                    return #G.consumeables.cards < G.consumeables.config.card_limit
                end,
                release_func = function(other)
                    if #G.consumeables.cards < G.consumeables.config.card_limit then
                        G.FUNCS.reserve_card({ config = { ref_table = other } })
                    end
                end,
            })
        end

        -- Reverie's "Cine" cards inside packs. "Select" drag target.
        if _card.area and _card.area == G.pack_cards and _card.ability.consumeable and
            _card.ability.set == 'Cine' and not has_select_drag_area then
            drag_target({
                cover        = G.DRAG_TARGETS.P_select,
                colour       = adjust_alpha(G.C.GREEN, 0.9),
                text         = { localize('b_select') },
                card         = _card,
                active_check = (function(other)
                    return sticky_can_select_card(other)
                end),
                release_func = (function(other)
                    if sticky_can_select_card(other) then
                        G.FUNCS.use_card({ config = { ref_table = other } })
                    end
                end),
            })
        end

        -- 'Cine' (Reverie) cards inside their own area.
        if _card.area and _card.area == G.cine_quests and _card.ability.consumeable and
            _card.ability.set == 'Cine' then
            local sell_loc = copy_table(localize('ml_sell_target'))
            sell_loc[#sell_loc + 1] = '$' .. (_card.facing == 'back' and '?' or _card.sell_cost)
            -- "Sell" target.
            drag_target({
                cover        = G.DRAG_TARGETS.C_sell,
                colour       = adjust_alpha(G.C.GOLD, 0.9),
                text         = sell_loc,
                card         = _card,
                active_check = (function(other)
                    return other:can_sell_card()
                end),
                release_func = (function(other)
                    G.FUNCS.sell_card { config = { ref_table = other } }
                end),
            })
            -- "Use" target.
            drag_target({
                cover        = G.DRAG_TARGETS.J_sell_vanilla,
                colour       = adjust_alpha(G.C.RED, 0.9),
                text         = { localize('b_use') },
                card         = _card,
                active_check = (function(other)
                    return other:can_use_consumeable()
                end),
                release_func = (function(other)
                    G.FUNCS.use_card({ config = { ref_table = other } })
                end),
            })
        end
    end
end

function create_drag_target_from_card(_card)
    if _card and G.STAGE == G.STAGES.RUN then
        debug_current_card = _card

        G.DRAG_TARGETS = G.DRAG_TARGETS or {
            S_buy = Moveable { T = { x = G.jokers.T.x, y = G.jokers.T.y - 0.1, w = G.consumeables.T.x + G.consumeables.T.w - G.jokers.T.x, h = G.jokers.T.h + 0.6 } },
            S_buy_and_use = Moveable { T = { x = G.deck.T.x + 0.2, y = G.deck.T.y - 5.1, w = G.deck.T.w - 0.1, h = 4.5 } },
            C_sell = Moveable { T = { x = G.jokers.T.x, y = G.jokers.T.y - 0.2, w = G.jokers.T.w, h = G.jokers.T.h + 0.6 } },
            J_sell = Moveable { T = { x = G.consumeables.T.x + 0.3, y = G.consumeables.T.y - 0.2, w = G.consumeables.T.w - 0.3, h = G.consumeables.T.h + 0.6 } },
            J_sell_vanilla = Moveable { T = { x = G.consumeables.T.x + 0.3, y = G.consumeables.T.y - 0.2, w = G.consumeables.T.w - 0.3, h = G.consumeables.T.h + 0.6 } },
            C_use = Moveable { T = { x = G.deck.T.x + 0.2, y = G.deck.T.y - 5.1, w = G.deck.T.w - 0.1, h = 4.5 } },
            P_select = Moveable { T = { x = G.play.T.x, y = G.play.T.y - 2, w = G.play.T.w + 2, h = G.play.T.h + 1 } },
            -- for Cryptid code cards and Pokermon item/energy cards (middle center)
            P_save = Moveable { T = { x = G.play.T.x, y = G.play.T.y - 2, w = G.play.T.w, h = G.play.T.h + 1 } },
            -- Prism's "double cards" have a "Switch" button
            P_switch = Moveable { T = { x = G.deck.T.x + 0.2, y = G.deck.T.y - 5.1, w = G.deck.T.w - 0.1, h = 4.5 } },
        }

        if DTM.config.vanilla_joker_sell == false then
            G.DRAG_TARGETS.J_sell = Moveable { T = { x = G.deck.T.x + 0.2, y = G.deck.T.y - 5.1, w = G.deck.T.w - 0.1, h = 4.5 } }
        else
            G.DRAG_TARGETS.J_sell = G.DRAG_TARGETS.J_sell_vanilla
        end

        if _card.area then
            -- is the card in one of the shop areas?
            if _card.area == G.shop_jokers or _card.area == G.shop_vouchers or
                _card.area == G.shop_booster then
                local buy_loc = copy_table(localize((_card.ability.set == 'Voucher' and 'ml_redeem_target') or
                    (_card.ability.set == 'Booster' and 'ml_open_target') or 'ml_buy_target'))
                buy_loc[#buy_loc + 1] = '$' .. _card.cost
                drag_target({
                    cover = G.DRAG_TARGETS.S_buy,
                    colour = adjust_alpha(G.C.GREEN, 0.9),
                    text = buy_loc,
                    card = _card,
                    active_check = (function(other)
                        return sticky_can_buy(other)
                    end),
                    release_func = (function(other)
                        if other.ability.set == 'Joker' and sticky_can_buy(other) then
                            if G.OVERLAY_TUTORIAL and G.OVERLAY_TUTORIAL.button_listen == 'buy_from_shop' then
                                G.FUNCS.tut_next()
                            end
                            G.FUNCS.buy_from_shop({
                                config = {
                                    ref_table = other,
                                    id = 'buy'
                                }
                            })
                            return
                        elseif (other.ability.set == 'Voucher' or other.ability.set == 'Booster') and sticky_can_buy(other) then
                            G.FUNCS.use_card({ config = { ref_table = other } })
                        elseif sticky_can_buy(other) then
                            G.FUNCS.buy_from_shop({
                                config = {
                                    ref_table = other,
                                    id = 'buy'
                                }
                            })
                        end
                    end)
                })

                if sticky_can_buy_and_use(_card) then
                    local buy_use_loc = copy_table(localize('ml_buy_and_use_target'))
                    buy_use_loc[#buy_use_loc + 1] = '$' .. _card.cost
                    drag_target({
                        cover = G.DRAG_TARGETS.S_buy_and_use,
                        colour = adjust_alpha(G.C.ORANGE, 0.9),
                        text = buy_use_loc,
                        card = _card,
                        active_check = (function(other)
                            return sticky_can_buy_and_use(other)
                        end),
                        release_func = (function(other)
                            if sticky_can_buy_and_use(other) then
                                G.FUNCS.buy_from_shop({
                                    config = {
                                        ref_table = other,
                                        id = 'buy_and_use'
                                    }
                                })
                                return
                            end
                        end)
                    })
                end
            end

            -- is the card in a pack?
            if _card.area == G.pack_cards then
                -- is the card a consumeable?
                if _card.ability.consumeable then
                    local is_planet = _card.ability.set == 'Planet'
                    drag_target({
                        cover = (is_planet and G.DRAG_TARGETS.P_select) or G.DRAG_TARGETS.C_use,
                        colour = adjust_alpha((is_planet and G.C.GREEN) or G.C.RED, 0.9),
                        text = { localize('b_use') },
                        card = _card,
                        active_check = (function(other)
                            return other:can_use_consumeable()
                        end),
                        release_func = (function(other)
                            if other:can_use_consumeable() then
                                G.FUNCS.use_card({ config = { ref_table = other } })
                            end
                        end)
                    })
                else
                    drag_target({
                        cover = G.DRAG_TARGETS.P_select,
                        colour = adjust_alpha(G.C.GREEN, 0.9),
                        text = { localize('b_select') },
                        card = _card,
                        active_check = (function(other)
                            return sticky_can_select_card(other)
                        end),
                        release_func = (function(other)
                            if sticky_can_select_card(other) then
                                G.FUNCS.use_card({ config = { ref_table = other } })
                            end
                        end)
                    })
                end
            end

            -- is the card in the jokers/consumeables area?
            if _card.area and (_card.area == G.jokers or _card.area == G.consumeables) then
                local sell_loc = copy_table(localize('ml_sell_target'))
                sell_loc[#sell_loc + 1] = '$' .. (_card.facing == 'back' and '?' or _card.sell_cost)
                drag_target({
                    cover = _card.area == G.consumeables and G.DRAG_TARGETS.C_sell or G.DRAG_TARGETS.J_sell,
                    colour = adjust_alpha(G.C.GOLD, 0.9),
                    text = sell_loc,
                    card = _card,
                    active_check = (function(other)
                        return other:can_sell_card()
                    end),
                    release_func = (function(other)
                        G.FUNCS.sell_card { config = { ref_table = other } }
                    end)
                })
                if _card.area == G.consumeables then
                    drag_target({
                        cover = G.DRAG_TARGETS.C_use,
                        colour = adjust_alpha(G.C.RED, 0.9),
                        text = { localize('b_use') },
                        card = _card,
                        active_check = (function(other)
                            return other:can_use_consumeable()
                        end),
                        release_func = (function(other)
                            if other:can_use_consumeable() then
                                G.FUNCS.use_card({ config = { ref_table = other } })
                                if G.OVERLAY_TUTORIAL and G.OVERLAY_TUTORIAL.button_listen == 'use_card' then
                                    G.FUNCS.tut_next()
                                end
                            end
                        end)
                    })
                end
            end
        end
    end
end

function remove_highlighted_card_from_area(card, area)
    for i = #area.highlighted, 1, -1 do
        if area.highlighted[i] == card then
            table.remove(card.area.highlighted, i)
            break
        end
    end
end

function is_element_in_table(element, table)
    for _, value in ipairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

sticky_can_use_blind_card = function(_card)
    local temp_config = { UIBox = { states = { visible = false } }, config = { ref_table = _card } }
    G.FUNCS.can_use_blind_card(temp_config)
    return temp_config.config.button ~= nil;
end

sticky_can_reserve_card = function(_card)
    local temp_config = { UIBox = { states = { visible = false } }, config = { ref_table = _card } }
    G.FUNCS.can_reserve_card(temp_config)
    return temp_config.config.button ~= nil;
end

sticky_can_select_card = function(_card)
    local temp_config = { UIBox = { states = { visible = false } }, config = { ref_table = _card } }
    G.FUNCS.can_select_card(temp_config)
    return temp_config.config.button ~= nil;
end

sticky_can_buy = function(_card)
    local temp_config = { UIBox = { states = { visible = false } }, config = { ref_table = _card } }
    G.FUNCS.can_buy(temp_config)
    return temp_config.config.button ~= nil;
end

sticky_can_buy_and_use = function(_card)
    local temp_config = { UIBox = { states = { visible = false } }, config = { ref_table = _card } }
    G.FUNCS.can_buy_and_use(temp_config)
    return temp_config.config.button ~= nil;
end

sticky_can_select_crazy_card = function(_card)
    local temp_config = { UIBox = { states = { visible = false } }, config = { ref_table = _card } }
    G.FUNCS.can_select_crazy_card(temp_config)
    return temp_config.config.button ~= nil;
end
