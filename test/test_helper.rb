# encoding: utf-8

major, minor, patch = RUBY_VERSION.split('.')
$KCODE = "U" if major.to_i == 1 && minor.to_i < 9

require 'test/unit'
require File.expand_path('../../lib/me2text', __FILE__)


