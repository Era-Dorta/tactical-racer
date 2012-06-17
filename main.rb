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
      #Fast going to play game for development purposes
      player1 = [["Bla"],
          ["./media/graphics/cars/car1.png"]]
      player2 = [["Bla", "Bli"],
          ["./media/graphics/cars/car1.png", "./media/graphics/cars/car2.png"]]
      player3 = [["Bla", "Bli", "Blo"],
          ["./media/graphics/cars/car1.png", "./media/graphics/cars/car2.png",
            "./media/graphics/cars/car3.png",]]            
      push_game_state(Play_Map.new(:map => "map2.map", 
          :players => player3))
      #push_game_state(Number_Players)
    end
  end
end  

#State to set number of players
class Number_Players < BackGameState
  def initialize(options = {})
    super
    Text.create("Choose number of players", :x => 300, :y => 50 )
    @n_players_buttons = []
    j = 0
    #Maximun six players
    6.times do |i|
      @n_players_buttons.push Chingu::PressButton.create(:x => 370, :y => 100 + j, 
      :button_image => "./media/menu/" +(i + 1).to_s + "-button.png")
      j += 50
    end
    
    #Name selection from next state
    @names_entered = 0
    @players_name = [] 
    @message = "Pick a name for player 1:"
    @n_players_buttons.each_index do |i|
      @n_players_buttons[i].on_release do
        push_game_state(Name_Select.new(
        :message => @message, :callback => method(:got_name)))
        @n_players = i + 1
      end
    end   
  end
  
  #Next state will call this funtion every time a name is given
  def got_name name
    if @players_name.include? name
      @message = "Player #{@names_entered + 1}, pick another name:"
      push_game_state(Name_Select.new(
      :message => @message, :callback => method(:got_name)))      
    else
      @names_entered += 1 
      @players_name.push name
      if @names_entered == @n_players
        push_game_state(Car_Selection.new(:players_name => @players_name))  
        #push_game_state(Map_Select.new(:players_name => @players_name))  
      else
      @message = "Pick a name for player #{@names_entered + 1}:"
      push_game_state(Name_Select.new(
      :message => @message, :callback => method(:got_name)))
      end        
    end
  end 
end  

#State that allows player to select theirs name
#TODO create my own awesome EnterName
class Name_Select < GameStates::EnterName
  def initialize(options = {})
    super
    
    @background = GameObject.create(:image => "./media/menu/menu-background.png", 
    :rotation_center => :top_left, :zorder => 0)
    
    #Change starting letter to enter to quick test
    @texts[@index].color = ::Gosu::Color::WHITE
    @index = 55
    @texts[@index].color = ::Gosu::Color::RED
    
    @back_button = Chingu::PressButton.create(:x => 100, :y => 500, 
    :button_image => "./media/menu/back-button.png") 
    @text = Text.create(options[:message], :x => 300, :y => 50 )
    
    @back_button.on_release do
      push_game_state(Number_Players)
    end    
  end
  
  def go
    @callback.call(@name.text)
  end
  
end 

#State that allows players to select which car they want
class Car_Selection < BackGameState
  def initialize(options = {})
    super 
    @players_name = options[:players_name] 
    n_players = @players_name.length 
    i = 0
    @text = Text.create("#{@players_name[i]} pick a car", :x => 300, :y => 50 )
    @players_cars = []
    j = 0
    #Read al file names in map 
    @car_dir = "./media/graphics/cars/"
    Dir.entries(@car_dir).each do |file| 
      if file.include? ".png" and not file.include? "~"
        Text.create(file.gsub(".png",""), :x => 300, :y => 100 + j )
        button = Chingu::PressButton.create(:x => 400, :y => 105 + j, 
        :button_image => @car_dir + file) 
        
        button.on_release do
          @players_cars.push @car_dir + file
          @text.destroy
          i += 1
          if i == n_players
            player_info = [@players_name, @players_cars]
            push_game_state(Map_Select.new(:players => player_info))
          end
          @text = Text.create("#{@players_name[i]} pick a car", 
          :x => 300, :y => 50 )
        end
        
        j += 60
      end     
    end 
  end
end  

#Map selection from map files
class Map_Select < BackGameState
  def initialize(options = {})
    super
    Text.create("Select a map", :x => 300, :y => 10)
    j = 0
    #Read al file names in map 
    Dir.entries("./maps/").each do |file| 
      if file.include? ".map" and not file.include? "~"
        Text.create(file.gsub(".map",""), :x => 300, :y => 50 + j )
        button = Chingu::PressButton.create(:x => 400, :y => 55 + j, 
        :button_image => "./media/menu/play-map-button.png") 
        
        button.on_release do
          push_game_state(Play_Map.new(:map => file, 
          :players => options[:players]))
        end
        j += 60
      end     
    end
  end
end  

#Play_Map need a map file name and players in the next format:
#[[Names],[Cars]] Where names is a vector of names and
#Cars is a vector of car files
class Play_Map < BackGameState
  
  def create_player_interface
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
    @gasoline_text = Chingu::Text.create(:text=> @current_player.current_gas.to_s , :x => 105, :y => 560)
    @boost_text = Chingu::Text.create(:text=> @current_player.main_boost.to_s , :x => 90, :y => 530)
    @dice_text = Chingu::Text.create(:text=> "" , :x => 420, :y => 540)
    hide_game_object @dice_text        
  end
  
  def next_player
    #TODO Make a real next_player
    @player_turn = @player_turn.rotate
    @current_player = @player_turn[0][0]
  end
  
  def set_game_logic
    #TODO Game is more complicated, cards, etc
    
    #Basic mechanic is: roll dice, then pick a square
    @map.each_square do |square|
      square.button.on_release do
        #Deactivate the squares
        @dice_result.times do |j|
          square_index = (@current_player.current_square.index + j + 1) % @map.length
          @map[square_index].button.active = false
        end        
        #Move player
        @current_player.move_car square
        #Allow next player dice rolling
        hide_game_object @dice_label
        hide_game_object @dice_text
        show_game_object @dice_button 
        @dice_button.active = true
        #Set next player
        next_player
      end   
    end   
    
    @dice_button.on_release do
      @dice_result = @current_player.roll_dice
      #Activate the posible squares
      @dice_result.times do |j|
        square_index = (@current_player.current_square.index + j + 1) % @map.length
        if @map[square_index].new_player?        
          @map[square_index].button.active = true
        else
          break  
        end  
      end  
      @dice_text.text = @dice_result.to_s
      show_game_object @dice_label
      show_game_object @dice_text
      hide_game_object @dice_button 
      @dice_button.active = false
    end     
  end
  
  def initialize(options = {})
    super   
    @back_button.on_release do
      push_game_state(Map_Select.new(:players => options[:players]))
    end   
    @map = Map.new options[:map]
    @player_turn = @map.place_players options[:players]
    @current_player = @player_turn[0][0] 
    create_player_interface
    set_game_logic
  end
end  

Game.new.show()
