module KspCfg
  module Parser
    class Cfg < Parslet::Parser
      # Some really atomic things
      rule(:digit)      { match["0-9"] }
      rule(:space)      { match["\t "] }
      rule(:space?)     { space.repeat }
      rule(:newline)    { str("\n") }

      # Data Types
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
        (match('[A-Za-z_-]') >> match('[ A-Za-z0-9_-]').repeat).as(:string)
      end

      # Comments
      rule(:comment?) do
        (str("//") >> (newline.absent? >> any).repeat).maybe
      end

      # Values can be any data type, keys only strings without spaces
      rule(:value) do
        ( float | integer | boolean | string ).as(:value)
      end

      rule :key do
        str("//").absent? >> newline.absent? >>
        (space.absent? >> any).repeat(1).as(:key)
      end

      # key = val
      rule :assignment do
        key >>
        space? >> str("=") >> space? >>
        value
      end

      # assignment with surrounding spaces and maybe a comment at the end
      rule :assignment_line do
        space? >> assignment.maybe >> space? >> comment?
      end

      rule :block do
        block_name >> space? >> newline.maybe >>
        opening_brace >> assignments.as(:block) >> closing_brace
      end

      rule :opening_brace do
        newline.maybe >> space? >> str("{") >> space? >> newline.maybe
      end

      rule :closing_brace do
        newline.maybe >> space? >> str("}") >> space? >> newline.maybe
      end

      rule :block_name do
        str("//").absent? >> newline.absent? >>
        (space.absent? >> newline.absent? >> any).repeat(1).as(:block_name)
      end

      # key1 = val1
      # // something
      # key2 = val2
      rule :assignments do
        assignment_line >> (newline >> assignment_line).repeat.maybe
      end

      # The whole thing, still WIP
      rule :document do
        (assignment >>
         key_group.repeat >>
         newline.maybe).as(:document)
      end

      root :document
    end
  end
end
