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
require '../chingu/lib/chungu.rb'
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
