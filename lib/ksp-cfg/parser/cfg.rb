module KspCfg
  module Parser
    class Cfg < Parslet::Parser
      # Single character rules
      rule(:pair) {
        key >> value
      }

      rule(:key) {
        spaces? >>
        (match('[A-Za-z_-]') >> match('[A-Za-z0-9_-]').repeat).repeat.as(:key) >>
        spaces? >> str("=")
      }

      rule(:value) {
        spaces? >>
        (match('[A-Za-z_-]') >> match('[A-Za-z0-9_-]').repeat).repeat.as(:value) >>
        spaces?
      }

      rule(:spaces) {
        match('\s').repeat(1)
      }
      rule(:spaces?) {
        spaces.maybe
      }

      rule(:newline) {
        spaces? >> match('\n').repeat(1)
      }

      rule(:pair_list) { pair >> pair.repeat.maybe }
      root :pair_list
    end

  end
end
