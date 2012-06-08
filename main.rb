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

    @exitButton.on_release do
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
    j = 0
    #Read al file names in map 
    Dir.entries("./maps/").each do |file| 
      if file.include? ".map"
        Text.create(file.gsub(".map",""), :x => 300, :y => 50 + j )
        button = Chingu::PressButton.create(:x => 400, :y => 55 + j, 
        :button_image => "./media/menu/play-map-button.png") 
        
        button.on_release do
          push_game_state(Play_Map.new(:map => file))
        end
        j += 60
      end     
    end
  end
end  

class Play_Map < Chingu::GameState
  
  def create_map map
    @map = []
    current_x = 100
    current_y = 30    
    size_x = 50
    size_y = 50
    map_file = File.open "./maps/" + map, "r"
    map_file.each_line do |line|
      line.chomp!
      case line.split(" ")[0] 
        when "up"
          current_y = current_y - size_y
          square_image = "./media/graphics/vertical.png" 
        when "down" 
          current_y = current_y + size_y  
          square_image = "./media/graphics/vertical.png"           
        when "left"
          current_x = current_x - size_x         
          square_image = "./media/graphics/horizontal.png"  
        when "right"
          current_x = current_x + size_x         
          square_image = "./media/graphics/horizontal.png"           
        when "right-down"
          current_x = current_x - size_x               
          square_image = "./media/graphics/turn-down-right.png"
        when "down-right"
          current_y = current_y - size_y    
          square_image = "./media/graphics/turn-down-right.png"          
        when "left-down"
          current_x = current_x + size_x 
          square_image = "./media/graphics/turn-left-down.png"    
        when "down-left"
          current_y = current_y - size_y  
          square_image = "./media/graphics/turn-left-down.png"            
        when "left-up"
          current_x = current_x + size_x  
          square_image = "./media/graphics/turn-left-top.png"  
        when "up-left"
          current_y = current_y + size_y  
          square_image = "./media/graphics/turn-left-top.png" 
        when "right-up"
          current_x = current_x - size_x  
          square_image = "./media/graphics/turn-top-right.png"                      
        when "up-right"
          current_y = current_y + size_y 
          square_image = "./media/graphics/turn-top-right.png"           
        else
          puts "Corrupted file map, unexpected #{line.split(" ")[0]}\n"
          return
      end
        square = Square.new
        square.button = PressButton.create(:x => current_x.to_i, :y => current_y.to_i, 
          :button_image => square_image) 
        square.button.active = false   
        @map.push square 
    end 
    map_file.close      
  end
  
  def initialize(options = {})
    super
    @background = GameObject.create(:image => "./media/menu/menu-background.png", 
    :rotation_center => :top_left)
    create_map options[:map]
  end
end  

Game.new.show()