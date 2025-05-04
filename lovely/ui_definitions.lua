function drag_target(args)
  args = args or {}
  args.text = args.text or { 'BUY' }
  args.colour = copy_table(args.colour or G.C.UI.TRANSPARENT_DARK)
  args.cover = args.cover or nil
  args.emboss = args.emboss or nil
  args.active_check = args.active_check or (function(other) return true end)
  args.release_func = args.release_func or (function(other) G.DEBUG_VALUE = 'WORKIN' end)
  args.text_colour = copy_table(G.C.WHITE)
  args.uibox_config = {
    align = args.align or 'tli',
    offset = args.offset or { x = 0, y = 0 },
    major = args.cover or args.major or nil,
  }

  local drag_area_width = (args.T and args.T.w or args.cover and args.cover.T.w or 0.001) + (args.cover_padding or 0)

  local text_rows = {}
  for k, v in ipairs(args.text) do
    text_rows[#text_rows + 1] = { n = G.UIT.R, config = { align = "cm", padding = 0.05, maxw = drag_area_width - 0.1 }, nodes = { { n = G.UIT.O, config = { object = DynaText({ scale = args.scale, string = v, maxw = args.maxw or (drag_area_width - 0.1), colours = { args.text_colour }, float = true, shadow = true, silent = not args.noisy, 0.7, pop_in = 0, pop_in_rate = 6, rotate = args.rotate or nil }) } } } }
  end

  args.DT = UIBox {
    T = { 0, 0, 0, 0 },
    definition =
    { n = G.UIT.ROOT, config = { align = 'cm', args = args, can_collide = true, hover = true, release_func = args.release_func, func = 'check_drag_target_active', minw = drag_area_width, minh = (args.cover and args.cover.T.h or 0.001) + (args.cover_padding or 0), padding = 0.03, r = 0.1, emboss = args.emboss, colour = G.C.CLEAR }, nodes = text_rows },
    config = args.uibox_config
  }
  args.DT.attention_text = true

  if G.OVERLAY_TUTORIAL and G.OVERLAY_TUTORIAL.highlights then
    G.OVERLAY_TUTORIAL.highlights[#G.OVERLAY_TUTORIAL.highlights + 1] = args.DT
  end

  G.E_MANAGER:add_event(Event({
    trigger = 'after',
    delay = 0,
    blockable = false,
    blocking = false,
    func = function()
      if not G.CONTROLLER.dragging.target and args.DT then
        if G.OVERLAY_TUTORIAL and G.OVERLAY_TUTORIAL.highlights then
          for k, v in ipairs(G.OVERLAY_TUTORIAL.highlights) do
            if args.DT == v then
              table.remove(G.OVERLAY_TUTORIAL.highlights, k)
              break
            end
          end
        end
        args.DT:remove()
        return true
      end
    end
  }))
end
