#! /usr/bin/env perl
# Make a new color scheme using the data hard-coded here
# SPDX-License-Identifier: MIT

use 5.026001;
use strict;
use warnings;
use POSIX qw( fmod );
use List::Util qw( min max );
use Math::Round qw( nearest );
use Color::Rgb;

# The available formats for color information are
#   -  Common names, including the named colors for CSS files: WhiteSmoke
#   -  Hex codes: f5f5f5 is WhiteSmoke in web colors
#   -  CSS-style hex codes: #f5f5f5 is WhiteSmoke
#   -  RGB color tuples: 245 245 245 is WhiteSmoke. Valid numbers include real
#       numbers, such as 136.3. Range is 0 - 255 inclusive.
#   -  RGB color values as a string: '245,245,235' is WhiteSmoke
#   -  HSL tuples: 0.00 75.00 47.06 is Chocolate
#   -  HSL values as a string: '0.00,75.00,47.06' is Chocolate
#   -  HSV tuples: 218.54 57.81 92.94 is Cornflower Blue
#   -  HSV values as a string: '218.54,57.81,92.94' is Cornflower Blue
#
#   Note that the string values do not include the bracketing information and
#   the HSL/HSV strings, and tuples, do not include the degree or percent markers.
#   The HSL values, in string or tuple format, are reported with Hue in the range
#   of 0 to 360 degrees, Saturation, Value, and Lightness as percentages, in the
#   range of 0 to 100 (the values are already multiplied by 100).
#
#   To use the HSL values in a CSS declaration the extra information will need to
#   be applied. This is slightly easier with the tuple than the string.
#       Using the tuple, @hsv_tuple, the CSS format could be made with
#         $css_hsl = sprintf 'hsl(%.2fdef, %.2f%%, %.2f%%)', @hsl_tuple;
#       Using the string, $hsl_string, the CSS format coule be made with
#         $css_hsl = sprintf 'hsl(%.2fdeg, %.2f%%, %.2f%%)', split ',', $hsl_string
#   Similar treatment is needed to use the return values in other cases as well. Only
#   the results of $colors->rgb2hex($red, $green, $blue, '#') are suitable for direct
#   inclusion in a CSS declaration.



my $colors  = new Color::Rgb(rgb_txt=>'/usr/share/vim/vim82/rgb.txt');

# find the hue from tuple of rgb percentages
# used in conversion to hsl and hsv
sub _rgbf2hue {
    my ($red_factor, $green_factor, $blue_factor) = @_;
    my $hue = 0;
    my $chroma_max = max ($red_factor, $green_factor, $blue_factor);
    my $chroma_min = min ($red_factor, $green_factor, $blue_factor);
    my $chroma_delta = $chroma_max - $chroma_min;
    unless ( 0 == $chroma_delta ) {
        $hue = 60 * ((($red_factor   - $green_factor) / $chroma_delta) + 4) if $chroma_max == $blue_factor;
        $hue = 60 * ((($blue_factor  - $red_factor  ) / $chroma_delta) + 2) if $chroma_max == $green_factor;
        $hue = 60 * ((($green_factor - $blue_factor ) / $chroma_delta) % 6) if $chroma_max == $red_factor;
    }
    return ($hue, $chroma_max, $chroma_min, $chroma_delta);
}

# convert tuple of rgb values to hsv tuple. rgb data in 0-255 format
sub rgb2hsv {
    my ($hue, $chroma_max, $chroma_min, $chroma_delta) = _rgbf2hue( map { $_ / 255 } @_[0..2] );
    my ($sat, $val) = (0, 0);
    $sat = $chroma_delta / $chroma_max  unless 0 == $chroma_max;
    $val = $chroma_max;
    return ($hue, 100 * $sat, 100 * $val) if wantarray;
    return join $_[3] || ',', nearest(.01, $hue), nearest(.001, 100 * $sat), nearest(.001, 100 * $val); 
}

# convert tuple of rgb values to hsl tuple. rgb data in 0-255 format
sub rgb2hsl {
    my ($hue, $chroma_max, $chroma_min, $chroma_delta) = _rgbf2hue( map { $_ / 255 } @_[0..2] );
    my ($sat, $lum) = (0, 0);
    $lum = ($chroma_max + $chroma_min) / 2;
    $sat = $chroma_delta / (1 - abs(2 * $lum - 1)) unless 0 == $chroma_delta;
    return ($hue, 100 * $sat, 100 * $lum) if wantarray;
    return join $_[3] || ',', nearest(.01, $hue), nearest(.001, 100 * $sat), nearest(.001, 100 * $lum); 
}

# convert hue, chroma, minum value into rgb percentage tuple
# Used in converting hsl and hsv to rgb
# Internal use only
sub _hcm2rgbf {
    my ($hue, $chroma, $minum) = @_;
    my ($red_factor, $green_factor, $blue_factor) = ($minum, $minum, $minum);
    my $cross = $chroma * (1 - abs( fmod(($hue / 60), 2) - 1 ));
    if ( 60 > $hue ) {
        $red_factor += $chroma;
        $green_factor += $cross;
    } elsif ( 120 > $hue ) {
        $green_factor += $chroma;
        $red_factor += $cross;
    } elsif ( 180 > $hue ) {
        $green_factor += $chroma;
        $blue_factor += $cross;
    } elsif ( 240 > $hue ) {
        $blue_factor += $chroma;
        $green_factor += $cross;
    } elsif ( 300 > $hue ) {
        $blue_factor += $chroma;
        $red_factor += $cross;
    } else {
        $red_factor += $chroma;
        $blue_factor += $cross;
    }
    return ($red_factor, $green_factor, $blue_factor);
}

# convert hsv tuple into rgb tuple in 0-255 format
sub hsv2rgb {
    my ($hue, $sat, $val) = ($_[0], $_[1]/100, $_[2]/100);
    my $chroma = $val * $sat;
    my $minum = $val - $chroma;
    return map { $_ * 255 } (_hcm2rgbf($hue, $chroma, $minum)) if wantarray;
    return join $_[3] || ',' , map { nearest(.01, $_ * 255) } (_hcm2rgbf($hue, $chroma, $minum));
}

# convert hsl tuple into rgb tuple in 0-255 format
sub hsl2rgb {
    my ($hue, $sat, $lum) = ($_[0], $_[1]/100, $_[2]/100);
    my $chroma = (1 - abs($lum * 2 - 1)) * $sat;
    my $minum = $lum - $chroma / 2;
    return map { $_ * 255 } (_hcm2rgbf($hue, $chroma, $minum)) if wantarray;
    return join $_[3] || ',' , map { nearest(.01, $_ * 255) } (_hcm2rgbf($hue, $chroma, $minum));
}

# blend a single color pair, one opaque and one semi-opaque.
# the supplied pair of color value can be either percent or 0-255, provided
# both are in the same format. The factor is a float between 0 and 1, inclusive.
# The returned value is in the same format, percent or 0-255, as the source.
sub _blend_colors {
    my ($base_color, $overlay_color, $factor) = @_;
    my $new_color = $factor * $overlay_color + (1 - $factor) * $base_color;
    return $new_color;
}

# blend two rgb color tuples with the given opacity for the second color
# the pair of tuples must be in the same format (either percentage or 0-255 formats)
# internally and collectively. Return is a tuple in the same format of
# the resulting color with 100% opacity.
sub add_overlay {
    my (
        $base_red, $base_green, $base_blue,
        $overlay_red, $overlay_green, $overlay_blue,
        $factor
    ) =@_;
    return (
        _blend_colors($base_red, $overlay_red, $factor),
        _blend_colors($base_green, $overlay_green, $factor),
        _blend_colors($base_blue, $overlay_blue, $factor)
    );
}

# Add two overlays, applying the second color as an overlay to the first, 
# the applying the third color as an overlay to the result of the first pair.
# Used to apply a state overlay onto a surface level overlay of the base color.
sub double_overlay {
    my ($base_red, $base_green, $base_blue,
        $overlay_red, $overlay_green, $overlay_blue, $overlay_factor,
        $accent_red, $accent_green, $accent_blue, $accent_factor
    ) =@_;
    return (
        add_overlay(
            add_overlay($base_red, $base_green, $base_blue,
            $overlay_red, $overlay_green, $overlay_blue, $overlay_factor),
        $accent_red, $accent_green, $accent_blue, $accent_factor)
    )
}

sub demo {

    # Converting named colors to available formats
    my $name    = 'BurlyWood';
    say sprintf '%s as HEX code is %s.', $name, $colors->hex($name);
    say sprintf '%s as CSS hex is %s.', $name, $colors->hex($name, '#');
    say sprintf '%s as RGB tuple is [%d %d %d].', $name, $colors->rgb($name);
    say sprintf '%s as RGB string is %s.', $name, $colors->rgb($name, ',');
    say sprintf '%s as HSL tuple is [%.2f %.2f %.2f].', $name, rgb2hsl $colors->rgb($name);
    say sprintf '%s as HSL string is %s.', $name, scalar rgb2hsl $colors->rgb($name);
    say sprintf '%s as HSL string is %s.', $name, scalar rgb2hsl $colors->rgb($name), ":";
    say sprintf '%s as HSV tuple is [%.2f %.2f %.2f].', $name, rgb2hsv $colors->rgb($name);
    say sprintf '%s as HSV string is %s.', $name, scalar rgb2hsv $colors->rgb($name);
    say sprintf '%s as HSV string is %s.', $name, scalar rgb2hsv $colors->rgb($name), ":";

    # Converting hex color codes to available formats
    my $hex_code = '6495ed';
    say sprintf '%s as RGB tuple is [%d %d %d].', $hex_code, $colors->hex2rgb($hex_code);
    say sprintf '%s as RGB string is %s.', $hex_code, $colors->hex2rgb($hex_code, ',');
    say sprintf '%s as HSL tuple is [%.2f %.2f %.2f].', $hex_code, rgb2hsl $colors->hex2rgb($hex_code) ;
    say sprintf '%s as HSL string is %s.', $hex_code, scalar rgb2hsl $colors->hex2rgb($hex_code);
    say sprintf '%s as HSL string is %s.', $hex_code, scalar rgb2hsl $colors->hex2rgb($hex_code), ":";
    say sprintf '%s as HSV tuple is [%.2f %.2f %.2f].', $hex_code, rgb2hsv $colors->hex2rgb($hex_code);
    say sprintf '%s as HSV string is %s.', $hex_code, scalar rgb2hsv $colors->hex2rgb($hex_code);
    say sprintf '%s as HSV string is %s.', $hex_code, scalar rgb2hsv $colors->hex2rgb($hex_code), ":";

    # Converting CSS-style hex color codes to available formats
    my $hex_css = '#123456';
    say sprintf '%s as RGB tuple is [%d %d %d].', $hex_css, $colors->hex2rgb($hex_css);
    say sprintf '%s as RGB string is %s.', $hex_css, $colors->hex2rgb($hex_css, ',');
    say sprintf '%s as HSL tuple is [%.2f %.2f %.2f].', $hex_css, rgb2hsl $colors->hex2rgb($hex_css);
    say sprintf '%s as HSL string is %s.', $hex_css, scalar rgb2hsl $colors->hex2rgb($hex_css);
    say sprintf '%s as HSL string is %s.', $hex_css, scalar rgb2hsl $colors->hex2rgb($hex_css), ":";
    say sprintf '%s as HSV tuple is [%.2f %.2f %.2f].', $hex_css, rgb2hsv $colors->hex2rgb($hex_css);
    say sprintf '%s as HSV tuple is %s.', $hex_css, scalar rgb2hsv $colors->hex2rgb($hex_css);
    say sprintf '%s as HSV tuple is %s.', $hex_css, scalar rgb2hsv $colors->hex2rgb($hex_css), ":";

    # Converting RGB tuples (0-255) into available formats
    my @rgb_tuple = (3, 218, 198);
    say sprintf 'RGB tuple [%d %d %d] as hex code is %s.', @rgb_tuple, $colors->rgb2hex(@rgb_tuple);
    say sprintf 'RGB tuple [%d %d %d] as CSS hex is %s.', @rgb_tuple, $colors->rgb2hex(@rgb_tuple, "#");
    say sprintf 'RGB tuple [%d %d %d] as HSL tuple is [%.2f %.2f %.2f].', @rgb_tuple, rgb2hsl @rgb_tuple;
    say sprintf 'RGB tuple [%d %d %d] as HSL string is %s', @rgb_tuple, scalar rgb2hsl @rgb_tuple;
    say sprintf 'RGB tuple [%d %d %d] as HSL string is %s', @rgb_tuple, scalar rgb2hsl @rgb_tuple, ":";
    say sprintf 'RGB tuple [%d %d %d] as HSV tuple is [%.2f %.2f %.2f].', @rgb_tuple, rgb2hsv @rgb_tuple;
    say sprintf 'RGB tuple [%d %d %d] as HSV string is %s', @rgb_tuple, scalar rgb2hsv @rgb_tuple;
    say sprintf 'RGB tuple [%d %d %d] as HSV string is %s', @rgb_tuple, scalar rgb2hsv @rgb_tuple, ":";

    # Converting RGB strings, '172,0,32', into available formats
    my $rgb_string = '176,0,32';
    say sprintf 'RGB string %s as hex code is %s.', $rgb_string, $colors->rgb2hex(split ',', $rgb_string);
    say sprintf 'RGB string %s as CSS hex is %s.', $rgb_string, $colors->rgb2hex(split(',', $rgb_string), "#");
    say sprintf 'RGB string %s as HSL tuple is [%.2f %.2f %.2f].', $rgb_string, rgb2hsl split ',', $rgb_string;
    say sprintf 'RGB string %s as HSL string is %s', $rgb_string, scalar rgb2hsl split ',', $rgb_string;
    say sprintf 'RGB string %s as HSL string is %s', $rgb_string, scalar rgb2hsl split(',', $rgb_string), ":";
    say sprintf 'RGB string %s as HSV tuple is [%.2f %.2f %.2f].', $rgb_string, rgb2hsv split ',', $rgb_string;
    say sprintf 'RGB string %s as HSV string is %s', $rgb_string, scalar rgb2hsv split ',', $rgb_string;
    say sprintf 'RGB string %s as HSV string is %s', $rgb_string, scalar rgb2hsv split(',', $rgb_string), ":";

    # Converting HSL tuples into available formats
    my @hsl_tuple = (262,52,47);
    say sprintf 'HSL tuple [%.f %.f %.f] as hex code is %s.', @hsl_tuple, $colors->rgb2hex(hsl2rgb @hsl_tuple);
    say sprintf 'HSL tuple [%.f %.f %.f] as CSS hex is %s.', @hsl_tuple, $colors->rgb2hex(hsl2rgb @hsl_tuple, '#');
    say sprintf 'HSL tuple [%.f %.f %.f] as RGB tuple is [%.2f %.2f %.2f.', @hsl_tuple, (hsl2rgb @hsl_tuple);
    say sprintf 'HSL tuple [%.f %.f %.f] as RGB string is %s.', @hsl_tuple, scalar hsl2rgb @hsl_tuple;
    say sprintf 'HSL tuple [%.f %.f %.f] as RGB string is %s.', @hsl_tuple, scalar hsl2rgb @hsl_tuple, ':';
    say sprintf 'HSL tuple [%.f %.f %.f] as HSV tuple is [%.2f %.2f %.2f.', @hsl_tuple, rgb2hsv hsl2rgb @hsl_tuple;
    say sprintf 'HSL tuple [%.f %.f %.f] as HSV string is %s.', @hsl_tuple, scalar rgb2hsv hsl2rgb @hsl_tuple;
    say sprintf 'HSL tuple [%.f %.f %.f] as HSV string is %s.', @hsl_tuple, scalar rgb2hsv hsl2rgb @hsl_tuple, ':';

    # Converting HSL strings into available formats
    my $hsl_string = '262,52,47';
    say sprintf 'HSL string  %s as hex code is %s.', $hsl_string, $colors->rgb2hex(hsl2rgb split ',', $hsl_string);
    say sprintf 'HSL string  %s as CSS hex is %s.', $hsl_string, $colors->rgb2hex(hsl2rgb split(',', $hsl_string), '#');
    say sprintf 'HSL string  %s as RGB tuple is [%.2f %.2f %.2f.', $hsl_string, hsl2rgb split ',', $hsl_string;
    say sprintf 'HSL string  %s as RGB string is %s.', $hsl_string, scalar hsl2rgb split ',', $hsl_string;
    say sprintf 'HSL string  %s as RGB string is %s.', $hsl_string, scalar hsl2rgb split(',', $hsl_string), ':' ;
    say sprintf 'HSL string  %s as HSV tuple is [%.2f %.2f %.2f.', $hsl_string, rgb2hsv hsl2rgb split ',', $hsl_string;
    say sprintf 'HSL string  %s as HSV string is %s.', $hsl_string, scalar rgb2hsv hsl2rgb split ',', $hsl_string;
    say sprintf 'HSL string  %s as HSV string is %s.', $hsl_string, scalar rgb2hsv hsl2rgb split(',', $hsl_string), ':';

    # Converting HSV tuples into available formats
    my @hsv_tuple = (329,78,15);
    say sprintf 'HSV tuple [%.f %.f %.f] as hex code is %s.', @hsv_tuple, $colors->rgb2hex(hsv2rgb @hsv_tuple );
    say sprintf 'HSV tuple [%.f %.f %.f] as CSS hex is %s.', @hsv_tuple, $colors->rgb2hex(hsv2rgb @hsv_tuple , '#');
    say sprintf 'HSV tuple [%.f %.f %.f] as RGB tuple is [%.2f %.2f %.2f.', @hsv_tuple, hsv2rgb @hsv_tuple;
    say sprintf 'HSV tuple [%.f %.f %.f] as RGB string is %s.', @hsv_tuple, scalar hsv2rgb @hsv_tuple;
    say sprintf 'HSV tuple [%.f %.f %.f] as RGB string is %s.', @hsv_tuple, scalar hsv2rgb @hsv_tuple, ':';
    say sprintf 'HSV tuple [%.f %.f %.f] as HSL tuple is [%.2f %.2f %.2f.', @hsv_tuple, rgb2hsl hsv2rgb @hsv_tuple;
    say sprintf 'HSV tuple [%.f %.f %.f] as HSL string is %s.', @hsv_tuple, scalar rgb2hsl hsv2rgb @hsv_tuple;
    say sprintf 'HSV tuple [%.f %.f %.f] as HSL string is %s.', @hsv_tuple, scalar rgb2hsl hsv2rgb @hsv_tuple, ':';

    # Converting HSL strings into available formats
    my $hsv_string = '329,78,15';
    say sprintf 'HSV string  %s as hex code is %s.', $hsv_string, $colors->rgb2hex(hsv2rgb split ',', $hsv_string);
    say sprintf 'HSV string  %s as CSS hex is %s.', $hsv_string, $colors->rgb2hex(hsv2rgb split(',', $hsv_string), '#');
    say sprintf 'HSV string  %s as RGB tuple is [%.2f %.2f %.2f.', $hsv_string, hsv2rgb split ',', $hsv_string;
    say sprintf 'HSV string  %s as RGB string is %s.', $hsv_string, scalar hsv2rgb split ',', $hsv_string ;
    say sprintf 'HSV string  %s as RGB string is %s.', $hsv_string, scalar hsv2rgb split(',', $hsv_string), ':';
    say sprintf 'HSV string  %s as HSL tuple is [%.2f %.2f %.2f.', $hsv_string, rgb2hsl hsv2rgb split ',', $hsv_string;
    say sprintf 'HSV string  %s as HSL string is %s.', $hsv_string, scalar rgb2hsl hsv2rgb split ',', $hsv_string;
    say sprintf 'HSV string  %s as HSL string is %s.', $hsv_string, scalar rgb2hsl hsv2rgb split(',', $hsv_string), ':';

    # Adding a semi-opaque overlay of some color to a solid base color
    # such as to create elevations in Material UI themes
    my ($base_hex, $cover_hex, $cover_rate, $second_hex, $second_rate) = ('#663399','#fafafa', 0.13, '00d000', 0.18);
    my @base_rgb_tuple = $colors->hex2rgb($base_hex);
    my @cover_rgb_tuple = $colors->hex2rgb($cover_hex);
    my @surface_rgb_tuple = add_overlay @base_rgb_tuple, @cover_rgb_tuple, $cover_rate;
    my $surface_css_hex = $colors->rgb2hex(@surface_rgb_tuple, '#');
    say sprintf 'Base color of %s with an overlay of %s as %.4f opacity is %s.',
        $base_hex, $cover_hex, $cover_rate, $surface_css_hex;

    # Adding a pair of semi-opaque overlays, in steps, to a solid base color
    # such as to add an action state to an elevated surface in Material UI themes
    my @second_rgb_tuple = $colors->hex2rgb($second_hex);
    my @state_rgb_tuple = double_overlay @base_rgb_tuple, @cover_rgb_tuple, $cover_rate, @second_rgb_tuple, $second_rate;
    my $state_css_hex = $colors->rgb2hex(@state_rgb_tuple, '#');
    say sprintf 'Adding a second overlay of %s at %.4f opacity is %s.',
        $second_hex, $second_rate, $state_css_hex;
}

