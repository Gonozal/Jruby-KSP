module KspCfg
  module Parser
    class Cfg < Parslet::Parser


      ###############################################################
      # ATOMICS, BASICS
      rule(:digit)      { match["0-9"] }
      rule(:word)       { (match('[A-Za-z]') >> match('[.A-Za-z0-9_-]').repeat) }
      rule(:space)      { match('[ \t ]').repeat(1) }
      rule(:space?)     { space.maybe }
      rule(:newline)    { match('[\r\n]') }
      rule(:eof)        { match('\z') }

      rule(:line_separator) do
        (space? >> ((comment.maybe >> newline) | comment >> eof)).repeat(1)
      end

      rule(:blank) { line_separator | space }
      rule(:blank?) { blank.maybe }

      def spaced( atom )
        space? >> atom >> space?
      end


      ###############################################################
      # DATA TYPES
      rule(:integer) do
        (str("-").maybe >> ((match["1-9"] >> digit.repeat) | str("0")) >> 
         not_numbers.absent?).as(:integer)
      end

      rule(:float) do
        (str("-").maybe >> digit.repeat >>
         str(".") >> digit.repeat(1) >> not_numbers.absent?).as(:float) >> 
        not_numbers.absent?
      end

      rule(:not_numbers) do
        match('[ A-Za-z_*.]')
      end

      rule(:boolean) do
        (str("true") | str("True") | str("False") | str("false")).as(:boolean)
      end

      rule(:string) do
        (match('[\[\]0-9A-Za-z\-]') >>
         (space? >> match('[ |!\\?\[\]\(\)*A-Za-z0-9%"\'.:;,_-]')).repeat).as(:string)
      end


      ###############################################################
      # COMMENTS
      rule(:comment)  { str('//') >> match('[^\r\n]').repeat }
      rule(:comment?) { comment.maybe }


      ###############################################################
      # STATEMENTS
      rule :statements do
        (
          line_separator.repeat.maybe >> 
          statement >> (line_separator >> statement).repeat >> line_separator.maybe
        ).maybe
      end

      rule :statement do
        block | assignment
      end

      ###############################################################
      # ASSIGNMENTS
      rule :assignment do
        spaced(key) >> str("=") >> (spaced(list)).maybe
      end

      # Values can be any data type, keys only strings without spaces
      rule(:value) do
        ( float | integer | boolean | string )
      end

      rule :list do
        (value >> (spaced(str(",")) >> value).repeat).as(:value)
      end

      rule :key do
        word.as(:key)
      end


      ###############################################################
      # BLOCKS
      rule :block do
        block_name >> line_separator.maybe >> braced(statements.as(:block))
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
        line_separator.maybe >>
        statements.as(:document) >>
        line_separator.maybe
      end

      root :document
    end
  end
end
