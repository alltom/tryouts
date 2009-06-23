

class Tryouts
  
  # = Drill
  # 
  # This class represents a drill. A drill is single test. 
  #
  class Drill
  
  require 'tryouts/drill/response'
  require 'tryouts/drill/sergeant/cli'
  require 'tryouts/drill/sergeant/api'
  
  class NoSergeant < Tryouts::Exception; end
    
    # A symbol specifying the drill type. One of: :cli, :api
  attr_reader :dtype
    # The name of the drill. This should match the name used in the dreams file. 
  attr_reader :name
    # A Proc object which contains the drill logic. 
  attr_reader :drill
  
    # A Sergeant object which executes the drill
  attr_reader :sergeant
    # A Dream object (the expected output of the test)
  attr_reader :dream
    # A Reality object (the actual output of the test)
  attr_reader :reality
      
  def initialize(name, dtype, *drill_args, &drill)
    @name, @dtype, @drill = name, dtype, drill
    @sergeant = hire_sergeant *drill_args
    # For CLI drills, a block takes precedence over inline args. 
    # A block will contain multiple shell commands (see Rye::Box#batch)
    drill_args = [] if dtype == :cli && drill.is_a?(Proc)
    @reality = Tryouts::Drill::Reality.new
  end
  
  def hire_sergeant(*drill_args)
    if @dtype == :cli
      Tryouts::Drill::Sergeant::CLI.new(*drill_args)
    elsif @dtype == :api
      Tryouts::Drill::Sergeant::API.new(drill_args.first)
    else
      raise NoSergeant, "What is #{@dtype}?"
    end
  end
  
  def run(context=nil)
    begin
      print Tryouts::DRILL_MSG % @name
      @reality = @sergeant.run @drill, context
      # Store the stash from the drill block
      @reality.stash = context.stash if context.respond_to? :stash
      # Create or overwrite an existing dream if onw was defined in the block
      if context.respond_to?(:dream) && context.has_dream?
        @dream = Tryouts::Drill::Dream.new
        @dream.output = context.dream
        @dream.format = context.format unless context.format.nil?
        @dream.rcode = context.rcode unless context.rcode.nil?
        @dream.emsg = context.emsg unless context.emsg.nil?
      end
      
      # If the drill block returned true we assume success if there's no dream
      if @dream.nil? && @reality.output == true
        @dream = Tryouts::Drill::Dream.new
        @dream.output = true
      end
      process_reality
    rescue => ex
      @reality.rcode = -2
      @reality.emsg, @reality.backtrace = ex.message, ex.backtrace
    end  
    note = @dream ? discrepency.join(', ') : 'nodream'
    puts self.success? ? "PASS".color(:green) : "FAIL (#{note})".color(:red)
    self.success?
  end
  
  def success?
    return false if @dream.nil? || @reality.nil?
    @dream == @reality
  end
  
  def discrepency
    diffs = []
    if @dream
      diffs << "rcode" if @dream.rcode != @reality.rcode
      diffs << "output" if !@dream.compare_output(@reality)
      diffs << "emsg" if @dream.emsg != @reality.emsg
    end
    diffs
  end
  
  def add_dream(d)
    @dream = d if d.is_a?(Tryouts::Drill::Dream)
  end
  
  private 
  # Use the :format provided in the dream to convert the output from reality
  def process_reality
    @reality.normalize!
    return unless @dream && @dream.format
    if @dream.format == :to_yaml
      @reality.output = YAML.load(@reality.output.join("\n"))
    elsif  @dream.format == :to_json
      @reality.output = JSON.load(@reality.output.join("\n"))
    end
    
    #p [:process, @name, @dream.format, @reality.output]
  end
  
end; end