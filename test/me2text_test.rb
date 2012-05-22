# -*- encoding: utf-8 -*-

require File.expand_path('../test_helper', __FILE__)

class Me2TextTest < Test::Unit::TestCase

  if RUBY_VERSION < '1.9'
    def test_encoding
      #'안녕?' in EUC_KR
      invalid_text = "\xBE\xC8\xB3\xE7?"
      
      assert_raise ArgumentError do
        Me2Text.me2text(invalid_text)
      end

      assert_nothing_raised ArgumentError do
        require 'iconv'
        Me2Text.me2text(Iconv.conv('UTF-8', 'EUC-KR', invalid_text))
      end
    end
  else
    def test_encoding
      #'안녕?' in EUC_KR
      invalid_text = "\xBE\xC8\xB3\xE7?"
      
      assert_raise ArgumentError do
        Me2Text.me2text(invalid_text)
      end

      assert_nothing_raised ArgumentError do
        Me2Text.me2text(invalid_text.force_encoding(Encoding::EUC_KR).encode(Encoding::UTF_8))
      end
    end
  end  

  def test_to_html
    cases = [
      # 일반 텍스트
      ['안녕하세요. 미투데이입니다.', '안녕하세요. 미투데이입니다.'],
      ['"안녕하세요." 미투데이입니다.', '“안녕하세요.” 미투데이입니다.'],
      ['안녕하세요...(C)(R)(TM)-- 미투데이입니다', "안녕하세요…©®™— 미투데이입니다"],

      # html 이스케이프
      ['안녕하세요. <br /> 미투데이입니다.', '안녕하세요. &lt;br /&gt; 미투데이입니다.'],
      ['안녕하세요. &nbsp;미투데이입니다.', '안녕하세요. &amp;nbsp;미투데이입니다.'],

      # 링크 문법
      ['"안녕하세요":http://me2day.net . 미투데이입니다.', '<a href=\'http://me2day.net\'>안녕하세요</a>. 미투데이입니다.'],
      ['안녕"하세요":http://me2day.net . 미투데이입니다.', '안녕<a href=\'http://me2day.net\'>하세요</a>. 미투데이입니다.'],
      ['안녕하세요. "미투데이입니다.":http://me2day.net', '안녕하세요. <a href=\'http://me2day.net\'>미투데이입니다.</a>'],

      # 키워드 문법
      ['[안녕하세요]. 미투데이입니다.', '[안녕하세요]. 미투데이입니다.'],

      # 따옴표 이스케이프한 경우 
      ['"\\"안녕하세요\\"":http://me2day.net . 미투데이입니다.', '<a href=\'http://me2day.net\'>“안녕하세요”</a>. 미투데이입니다.'],

      # 컨트롤 문자 strip
      ["\000안녕하세요. 미투데이입니다.", '안녕하세요. 미투데이입니다.']
    ]

    cases.each_with_index do |test, index|
      assert_equal test[1], Me2Text.me2text(test[0], :html)
    end 
  end

  def test_strip_linebreak
    cases = [
      ["안녕하세요.\n미투데이입니다.", '안녕하세요.<br />미투데이입니다.'],
      ["안녕하세요.\r미투데이입니다.", '안녕하세요.<br />미투데이입니다.'],
      ["안녕하세요.\r\n미투데이입니다.", '안녕하세요.<br />미투데이입니다.'],
      ["안녕하세요.\n\r미투데이입니다.", '안녕하세요.<br /><br />미투데이입니다.'],
    ]

    cases.each_with_index do |test, index|
      assert_equal test[1], Me2Text.me2text(test[0], :html, :allow_line_break => true)
    end 
  end
end

