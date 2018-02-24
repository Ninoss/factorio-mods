data:extend({
  {
    type = "explosion",
    name = "train-honk-long-single",
    flags = {"not-on-map"},
    animations =
    {
      {
        filename = "__core__/graphics/empty.png",
        priority = "low",
        width = 1,
        height = 1,
        frame_count = 1,
        line_length = 1,
        animation_speed = 1
      },
    },
    light = {intensity = 0, size = 0},
    sound =
    {
      {
      filename = "__Honk__/sounds/honklong.ogg",
      volume = SINGLE_HONK_VOLUME
      }
    }
  },
  {
    type = "explosion",
    name = "train-honk-short-double",
    flags = {"not-on-map"},
    animations =
    {
      {
        filename = "__core__/graphics/empty.png",
        priority = "low",
        width = 1,
        height = 1,
        frame_count = 1,
        line_length = 1,
        animation_speed = 1
      },
    },
    light = {intensity = 0, size = 0},
    sound =
    {
      {
      filename = "__Honk__/sounds/honk2xshort.ogg",
      volume = DOUBLE_HONK_VOLUME
      }
    }
  }
})