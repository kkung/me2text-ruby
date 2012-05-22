# -*- encoding: utf-8 -*-

require 'me2text/token'

# Public: me2text 변환 메소드 제공한다.
#
# Examples
#
#    require 'me2text'
#    
#    str = 'me2text는 "미투데이(TM)":http://me2day.net 의 글/댓글 작성 규칙이다.'
#    Me2Text.me2text(str)
#    # => me2text는 <a href='http://me2day.net'>미투데이™"</a>의 글/댓글 작성 규칙이다.
module Me2Text
  class << self
    # me2text(`text`)를 HTML로 변환한다.
    #
    # text - 변환할 me2text 형식의 문자열
    # options - 다음과 같은 옵션을 지원한다. :
    #     :symbolize - 특정 순서의 문자열을 UNICODE의 해당 심볼로 변환한다. 
    #         지정하지 않는 경우 `true`.
    #     :open_new_window - +:html+ 형식으로 변환시 link에 대해 클릭하면 새 창으로 열릴 
    #         수 있도록 `<a>` 태그에 `target='_blank'`를 삽입한다. 
    #         지정하지 않는 경우 `false`.
    #     :allow_line_break - 라인브레이크를 허용한다. `:html` 로 변환시 라인브레이크는 
    #                         `<br />` 태그로 변환된다. 지정하지 않는 경우 `false`. 
    #     :limit - 변환 결과의 글자수를 제한한다. `:limit`에는 숫자를 지정하며 변환 결과는 
    #              지정된 글자 수 까지만 변환된다.
    #     :link_handler - 문자열에 나타나는 각 링크에 대해 지정된 block이 호출된다.
    def to_html(text, options = {})
      me2text(text, :html, options)
    end

    # me2text(+text+)를 평문(plain text)로 변환한다.
    #
    # text - 변환할 me2text 형식의 문자열
    # options - 다음과 같은 옵션을 지원한다. :
    #     :symbolize - 특정 순서의 문자열을 UNICODE의 해당 심볼로 변환한다. 
    #         지정하지 않는 경우 `true`.
    #     :allow_line_break - 라인브레이크를 허용한다. `:html` 로 변환시 라인브레이크는 
    #                         `<br />` 태그로 변환된다. 지정하지 않는 경우 `false`. 
    #     :limit - 변환 결과의 글자수를 제한한다. `:limit`에는 숫자를 지정하며 변환 결과는 
    #              지정된 글자 수 까지만 변환된다.
    #     :link_handler - 문자열에 나타나는 각 링크에 대해 지정된 block이 호출된다.
    def to_text(text, options = {})
      me2text(text, :text, options)
    end

    # me2text(`text`)를 지정한 형식(`format`)으로 변환한다.
    #
    # text - 변환할 me2text 형식의 문자열
    # format - 변환 형식을 지정한다. `:html`, `:text` 중 하나를 지정하며 
    #     지정하지 않은 경우 +:html+ 이 지정된다. `:html`은 HTML 형식으로 변환하며 
    #     +:text+는 평문(plain text)으로 변환한다.
    # options - 다음과 같은 옵션을 지원한다. :
    #     :symbolize - 특정 순서의 문자열을 UNICODE의 해당 심볼로 변환한다. 
    #         지정하지 않는 경우 `true`.
    #     :open_new_window - +:html+ 형식으로 변환시 link에 대해 클릭하면 새 창으로 열릴 
    #         수 있도록 `<a>` 태그에 `target='_blank'`를 삽입한다. 
    #         지정하지 않는 경우 `false`.
    #     :allow_line_break - 라인브레이크를 허용한다. `:html` 로 변환시 라인브레이크는 
    #                         `<br />` 태그로 변환된다. 지정하지 않는 경우 `false`. 
    #     :limit - 변환 결과의 글자수를 제한한다. `:limit`에는 숫자를 지정하며 변환 결과는 
    #              지정된 글자 수 까지만 변환된다.
    #     :link_handler - 문자열에 나타나는 각 링크에 대해 지정된 block이 호출된다.
    def me2text(text, format = :html, options = {})
      options = {
        :symbolize => true,
        :open_new_window => false,
        :allow_line_break => false,
        :limit => nil,
        :link_handler => nil
      }.merge(options)

      if RUBY_VERSION < '1.9'
        begin
          text.dup.unpack('U*')
        rescue ArgumentError
          raise ArgumentError.new('me2text는 유효한 UTF-8 입력만 처리 가능합니다.')
        end
      else
        is_utf8 = case text.encoding
        when Encoding::UTF_8
          text.dup.valid_encoding?
        when Encoding::ASCII_8BIT, Encoding::US_ASCII
          text.dup.force_encoding(Encoding::UTF_8).valid_encoding?
        else
          false
        end

        raise ArgumentError.new('me2text는 유효한 UTF-8 입력만 처리 가능합니다.') unless is_utf8

        text = text.force_encoding(Encoding::UTF_8)
      end

      text = strip_linebreak(text) unless options[:allow_line_break]
      
      text = Token.join_tokens(Token.tokenize(text), format, options)
      
      # 키워드 핸들러 등록시, doublequote 가 결과에 포함되어 있는 경우 
      # doublequotize 메소드가 마지막에 호출 됨으로 에러 발생한다.
      text = doublequotize(text) if options[:symbolize]
      
      if format == :html
        text = htmlize_linebreak(text) if options[:allow_line_break]
      end
      
      strip_control_chars(text)
    end

    def doublequotize(text) #:nodoc:
      text.gsub(/\"([^"]*)\"/u) { |s|  "“#{$1}”" }
    end

    # 라인브레이크를 <br /> 태그로 대체한다.
    def htmlize_linebreak(text) 
      text.gsub(/\r\n/u, "<br />").gsub(/\n/u, "<br />").gsub(/\r/u, "<br />")
    end

    # 컨트롤 문자를 제거한다.
    def strip_control_chars(text) 
      text.gsub(/[[:cntrl:]]/u, "")
    end

    # 라인브래이크를 공백으로 변환한다
    def strip_linebreak(text) 
      text.gsub(/\s\r\n/u, "").gsub(/\r\n/u, " ").gsub(/[\r\n]/u, " ")
    end
  end
end
