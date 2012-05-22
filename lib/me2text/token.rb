# -*- encoding: utf-8 -*-

module Me2Text
  class Token 
    REGEX_ME2LINK = begin 
      dquota_s = '\\xe2\\x80\\x9c|\\xe2\\x80\\x9f|\\xe2\\x9d\\x9d|\\xe2\\x80\\xb6|\\xe2\\x80\\x9d|\\x22|\\xef\\xbc\\x82'
      dquota_e = '\\xe2\\x80\\x9d|\\xe2\\x80\\x9e|\\xe2\\x9d\\x9e|\\xcb\\x9d|\\xe2\\x80\\xb3|\\xe2\\x80\\x9e|\\xe2\\x80\\x9f|\\x22|\\xef\\xbc\\x82'
      dquota_ne = '\\xe2\\x80\\x9d\\xe2\\x80\\x9e\\xe2\\x9d\\x9e\\xcb\\x9d\\xe2\\x80\\xb3\\xe2\\x80\\x9e\\xe2\\x80\\x9f\\x22\\xef\\xbc\\x82'
      /(?:#{dquota_s})([^#{dquota_ne}]*)(?:#{dquota_e}):(http[s]?:\/\/[^\s]*)(\s|$)/u
    end
    REGEX_URL = /(http[s]?:\/\/[^\s|^\'|^\"]*)([\'|\"|\s]|$)/u
    ESCAPE_CHAR = "\xc2\xa0"

    attr_accessor :text
    
    def to_s(format, options = {})
      unless [:html, :text].include?(format)
        raise ArgumentError.new("Unknown format: #{format.inspect}") 
      end
      self.send('to_' + format.to_s, options)
    end
    
    def to_html(options ={})
    end
    
    def to_text(options ={})
    end
    
    def length(options ={})
      1
    end
    
    def truncate(nos, format, options = {})
      options = {
        :ellipsis => "…"
      }.merge(options)

      [options[:ellipsis], 1]
    end

  protected

    def htmlize(text, options = {})
      options = {
        :symbolize => true,
        :linklize_class => "write_link"
      }.merge(options)
      
      remain = text
      result = ""
      if options[:linklize]
        while (m = remain.match(REGEX_URL))
          url = m[1]
          after_url = m[2]

          result << htmlize_chars(m.pre_match, options) if !m.pre_match.empty?
          result << "<a href='#{url.to_s.strip}'"
          result << " class='#{options[:linklize_class]}'" if options[:linklize_class]
          result << " target='_blank'" if options[:open_new_window]
          result << ">"
          result << url
          result << "</a>"
          result << after_url
          
          remain = m.post_match
        end
      end
      result << htmlize_chars(remain, options)

      result
    end
    
    def htmlize_chars(text, options = {})
      html_result = text.to_s.gsub(/&/u, "&amp;").gsub(/</u, "&lt;").gsub(/>/u, "&gt;")
      html_result = textize(html_result, options)
      html_result
    end

    def textize(text, options = {})
      options = {
        :symbolize => true
      }.merge(options)

      if options[:symbolize]
        text = text.gsub(/\.\.\./u, "…").
                    gsub(/\(TM\)/u, "™").
                    gsub(/\(R\)/u, "®").
                    gsub(/\(C\)/u, "©").
                    gsub(/--/u, "—")
      end
      text
    end

    class << self
      def tokenize(text, options = {})
        tokenize_me2link(text.gsub(/\\\"/u, ESCAPE_CHAR), options)
      end
      
      def tokenize_me2link(text, options = {})
        tokens = []
        while (m = text.match(REGEX_ME2LINK))
          # 매치 이전 텍스트 처리
          tokens += tokenize_keyword(m.pre_match, options) if !m.pre_match.empty?
          
          url = m[2]
          anchor_text = m[1]
          if url
            if !options[:link_handler].nil?
              url = options[:link_handler].call(url, options)
            end
            tokens << Link.new(anchor_text, url, m[3].length > 0)
          else
            tokens += tokenize_keyword(anchor_text, options)
          end

          text = m.post_match
        end
        if !text.empty?
          tokens += tokenize_keyword(text, options)
        end

        tokens
      end

      def tokenize_keyword(text, options = {})
        tokens = []
        while (m = text.match(Keyword::KEYWORD_REGEX))
          tokens += tokenize_plaintext(m.pre_match, options) if !m.pre_match.empty?
          tokens << Keyword.new(m.to_s, options)
          text = m.post_match
        end        
        if !text.empty?
          tokens += tokenize_plaintext(text, options)
        end
        
        tokens
      end

      def tokenize_plaintext(text, options = {})
        [Plain.new(text)]
      end

      def join_tokens(tokens, format, options)
        if options[:limit].nil?
          return tokens.map { |token| token.to_s(format, options) }.join
        end

        result = ""
        process_length = 0
        tokens.each_with_index do |tk, idx| 
          n_len = process_length + tk.length
          r_len = length - n_len
          
          # 길이가 남았다.
          if r_len > 0
            process_length = process_length + tk.length
            result << tk.to_s(format, options)

          # 길이가 딱 맞다.
          elsif r_len == 0
            # 이번 토큰이 마지막 토큰(더이상 추가할 게 없음) 인가? 
            if (idx + 1) == tokens.size
              process_length = process_length + tk.length
              result << tk.to_s(format, options)
            else
              # 남은 문자열이 있다.
              val = tk.truncate(0, format, options)
              process_length = process_length + val[1]
              result << val.first
            end
            break

          # 길이가 r_len만큼 모자르다
          else
            val = tk.truncate(-r_len, format, options)
            process_length = process_length + val[1]
            result << val.first
            break
          end
        end
      
        result
      end
    end
  end

  class Plain < Token 
    def initialize(tv)
      @text = tv.gsub(ESCAPE_CHAR, "\"")
    end
  
    def to_html(options = {})
      htmlize(@text, options)
    end
    
    def to_text(options = {})
      textize(@text, options)
    end
    
    def length
      @text.split(//u).length
    end
    
    def truncate(nos, format, options = {})
      options = {
        :ellipsis => "…"
      }.merge(options)
      
      val = self.to_s(format, options)
      if (val.length - nos) <= 0 
        #빼면 아무것도 없다면..
        ##이 링크는 버린다
        options[:ellipsis]
      else
        val = val.split(//u)[0...(val.length - nos) - 1]
        val << options[:ellipsis]
      end
      
      @text = val 
      
      [val, length]
    end
  end

  class Link < Token 
    attr_accessor :link
    attr_accessor :include_ws
    
    def initialize(label, link, include_ws = false)
      @text = label.gsub(ESCAPE_CHAR, "\"")
      @link = link.gsub("'","%27").gsub("\"","%22").gsub("<", "%3C").gsub(">", "%3E")
      @include_ws = include_ws   
    end
    
    def to_label(format,options = {})
      options = options.merge({
        :linklize => false
      })
      
      result = if format == :html
        htmlize(@text, options)
      elsif format == :text
        textize(@text, options)
      else
        @text
      end
      
      if result.strip.length == 0
        if format == :html 
          result = htmlize(" " + link + " ",options)
        elsif format == :text
          result = textize(" " + link + " " ,options)
        else
          @text
        end
      end
      
      return result
    end
    
    def to_html(options = {})
      if options[:open_new_window]
        "<a href='#{link}' target='_blank'>#{to_label(:html,options)}</a>"
      else
        "<a href='#{link}'>#{to_label(:html,options)}</a>"
      end
    end
    
    def to_text(options = {})
      to_label(:text, options)
    end
    
    def length(options = {})
      textize(@text,options).length
    end
    
    def truncate(nos, format, options = {})
      options = {
        :ellipsis => "…"
      }.merge(options)
      
      val = self.to_label(format,options)
      if (val.length - nos) <= 0 
        #빼면 아무것도 없다면..
        ##이 링크는 버린다
        options[:ellipsis]
      else
        val = val.split(//u)[0...(val.length-nos) - 1]
        val << options[:ellipsis]
      end
      
      @text= val 
      [to_s(format,options), length(options)]
    end
  end
  
  class Keyword < Token 
    KEYWORD_REGEX = /(\[([^\[\]]+)\])/u
    attr_accessor :link
    
    def initialize(keyword, options)
      # keyword는 "[키워드]" 같은 형태
      _keyword = keyword.to_s.strip.scan(KEYWORD_REGEX)
      _keyword = _keyword.flatten[1]

      raise ArgumentError.new("키워드가 없습니다.") if _keyword.nil?
      
      @text = _keyword.gsub(ESCAPE_CHAR, "\"")
    end
    
    def to_html(options = {})
      if options[:keyword_handler] && options[:keyword_handler].is_a?(Proc)
        options[:keyword_handler].call(@text, options)
      else
        "[#{htmlize(@text, options)}]"
      end
    end
    
    def to_text(options = {})
      "[#{textize(@text, options)}]"
    end
    
    def length(options = {})
      textize(@text, options).length
    end
    
    def truncate(nos, format, options = {})
      options = {
        :ellipsis => "…"
      }.merge(options)
      
      val = self.to_text(options)
      if (val.length - nos) <= 0 
        # 빼면 아무것도 없다면 이 링크는 버린다
        options[:ellipsis]
      else
        val = val.split(//u)[0...(val.length - nos) - 1]
        val << options[:ellipsis]
      end
      
      @text = val 
      [to_s(format, options), length(options)]
    end
  end
end