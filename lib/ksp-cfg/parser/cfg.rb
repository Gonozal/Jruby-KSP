module KspCfg
  module Parser
    class Cfg < Parslet::Parser
      rule(:space)      { match["\t "] }
      rule(:space?)     { space.repeat }
      rule(:newline)    { str("\n") }

      rule(:comment?) do
        (str("//") >> (newline.absent? >> any).repeat).maybe
      end

      rule(:string) do
        str("//").absent? >> match('[A-Za-z_-]') >> match('[ A-Za-z0-9_-]').repeat
      end

      rule :key do
        str("//").absent? >> newline.absent? >>
        (space.absent? >> any).repeat(1).as(:key)
      end

      rule :value do
        string.as(:value)
      end

      rule :assignment do
        key >>
        space? >> str("=") >> space? >>
        value
      end

      rule :assignment_line do
        space? >> assignment.maybe >> space? >> comment?
      end

      rule :assignments do
        assignment_line >> (newline >> assignment_line).repeat.maybe
      end

      rule :document do
        (assignment >>
         key_group.repeat >>
         newline.maybe).as(:document)
      end

      root :document
    end
  end
end
