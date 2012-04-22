# encoding: utf-8

major, minor, patch = RUBY_VERSION.split('.')
if major.to_i == 1 && minor.to_i > 8
  raise("me2text는 ruby 1.9 이상은 현재 지원하지 않습니다.")
else
  # Ruby 1.8 $KCODE check.
  unless $KCODE[0].chr =~ /u/i
    raise("me2text를 사용하기 위해서는 $KCODE 변수를 'UTF8' 또는 'u'로 지정해야 합니다.") 
  end
end

$:.push(File.expand_path("..", __FILE__))

module Me2Text
end

require 'me2text/version'
require 'me2text/me2text'

