require 'hexoid'

# TEST 1: test matches result with expectation
1 + 1
#=> 2


# TEST 2: comments and values can 
# contain multiple lines
a = 1
b = 2
a + b
# => 3
# => 2 + 1

# TEST 3: test expectation type matters
'foo'.class
#=> String


# TEST 4: test ignores blank lines before expectations
'foo'


#=> 'foo'


# TEST 5: test allows whiny expectation markers for textmate users *sigh*
'foo'
# =>  'foo'


# TEST 6: test expectations can be commented out
'foo'
##=> 'this would fail'

x = raise rescue 'foo'
#=> 'foo'

