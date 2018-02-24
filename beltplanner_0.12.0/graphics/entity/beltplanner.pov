#version 3.7;

//this doesn't need to be distributed, but maybe it's interesting for someone, so why not

global_settings
{
    assumed_gamma 1.2
}

camera
{
    orthographic
    location <0.75, 6.0, -4.0>
    look_at  <0.75, 0.0,  0.0>
    angle 20
}

light_source
{
    <-4.0, 3.0, 0.0>
    color rgb 1
    parallel point_at 0
}

#macro cut_plane(rot)
plane
{
    <4.0, -1.0, 0.0>, -0.375
    rotate <0.0, rot, 0.0>
}
#end

difference
{
    box { <0.5, 0.5, 0.5>, <-0.5, -0.5, -0.5> }
    object { cut_plane(  0) }
    object { cut_plane( 90) }
    object { cut_plane(180) }
    object { cut_plane(270) }
    scale <1.0, 0.5, 1.0>
    texture
    {
        normal { marble turbulence .8 scale .25 }
        pigment
        {
            marble
            color_map
            {
                [0.0  color rgb <0.7, 0.5, 0.0>]
                [0.45 color rgb <0.7, 0.5, 0.0>]
                [0.45 color rgb <0.15, 0.15, 0.15>]
                [1.0  color rgb <0.15, 0.15, 0.15>]
            }
            scale .24
            rotate <0, 20, 60>
            translate <0.25, 0.0, 0.0>
        }
    }
}

#local pole_texture = texture
{
    normal { marble turbulence .8 scale .5 rotate <0, 0, 60> }
    pigment { color rgb <0.5, 0.5, 0.5> }
}

#macro pole(xlat)
cylinder
{
    <0.0, 0.0, 0.0>,
    <0.0, 1.1, 0.0>,
    0.05
    translate xlat
    texture { pole_texture }
}
#end

#local pole_offset = 0.125;
#local pole_translation = <pole_offset, 0.0, pole_offset>;

object { pole(pole_translation) }
object { pole(-pole_translation) }

#local h = 0.5;
#local len = 0.4;

cylinder
{
    pole_translation, -pole_translation
    0.025
    translate <0.0, h, 0.0>
    texture { pole_texture }
}

cylinder
{
    pole_translation+<0.0, len, 0.0>, -pole_translation
    0.025
    translate <0.0, h, 0.0>
    texture { pole_texture }
}

cylinder
{
    pole_translation, -pole_translation
    0.025
    translate <0.0, h+len, 0.0>
    texture { pole_texture }
}

#ifndef(NO_GROUND)
plane
{
    y,
    -0.25
    pigment { color rgb 1 }
}
#end
