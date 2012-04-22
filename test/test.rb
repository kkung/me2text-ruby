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

  def test_emphasis
    cases = [
      ['...', '...',  "…"],      
      
      ['안녕"하세":http://me2day.net 요', '안녕',     "<em>안녕</em><a href='http://me2day.net'>하세</a>요"],
      ['안녕"하세":http://me2day.net 요', '안녕하',    "<em>안녕</em><a href='http://me2day.net'><em>하</em>세</a>요"], 
      ['안녕"하세":http://me2day.net 요', '하',      "안녕<a href='http://me2day.net'><em>하</em>세</a>요"],
      ['안녕"하세":http://me2day.net 요', '세요',     "안녕<a href='http://me2day.net'>하<em>세</em></a><em>요</em>"],
      ['안녕"하세":http://me2day.net 요', '녕하세요',   "안<em>녕</em><a href='http://me2day.net'><em>하세</em></a><em>요</em>"],
      ['안녕"&세":http://me2day.net 요', '녕&세요',   "안<em>녕</em><a href='http://me2day.net'><em>&amp;세</em></a><em>요</em>"],

      ['"안녕하":http://me2day.net 세요', '안녕',     "<a href='http://me2day.net'><em>안녕</em>하</a>세요"],
      ['"안녕하":http://me2day.net 세요', '안녕하',    "<a href='http://me2day.net'><em>안녕하</em></a>세요"], 
      ['"안녕하":http://me2day.net 세요', '녕하세',    "<a href='http://me2day.net'>안<em>녕하</em></a><em>세</em>요"],
      ['"안녕하":http://me2day.net 세요', '하세요',    "<a href='http://me2day.net'>안녕<em>하</em></a><em>세요</em>"],
      ['"안녕하":http://me2day.net 세요', '세요',     "<a href='http://me2day.net'>안녕하</a><em>세요</em>"],
      ['"안녕하":http://me2day.net 세요', '요',      "<a href='http://me2day.net'>안녕하</a>세<em>요</em>"],
      ['"안녕하":http://me2day.net 세&', '&',      "<a href='http://me2day.net'>안녕하</a>세<em>&amp;</em>"],

      ['안녕"하세요":http://me2day.net', '안', "<em>안</em>녕<a href='http://me2day.net'>하세요</a>"],
      ['안녕"하세요":http://me2day.net', '안녕', "<em>안녕</em><a href='http://me2day.net'>하세요</a>"], 
      ['안녕"하세요":http://me2day.net', '녕하', "안<em>녕</em><a href='http://me2day.net'><em>하</em>세요</a>"],
      ['안녕"하세요":http://me2day.net', '녕하세요', "안<em>녕</em><a href='http://me2day.net'><em>하세요</em></a>"],
      ['안녕"하세요":http://me2day.net', '하세요', "안녕<a href='http://me2day.net'><em>하세요</em></a>"],
      ['안녕"하세요":http://me2day.net', '세요', "안녕<a href='http://me2day.net'>하<em>세요</em></a>"],
      ['안녕"하세요":http://me2day.net', '요', "안녕<a href='http://me2day.net'>하세<em>요</em></a>"],
      ['안녕"하세&":http://me2day.net', '&', "안녕<a href='http://me2day.net'>하세<em>&amp;</em></a>"],
      
      ['안녕"하세요":http://me2day.net  미투"데이":http://me2day.net/sumanpark?hello=world 입니다', '안',          "<em>안</em>녕<a href='http://me2day.net'>하세요</a> 미투<a href='http://me2day.net/sumanpark?hello=world'>데이</a>입니다"],
      ['안녕"하세요":http://me2day.net  미투"데이":http://me2day.net/sumanpark?hello=world 입니다', '안녕',         "<em>안녕</em><a href='http://me2day.net'>하세요</a> 미투<a href='http://me2day.net/sumanpark?hello=world'>데이</a>입니다"],
      ['안녕"하세요":http://me2day.net  미투"데이":http://me2day.net/sumanpark?hello=world 입니다', '녕하세',        "안<em>녕</em><a href='http://me2day.net'><em>하세</em>요</a> 미투<a href='http://me2day.net/sumanpark?hello=world'>데이</a>입니다"],
      ['안녕"하세요":http://me2day.net  미투"데이":http://me2day.net/sumanpark?hello=world 입니다', '녕하세요',       "안<em>녕</em><a href='http://me2day.net'><em>하세요</em></a> 미투<a href='http://me2day.net/sumanpark?hello=world'>데이</a>입니다"],
      ['안녕"하세요":http://me2day.net  미투"데이":http://me2day.net/sumanpark?hello=world 입니다', '녕하세요 미',     "안<em>녕</em><a href='http://me2day.net'><em>하세요</em></a><em> 미</em>투<a href='http://me2day.net/sumanpark?hello=world'>데이</a>입니다"],
      ['안녕"하세요":http://me2day.net  미투"데이":http://me2day.net/sumanpark?hello=world 입니다', '녕하세요 미투',    "안<em>녕</em><a href='http://me2day.net'><em>하세요</em></a><em> 미투</em><a href='http://me2day.net/sumanpark?hello=world'>데이</a>입니다"],
      ['안녕"하세요":http://me2day.net  미투"데이":http://me2day.net/sumanpark?hello=world 입니다', '녕하세요 미투데',   "안<em>녕</em><a href='http://me2day.net'><em>하세요</em></a><em> 미투</em><a href='http://me2day.net/sumanpark?hello=world'><em>데</em>이</a>입니다"],
      ['안녕"하세요":http://me2day.net  미투"데이":http://me2day.net/sumanpark?hello=world 입니다', '녕하세요 미투데이',  "안<em>녕</em><a href='http://me2day.net'><em>하세요</em></a><em> 미투</em><a href='http://me2day.net/sumanpark?hello=world'><em>데이</em></a>입니다"],
      ['안녕"하세요":http://me2day.net  미투"데이":http://me2day.net/sumanpark?hello=world 입니다', '녕하세요 미투데이입', "안<em>녕</em><a href='http://me2day.net'><em>하세요</em></a><em> 미투</em><a href='http://me2day.net/sumanpark?hello=world'><em>데이</em></a><em>입</em>니다"],
      ['안녕"하세요":http://me2day.net  미투"데이":http://me2day.net/sumanpark?hello=world 입니다', '요 미',        "안녕<a href='http://me2day.net'>하세<em>요</em></a><em> 미</em>투<a href='http://me2day.net/sumanpark?hello=world'>데이</a>입니다"],
      ['안녕"하세요":http://me2day.net  미투"데이":http://me2day.net/sumanpark?hello=world 입니다', '요 미투데',      "안녕<a href='http://me2day.net'>하세<em>요</em></a><em> 미투</em><a href='http://me2day.net/sumanpark?hello=world'><em>데</em>이</a>입니다"],
      ['안녕"하세요":http://me2day.net  미투"데이":http://me2day.net/sumanpark?hello=world 입니다', '요 미투데이입니다',  "안녕<a href='http://me2day.net'>하세<em>요</em></a><em> 미투</em><a href='http://me2day.net/sumanpark?hello=world'><em>데이</em></a><em>입니다</em>"],
      ['안녕"하세요":http://me2day.net  미투"&이":http://me2day.net/sumanpark?hello=world 입니다', '요 미투&이입니다',  "안녕<a href='http://me2day.net'>하세<em>요</em></a><em> 미투</em><a href='http://me2day.net/sumanpark?hello=world'><em>&amp;이</em></a><em>입니다</em>"],
      [
        '안녕"하세요":http://me2day.net  미투"데이":http://me2day.net/sumanpark?hello=world 입니다', 
        ['안녕', '안녕하', '미', '미투', '이입니', '이입니다'],
        "<em>안녕</em><a href='http://me2day.net'><em>하</em>세요</a> <em>미투</em><a href='http://me2day.net/sumanpark?hello=world'>데<em>이</em></a><em>입니다</em>"
      ],
      [
        'ABcde fGHi JKLmn', 
        ['ab', 'de f', 'hi j', 'klm'],
        "<em>AB</em>c<em>de f</em>G<em>Hi J</em><em>KLm</em>n"
      ],
      # 시작하는 단어와 중간에서 분기되는 경우
      [
        'me2mobile me2book',
        ['me2', 'mobile'],
        "<em>me2</em><em>mobile</em> <em>me2</em>book"
      ],
      [
        'abc"de":http://me2day.net  fghijk',
        ['abcde fi', 'abcde fg'],
        "<em>abc</em><a href='http://me2day.net'><em>de</em></a><em> fg</em>hijk"
      ]
    ]

    cases.each_with_index do |test, index|
      text = test[0]
      emp = test[1]
      expect = test[2]

      result = Me2Text.me2text(text, :html, :emphasis => emp)
      if expect != result
        flunk "TEXT:   #{text}\n" +
              "EMP:    #{emp}\n" +
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

