#!/usr/bin/env ruby
require 'rubygems' rescue nil
$LOAD_PATH.unshift File.join(File.expand_path(__FILE__), "..", "..", "lib")
require 'chingu'
require 'Qt4'
include Gosu
include Chingu

class Game < Chingu::Window
  def initialize
    super(600,600)
    puts "game created"
    #Show cursor
    $window.cursor = true
    #First state is menu
    push_game_state(EntryMenu)
  end
end

 class Player < Chingu::GameObject
  def initialize(options = {})
    super
    @image = Image["../media/graphics/car1.png"]
  end

  def move_left;  @x -= 6; end

  def move_right; @x += 6; end

  def move_up;    @y -= 6; end

  def move_down;  @y += 6; end

  def setup
    self.input = {  :holding_left => :move_left,
      :holding_right => :move_right,
      :holding_up => :move_up,
      :holding_down => :move_down,
    }
  end

end



class PressButton < Chingu::GameObject
  def setup
        
    # @animations = Chingu::Animation.new(:file => "../media/heli.png")
    puts "press ejecuto"
    puts @animations
    #Set event methods to nill 
    @on_click_method = @on_release_method  = @on_hold_method  = Proc.new {}
    #Normaly a button has two images, pressed and unpressed
    @animations.frame_names =  {:scan => 0..1}
    #puts self.width
    #puts self.height
    @animation = @animations[:scan]
    #The button starts unpressed
    @image = @animation.first
    @clicked = false
    half_width = self.width / 2 
    half_height = self.height / 2 
    #Total area of the button
    @button_range = {:x => ((self.x - half_width)..(self.x + self.width - half_width)),
      :y => ((self.y - half_height)..(self.y + self.height - half_height))}
    #If the user clicks, we check if he clicked a button
    self.input = {:left_mouse_button => :check_click,
      :released_left_mouse_button => :check_release,
      :holding_left_mouse_button => :check_hold }
  end
  
   def check_click
=begin      
      puts $window.mouse_x
      puts $window.mouse_y
      puts self.center_x
      puts self.center_y
      puts self.center
      puts @button_range
=end
      #If mouse position is inside the range, then go to click
      if @button_range[:x].include? $window.mouse_x and
         @button_range[:y].include? $window.mouse_y then
         #The user clicked on this button
         @clicked = true
         self.on_click
      end
   end 
   
  def check_hold
=begin
  puts "holding"
  puts $window.mouse_x
  puts $window.mouse_y
  puts @button_range
=end
    if @button_range[:x].include? $window.mouse_x and 
      @button_range[:y].include? $window.mouse_y then
      self.on_hold
    end
  end 
   
  def check_release
=begin
    puts $window.mouse_x
    puts $window.mouse_y
    puts @button_range
=end
    #If the button was pressed, it does not matter
    #where the user has the mouse
    if @clicked then
      @clicked = false
      self.on_release
    end
  end 
   
  #Methods that allow QT like use. 
  def on_click(&block)
    #Set pressed image
    @image = @animation.last
    if block_given?
      #If is first call, save the block that will be executed
      @on_click_method = block
    else
      #On a normal call, execute user's code
      @on_click_method.call
    end
  end 
   
   
  def on_release(&block)
    @image = @animation.first
    if block_given?
      @on_release_method = block
    else
      @on_release_method.call
    end
  end 
   
  def on_hold(&block)
    if block_given?
      @on_hold_method = block
    else
      @on_hold_method.call
    end
  end 
   
end

 class SoloButton < PressButton
  def initialize(options = {})
    puts "solo ejec"
    @animations = Chingu::Animation.new(:file => "../media/menu/solo-game-menu.png",  :size => [100,20])
    puts @animations
    super
  end

end


 class OnlineButton < PressButton
  def initialize(options = {})
    puts "onlie ejec"
    @animations = Chingu::Animation.new(:file => "../media/menu/online-game-menu.png")
    super
  end

end

class MultiplayerButton < PressButton
  def initialize(options = {})
    puts "onlie ejec"
    @animations = Chingu::Animation.new(:file => "../media/menu/online-game-menu.png")
    super
  end
end

 class EntryMenu < Chingu::GameState
  def initialize(options = {})
    super
    @song = Song["../media/music/cave.ogg"].play(true)
    @level = GameObject.create(:image => "../media/menu/menu-background.png", :rotation_center => :top_left)
    @soloButton = SoloButton.create(:x => 300, :y => 500)
    #   @onlineButton = OnlineButton.create(:x => 300, :y => 300 )
    #  @multiplayerButton = MultiplayerButton.create(:x => 300, :y => 300 )

    @soloButton.on_click do
      puts "cambiando"
      switch_game_state(Level)
      puts "cambiado"
    end

  end

  def update
    super
    @image = Image["../media/menu/menu-background.png"]
  end

end  

 class Level < Chingu::GameState
  #
  # initialize() is called when you create the game state
  #
  def initialize(options = {})
    super
    @song = Song["../media/music/cave.ogg"].play(true)
    @title = Chingu::Text.create(:text=>"Level #{options[:level].to_s}. P: pause R:restart", :x=>20, :y=>10, :size=>30)
    @level = GameObject.create(:image => "../media/graphics/map1.png", :rotation_center => :top_left)
    @player = Player.create
    @button = SoloButton.create(:x => 300, :y => 500)
    #
    # The below code can mostly be replaced with the use of methods "holding?", "holding_all?" or "holding_any?" in Level#update
    # Using holding? in update could be good if you need fine grained controll over when input is dispatched.
    #
=begin
    @player.input = {  :holding_left => :move_left,
    :holding_right => :move_right,
    :holding_up => :move_up,
    :holding_down => :move_down,
    }
=end
    #
    # The input-handler understands gamestates. P is pressed --> push_gamegate(Pause)
    # You can also give it Procs/Lambdas which it will execute when key is pressed.
    #
    self.input = {:p => Pause, :r => lambda{ current_game_state.setup } }
  end

  def update
    super

    #
    # Another way of checking input
    #
    # @player.move_left   if holding_any?(:left, :a)
    # @player.move_right  if holding_any?(:right, :d)
    # @player.move_up     if holding_any?(:up, :w)
    # @player.move_down   if holding_any?(:down, :s)
    # @player.fire        if holding?(:space)
    @image = Image["../media/graphics/map1.png"]
    $window.caption = "FPS: #{$window.fps} - GameObjects: #{game_objects.size} "
  end

  #
  # setup() is called each time you switch to the game state (and on creation time).
  # You can skip setup by switching with push_game_state(:setup => false) or pop_game_state(:setup => false)
  #
  # This can be useful if you want to display some kind of box above the gameplay (pause/options/info/... box)
  #
  def setup
    # Destroy all created objects of class Bullet

    # Place player in a good starting position
    @player.x = $window.width/2
    @player.y = $window.height - @player.image.height
  end

end

 class Level2 < Chingu::GameState
  #
  # initialize() is called when you create the game state
  #
  def initialize(options = {})
    super
    @song = Song["../media/music/cave.ogg"].play(true)
    @title = Chingu::Text.create(:text=>"Level #{options[:level].to_s}. P: pause R:restart", :x=>20, :y=>10, :size=>30)
    @level = GameObject.create(:image => "../media/graphics/car1.png", :rotation_center => :top_left)
    @player = Player.create
    #
    # The below code can mostly be replaced with the use of methods "holding?", "holding_all?" or "holding_any?" in Level#update
    # Using holding? in update could be good if you need fine grained controll over when input is dispatched.
    #

    @player.input = {  :holding_left => :move_left,
      :holding_right => :move_right,
      :holding_up => :move_up,
      :holding_down => :move_down,
    }

    #
    # The input-handler understands gamestates. P is pressed --> push_gamegate(Pause)
    # You can also give it Procs/Lambdas which it will execute when key is pressed.
    #
    self.input = {:p => Pause, :r => lambda{ current_game_state.setup } }
  end

  def update
    super

    #
    # Another way of checking input
    #
    # @player.move_left   if holding_any?(:left, :a)
    # @player.move_right  if holding_any?(:right, :d)
    # @player.move_up     if holding_any?(:up, :w)
    # @player.move_down   if holding_any?(:down, :s)
    # @player.fire        if holding?(:space)
    @image = Image["../media/graphics/map1.png"]
    $window.caption = "FPS: #{$window.fps} - GameObjects: #{game_objects.size} "
  end

  #
  # setup() is called each time you switch to the game state (and on creation time).
  # You can skip setup by switching with push_game_state(:setup => false) or pop_game_state(:setup => false)
  #
  # This can be useful if you want to display some kind of box above the gameplay (pause/options/info/... box)
  #
  def setup
    # Destroy all created objects of class Bullet

    # Place player in a good starting position
    @player.x = $window.width/2
    @player.y = $window.height - @player.image.height
  end

end

 #
  # SPECIAL GAMESTATE - Pause
  #
  # NOTICE: Chingu now comes with a predefined Chingu::GameStates::Pause that works simular to this!
  #
  class Pause < Chingu::GameState
    def initialize(options = {})
      super
      @title = Chingu::Text.create(:text=>"PAUSED (press 'u' to un-pause)", :x=>100, :y=>200, :size=>20, :color => Color.new(0xFF00FF00))
      self.input = { :u => :un_pause }
    end

    def un_pause
      pop_game_state(:setup => false)    # Return the previous game state, dont call setup()
    end

    def draw
      previous_game_state.draw    # Draw prev game state onto screen (in this case our level)
      super                       # Draw game objects in current game state, this includes Chingu::Texts
    end
  end

=begin
  $comunicationWithKernel = Comunication.new
=end
  Game.new.show()
