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
# General Public License for more details.
#
# You should have received a copy of the GNU General Public
# License along with this program; if not, write to the Free Software
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

class FactorButton < Chingu::PressButton
  def initialize(options = {})
    if options[:x]
      options[:x] = ($window.width / 1980.0)*options[:x]
    end
    if options[:y]   
      options[:y] = ($window.height / 1200.0)*options[:y]
    end    
    options[:factor_x] = $factor_x
    options[:factor_y] = $factor_y 
    super           
  end
end

class FactorObject < Chingu::GameObject
  def initialize(options = {})    
    if options[:x]
      options[:x] = ($window.width / 1980.0)*options[:x]
    end
    if options[:y]   
      options[:y] = ($window.height / 1200.0)*options[:y]
    end    
    options[:factor_x] = $factor_x
    options[:factor_y] = $factor_y 
    super 
  end
end

class FactorText < Chingu::Text
  def initialize(text, options = {})    
    if options[:x]
      options[:x] = ($window.width / 1980.0)*options[:x]
    end
    if options[:y]   
      options[:y] = ($window.height / 1200.0)*options[:y]
    end   
    options[:size] = (($window.width / 1980.0)*80).round 
    #options[:factor_x] = $factor_x
    #options[:factor_y] = $factor_y 
    super 
  end
end

class Rand_Generator
  def initialize
    @time = Time.new.usec
    @rand_generator = Random.new(Time.new.usec)
  end
  
  def time
    return @time
  end
  
  def get_rand interval
    return @rand_generator.rand(interval)
  end
end

RG = Rand_Generator.new

class Boost_Card
  def initialize value, x, y
    @value = value
    @image = FactorButton.create(:x => x, :y => y, 
          :button_image => "./media/boost_cards/card" + value.to_s + ".png")
    @image.on_click do
      #TODO do something xD
    end          
  end
end

class Square
  attr_reader :button, :index,
  :next_square, :previous_square
  def initialize(options = {})
    @button = options[:button]
    @button.active = false
    @n_lanes = options[:n_lanes]
    @used_lanes = 0
    @players_in_lane = Array.new(@n_lanes, nil)
    @gas_cost = options[:gas_cost]
    @player_may_move = false
    @type = options[:type]
    @size_x = 12
    @size_y = 12
    @lane_offset = 6
    @index = options[:index]
    @next_square = nil
    @previous_square = nil
  end
  
  def search_free_lane
    i = 0
    while @players_in_lane[i] != nil
      i += 1
    end 
    return i
  end
  
  def set_next_square value
    if @next_square
      raise "Trying to change next square of square #{index}"
    else
      @next_square = value
    end
  end
  
  def set_previous_square value
    if @previous_square
      raise "Trying to change previous square of square #{index}"
    else
      @previous_square = value
    end    
  end
  
  def new_player?
      return @used_lanes < @n_lanes
  end
  
  #Gives posible position of a player in this square 
  def player_coord
    if @used_lanes == @n_lanes
      return nil
    end
    #Player position on the square depends on the 
    #type of square, how many cars are in the square
    #and how many cars can be on the square
    current_lane = search_free_lane
    case @type
    when "vertical"
      x = @button.x + @size_x*current_lane - (@n_lanes - 1)*@lane_offset
      y = @button.y - @size_y*current_lane + (@n_lanes - 1)*@lane_offset 
    when "horizontal"
      x = @button.x + @size_x*current_lane - (@n_lanes - 1)*@lane_offset
      y = @button.y - @size_y*current_lane + (@n_lanes - 1)*@lane_offset           
    when "right-down"
      x = @button.x + @size_x*current_lane - (@n_lanes - 1)*@lane_offset
      y = @button.y + @size_y*current_lane - (@n_lanes - 1)*@lane_offset          
    when "left-down"
      x = @button.x + @size_x*current_lane - (@n_lanes - 1)*@lane_offset
      y = @button.y - @size_y*current_lane + (@n_lanes - 1)*@lane_offset        
    when "left-up"
      x = @button.x + @size_x*current_lane - (@n_lanes - 1)*@lane_offset
      y = @button.y + @size_y*current_lane - (@n_lanes - 1)*@lane_offset       
    when "right-up"
      x = @button.x + @size_x*current_lane - (@n_lanes - 1)*@lane_offset
      y = @button.y - @size_y*current_lane + (@n_lanes - 1)*@lane_offset      
    end
    return {:x => x, :y => y} 
  end
  
  #A new player is in the square
  def player_in player
    if @used_lanes < @n_lanes
      @used_lanes += 1
      i = search_free_lane
      @players_in_lane[i] = player
    else
      raise "Square: #{@index} is full but a player wanted to go in\n" 
    end   
  end
  
  #A player leave the square
  def player_out player
    if @used_lanes > 0
      @used_lanes -= 1
      i = @players_in_lane.rindex player
      if i 
        @players_in_lane[i] = nil
      else
        raise "Player #{player} wanted out of Square: #{@index} but he is not in"
      end
    else
      raise "Square: #{@index} is empty but a player wanted to go out\n" 
    end  
  end
    
end

class Boxes_Square < Square
  def initialize
    super
    @gas_cost = 0
  end
  
  def change_tyres player
    player.tyre_change = true
  end
end

class Player < FactorObject
   attr_reader :current_gas, :main_boost, :current_square
   trait :velocity
   trait :animation, :delay => 200
  def initialize(options = {})
    super   
    @last_dice_roll = nil
    @current_square = nil
    @transitional_square = nil
    @current_gas = 300
    @tyre_change = false
    @main_boost = 20
    @dice_record = {1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0}
    @current_lap = 0
    @name = options[:name]
    @boxes = options[:boxes]
    @crashed = false
    @boost_cards = []
    @final_x = 0
    @final_y = 0
    @going_back = false

    @animation = Animation.new(:file => options[:car_image], :delay => 100)
    @image = @animation.first    
    @position_offset = 0.1
    @speed_factor = 0.05
    #self.factor_x = 0.3
    #self.factor_y = 0.3
  end
  
  #Set starting position in a lap
  def set_current_square value
    if @current_square
      raise "Changin player #{@name} current square"
    else
      @current_square = value
    end
  end
  
  #Set a speed vector between two squares
  def set_movement
    position = @transitional_square.player_coord
    @velocity_x = (position[:x] - @x)*@speed_factor
    @velocity_y = (position[:y] - @y)*@speed_factor
    @final_x = position[:x]
    @final_y = position[:y]          
  end
  
  #Move the player to a given square
  def move_car new_square, boost_cards = nil
    #TODO Decrease current_gas, check lap
    #TODO Include boost cards
    if boost_cards
      puts "Not boost cards implemented yet\n"
    else
      @going_back = false
      #Transitional square is for animated movement
      @transitional_square = @current_square.next_square
      @current_square.player_out self
      set_movement
      @current_square = new_square  
      @sound = Sound["./media/music/car_engine.ogg"].play(1)
      #Delete any warning that was shown on rolling dice
      @back_text.destroy if @back_text       
    end   
  end
  
  def roll_dice
    @last_dice_roll = RG.get_rand(1..6)
    @dice_record[@last_dice_roll] += 1
    #If player got six times one move him back
    if @dice_record[1] == 1
      #Reset dice record
      @dice_record[1] = 0
      #Calculate how far he must go
      goes_back = RG.get_rand(1..6)
      i = 0
      new_square = @current_square
      #Check if player can actually go back
      begin
        new_square = new_square.previous_square
        i += 1
      end while i < goes_back and new_square.new_player?
      #If last square is full, advance one
      if not new_square.new_player?
        new_square = new_square.next_square
        i -= 1
      end        
      #If player has to go back   
      if i != 0
        #Show warning
        @back_text = FactorText.create("You got 6 times 1, \n you must go back #{i} squares", 
        :x => 300, :y => 50, :zorder => 120, :size => 20)
                  
        @going_back = true
        @transitional_square = @current_square.previous_square
        @current_square.player_out self
        set_movement
        @sound = Sound["./media/music/car_break.ogg"].play(1)
        @current_square = new_square 
      else
        #Player is lucky and cannot move back
        #Show warning
        @back_text = FactorText.create("You got 6 times 1, \n but you do not have to go back", 
        :x => 300, :y => 50, :zorder => 120, :size => 20)                                      
      end       
    end
    
    #If player got six times six give a card award
    if @dice_record[6] == 6
      @boost_cards.push RG.get_rand(1..6)
      @dice_record[6] = 0
      #TODO Update view
    end    
    return @last_dice_roll
  end
  
  def update 
    #TODO Create better animations
    #Go to next frame of the animation
    @image = @animation.next  if @animation
    #If the player is moving?
    if @velocity_x != 0 or @velocity_y != 0 
      #Did the player got to the square he is moving to?  
      if (@final_x - @position_offset..@final_x + @position_offset).include? @x and 
        (@final_y - @position_offset..@final_y + @position_offset).include? @y then
        #Is this the last square?
        if @transitional_square == @current_square
          @velocity_x = 0
          @velocity_y = 0  
          @current_square.player_in self 
          @sound.stop  
        else
          if @going_back
            @transitional_square = @transitional_square.previous_square 
          else
            @transitional_square = @transitional_square.next_square            
          end
          #Calculate new movement vector for new square
          set_movement     
        end    
      end
    end  
  end
  
end

class Map
  def initialize map
    #TODO fix maps so, it doesnt matter which square is first
    @squares = []
    current_x = 100
    #current_y = 30    
    current_y = 70
    i = 0
    previous_square = nil
    file_type = ".png"
    map_file = File.open "./maps/" + map, "r"
    location = "./media/graphics/squares/"
    #Get width and height of a given square
    test_square = Image[location + "horizontal11" + file_type]  
    #size_x = 50
    #size_y = 50
    size_x = test_square.width
    size_y = test_square.height    
    #Read the map file
    map_file.each_line do |line|
      line.chomp!
      #Calculate where the square should be placed
      case line.split(" ")[0] 
        when "up"
          type = "vertical"
          current_y = current_y - size_y
          square_image = "vertical" 
        when "down" 
          type = "vertical"
          current_y = current_y + size_y  
          square_image = "vertical"           
        when "left"
          type = "horizontal"
          current_x = current_x - size_x         
          square_image = "horizontal"  
        when "right"
          type = "horizontal"
          current_x = current_x + size_x         
          square_image = "horizontal"           
        when "right-down"
          type = "right-down"
          current_x = current_x - size_x               
          square_image = "turn-down-right"
        when "down-right"
          type = "right-down"
          current_y = current_y - size_y    
          square_image = "turn-down-right"          
        when "left-down"
          type = "left-down"
          current_x = current_x + size_x 
          square_image = "turn-left-down"    
        when "down-left"
          type = "left-down"
          current_y = current_y - size_y  
          square_image = "turn-left-down"            
        when "left-up"
          type = "left-up"
          current_x = current_x + size_x  
          square_image = "turn-left-top"  
        when "up-left"
          type = "left-up"
          current_y = current_y + size_y  
          square_image = "turn-left-top" 
        when "right-up"
          type = "right-up"
          current_x = current_x - size_x  
          square_image = "turn-top-right"                      
        when "up-right"
          type = "right-up"
          current_y = current_y + size_y 
          square_image = "turn-top-right"           
        else
          puts "Corrupted file map, unexpected #{line.split(" ")[0]}\n"
          return
      end
      #Get square information and save it in square vector
      n_lanes = line.split(" ")[1].to_i
      gas_cost = line.split(" ")[2].to_i
      square_image = location + square_image + n_lanes.to_s + 
      gas_cost.to_s + file_type
      button = FactorButton.create(:x => current_x.to_i, :y => current_y.to_i, 
        :button_image => square_image) 
      square = Square.new(:type => type, :index => i, :n_lanes => n_lanes, 
      :button => button, :gas_cost => gas_cost ) 
      @squares.push square 
      #Made links between squares
      if i > 0
        previous_square.set_next_square square
        square.set_previous_square previous_square
      end
      i += 1
      previous_square = square
    end 
    #Link last with first square
    @squares.last.set_next_square @squares.first
    @squares.first.set_previous_square @squares.last
    map_file.close      
  end
  
  #Set initial position of the players
  def place_players players
    #TODO here main boost is set
    #Set turns randomly
    @player_turn = []
    @players = []
    c_players = players.clone
    #Asociate every player with its car
    c_players = c_players.transpose
    n_players = c_players.length
    n_players.times do 
      #Pick a player randomly
      player = c_players.sample
      c_players.delete player
      #Create player
      @players.push Player.create(:name => player[0], 
      :car_image => player[1])
      #Insert it in turn queue
      @player_turn.push [@players.last]     
    end
    
    #Place players on the map
    i = 0
    current_square = @squares[i]
    @player_turn.each do |turn|
      turn.each do |player|
        #Ask current square for a player position on it
        player_pos = current_square.player_coord
        #If there is not position, go to next square
        if player_pos == nil
          i = (i - 1) % @squares.length
          current_square = @squares[i]
          player_pos = current_square.player_coord
        end
        #Place player on its square
        player.x = player_pos[:x]
        player.y = player_pos[:y]
        player.set_current_square current_square
        current_square.player_in player
      end
    end 
    return @player_turn   
  end
  
  #Map length in squares
  def length
    return @squares.length
  end
  
  #Method to iterate from every square
  def each_square
    @squares.each do |square|
      yield square
    end  
  end
  
  #Method to access the squares
  def [](i)
    @squares[i]
  end  
 
end

#Standard game state has a background and a back button
#that lets the user go to Entry_Menu
class BackGameState < Chingu::GameState
  def initialize(options = {})
    super
    #The background must go in the background, so zorder minimum
    @background = FactorObject.create(:image => "./media/menu/menu-background.png", 
    :rotation_center => :top_left, :zorder => 0)
    #The back button is always visible, so zorder over than average
    @back_button = FactorButton.create(:x => 100, :y => 510, 
    :button_image => "./media/menu/back-button.png", :zorder => 110)
    @back_button.on_release do
      push_game_state(Entry_Menu)
    end   
  end
end
