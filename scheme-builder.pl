#! /usr/bin/env perl
# Make a new color scheme using the data hard-coded here
# SPDX-License-Identifier: MIT

use 5.026001;
use strict;
use warnings;
use Color::Rgb;

my $colors  = new Color::Rgb(rgb_txt=>'/usr/share/vim/vim82/rgb.txt');

my $name    = 'RebeccaPurple';
my @name_as_rgb_set = $colors->rgb($name);
my $name_as_rgb_str = $colors->rgb($name, ',');
my $name_as_hex_plain  = $colors->hex($name);
my $name_as_hex_css = $colors->hex($name, '#');

my $hex_code = '336699';
my @hex_code_as_rgb_set = $colors->hex2rgb($hex_code);
my $hex_code_as_rgb_str = $colors->hex2rgb($hex_code, ',');

my $hex_css = '#121212';
my @hex_css_as_rgb_set = $colors->hex2rgb($hex_css);
my $hex_css_as_rgb_str = $colors->hex2rgb($hex_css, ',');

my @rgb_values = (207, 102, 121);
my $rgb_values_as_hex_code = $colors->rgb2hex(@rgb_values);
my $rgb_values_as_hex_css = $colors->rgb2hex(@rgb_values, '#');

my $rgb_string = '176,0,32';
my $rgb_string_as_hex_code = $colors->rgb2hex(split ',', $rgb_string);
my $rgb_string_as_hex_css = $colors->rgb2hex(split(',', $rgb_string), '#');

