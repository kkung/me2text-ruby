# encoding: utf-8

require File.expand_path('../test_helper', __FILE__)

class Me2TextTest < Test::Unit::TestCase  
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
      text = test[0]
      expect = test[1]
      result = Me2Text.me2text(text, :html)
      if expect != result
        flunk "TEXT:   #{text}\n" +
              "EXPECT: #{expect}\n" +
              "RESULT: #{result}\n"
      end
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
      text = test[0]
      expect = test[1]
      result = Me2Text.me2text(text, :html, :allow_line_break => true)
      if expect != result
        flunk "TEXT:   #{text.inspect}\n" +
              "EXPECT: #{expect}\n" +
              "RESULT: #{result}\n"
      end
    end 
  end
end

