module KspCfg
  module Parser
    class Transform < Parslet::Transform
      rule(integer:       simple(:n))       { Integer(n) }
      rule(float:         simple(:n))       { Float(n) }
      rule(boolean:       simple(:b))       { b == "true" or b == "True" }
      rule(string:        simple(:st))      { String.try_convert(st) }

      rule(value:         subtree(:a))      { a }

      rule(key: simple(:key), value: subtree(:value)) do
        { key.to_sym => value }
      end

      rule(block_name: simple(:block_name), block: subtree(:values)) do |dict|
        if dict[:values].kind_of? Array
          { dict[:block_name].to_sym => combine_blocks(dict[:values]) }
        else
          { dict[:block_name].to_sym => dict[:values] }
        end
      end

      rule(document: subtree(:contents)) do |dict|
        if dict[:contents].kind_of? Array
          { document: combine_blocks(dict[:contents])}
        else
          { document: dict[:contents]}
        end
      end

      def self.combine_blocks(assignments)
        {}.tap do |context|
          assignments.each do |assignment|
            key, value = assignment.first
            if context.has_key? key.to_sym
              if context[key.to_sym].kind_of? Array
                context[key.to_sym] << value
              else
                context[key.to_sym] = [context[key.to_sym]]
                context[key.to_sym] << value
              end
            else
              context[key.to_sym] = value
            end
          end
        end
      end
    end
  end
end
