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

class N_Players < Chingu::GameState
  def initialize(options = {})
    super
    @background = GameObject.create(:image => "./media/menu/menu-background.png", 
    :rotation_center => :top_left)
    @back_button = Chingu::PressButton.create(:x => 100, :y => 500, 
    :button_image => "./media/menu/back-button.png")
    
    @back_button.on_release do
      push_game_state(Entry_Menu)
    end
    
    Text.create("Choose number of players", :x => 300, :y => 50 )
    @n_players_buttons = []
    j = 0
    6.times do |i|
      @n_players_buttons.push Chingu::PressButton.create(:x => 100, :y => 100 + j, 
      :button_image => "./media/menu/" +(i + 1).to_s + "-button.png")
    end
    
    @n_players_buttons.each_index do |i|
      @n_players_buttons[i].on_release do
        #TODO pass information about players and select name
        push_game_state(Map_Select(:n_players => i + 1))
      end
    end    
  end
end  

class Map_Select < Chingu::GameState
  def initialize(options = {})
    super
    @background = GameObject.create(:image => "./media/menu/menu-background.png", 
    :rotation_center => :top_left)
    @back_button = Chingu::PressButton.create(:x => 100, :y => 500, 
    :button_image => "./media/menu/back-button.png")
    Text.create("Select a map", :x => 300, :y => 10)
    
    @back_button.on_release do
      push_game_state(Entry_Menu)
    end
    j = 0
    #Read al file names in map 
    Dir.entries("./maps/").each do |file| 
      if file.include? ".map" and not file.include? "~"
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
    file_type = ".png"
    map_file = File.open "./maps/" + map, "r"
    map_file.each_line do |line|
      line.chomp!
      case line.split(" ")[0] 
        when "up"
          type = "vertical"
          current_y = current_y - size_y
          square_image = "./media/graphics/vertical" 
        when "down" 
          type = "vertical"
          current_y = current_y + size_y  
          square_image = "./media/graphics/vertical"           
        when "left"
          type = "horizontal"
          current_x = current_x - size_x         
          square_image = "./media/graphics/horizontal"  
        when "right"
          type = "horizontal"
          current_x = current_x + size_x         
          square_image = "./media/graphics/horizontal"           
        when "right-down"
          type = "right-down"
          current_x = current_x - size_x               
          square_image = "./media/graphics/turn-down-right"
        when "down-right"
          type = "right-down"
          current_y = current_y - size_y    
          square_image = "./media/graphics/turn-down-right"          
        when "left-down"
          type = "left-down"
          current_x = current_x + size_x 
          square_image = "./media/graphics/turn-left-down"    
        when "down-left"
          type = "left-down"
          current_y = current_y - size_y  
          square_image = "./media/graphics/turn-left-down"            
        when "left-up"
          type = "left-up"
          current_x = current_x + size_x  
          square_image = "./media/graphics/turn-left-top"  
        when "up-left"
          type = "left-up"
          current_y = current_y + size_y  
          square_image = "./media/graphics/turn-left-top" 
        when "right-up"
          type = "right-up"
          current_x = current_x - size_x  
          square_image = "./media/graphics/turn-top-right"                      
        when "up-right"
          type = "right-up"
          current_y = current_y + size_y 
          square_image = "./media/graphics/turn-top-right"           
        else
          puts "Corrupted file map, unexpected #{line.split(" ")[0]}\n"
          return
      end
        square_image += line.split(" ")[1] + line.split(" ")[2] + file_type
        square = Square.new
        square.button = PressButton.create(:x => current_x.to_i, :y => current_y.to_i, 
          :button_image => square_image) 
        square.button.active = false  
        square.type = type 
        @map.push square 
    end 
    map_file.close      
  end
  
  def place_players players
    #Set turns randomly
    @player_turn = []
    c_players = Array.new(players)
    n_players = c_players.length
    n_players.times do 
      #Pick a player randomly
      player = c_players.sample
      c_players.delete player
      #Insert it in turn queue
      @player_turn.push [player]     
    end
    
    #Place players on the map
    i = 0
    current_square = @map[i]
    @player_turn.each do |turn|
      turn.each do |player|
        #Ask current square for a player position on it
        player_pos = current_square.player_coord
        #If there is not position, go to next square
        if player_pos == nil
          i += 1
          current_square = @map[i]
          player_pos = current_square.player_coord
        end
        #Place player on its square
        player.x = player_pos[:x]
        player.y = player_pos[:y]
        player.current_square = i
        @map[i].player_in
      end
    end    
  end
  
  def initialize(options = {})
    super
    @background = GameObject.create(:image => "./media/menu/menu-background.png", 
    :rotation_center => :top_left)
    @back_button = Chingu::PressButton.create(:x => 100, :y => 500, 
    :button_image => "./media/menu/back-button.png")
    
    @back_button.on_release do
      push_game_state(Map_Select)
    end    
    
    create_map options[:map]
    @players = []
    @players.push Player.create(:name => "Pepe", :car_image => "./media/graphics/car1.png")
    @players.push Player.create(:name => "Juan", :car_image => "./media/graphics/car2.png")
    @players.push Player.create(:name => "Andres", :car_image => "./media/graphics/car3.png")
    place_players @players
    
    current_player = @player_turn[0][0]
    #Create the player interface
    @interface_back = GameObject.create(:image => "./media/menu/interface-background.png", 
    :x => 400, :y => 550)
    @dice_button = Chingu::PressButton.create(:x => 400, :y => 550, 
    :button_image => "./media/menu/roll-dice-button-unpressed.png")
    @boost_label = Chingu::Text.create(:text=>"Boost:", :x => 50, :y => 530)
    @gasoline_label = Chingu::Text.create(:text=>"Gasoline:", :x => 50, :y => 560)
    @boost_cards_label = Chingu::Text.create(:text=> "Boost cards" , :x => 610, :y => 510)
    @dice_label = Chingu::Text.create(:text=> "Dice result:" , :x => 350, :y => 540)
    hide_game_object @dice_label
    
    @gasoline_text = Chingu::Text.create(:text=> current_player.current_gas.to_s , :x => 105, :y => 560)
    @boost_text = Chingu::Text.create(:text=> current_player.main_boost.to_s , :x => 90, :y => 530)
    @dice_text = Chingu::Text.create(:text=> "" , :x => 420, :y => 540)
    hide_game_object @dice_text    
  end
end  

Game.new.show()