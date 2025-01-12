function Card:simple_touch()
  return false
end

function Card:single_tap()
  if self.area and self.area:can_highlight(self) and self.area == G.hand then
      if (self.area == G.hand) and (G.STATE == G.STATES.HAND_PLAYED) then return end
      if self.highlighted ~= true then 
          self.area:add_to_highlighted(self)
      else
          self.area:remove_from_highlighted(self)
          play_sound('cardSlide2', nil, 0.3)
      end
  end
  if self.area and self.area == G.deck and self.area.cards[1] == self then 
      G.FUNCS.deck_info()
  end
  G.MOBILE_VIBRATION_QUEUE = math.max(G.MOBILE_VIBRATION_QUEUE or 0, 1)
end

function Card:can_long_press()
  if self.area and ((self.area == G.hand) or
  ( self.area == G.deck and self.area.cards[1] == self)) then
      return true
  end
end

function Card:can_hover_on_drag()
  return false
end

function Card:swipe_up()
  G.MOBILE_VIBRATION_QUEUE = math.max(G.MOBILE_VIBRATION_QUEUE or 0, 2)
  if self.area and self.area == G.hand and self.area:can_highlight(self) then
      if (self.area == G.hand) and (G.STATE == G.STATES.HAND_PLAYED) then return end
      if self.highlighted ~= true then 
          self.area:add_to_highlighted(self)
      end
  end
  if not self.ability.consumeable and self.area and self.area == G.pack_cards and G.FUNCS.can_select_card(self) then
      G.FUNCS.use_card({config={ref_table = self}})
      return
  end
  if self.area and ((self.area == G.shop_jokers) or (self.area == G.shop_booster) or (self.area == G.shop_vouchers)) then
      if self.ability.set == 'Booster' and ((self.cost) <= 0 or (self.cost <= G.GAME.dollars - G.GAME.bankrupt_at)) then
          G.FUNCS.use_card({config={ref_table = self}})
          return
      elseif self.ability.set == 'Voucher' and ((self.cost) <= 0 or (self.cost <= G.GAME.dollars - G.GAME.bankrupt_at)) then   
          G.FUNCS.use_card({config={ref_table = self}})
          return
      elseif self.area == G.shop_jokers and G.FUNCS.can_buy(self) then 
          G.FUNCS.buy_from_shop({config = {
              ref_table = self,
              id = 'buy'
          }})
          return
      end
  end
  if self.ability.consumeable and self.area and (self.area == G.consumeables or self.area == G.pack_cards) and self:can_use_consumeable() then 
      G.FUNCS.use_card({config={ref_table = self}})
  end
end

function Card:swipe_down()
  G.MOBILE_VIBRATION_QUEUE = math.max(G.MOBILE_VIBRATION_QUEUE or 0, 3)
  if self.area and self.area:can_highlight(self) then
      if (self.area == G.hand) and (G.STATE == G.STATES.HAND_PLAYED) then return end
      if self.highlighted == true then 
          self.area:remove_from_highlighted(self)
          play_sound('cardSlide2', nil, 0.3)
      end
  end
  if G.FUNCS.can_buy_and_use(self) then 
      G.FUNCS.buy_from_shop({config = {
          ref_table = self,
          id = 'buy_and_use'
      }})
      return
  end
  if self.area and (self.area == G.jokers or self.area == G.consumeables) then
      self:sell_card()
  end
end