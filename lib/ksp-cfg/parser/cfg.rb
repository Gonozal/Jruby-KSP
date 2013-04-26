module KspCfg
  module Parser
    class Cfg < Parslet::Parser


      ###############################################################
      # ATOMICS, BASICS
      rule(:digit)      { match["0-9"] }
      rule(:word)       { (match('[A-Za-z]') >> match('[A-Za-z0-9_-]').repeat) }
      rule(:space)      { match('[ \t ]').repeat(1) }
      rule(:space?)     { space.maybe }
      rule(:newline)    { match('[\r\n]') }

      rule(:line_separator) do
        (space? >> (comment.maybe >> newline)).repeat(1)
      end

      rule(:blank) { line_separator | space }
      rule(:blank?) { blank.maybe }

      def spaced( atom )
        space? >> atom >> space?
      end


      ###############################################################
      # DATA TYPES
      rule(:integer) do
        (str("-").maybe >> match["1-9"] >> digit.repeat).as(:integer)
      end

      rule(:float) do
        (str("-").maybe >> digit.repeat(1) >>
         str(".") >> digit.repeat(1)).as(:float)
      end

      rule(:boolean) do
        (str("true") | str("True") | str("False") | str("false")).as(:boolean)
      end

      rule(:string) do
        (match('[A-Za-z]') >> match('[ A-Za-z0-9_-]').repeat).as(:string)
      end


      ###############################################################
      # COMMENTS
      rule(:comment)  { str('//') >> match('[^\r\n]').repeat }
      rule(:comment?) { comment.maybe }


      ###############################################################
      # STATEMENTS
      rule :statements do
        (statement >> (line_separator >> statement).repeat >> line_separator.maybe).maybe
      end

      rule :statement do
        block | assignment
      end


      ###############################################################
      # ASSIGNMENTS
      rule :assignment do
        spaced(key) >> str("=") >> spaced(value)
      end

      # Values can be any data type, keys only strings without spaces
      rule(:value) do
        ( float | integer | boolean | string ).as(:value)
      end

      rule :key do
        word.as(:key)
      end


      ###############################################################
      # BLOCKS
      rule :block do
        block_name >> line_separator >> braced(statements.as(:block))
      end

      rule :block_name do
        spaced(word.as(:block_name))
      end

      rule :opening_brace do
        line_separator.maybe >> spaced(str("{")) >> line_separator.maybe
      end

      rule :closing_brace do
        line_separator.maybe >> spaced(str("}"))
      end

      def braced( atom )
        opening_brace >> atom >> closing_brace
      end


      ###############################################################
      # THE DOCUMENT
      rule :document do
        newline.maybe >>
        statements.as(:document) >>
        newline.maybe
      end

      root :document
    end
  end
end
