# encoding: utf-8

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
  def self.included(base)
    base.extend ClassMethods
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods 
    def me2text(format = :html, options = {})
      Me2Text.me2text(self, format, options)
    end
  end

  module ClassMethods 
    def me2text(text, format = :html, options = {})
      Me2Text.me2text(text, format, options)
    end
  end

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
    #     :emphasis - 문자열을 지정한다. HTML로 변환시 `:emphasis`로 지정된 문자열에 
    #                 대해 강조를 위해 `<em>` 태그가 삽입된다. 
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
    #     :emphasis - 문자열을 지정한다. HTML로 변환시 `:emphasis`로 지정된 문자열에 
    #                 대해 강조를 위해 `<em>` 태그가 삽입된다. 
    #     :limit - 변환 결과의 글자수를 제한한다. `:limit`에는 숫자를 지정하며 변환 결과는 
    #              지정된 글자 수 까지만 변환된다.
    #     :link_handler - 문자열에 나타나는 각 링크에 대해 지정된 block이 호출된다.
    def me2text(text, format = :html, options = {})
      options = {
        :symbolize => true,
        :open_new_window => false,
        :allow_line_break => false,
        :emphasis => [],
        :limit => nil,
        :link_handler => nil
      }.merge(options)
      options[:emphasis] = [options[:emphasis]].flatten.compact

      text = strip_linebreak(text) unless options[:allow_line_break]
      
      text = Token.join_tokens(Token.tokenize(text), format, options)
      
      # 키워드 핸들러 등록시, doublequote 가 결과에 포함되어 있는 경우 
      # doublequotize 메소드가 마지막에 호출 됨으로 에러 발생한다.
      text = doublequotize(text) if options[:symbolize]
      
      if format == :html
        text = htmlize_linebreak(text) if options[:allow_line_break]
        text = emphasize(text, options[:emphasis]) if !options[:emphasis].empty?
      end
      
      strip_control_chars(text)
    end

    def doublequotize(text) #:nodoc:
      text.gsub(/\"([^"]*)\"/) { |s|  "“#{$1}”" }
    end

    # 라인브레이크를 <br /> 태그로 대체한다.
    def htmlize_linebreak(text) 
      text.gsub(/\r\n/, "<br />").gsub(/\n/, "<br />").gsub(/\r/, "<br />")
    end

    # 컨트롤 문자를 제거한다.
    def strip_control_chars(text) 
      text.gsub(/[[:cntrl:]]/, "")
    end

    # 라인브래이크를 공백으로 변환한다
    def strip_linebreak(text) 
      text.gsub(/\s\r\n/, "").gsub(/\r\n/, " ").gsub(/[\r\n]/, " ")
    end

    def emphasize(text, emphasis) 
      # 글자수가 많은 단어부터 먼저 매칭하기 위해 정렬
      emphasis = emphasis.sort { |a, b| b.length <=> a.length }
      
      # entity 나 미투에서 바꿔 보여주는 단어들      
      emphasis = emphasis.map do |word|
        word.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").
             gsub("...", "").gsub("--", "—")
      end
      
      is_anchor = false
      matching_word = nil
      match_index = 0
      match_begin_index = 0
      match_result = []
      tmp_result = []

      text_arr = text.split(//u)
      text_arr.each_with_index do |c, index|
        c = c.to_s.downcase
        
        if !is_anchor && c == '<'
          is_anchor = true 
          
          # 앵커가 시작됨으로 바로 이전에 매칭이 되고 있었다면 
          if match_index > 0
            # 앵커 안의 내용이 매칭이 될지 안될지 모르니 임시로 저장
            # 만약 앵커안의 내용이 매칭이 되면 result로 넘겨야 하고,
            # 앵커안에서 매칭이 되지 않았다면 날림
            tmp_result << [match_begin_index, index - 1]
            match_begin_index = 0            
          end          
        end
        
        # 앵커안이면 스킵
        if is_anchor
          is_anchor = false if c == '>'
          next
        end

        if matching_word
          chars = matching_word.split(//u)
          if chars[match_index] && chars[match_index] != c
            emphasis.each do |emp|
              next if emp == matching_word
              for_match_word = (chars[0...match_index].to_s + c).
                               gsub('[','\[').gsub(']','\]').
                               gsub('{','\{').gsub('}','\}')
              is_match_word = emp.match(for_match_word) rescue nil
              matching_word = emp if is_match_word 
              chars = matching_word.split(//u)
            end
          end

          if chars[match_index] == c
            # 임시저장된 매칭결과가 있다면, 앵커안에서 다시 매칭 시작
            if !tmp_result.empty? && match_begin_index == 0
              match_begin_index = index 
            end
            
            match_index += 1
            
            # 완벽하게 매치된 경우 처리 
            if match_index == chars.length
              match_result += tmp_result
              tmp_result = []
              
              match_result << [match_begin_index, index]
              
              matching_word = nil
              match_index = 0
            end
          else
            tmp_result = []
            matching_word = nil
            match_index = 0
          end
        else
          emphasis.each do |emp|
            chars = emp.split(//u)
            if chars[0] == c
              if chars.size == 1
                match_result << [index, index]
              else  
                matching_word = emp
                match_index += 1
                match_begin_index = index
              end
              break
            end
          end
        end
      end
      
      result = ""
      text_arr.each_with_index do |c, index|
        match_result.each { |match| result << "<em>" if index == match[0] }
        result << c
        match_result.each { |match| result << "</em>" if index == match[1] }          
      end
      
      result
    end
  end
end
