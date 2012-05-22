me2text-ruby, me2text parser for ruby
======================================

me2text-ruby는 me2text 형식의 문자열을 HTML 또는 평문(plain text)로 변환해주는 
ruby 라이브러리이다. 

사용
----

### HTML로 변환

    require 'me2text'

    str = 'me2text는 "미투데이(TM)":http://me2day.net 의 글/댓글 작성 규칙이다.'
    Me2Text.me2text(str)
    # => me2text는 <a href='http://me2day.net'>미투데이™"</a>의 글/댓글 작성 규칙이다.

### 평문으로 변환

    require 'me2text'

    str = 'me2text는 "미투데이(TM)":http://me2day.net 의 글/댓글 작성 규칙이다.'
    Me2Text.me2text(str, :text)
    # => me2text는 미투데이™"의 글/댓글 작성 규칙이다.
    
### String 클래스 확장

    require 'me2text/string_ext'

    str = 'me2text는 "미투데이(TM)":http://me2day.net 의 글/댓글 작성 규칙이다.'
    str.me2text
    # => me2text는 <a href='http://me2day.net'>미투데이™"</a>의 글/댓글 작성 규칙이다.

### 주의 사항

me2text-ruby 사용을 위해서는 $KCODE 변수를 'UTF8' 또는 'u'로 지정해야 한다.

    $KCODE = 'UTF8'

me2text-ruby는 ruby 1.8.7-p302에서 테스트되었으며 아직 ruby 1.9.X를 지원하지 않는다.

설치
----
  me2text-ruby 라이브러리는 RubyGems를 통해 설치할 수 있다.

    gem install me2text-ruby


me2text란?
----------
me2text는 미투데이 글/댓글등의 글 작성 규칙을 일컫는다.

### 링크

  링크를 표현하는 형식은 다음과 같다

    "링크를 걸 문구":URL

  예를 들면 다음과 같다.

    미투텍스트는 "미투데이":http://me2day.net 의 글/댓글 작성 규칙을 일컫는다.
    => 미투텍스트는 <a href='http://me2day.net'>미투데이"</a>의 글/댓글 작성 규칙을 일컫는다.

  또, 이와 같은 링크 형식으로 작성되지 않더라도 단순히 URL만 지정한 경우에 대해서도 링크로 
  변환한다. 

    `자세한 내용은 이 주소로. http://me2day.net`
    => `자세한 내용은 이 주소로. <a href='http://me2day.net'>http://me2day.net</a>`

  백슬래시를 사용해 링크를 걸 문구에 따옴표를 포함할 수 있다. 즉, 아래와 같은 링크를 지정한 
  문자열에서 링크를 걸 문구에 포함된 따옴표에는 백슬래시를 붙여 전체 문자열에 링크를 적용할 
  수 있다.

    "레이디가가 소감, \"한국의 환대 따뜻하고 신나, 그리웠다\"":http://me2.do/FnlH8u3
    => <a href='http://me2.do/FnlH8u3'>레이디가가 소감, “한국의 환대 따뜻하고 신나, 그리웠다”</a>

### 따옴표 

  다음과 같이 따옴표 문자를 LEFT/RIGHT DOUBLE QUOTATION MARK(“”) 문자로 변환한다.

    "안녕하세요" -> “안녕하세요”

### 심볼 문자의 표현

  다음과 같은 특정 순서의 문자열을 심볼 문자로 변환한다. 

  * ...  => … (HORIZONTAL ELLIPSIS)
  * (TM) => ™ (TRADE MARK SIGN)
  * (R)  => ® (REGISTERED SIGN)
  * (C)  => © (COPYRIGHT SIGN)
  * --   => — (EN DASH)

TODO
----

  * Ruby 1.9 지원
  
Contributors
------------

Authors ordered by first contribution.

Heungseok Do <codian@gmail.com>  
MinYoung Jung <kkungkkung@gmail.com>  

License
-------

me2text-ruby is released under the MIT license:

* www.opensource.org/licenses/MIT
