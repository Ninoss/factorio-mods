local adveq =
{
  type="frame_style",
  parent="frame_style",
  graphical_set=
  {
    type = "monolith",
    top_monolith_border = 1,
    right_monolith_border = 1,
    bottom_monolith_border = 1,
    left_monolith_border = 1,
    monolith_image =
    {
      filename = "__AdvancedEquipment__/graphics/GUI/50x120.png",
      width = 120,
      height = 50,
      x = 0,
      y = 0
    }
  }
}



data.raw["gui-style"].default["adveq"] = adveq
