module Caboose
  
  module LogicParser
    # This module holds our recursive descent parser that take a logic string
    # the acl's in @acls and a context to check the logicstring against.
    # Include this module in your Handler class.
    
    # recursively processes an permission string and returns true or false
    def process(logicstring, context)
      # if logicstring contains any parenthasized patterns, call process recursively on them
      while logicstring =~ /\(/
        logicstring.sub!(/\(([^\)]+)\)/) {
          process($1, context)
        }
      end
      
      # process each operator in order of precedence
      #!
      while logicstring =~ /!/
        logicstring.sub!(/!([^ &|]+)/) { 
          (!@acls[logicstring[$1]].check context).to_s
        }
      end
      
      #&
      if logicstring =~ /&/
        return (process(logicstring[/^[^&]+/], context) and process(logicstring[/^[^&]+&(.*)$/,1], context))
      end
      
      #|
      if logicstring =~ /\|/
        return (process(logicstring[/^[^\|]+/], context) or process(logicstring[/^[^\|]+\|(.*)$/,1], context))
      end
      
      # constants
      if logicstring =~ /^\s*true\s*$/i
        return true
      elsif logicstring =~ /^\s*false\s*$/i
        return false
      end
      
      # single list items
      return (@acls[logicstring.strip].check context)
    end
    
  end # LogicParser

end