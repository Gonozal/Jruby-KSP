module KspCfg
  module Parser
    class Transform < Parslet::Transform
      rule(integer:       simple(:n))       { Integer(n) }
      rule(float:         simple(:n))       { Float(n) }
      rule(boolean:       simple(:b))       { b == "true" or b == "True" }
      rule(string:        simple(:st))      { st }

      rule(value:         subtree(:a))      { a }

      rule(key: simple(:key), value: subtree(:value)) do
        { key.to_sym => value }
      end

      rule(block_name: simple(:block_name), block: subtree(:values)) do |dict|
        if dict[:values].kind_of? Array
          { dict[:block_name].to_sym => combine_assignments(dict[:values]) }
        else
          { dict[:block_name].to_sym => dict[:values] }
        end
      end

      def self.combine_assignments(assignments)
        {}.tap do |context|
          assignments.each do |assignment|
            key, value = assignment.first
            context[key.to_s] = value
          end
        end
      end
    end
  end
end
