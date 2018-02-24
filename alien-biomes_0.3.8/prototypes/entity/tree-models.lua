local function index_to_letter(index, starting_at)
  return string.char(string.byte(starting_at or "a", 1) - 1 + index)
end

local tree_types =
{
  { -- tree-01
    --addHere-tree01
    type_name = "01",
    drawing_box = {{-0.9, -3}, {0.9, 0.6}},
    variations = {
      { -- a
        trunk = {
          width = 177,
          height = 150,
          shift = util.by_pixel(29.5, -38),
          hr_version = {
            width = 354,
            height = 298,
            shift = util.by_pixel(30.5, -37.5),
            scale = 0.5
          },
        },
        leaves = {
          width = 102,
          height = 115,
          shift = util.by_pixel(-11, -65.5),
          hr_version = {
            width = 204,
            height = 231,
            shift = util.by_pixel(-10.5, -64.75),
            scale = 0.5
          },
        },
      },
      { -- b
        trunk = {
          width = 179,
          height = 149,
          shift = util.by_pixel(49.5, -40.5),
          hr_version = {
            width = 358,
            height = 298,
            shift = util.by_pixel(50, -40),
            scale = 0.5
          },
        },
        leaves = {
          width = 89,
          height = 107,
          shift = util.by_pixel(3.5, -69.5),
          hr_version = {
            width = 178,
            height = 215,
            shift = util.by_pixel(4, -69.25),
            scale = 0.5
          },
        },
      },
      { -- c
        trunk = {
          width = 156,
          height = 146,
          shift = util.by_pixel(52, -34),
          hr_version = {
            width = 313,
            height = 291,
            shift = util.by_pixel(52.25, -33.75),
            scale = 0.5
          },
        },
        leaves = {
          width = 94,
          height = 104,
          shift = util.by_pixel(6, -64),
          hr_version = {
            width = 190,
            height = 210,
            shift = util.by_pixel(6.5, -63.5),
            scale = 0.5
          },
        },
      },
      { -- d
        trunk = {
          width = 176,
          height = 152,
          shift = util.by_pixel(55, -35),
          hr_version = {
            width = 351,
            height = 302,
            shift = util.by_pixel(55.25, -34.5),
            scale = 0.5
          },
        },
        leaves = {
          width = 102,
          height = 106,
          shift = util.by_pixel(12, -63),
          hr_version = {
            width = 205,
            height = 212,
            shift = util.by_pixel(12.25, -62),
            scale = 0.5
          },
        },
      },
      { -- e
        trunk = {
          width = 174,
          height = 141,
          shift = util.by_pixel(56, -35.5),
          hr_version = {
            width = 346,
            height = 281,
            shift = util.by_pixel(56.5, -34.75),
            scale = 0.5
          },
        },
        leaves = {
          width = 105,
          height = 110,
          shift = util.by_pixel(16.5, -55),
          hr_version = {
            width = 212,
            height = 221,
            shift = util.by_pixel(17, -54.75),
            scale = 0.5
          },
        },
      },
      { -- f
        trunk = {
          width = 176,
          height = 141,
          shift = util.by_pixel(42, -22.5),
          hr_version = {
            width = 350,
            height = 280,
            shift = util.by_pixel(42.5, -22),
            scale = 0.5
          },
        },
        leaves = {
          width = 95,
          height = 101,
          shift = util.by_pixel(0.5, -46.5),
          hr_version = {
            width = 191,
            height = 203,
            shift = util.by_pixel(0.75, -45.75),
            scale = 0.5
          },
        },
      },
      { -- g
        trunk = {
          width = 164,
          height = 150,
          shift = util.by_pixel(20, -24),
          hr_version = {
            width = 328,
            height = 301,
            shift = util.by_pixel(20.5, -23.75),
            scale = 0.5
          },
        },
        leaves = {
          width = 96,
          height = 119,
          shift = util.by_pixel(-18, -50.5),
          hr_version = {
            width = 193,
            height = 239,
            shift = util.by_pixel(-17.75, -49.75),
            scale = 0.5
          },
        },
      },
      { -- h
        trunk = {
          width = 181,
          height = 144,
          shift = util.by_pixel(26.5, -33),
          hr_version = {
            width = 360,
            height = 288,
            shift = util.by_pixel(27, -32.5),
            scale = 0.5
          },
        },
        leaves = {
          width = 108,
          height = 108,
          shift = util.by_pixel(-20, -59),
          hr_version = {
            width = 216,
            height = 216,
            shift = util.by_pixel(-20, -59),
            scale = 0.5
          },
        },
      },
      { -- i
        trunk = {
          width = 165,
          height = 162,
          shift = util.by_pixel(41.5, -22),
          hr_version = {
            width = 329,
            height = 323,
            shift = util.by_pixel(41.75, -21.25),
            scale = 0.5
          },
        },
        leaves = {
          width = 88,
          height = 121,
          shift = util.by_pixel(0, -47.5),
          hr_version = {
            width = 177,
            height = 244,
            shift = util.by_pixel(0.75, -47),
            scale = 0.5
          },
        },
      },
      { -- j
        trunk = {
          width = 132,
          height = 115,
          shift = util.by_pixel(35, -29.5),
          hr_version = {
            width = 264,
            height = 229,
            shift = util.by_pixel(35.5, -29.25),
            scale = 0.5
          },
        },
        leaves = {
          width = 89,
          height = 90,
          shift = util.by_pixel(4.5, -53),
          hr_version = {
            width = 180,
            height = 179,
            shift = util.by_pixel(5, -52.25),
            scale = 0.5
          },
        },
      },
    },
  },
  { -- tree-02
    --addHere-tree02
    type_name = "02",
    drawing_box = {{-0.9, -3.9}, {0.9, 0.6}},
    variations = {
      { -- a
        trunk = {
          width = 225,
          height = 169,
          shift = util.by_pixel(61.5, -46.5),
          hr_version = {
            width = 448,
            height = 340,
            shift = util.by_pixel(61.5, -47.5),
            scale = 0.5
          },
        },
        leaves = {
          width = 95,
          height = 131,
          shift = util.by_pixel(-4.5, -70.5),
          hr_version = {
            width = 190,
            height = 261,
            shift = util.by_pixel(-4.5, -70.75),
            scale = 0.5
          },
        },
      },
      { -- b
        trunk = {
          width = 279,
          height = 193,
          shift = util.by_pixel(31.5, -43.5),
          hr_version = {
            width = 558,
            height = 385,
            shift = util.by_pixel(32, -43.25),
            scale = 0.5
          },
        },
        leaves = {
          width = 98,
          height = 143,
          shift = util.by_pixel(-6, -70.5),
          hr_version = {
            width = 194,
            height = 285,
            shift = util.by_pixel(-6, -70.25),
            scale = 0.5
          },
        },
      },
      { -- c
        trunk = {
          width = 249,
          height = 188,
          shift = util.by_pixel(69.5, -51),
          hr_version = {
            width = 499,
            height = 377,
            shift = util.by_pixel(69.25, -50.75),
            scale = 0.5
          },
        },
        leaves = {
          width = 106,
          height = 154,
          shift = util.by_pixel(-3, -83),
          hr_version = {
            width = 213,
            height = 309,
            shift = util.by_pixel(-3.25, -83.25),
            scale = 0.5
          },
        },
      },
      { -- d
        trunk = {
          width = 271,
          height = 187,
          shift = util.by_pixel(90.5, -50.5),
          hr_version = {
            width = 541,
            height = 374,
            shift = util.by_pixel(90.25, -51),
            scale = 0.5
          },
        },
        leaves = {
          width = 119,
          height = 154,
          shift = util.by_pixel(13.5, -70),
          hr_version = {
            width = 238,
            height = 309,
            shift = util.by_pixel(14, -70.25),
            scale = 0.5
          },
        },
      },
      { -- e
        trunk = {
          width = 256,
          height = 191,
          shift = util.by_pixel(73, -46.5),
          hr_version = {
            width = 512,
            height = 381,
            shift = util.by_pixel(73.5, -46.25),
            scale = 0.5
          },
        },
        leaves = {
          width = 104,
          height = 144,
          shift = util.by_pixel(-3, -73),
          hr_version = {
            width = 207,
            height = 286,
            shift = util.by_pixel(-2.75, -73),
            scale = 0.5
          },
        },
      },
    },
  },
  { -- tree-03
    --addHere-tree03
    type_name = "03",
    drawing_box = {{-0.9, -3.7}, {0.9, 0.6}},
    variations = {
      { -- a
        trunk = {
          width = 243,
          height = 156,
          shift = util.by_pixel(72.5, -45),
          hr_version = {
            width = 487,
            height = 312,
            shift = util.by_pixel(72.75, -45),
            scale = 0.5
          },
        },
        leaves = {
          width = 119,
          height = 98,
          shift = util.by_pixel(12.5, -76),
          hr_version = {
            width = 237,
            height = 195,
            shift = util.by_pixel(13.25, -75.75),
            scale = 0.5
          },
        },
      },
      { -- b
        trunk = {
          width = 162,
          height = 124,
          shift = util.by_pixel(50, -39),
          hr_version = {
            width = 324,
            height = 246,
            shift = util.by_pixel(50, -39),
            scale = 0.5
          },
        },
        leaves = {
          width = 78,
          height = 72,
          shift = util.by_pixel(12, -65),
          hr_version = {
            width = 157,
            height = 144,
            shift = util.by_pixel(12.75, -65),
            scale = 0.5
          },
        },
      },
      { -- c
        trunk = {
          width = 193,
          height = 169,
          shift = util.by_pixel(59.5, -51.5),
          hr_version = {
            width = 387,
            height = 337,
            shift = util.by_pixel(59.75, -51.25),
            scale = 0.5
          },
        },
        leaves = {
          width = 94,
          height = 88,
          shift = util.by_pixel(13, -92),
          hr_version = {
            width = 187,
            height = 178,
            shift = util.by_pixel(13.25, -91.5),
            scale = 0.5
          },
        },
      },
      { -- d
        trunk = {
          width = 236,
          height = 169,
          shift = util.by_pixel(65, -53.5),
          hr_version = {
            width = 473,
            height = 337,
            shift = util.by_pixel(64.75, -53.75),
            scale = 0.5
          },
        },
        leaves = {
          width = 100,
          height = 83,
          shift = util.by_pixel(0, -98.5),
          hr_version = {
            width = 204,
            height = 167,
            shift = util.by_pixel(0.5, -97.75),
            scale = 0.5
          },
        },
      },
      { -- e
        trunk = {
          width = 258,
          height = 143,
          shift = util.by_pixel(59, -48.5),
          hr_version = {
            width = 516,
            height = 285,
            shift = util.by_pixel(59, -48.75),
            scale = 0.5
          },
        },
        leaves = {
          width = 117,
          height = 83,
          shift = util.by_pixel(-7.5, -80.5),
          hr_version = {
            width = 235,
            height = 167,
            shift = util.by_pixel(-6.75, -79.75),
            scale = 0.5
          },
        },
      },
      { -- f
        trunk = {
          width = 213,
          height = 158,
          shift = util.by_pixel(48.5, -44),
          hr_version = {
            width = 427,
            height = 315,
            shift = util.by_pixel(48.75, -43.75),
            scale = 0.5
          },
        },
        leaves = {
          width = 93,
          height = 100,
          shift = util.by_pixel(-8.5, -67),
          hr_version = {
            width = 186,
            height = 201,
            shift = util.by_pixel(-8, -66.25),
            scale = 0.5
          },
        },
      },
      { -- g
        trunk = {
          width = 176,
          height = 149,
          shift = util.by_pixel(40, -34.5),
          hr_version = {
            width = 352,
            height = 299,
            shift = util.by_pixel(40, -35.25),
            scale = 0.5
          },
        },
        leaves = {
          width = 76,
          height = 105,
          shift = util.by_pixel(-6, -59.5),
          hr_version = {
            width = 155,
            height = 212,
            shift = util.by_pixel(-5.25, -59),
            scale = 0.5
          },
        },
      },
    },
  },
  { -- tree-04
    --addHere-tree04
    type_name = "04",
    drawing_box = {{-0.9, -3.9}, {0.9, 0.6}},
    variations = {
      { -- a
        trunk = {
          width = 255,
          height = 170,
          shift = util.by_pixel(78.5, -50),
          hr_version = {
            width = 509,
            height = 340,
            shift = util.by_pixel(78.75, -49.5),
            scale = 0.5
          },
        },
        leaves = {
          width = 98,
          height = 127,
          shift = util.by_pixel(0, -76.5),
          hr_version = {
            width = 197,
            height = 254,
            shift = util.by_pixel(0.25, -75.5),
            scale = 0.5
          },
        },
      },
      { -- b
        trunk = {
          width = 231,
          height = 168,
          shift = util.by_pixel(69.5, -46),
          hr_version = {
            width = 463,
            height = 336,
            shift = util.by_pixel(70.25, -45.5),
            scale = 0.5
          },
        },
        leaves = {
          width = 105,
          height = 140,
          shift = util.by_pixel(3.5, -68),
          hr_version = {
            width = 212,
            height = 280,
            shift = util.by_pixel(4, -67.5),
            scale = 0.5
          },
        },
      },
      { -- c
        trunk = {
          width = 265,
          height = 176,
          shift = util.by_pixel(92.5, -47),
          hr_version = {
            width = 530,
            height = 353,
            shift = util.by_pixel(92.5, -47.25),
            scale = 0.5
          },
        },
        leaves = {
          width = 99,
          height = 125,
          shift = util.by_pixel(1.5, -74.5),
          hr_version = {
            width = 197,
            height = 250,
            shift = util.by_pixel(2.25, -74.5),
            scale = 0.5
          },
        },
      },
      { -- d
        trunk = {
          width = 273,
          height = 173,
          shift = util.by_pixel(88.5, -46.5),
          hr_version = {
            width = 545,
            height = 348,
            shift = util.by_pixel(88.75, -46.5),
            scale = 0.5
          },
        },
        leaves = {
          width = 99,
          height = 125,
          shift = util.by_pixel(-6.5, -75.5),
          hr_version = {
            width = 198,
            height = 248,
            shift = util.by_pixel(-6, -75),
            scale = 0.5
          },
        },
      },
      { -- e
        trunk = {
          width = 246,
          height = 183,
          shift = util.by_pixel(63, -51.5),
          hr_version = {
            width = 492,
            height = 365,
            shift = util.by_pixel(63.5, -50.75),
            scale = 0.5
          },
        },
        leaves = {
          width = 108,
          height = 136,
          shift = util.by_pixel(-8, -77),
          hr_version = {
            width = 217,
            height = 273,
            shift = util.by_pixel(-7.75, -76.25),
            scale = 0.5
          },
        },
      },
      { -- f
        trunk = {
          width = 260,
          height = 190,
          shift = util.by_pixel(86, -51),
          hr_version = {
            width = 520,
            height = 380,
            shift = util.by_pixel(86.5, -51),
            scale = 0.5
          },
        },
        leaves = {
          width = 100,
          height = 122,
          shift = util.by_pixel(4, -87),
          hr_version = {
            width = 200,
            height = 246,
            shift = util.by_pixel(4, -87),
            scale = 0.5
          },
        },
      },
      { -- g
        trunk = {
          width = 260,
          height = 177,
          shift = util.by_pixel(82, -36.5),
          hr_version = {
            width = 522,
            height = 353,
            shift = util.by_pixel(82.5, -36.25),
            scale = 0.5
          },
        },
        leaves = {
          width = 98,
          height = 116,
          shift = util.by_pixel(-1, -70),
          hr_version = {
            width = 199,
            height = 231,
            shift = util.by_pixel(-0.75, -69.75),
            scale = 0.5
          },
        },
      },
      { -- h
        trunk = {
          width = 253,
          height = 169,
          shift = util.by_pixel(76.5, -35.5),
          hr_version = {
            width = 505,
            height = 340,
            shift = util.by_pixel(77.25, -35.5),
            scale = 0.5
          },
        },
        leaves = {
          width = 103,
          height = 122,
          shift = util.by_pixel(-0.5, -62),
          hr_version = {
            width = 206,
            height = 245,
            shift = util.by_pixel(0, -61.25),
            scale = 0.5
          },
        },
      },
    },
  },
  { -- tree-05
    --addHere-tree05
    type_name = "05",
    drawing_box = {{-0.9, -3.5}, {0.9, 0.6}},
    variations = {
      { -- a
        trunk = {
          width = 210,
          height = 142,
          shift = util.by_pixel(55, -33),
          hr_version = {
            width = 419,
            height = 284,
            shift = util.by_pixel(55.25, -33),
            scale = 0.5
          },
        },
        leaves = {
          width = 116,
          height = 118,
          shift = util.by_pixel(-3, -56),
          hr_version = {
            width = 233,
            height = 236,
            shift = util.by_pixel(-2.75, -56),
            scale = 0.5
          },
        },
      },
      { -- b
        trunk = {
          width = 198,
          height = 129,
          shift = util.by_pixel(59, -29.5),
          hr_version = {
            width = 394,
            height = 259,
            shift = util.by_pixel(59.5, -29.25),
            scale = 0.5
          },
        },
        leaves = {
          width = 104,
          height = 115,
          shift = util.by_pixel(-2, -49.5),
          hr_version = {
            width = 210,
            height = 230,
            shift = util.by_pixel(-1.5, -49.5),
            scale = 0.5
          },
        },
      },
      { -- c
        trunk = {
          width = 187,
          height = 138,
          shift = util.by_pixel(56.5, -33),
          hr_version = {
            width = 375,
            height = 276,
            shift = util.by_pixel(56.75, -33),
            scale = 0.5
          },
        },
        leaves = {
          width = 116,
          height = 135,
          shift = util.by_pixel(7, -51.5),
          hr_version = {
            width = 232,
            height = 270,
            shift = util.by_pixel(7.5, -51),
            scale = 0.5
          },
        },
      },
      { -- d
        trunk = {
          width = 206,
          height = 138,
          shift = util.by_pixel(57, -23),
          hr_version = {
            width = 412,
            height = 275,
            shift = util.by_pixel(57, -22.75),
            scale = 0.5
          },
        },
        leaves = {
          width = 133,
          height = 131,
          shift = util.by_pixel(2.5, -35.5),
          hr_version = {
            width = 264,
            height = 260,
            shift = util.by_pixel(3, -35.5),
            scale = 0.5
          },
        },
      },
      { -- e
        trunk = {
          width = 185,
          height = 129,
          shift = util.by_pixel(40.5, -19.5),
          hr_version = {
            width = 369,
            height = 258,
            shift = util.by_pixel(41.25, -19.5),
            scale = 0.5
          },
        },
        leaves = {
          width = 120,
          height = 109,
          shift = util.by_pixel(-6, -39.5),
          hr_version = {
            width = 240,
            height = 216,
            shift = util.by_pixel(-6, -39.5),
            scale = 0.5
          },
        },
      },
      { -- f
        trunk = {
          width = 188,
          height = 145,
          shift = util.by_pixel(43, -36.5),
          hr_version = {
            width = 375,
            height = 291,
            shift = util.by_pixel(43.75, -36.25),
            scale = 0.5
          },
        },
        leaves = {
          width = 125,
          height = 140,
          shift = util.by_pixel(-0.5, -51),
          hr_version = {
            width = 250,
            height = 281,
            shift = util.by_pixel(0.5, -51.25),
            scale = 0.5
          },
        },
      },
      { -- g
        trunk = {
          width = 182,
          height = 108,
          shift = util.by_pixel(54, -17),
          hr_version = {
            width = 362,
            height = 216,
            shift = util.by_pixel(54.5, -16.5),
            scale = 0.5
          },
        },
        leaves = {
          width = 117,
          height = 100,
          shift = util.by_pixel(1.5, -33),
          hr_version = {
            width = 232,
            height = 201,
            shift = util.by_pixel(2, -33.25),
            scale = 0.5
          },
        },
      },
      { -- h
        trunk = {
          width = 164,
          height = 119,
          shift = util.by_pixel(45, -17.5),
          hr_version = {
            width = 330,
            height = 240,
            shift = util.by_pixel(45.5, -17.5),
            scale = 0.5
          },
        },
        leaves = {
          width = 111,
          height = 112,
          shift = util.by_pixel(7.5, -36),
          hr_version = {
            width = 221,
            height = 224,
            shift = util.by_pixel(7.75, -36),
            scale = 0.5
          },
        },
      },
      { -- i
        trunk = {
          width = 175,
          height = 111,
          shift = util.by_pixel(38.5, -9.5),
          hr_version = {
            width = 352,
            height = 221,
            shift = util.by_pixel(39, -9.25),
            scale = 0.5
          },
        },
        leaves = {
          width = 119,
          height = 110,
          shift = util.by_pixel(-1.5, -27),
          hr_version = {
            width = 238,
            height = 220,
            shift = util.by_pixel(-1, -26.5),
            scale = 0.5
          },
        },
      },
    },
  },
  { -- tree-06
    --addHere-tree06
    type_name = "06",
    drawing_box = {{-0.9, -3.5}, {0.9, 0.6}},
    variations = {
      { -- a
        trunk = {
          width = 178,
          height = 144,
          shift = util.by_pixel(60, -34),
          hr_version = {
            width = 356,
            height = 289,
            shift = util.by_pixel(59.5, -33.75),
            scale = 0.5
          },
        },
        leaves = {
          width = 66,
          height = 97,
          shift = util.by_pixel(19, -46.5),
          hr_version = {
            width = 133,
            height = 195,
            shift = util.by_pixel(19.25, -46.75),
            scale = 0.5
          },
        },
      },
      { -- b
        trunk = {
          width = 188,
          height = 129,
          shift = util.by_pixel(61, -23.5),
          hr_version = {
            width = 375,
            height = 258,
            shift = util.by_pixel(61.25, -23),
            scale = 0.5
          },
        },
        leaves = {
          width = 85,
          height = 92,
          shift = util.by_pixel(17.5, -37),
          hr_version = {
            width = 170,
            height = 186,
            shift = util.by_pixel(18, -37),
            scale = 0.5
          },
        },
      },
      { -- c
        trunk = {
          width = 202,
          height = 107,
          shift = util.by_pixel(52, -12.5),
          hr_version = {
            width = 403,
            height = 214,
            shift = util.by_pixel(52.25, -12.5),
            scale = 0.5
          },
        },
        leaves = {
          width = 89,
          height = 79,
          shift = util.by_pixel(11.5, -25.5),
          hr_version = {
            width = 178,
            height = 158,
            shift = util.by_pixel(11, -25.5),
            scale = 0.5
          },
        },
      },
      { -- d
        trunk = {
          width = 172,
          height = 130,
          shift = util.by_pixel(34, -17),
          hr_version = {
            width = 343,
            height = 259,
            shift = util.by_pixel(34.25, -16.75),
            scale = 0.5
          },
        },
        leaves = {
          width = 75,
          height = 90,
          shift = util.by_pixel(-6.5, -36),
          hr_version = {
            width = 150,
            height = 178,
            shift = util.by_pixel(-6.5, -36),
            scale = 0.5
          },
        },
      },
      { -- e
        trunk = {
          width = 140,
          height = 144,
          shift = util.by_pixel(18, -28),
          hr_version = {
            width = 280,
            height = 287,
            shift = util.by_pixel(18, -28.25),
            scale = 0.5
          },
        },
        leaves = {
          width = 68,
          height = 112,
          shift = util.by_pixel(-10, -44),
          hr_version = {
            width = 137,
            height = 224,
            shift = util.by_pixel(-10.25, -44.5),
            scale = 0.5
          },
        },
      },
      { -- f
        trunk = {
          width = 186,
          height = 136,
          shift = util.by_pixel(31, -36),
          hr_version = {
            width = 371,
            height = 272,
            shift = util.by_pixel(30.75, -36),
            scale = 0.5
          },
        },
        leaves = {
          width = 89,
          height = 114,
          shift = util.by_pixel(-10.5, -46),
          hr_version = {
            width = 177,
            height = 228,
            shift = util.by_pixel(-10.25, -45.5),
            scale = 0.5
          },
        },
      },
      { -- g
        trunk = {
          width = 202,
          height = 133,
          shift = util.by_pixel(43, -34.5),
          hr_version = {
            width = 402,
            height = 268,
            shift = util.by_pixel(43, -35),
            scale = 0.5
          },
        },
        leaves = {
          width = 89,
          height = 114,
          shift = util.by_pixel(-0.5, -44),
          hr_version = {
            width = 177,
            height = 228,
            shift = util.by_pixel(-0.75, -44),
            scale = 0.5
          },
        },
      },
      { -- h
        trunk = {
          width = 173,
          height = 129,
          shift = util.by_pixel(49.5, -34.5),
          hr_version = {
            width = 347,
            height = 258,
            shift = util.by_pixel(49.25, -34.5),
            scale = 0.5
          },
        },
        leaves = {
          width = 71,
          height = 95,
          shift = util.by_pixel(21.5, -43.5),
          hr_version = {
            width = 143,
            height = 190,
            shift = util.by_pixel(21.25, -43),
            scale = 0.5
          },
        },
      },
      { -- i
        trunk = {
          width = 127,
          height = 129,
          shift = util.by_pixel(12.5, -14.5),
          hr_version = {
            width = 253,
            height = 259,
            shift = util.by_pixel(12.75, -14.75),
            scale = 0.5
          },
        },
        leaves = {
          width = 65,
          height = 93,
          shift = util.by_pixel(-10.5, -33.5),
          hr_version = {
            width = 129,
            height = 185,
            shift = util.by_pixel(-10.25, -33.75),
            scale = 0.5
          },
        },
      },
      { -- j
        trunk = {
          width = 136,
          height = 126,
          shift = util.by_pixel(22, -17),
          hr_version = {
            width = 272,
            height = 253,
            shift = util.by_pixel(22, -16.75),
            scale = 0.5
          },
        },
        leaves = {
          width = 67,
          height = 92,
          shift = util.by_pixel(-6.5, -35),
          hr_version = {
            width = 133,
            height = 182,
            shift = util.by_pixel(-6.25, -35),
            scale = 0.5
          },
        },
      },
    },
  },
  { -- tree-07
    --addHere-tree07
    type_name = "07",
    drawing_box = {{-0.9, -3.5}, {0.9, 0.6}},
    variations = {
      { -- a
        trunk = {
          width = 181,
          height = 122,
          shift = util.by_pixel(38.5 + 24, -21),
          hr_version = {
            width = 362,
            height = 244,
            shift = util.by_pixel(39 + 24, -20.5),
            scale = 0.5
          },
        },
        leaves = {
          width = 50,
          height = 83,
          shift = util.by_pixel(-26 + 24, -42.5),
          hr_version = {
            width = 101,
            height = 164,
            shift = util.by_pixel(-26.25 + 24, -42),
            scale = 0.5
          },
        },
      },
      { -- b
        trunk = {
          width = 167,
          height = 120,
          shift = util.by_pixel(14.5 + 24, -36),
          hr_version = {
            width = 335,
            height = 239,
            shift = util.by_pixel(14.75 + 24, -35.75),
            scale = 0.5
          },
        },
        leaves = {
          width = 58,
          height = 91,
          shift = util.by_pixel(-41 + 24, -50.5),
          hr_version = {
            width = 116,
            height = 184,
            shift = util.by_pixel(-41 + 24, -50.5),
            scale = 0.5
          },
        },
      },
      { -- c
        trunk = {
          width = 167,
          height = 128,
          shift = util.by_pixel(8.5 + 24, -47),
          hr_version = {
            width = 334,
            height = 256,
            shift = util.by_pixel(9 + 24, -46.5),
            scale = 0.5
          },
        },
        leaves = {
          width = 67,
          height = 110,
          shift = util.by_pixel(-42.5 + 24, -57),
          hr_version = {
            width = 136,
            height = 220,
            shift = util.by_pixel(-42.5 + 24, -56.5),
            scale = 0.5
          },
        },
      },
      { -- d
        trunk = {
          width = 184,
          height = 158,
          shift = util.by_pixel(25 + 24, -48),
          hr_version = {
            width = 368,
            height = 314,
            shift = util.by_pixel(25.5 + 24, -47.5),
            scale = 0.5
          },
        },
        leaves = {
          width = 47,
          height = 126,
          shift = util.by_pixel(-28.5 + 24, -65),
          hr_version = {
            width = 95,
            height = 252,
            shift = util.by_pixel(-28.75 + 24, -64.5),
            scale = 0.5
          },
        },
      },
      { -- e
        trunk = {
          width = 202,
          height = 143,
          shift = util.by_pixel(48 + 24, -55.5),
          hr_version = {
            width = 405,
            height = 286,
            shift = util.by_pixel(48.25 + 24, -54.5),
            scale = 0.5
          },
        },
        leaves = {
          width = 47,
          height = 132,
          shift = util.by_pixel(-16.5 + 24, -62),
          hr_version = {
            width = 93,
            height = 264,
            shift = util.by_pixel(-16.75 + 24, -61),
            scale = 0.5
          },
        },
      },
      { -- f
        trunk = {
          width = 218,
          height = 135,
          shift = util.by_pixel(57 + 24, -49.5),
          hr_version = {
            width = 435,
            height = 270,
            shift = util.by_pixel(56.75 + 24, -49),
            scale = 0.5
          },
        },
        leaves = {
          width = 62,
          height = 119,
          shift = util.by_pixel(-3 + 24, -57.5),
          hr_version = {
            width = 126,
            height = 240,
            shift = util.by_pixel(-3 + 24, -57.5),
            scale = 0.5
          },
        },
      },
      { -- g
        trunk = {
          width = 213,
          height = 121,
          shift = util.by_pixel(55.5 + 24, -36.5),
          hr_version = {
            width = 426,
            height = 240,
            shift = util.by_pixel(55.5 + 24, -36),
            scale = 0.5
          },
        },
        leaves = {
          width = 61,
          height = 100,
          shift = util.by_pixel(-9.5 + 24, -47),
          hr_version = {
            width = 123,
            height = 199,
            shift = util.by_pixel(-9.75 + 24, -46.75),
            scale = 0.5
          },
        },
      },
      { -- h
        trunk = {
          width = 198,
          height = 121,
          shift = util.by_pixel(50 + 24, -21.5),
          hr_version = {
            width = 397,
            height = 243,
            shift = util.by_pixel(50.25 + 24, -21.25),
            scale = 0.5
          },
        },
        leaves = {
          width = 48,
          height = 85,
          shift = util.by_pixel(-20 + 24, -40.5),
          hr_version = {
            width = 94,
            height = 170,
            shift = util.by_pixel(-20 + 24, -40),
            scale = 0.5
          },
        },
      },
      { -- i
        trunk = {
          width = 169,
          height = 120,
          shift = util.by_pixel(19.5 + 24, -34),
          hr_version = {
            width = 337,
            height = 238,
            shift = util.by_pixel(19.25 + 24, -33.5),
            scale = 0.5
          },
        },
        leaves = {
          width = 55,
          height = 87,
          shift = util.by_pixel(-38.5 + 24, -49.5),
          hr_version = {
            width = 109,
            height = 177,
            shift = util.by_pixel(-38.25 + 24, -49.75),
            scale = 0.5
          },
        },
      },
    },
  },
  { -- tree-08
    --addHere-tree08
    type_name = "08",
    drawing_box = {{-0.9, -3}, {0.9, 0.6}},
    variations = {
      { -- a
        trunk = {
          width = 200,
          height = 140,
          shift = util.by_pixel(55, -34),
          hr_version = {
            width = 399,
            height = 279,
            shift = util.by_pixel(55.75, -33.75),
            scale = 0.5
          },
        },
        leaves = {
          width = 94,
          height = 70,
          shift = util.by_pixel(0, -71),
          hr_version = {
            width = 188,
            height = 141,
            shift = util.by_pixel(0.5, -70.75),
            scale = 0.5
          },
        },
      },
      { -- b
        trunk = {
          width = 213,
          height = 139,
          shift = util.by_pixel(57.5, -30.5),
          hr_version = {
            width = 426,
            height = 277,
            shift = util.by_pixel(57.5, -30.25),
            scale = 0.5
          },
        },
        leaves = {
          width = 102,
          height = 70,
          shift = util.by_pixel(2, -69),
          hr_version = {
            width = 205,
            height = 142,
            shift = util.by_pixel(2.25, -68.5),
            scale = 0.5
          },
        },
      },
      { -- c
        trunk = {
          width = 188,
          height = 136,
          shift = util.by_pixel(65, -36),
          hr_version = {
            width = 377,
            height = 271,
            shift = util.by_pixel(65.75, -35.75),
            scale = 0.5
          },
        },
        leaves = {
          width = 76,
          height = 76,
          shift = util.by_pixel(6, -68),
          hr_version = {
            width = 152,
            height = 152,
            shift = util.by_pixel(6.5, -68),
            scale = 0.5
          },
        },
      },
      { -- d
        trunk = {
          width = 212,
          height = 134,
          shift = util.by_pixel(62, -39),
          hr_version = {
            width = 424,
            height = 267,
            shift = util.by_pixel(62.5, -38.75),
            scale = 0.5
          },
        },
        leaves = {
          width = 93,
          height = 81,
          shift = util.by_pixel(-0.5, -69.5),
          hr_version = {
            width = 187,
            height = 162,
            shift = util.by_pixel(0.25, -68.5),
            scale = 0.5
          },
        },
      },
      { -- e
        trunk = {
          width = 208,
          height = 147,
          shift = util.by_pixel(55, -33.5),
          hr_version = {
            width = 416,
            height = 295,
            shift = util.by_pixel(55, -33.25),
            scale = 0.5
          },
        },
        leaves = {
          width = 95,
          height = 83,
          shift = util.by_pixel(-6.5, -70.5),
          hr_version = {
            width = 189,
            height = 166,
            shift = util.by_pixel(-5.75, -70),
            scale = 0.5
          },
        },
      },
    },
  },
  { -- tree-09
    --addHere-tree09
    type_name = "09",
    drawing_box = {{-0.9, -3.5}, {0.9, 0.6}},
    variations = {
      { -- a
        trunk = {
          width = 243,
          height = 170,
          shift = util.by_pixel(65.5, -37),
          hr_version = {
            width = 487,
            height = 340,
            shift = util.by_pixel(66.25, -36.5),
            scale = 0.5
          },
        },
        leaves = {
          width = 123,
          height = 102,
          shift = util.by_pixel(4.5, -73),
          hr_version = {
            width = 244,
            height = 204,
            shift = util.by_pixel(5, -72.5),
            scale = 0.5
          },
        },
      },
      { -- b
        trunk = {
          width = 208,
          height = 150,
          shift = util.by_pixel(53, -36),
          hr_version = {
            width = 415,
            height = 300,
            shift = util.by_pixel(53.25, -35.5),
            scale = 0.5
          },
        },
        leaves = {
          width = 99,
          height = 86,
          shift = util.by_pixel(-2.5, -69),
          hr_version = {
            width = 197,
            height = 172,
            shift = util.by_pixel(-2.25, -68.5),
            scale = 0.5
          },
        },
      },
      { -- c
        trunk = {
          width = 238,
          height = 167,
          shift = util.by_pixel(56, -37.5),
          hr_version = {
            width = 476,
            height = 333,
            shift = util.by_pixel(56.5, -37.25),
            scale = 0.5
          },
        },
        leaves = {
          width = 113,
          height = 95,
          shift = util.by_pixel(-8.5, -74.5),
          hr_version = {
            width = 225,
            height = 189,
            shift = util.by_pixel(-8.25, -73.75),
            scale = 0.5
          },
        },
      },
      { -- d
        trunk = {
          width = 169,
          height = 116,
          shift = util.by_pixel(45.5, -32),
          hr_version = {
            width = 338,
            height = 233,
            shift = util.by_pixel(46, -31.75),
            scale = 0.5
          },
        },
        leaves = {
          width = 90,
          height = 64,
          shift = util.by_pixel(4, -60),
          hr_version = {
            width = 179,
            height = 126,
            shift = util.by_pixel(4.75, -59.5),
            scale = 0.5
          },
        },
      },
      { -- e
        trunk = {
          width = 202,
          height = 157,
          shift = util.by_pixel(63, -38.5),
          hr_version = {
            width = 403,
            height = 315,
            shift = util.by_pixel(63.25, -38.25),
            scale = 0.5
          },
        },
        leaves = {
          width = 103,
          height = 103,
          shift = util.by_pixel(11.5, -67.5),
          hr_version = {
            width = 205,
            height = 206,
            shift = util.by_pixel(12.25, -67),
            scale = 0.5
          },
        },
      },
    },
  },
  { -- tree-conifer-01
    -- x positive moves image right
    -- y positive moves image down
    type_name = "conifer-01",
    alien_biomes_texture = true,
    drawing_box = {{-0.9, -5.9}, {0.9, 0.8}},
    variations = {
      { -- a
        trunk = {
          width = 1498/5,
          height = 226,
          shift = util.by_pixel(81, -62),
        },
        leaves = {
          width = 339/3,
          height = 164,
          shift = util.by_pixel(11, -84),
        },
      },
      { -- b
        trunk = {
          width = 540/4,
          height = 152,
          shift = util.by_pixel(18, -48),
        },
        leaves = {
          width = 279/3,
          height = 134,
          shift = util.by_pixel(0, -66),
        },
      },
      { -- c
        trunk = {
          width = 1400/4,
          height = 321,
          shift = util.by_pixel(90, -88),
        },
        leaves = {
          width = 534/3,
          height = 258,
          shift = util.by_pixel(4, -123),
        },
      },
    },
  },
  { -- tree-medusa-01
    type_name = "medusa-01",
    alien_biomes_texture = true,
    drawing_box = {{-0.9, -3.9}, {0.9, 0.6}},
    variations = {
      { -- a
        trunk = {
          frame_count = 2,
          width = 254/2,
          height = 100,
          shift = util.by_pixel(30, -22),
        },
        leaves = {
          frame_count = 1,
          width = 67,
          height = 57,
          shift = util.by_pixel(0, -44),
        },
      },
      { -- b
        trunk = {
          frame_count = 2,
            width = 302/2,
            height = 110,
          shift = util.by_pixel(16, -31),
        },
        leaves = {
          frame_count = 1,
          width = 87,
          height = 59,
          shift = util.by_pixel(-16, -58),
        },
      },
      { -- c
        trunk = {
          frame_count = 2,
          width = 232/2,
          height = 110,
          shift = util.by_pixel(24, -10),
        },
        leaves = {
          frame_count = 1,
          width = 72,
          height = 74,
          shift = util.by_pixel(2, -28),
        },
      },
      { -- d
        trunk = {
          frame_count = 2,
          width = 236/2,
          height = 110,
          shift = util.by_pixel(30, -40),
        },
        leaves = {
          frame_count = 1,
          width = 59,
          height = 65,
          shift = util.by_pixel(0, -62),
        },
      },
      { -- e
        trunk = {
          frame_count = 2,
          width = 200/2,
          height = 110,
          shift = util.by_pixel(28, -36),
        },
        leaves = {
          frame_count = 1,
          width = 65,
          height = 81,
          shift = util.by_pixel(8, -52),
        },
      },
    },
  },
}

local tree_models = {}
-- expand variations
for tree_index, tree_type in pairs(tree_types) do
  local type_name = tree_type.type_name
  local tree_variations = {}  -- expanded versions
  local i = 1
  -- lock letter
  for variation_index, variation in ipairs(tree_type.variations) do
    variation.variation_letter = index_to_letter(variation_index)
  end
  -- make sure there are at least 7 variations by duplicating earlier ones
  -- that way if more textures are added later there will be at least 7 in already generated areas
  while #tree_type.variations < 7 do
    i = i + 1
    table.insert(tree_type.variations, table.deepcopy(tree_type.variations[i]))
  end
  for variation_index, variation in ipairs(tree_type.variations) do
    local variation_letter = variation.variation_letter
    local variation_path = type_name .. "/tree-" .. type_name .. "-" .. variation_letter
    local hr_variation_path = type_name .. "/hr-tree-" .. type_name .. "-" .. variation_letter
    local path_start = tree_type.alien_biomes_texture and "__alien-biomes__" or "__base__"
    local newTree = {
      trunk =
      {
        filename = path_start.."/graphics/entity/tree/" .. variation_path .. "-trunk.png",
        flags = { "mipmap" },
        width = variation.trunk.width,
        height =  variation.trunk.height,
        frame_count = variation.trunk.frame_count or 4,
        shift = variation.trunk.shift,
        hr_version = util.table.deepcopy(variation.trunk.hr_version)
      },
      leaves =
      {
        filename = path_start.."/graphics/entity/tree/" .. variation_path .. "-leaves.png",
        flags = { "mipmap" },
        width = variation.leaves.width,
        height = variation.leaves.height,
        frame_count = variation.leaves.frame_count or 3,
        shift = variation.leaves.shift,
        hr_version = util.table.deepcopy(variation.leaves.hr_version)
      },
      leaf_generation =
      {
        type = "create-particle",
        entity_name = "leaf-particle",
        offset_deviation = {{-0.5, -0.5}, {0.5, 0.5}},
        initial_height = 2,
        initial_height_deviation = 1,
        speed_from_center = 0.01
      },
      branch_generation =
      {
        type = "create-particle",
        entity_name = "branch-particle",
        offset_deviation = {{-0.5, -0.5}, {0.5, 0.5}},
        initial_height = 2,
        initial_height_deviation = 2,
        speed_from_center = 0.01,
        frame_speed = 0.1,
        repeat_count = 15
      }
    }
    if newTree.trunk.hr_version then
      newTree.trunk.hr_version.filename = path_start.."/graphics/entity/tree/" .. hr_variation_path .. "-trunk.png"
      newTree.trunk.hr_version.frame_count = variation.trunk.hr_version.frame_count or 4
      newTree.trunk.hr_version.flags = { "mipmap" }
    end
    if newTree.leaves.hr_version then
      newTree.leaves.hr_version.filename = path_start.."/graphics/entity/tree/" .. hr_variation_path .. "-leaves.png"
      newTree.leaves.hr_version.frame_count = variation.leaves.hr_version.frame_count or 3
      newTree.leaves.hr_version.flags = { "mipmap" }
    end
    tree_variations[#tree_variations + 1] = newTree
  end
  tree_type.tree_variations = tree_variations
  tree_models[type_name] = tree_type
end

return tree_models
