#! /usr/bin/env perl
# Make a new color scheme using the data hard-coded here
# SPDX-License-Identifier: MIT

use 5.026001;
use strict;
use warnings;
use POSIX qw( fmod );
use List::Util qw( min max );
use Color::Rgb;

my $colors  = new Color::Rgb(rgb_txt=>'/usr/share/vim/vim82/rgb.txt');

my $name    = 'RebeccaPurple';
my @name_as_rgb_set = $colors->rgb($name);
my $name_as_rgb_str = $colors->rgb($name, ',');
my $name_as_hex_plain  = $colors->hex($name);
my $name_as_hex_css = $colors->hex($name, '#');

my $hex_code = 'bb86fc';
my @hex_code_as_rgb_set = $colors->hex2rgb($hex_code);
my $hex_code_as_rgb_str = $colors->hex2rgb($hex_code, ',');

my $hex_css = '#121212';
my @hex_css_as_rgb_set = $colors->hex2rgb($hex_css);
my $hex_css_as_rgb_str = $colors->hex2rgb($hex_css, ',');

my @rgb_values = (3, 218, 198);
my $rgb_values_as_hex_code = $colors->rgb2hex(@rgb_values);
my $rgb_values_as_hex_css = $colors->rgb2hex(@rgb_values, '#');

my $rgb_string = '176,0,32';
my $rgb_string_as_hex_code = $colors->rgb2hex(split ',', $rgb_string);
my $rgb_string_as_hex_css = $colors->rgb2hex(split(',', $rgb_string), '#');

sub rgbf2hue {
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

sub rgb2hsv {
    my ($hue, $chroma_max, $chroma_min, $chroma_delta) = rgbf2hue( map { $_ / 255 } @_ );
    my ($sat, $val) = (0, 0);
    $sat = $chroma_delta / $chroma_max  unless 0 == $chroma_max;
    $val = $chroma_max;
    return ($hue, 100 * $sat, 100 * $val);
}

sub rgb2hsl {
    my ($hue, $chroma_max, $chroma_min, $chroma_delta) = rgbf2hue( map { $_ / 255 } @_ );
    my ($sat, $lum) = (0, 0);
    $lum = ($chroma_max + $chroma_min) / 2;
    $sat = $chroma_delta / (1 - abs(2 * $lum - 1)) unless 0 == $chroma_delta;
    return ($hue, 100 * $sat, 100 * $lum);
}

sub hcm2rgbf {
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

sub hsv2rgb {
    my ($hue, $sat, $val) = ($_[0], $_[1]/100, $_[2]/100);
    my $chroma = $val * $sat;
    my $minum = $val - $chroma;
    return map { $_ * 255 } (hcm2rgbf ($hue, $chroma, $minum));
}

sub hsl2rgb {
    my ($hue, $sat, $lum) = ($_[0], $_[1]/100, $_[2]/100);
    my $chroma = (1 - abs($lum * 2 - 1)) * $sat;
    my $minum = $lum - $chroma / 2;
    return map { $_ * 255 } (hcm2rgbf ($hue, $chroma, $minum));
}

my @hsv_list = rgb2hsv(@rgb_values);
my @rgb_list = hsv2rgb(@hsv_list); 
my $rgb_return = $colors->rgb2hex(@rgb_list, "#");

my @hsl_list = rgb2hsl(@rgb_values);
@rgb_list = hsl2rgb(@hsl_list); 
$rgb_return = $colors->rgb2hex(@rgb_list, "#");




