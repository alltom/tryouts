require 'pathname'
require Pathname(__FILE__).dirname.parent + 'lib/nofw'

#def foo() 'foo'; end


# test matches result with expectation
1 + 1
#=> 2

# test expectation type matters
'foo' + 'bar'
#=> 'foobar'

# test expectation type matters
'foo'.class
#=> String

# test ignores blank lines before expectations
'foo'


#=> 'foo'

## test ignores comments before expectations
'foo'
# comment
# comment
#=> 'foo'

## test uses helper methods
## ( #foo is defined on top of file )
#foo()
##=> foo

# test expectations can be commented out
'foo'
##=> 'this would fail'

x = raise rescue 'foo'
#=> 'foo'

#begin
#  raise
#rescue
#  'foo'
#end
##=> 'foo'

## test handles multiple code lines
## only only tests last line against expectation
#str = ""
#str << 'foo'
#str << 'bar'
#str
##=> 'foobar'
##
### test failure
##'this fails'
###=> 'expectation not met'
#