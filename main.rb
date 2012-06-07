#--
#
# Tactical Racer -- Simple formula 1 game written in Ruby
# Copyright (C) 2012 neochuky neochuki@gmail.com
#
# This game is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public
# License as published by the Free Software Foundation; either
# version 3 of the License, or (at your option) any later version.
#
# This game is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
#++

#!/usr/bin/env ruby
require 'rubygems' rescue nil
$LOAD_PATH.unshift File.join(File.expand_path(__FILE__), "..", "..", "lib")
require '../chingu/lib/chingu.rb'
#require 'chingu'
include Gosu
include Chingu

 class EscapeMenu < Chingu::GameState
  def initialize(options = {})
    super
    #On scape key return to where the user was
    self.input = { :escape => :pop_game_state }
    @level = GameObject.create(:image => "./media/menu/escape-menu-background.png", :x => 400, :y => 300)

    @exitButton = Chingu::PressButton.create(:x => 400, :y => 300, :button_image => "./media/menu/exit-game-button.png")
          
    @exitButton.on_click do
      $window.close
      exit
    end    
    
  end
end 


class Game < Chingu::Window
  def initialize
    super(800,600,false)
    puts "game created"
    #To give a nice old pixeled look
  #  retrofy
    #Show cursor
    $window.cursor = true
    #On scape key pop esc menu
    self.input = { :escape => :push}
    #First state is menu
    push_game_state(EntryMenu)
    transitional_game_state(Chingu::GameStates::FadeTo, {:speed => 30})
  end
  
  def push
    if current_game_state.is_a?(EscapeMenu)
      push_game_state(@previous_game_state)
    else 
      @previous_game_state = current_game_state
      push_game_state(EscapeMenu)
    end    
  end
end

 class Player < Chingu::GameObject
   attr_accessor :current_tile
  def initialize(options = {})
    super
    @image = Image["./media/graphics/car1.png"]
    @current_tile = 0
    self.factor_x = 0.3
    self.factor_y = 0.3
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
=begin
 class Interface < Chingu::GameObject
   attr_accessor :dice 
  def initialize(options = {})
    super
    self.x = 400
    self.y = 550
    @image = GameObject.create(:image => "./media/menu/interface-background.png", :rotation_center => :top_left)
    @gasoline = 300
    @dice = Chingu::PressButton.create(:x => 400, :y => 550, :button_image => "./media/menu/roll-dice-button-unpressed.png",
      :pressed_image => "./media/menu/roll-dice-button-pressed.png")  
  end
end
=end

 class EntryMenu < Chingu::GameState
  def initialize(options = {})
    super
 #   @song = Song["./media/music/cave.ogg"].play(true)
    @level = GameObject.create(:image => "./media/menu/menu-background.png", :rotation_center => :top_left)
    @soloButton = Chingu::PressButton.create(:x => 300, :y => 500, :button_image => "./media/menu/solo-game-button-unpressed.png")
    @onlineButton = Chingu::PressButton.create(:x => 300, :y => 300, :button_image => "./media/pill-button.png",
       :factor_x => 0.3, :factor_y => 0.3)   
 #   @onlineButton = Chingu::PressButton.create(:x => 300, :y => 300, :button_image => "./media/menu/online-game-button-unpressed.png",
  #    :pressed_image => "./media/menu/online-game-button-pressed.png")
    @multiplayerButton = Chingu::PressButton.create(:x => 300, :y => 100, :button_image => "./media/menu/multiplayer-game-button-unpressed.png")
    
    @soloButton.on_click do
      puts "Llendo a solo game"
      @soloButton.set_x = @soloButton.x + 3 
      @soloButton.set_y = @soloButton.y - 5 
    end
    
    @onlineButton.on_click do
      puts "Llendo a online game"
    end    
    
    @multiplayerButton.on_click do
      puts "Llendo a multiplayer game"
      push_game_state(Map1)
    end
  end

end   

 class MapSelect < Chingu::GameState
  def initialize(options = {})
    super
 #   @song = Song["./media/music/cave.ogg"].play(true)
    @level = GameObject.create(:image => "./media/menu/menu-background.png", :rotation_center => :top_left)
    @soloButton = Chingu::PressButton.create(:x => 300, :y => 500, :button_image => "./media/menu/solo-game-button-unpressed.png")   
    @onlineButton = Chingu::PressButton.create(:x => 300, :y => 300, :button_image => "./media/menu/online-game-button-unpressed.png")
    @multiplayerButton = Chingu::PressButton.create(:x => 300, :y => 100, :button_image => "./media/menu/multiplayer-game-button-unpressed.png")

    @exitButton = Chingu::PressButton.create(:x => 750, :y => 30, :button_image => "./media/menu/exit-game-button.png")
      
    @exitButton.on_click do
      $window.close
      exit
    end
    
    @soloButton.on_click do
      puts "Llendo a solo game"
      @soloButton.set_x = @soloButton.x + 3 
      @soloButton.set_y = @soloButton.y - 5 
    end
    
    @onlineButton.on_click do
      puts "Llendo a online game"
    end    
    
    @multiplayerButton.on_click do
      puts "Llendo a multiplayer game"
      switch_game_state(Map1)
    end
  end

end  

 class Map1 < Chingu::GameState
  #
  # initialize() is called when you create the game state
  #
  def initialize(options = {})
    super
    @title = Chingu::Text.create(:text=>"Level #{options[:level].to_s}. P: pause R:restart", :x=>20, :y=>10, :size=>30)
    @level = GameObject.create(:image => "./media/graphics/map1.png", :rotation_center => :top_left)
    
    @interface_back = GameObject.create(:image => "./media/menu/interface-background.png", :x => 400, :y => 550)
    @gasoline = 300
    @boost = 30
    @dice_button = Chingu::PressButton.create(:x => 400, :y => 550, :button_image => "./media/menu/roll-dice-button-unpressed.png")  
      
 #   @dice_label = Chingu::Text.create(:text=>"Dice result: ", :x => 50, :y => 510)
    @boost_label = Chingu::Text.create(:text=>"Boost:", :x => 50, :y => 530)
    @gasoline_label = Chingu::Text.create(:text=>"Gasoline:", :x => 50, :y => 560)
    @boost_cards_label = Chingu::Text.create(:text=> "Boost cards" , :x => 610, :y => 510)
    @dice_label = Chingu::Text.create(:text=> "Dice result:" , :x => 350, :y => 540)
    hide_game_object @dice_label
    
    @gasoline_text = Chingu::Text.create(:text=> @gasoline.to_s , :x => 105, :y => 560)
    @boost_text = Chingu::Text.create(:text=> @boost.to_s , :x => 90, :y => 530)
    @dice_text = Chingu::Text.create(:text=> "" , :x => 420, :y => 540)
    hide_game_object @dice_text
    
    @tiles = []
    current_x = 100
    current_y = 30    
    size_x = 50
    size_y = 50
  #  last_dir = "l"
    map_file = File.open "./maps/map1.map", "r"
    #TODO create the map 
    map_file.each_line do |line|
   #   current_dir = line.split(" ")[0]
   #   case current_dir
   #   when last_dir == current_dir
   #   end  
      line.chomp!
      case line.split(" ")[0] 
        when "up"
          current_y = current_y - size_y
          tile_image = "./media/graphics/vertical.png" 
        when "down" 
          current_y = current_y + size_y  
          tile_image = "./media/graphics/vertical.png"           
        when "left"
          current_x = current_x - size_x         
          tile_image = "./media/graphics/horizontal.png"  
        when "right"
          current_x = current_x + size_x         
          tile_image = "./media/graphics/horizontal.png"           
        when "right-down"
          current_x = current_x - size_x               
          tile_image = "./media/graphics/turn-down-right.png"
        when "down-right"
          current_y = current_y - size_y    
          tile_image = "./media/graphics/turn-down-right.png"          
        when "left-down"
          current_x = current_x + size_x 
          tile_image = "./media/graphics/turn-left-down.png"    
        when "down-left"
          current_y = current_y - size_y  
          tile_image = "./media/graphics/turn-left-down.png"            
        when "left-up"
          current_x = current_x + size_x  
          tile_image = "./media/graphics/turn-left-top.png"  
        when "up-left"
          current_y = current_y + size_y  
          tile_image = "./media/graphics/turn-left-top.png" 
        when "right-up"
          current_x = current_x - size_x  
          tile_image = "./media/graphics/turn-top-right.png"                      
        when "up-right"
          current_y = current_y + size_y 
          tile_image = "./media/graphics/turn-top-right.png"           
        #when ""      
   #   current_x += (line.split(" ")[0]).to_i * size_x
   #   current_y += (line.split(" ")[1]).to_i * size_y
        else
          puts "Corrupted file map, unexpected #{line.split(" ")[0]}\n"
          return
      end
        @tiles.push PressButton.create(:x => current_x.to_i, :y => current_y.to_i, 
          :button_image => tile_image) 
        @tiles.last.active = false  
    end 
    map_file.close  

    @tiles.each_index do |i|
      @tiles[i].on_click do
        #Deactivate the tiles
        @dice_result.times do |j|
          @tiles[(@player.current_tile + j + 1) % @tiles.length].active = false
        end        
        puts "\n"
        #Set new player position and find where he is
        @player.x = @tiles[i].x
        @player.y = @tiles[i].y
        @player.current_tile = i 
        hide_game_object @dice_label
        hide_game_object @dice_text
        show_game_object @dice_button 
        @dice_button.active = true
      end
    end
    
    #Set a random seed
    @rand_generator = Random.new(Time.new.usec)
    
    @player_index_tile = 0
    #If player clicks on dice button, roll the dice
    @dice_button.on_click do
      @dice_result = @rand_generator.rand(1..6)
      #Activate the posible tiles
      @dice_result.times do |j|
        @tiles[(@player.current_tile + j + 1) % @tiles.length].active = true
      end  
      @dice_text.text = @dice_result.to_s
      show_game_object @dice_label
      show_game_object @dice_text
      hide_game_object @dice_button 
      @dice_button.active = false
    end

    #Objects are drawn in order, so player must be last one
    @player = Player.create
    @player.x = @tiles[0].x
    @player.y = @tiles[0].y   

    self.input = {:p => Pause}
  end
end

 class Level < Chingu::GameState
  #
  # initialize() is called when you create the game state
  #
  def initialize(options = {})
    super
  #  @song = Song["./media/music/cave.ogg"].play(true)
    @title = Chingu::Text.create(:text=>"Level #{options[:level].to_s}. P: pause R:restart", :x=>20, :y=>10, :size=>30)
    @level = GameObject.create(:image => "./media/graphics/map1.png", :rotation_center => :top_left)
    @player = Player.create
    @button = Chingu::PressButton.create(:x => 300, :y => 500, :button_image => "./media/menu/solo-game-button-unpressed.png")
    #
    # The below code can mostly be replaced with the use of methods "holding?", "holding_all?" or "holding_any?" in Level#update
    # Using holding? in update could be good if you need fine grained controll over when input is dispatched.
    #

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
    @image = Image["./media/graphics/map1.png"]
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

def readMap options = {}
  map_file = File.open options[:map_name], "r"
  
  map_file.each_line do |line|
    
  end
end

  Game.new.show()
