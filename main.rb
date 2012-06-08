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

require './classes.rb'

class Escape_Menu < Chingu::GameState
  def initialize(options = {})
    super
    #On scape key return to where the user was
    self.input = { :escape => :pop_game_state }
    @level = GameObject.create(:image => "./media/menu/escape-menu-background.png",
    :x => 400, :y => 300)

    @exitButton = Chingu::PressButton.create(:x => 400, :y => 300,
    :button_image => "./media/menu/exit-game-button.png")

    @exitButton.on_click do
      $window.close
      exit
    end
  end
end

class Game < Chingu::Window
  def initialize
    super(800,600,false)
    #Show cursor
    $window.cursor = true
    #On scape key pop esc menu
    self.input = { :escape => :push}
    #First state is menu
    push_game_state(Entry_Menu)
    transitional_game_state(Chingu::GameStates::FadeTo, {:speed => 30})
  end

  def push
    if current_game_state.is_a?(Escape_Menu)
      push_game_state(@previous_game_state)
    else
      @previous_game_state = current_game_state
      push_game_state(Escape_Menu)
    end
  end
end

class Entry_Menu < Chingu::GameState
  def initialize(options = {})
    super
    @song = Song["./media/music/cave.ogg"].play(true)
    @background = GameObject.create(:image => "./media/menu/menu-background.png", 
    :rotation_center => :top_left)
    @soloButton = Chingu::PressButton.create(:x => 300, :y => 500, 
    :button_image => "./media/menu/solo-game-button-unpressed.png")
    @onlineButton = Chingu::PressButton.create(:x => 300, :y => 300, 
    :button_image => "./media/menu/online-game-button-unpressed.png")   
    @multiplayerButton = Chingu::PressButton.create(:x => 300, :y => 100, 
    :button_image => "./media/menu/multiplayer-game-button-unpressed.png")
    
    @soloButton.on_release do
      #TODO Solo vs IA game
    end
    
    @onlineButton.on_release do
      #TODO play online with friends
    end    
    
    @multiplayerButton.on_release do
      push_game_state(Map_Select)
    end
  end
end  

class Map_Select < Chingu::GameState
  def initialize(options = {})
    super
    @background = GameObject.create(:image => "./media/menu/menu-background.png", 
    :rotation_center => :top_left)
    @maps = []
    @maps_button = []
    #Read al file names in map 
    Dir.entries("./maps/").each do |file| 
      if file.include? ".map"
        @maps.push file
      end  
      
    end
    @text = Chingu::PressButtonText.create("blablabla", :x => 300, :y => 500 )
   # @text.on_click do
      puts "yea\n"
      puts @text.width
   # end
    
        @multiplayerButton = Chingu::PressButton.create(:x => 300, :y => 100, 
    :button_image => "./media/menu/multiplayer-game-button-unpressed.png")
      @multiplayerButton.on_click do
      puts "yea2\n"
      puts @multiplayerButton.width
    end  
    
    
  end
end  



Game.new.show()
