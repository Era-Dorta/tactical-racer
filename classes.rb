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
require 'singleton'
#require 'chingu'
include Gosu
include Chingu

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
    @image = PressButton.create(:x => x, :y => y, 
          :button_image => "./media/boost_cards/card" + value.to_s + ".png")
    @image.on_click do
      #TODO do something xD
    end          
  end
end

class Square
  attr_accessor :n_lanes, :button, :type
  def initialize
    @button = nil
    @n_lanes = 3
    @used_lanes = 0
    @gas_cost = 1
    @player_may_move = false
    @type = nil
    @size_x = 12
    @size_y = 12
    @lane_offset = 5
    @extra_offset = 15
  end
  
  def player_coord
    if @used_lanes == @n_lanes
      return nil
    end
    #Player position on the square depends on the 
    #type of square, how many cars are in the square
    #and how many cars can be on the square
    case @type
    when "vertical"
      x = @button.x + @size_x*@used_lanes - (@n_lanes - 1)*@lane_offset
      y = @button.y - @extra_offset
    when "horizontal"
      x = @button.y
      y = @button.y + @size_y*@used_lanes + (@n_lanes - 1)*@lane_offset - @extra_offset          
    when "right-down"
      x = @button.x + @size_x*@used_lanes - (@n_lanes - 1)*@lane_offset
      y = @button.y + @size_y*@used_lanes + (@n_lanes - 1)*@lane_offset - @extra_offset         
    when "left-down"
      x = @button.x + @size_x*@used_lanes - (@n_lanes - 1)*@lane_offset
      y = @button.y - @size_y*@used_lanes + (@n_lanes - 1)*@lane_offset - @extra_offset       
    when "left-up"
      x = @button.x + @size_x*@used_lanes - (@n_lanes - 1)*@lane_offset
      y = @button.y + @size_y*@used_lanes + (@n_lanes - 1)*@lane_offset - @extra_offset      
    when "right-up"
      x = @button.x + @size_x*@used_lanes - (@n_lanes - 1)*@lane_offset
      y = @button.y - @size_y*@used_lanes + (@n_lanes - 1)*@lane_offse - @extra_offset      
    end
    return {:x => x, :y => y} 
  end
  
  def player_in
    if @used_lanes < @n_lanes
      @used_lanes += 1
    else
      raise "Square: #{@button.x} #{@button.y} is full but a player wanted to go in\n" 
    end   
  end
  
  def player_out
    if @used_lanes > 0
      @used_lanes -= 1
    else
      raise "Square: #{@button.x} #{@button.y} is emppty but a player wanted to go out\n" 
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

class Player < Chingu::GameObject
   attr_accessor :tyre_change, :map, :current_square
   attr_reader :current_gas, :main_boost
  def initialize(options = {})
    super
   
    @last_dice_roll = nil
    @current_square = 0
    @current_gas = 300
    @tyre_change = false
    @main_boost = 20
    @dice_record = Array.new(6,0)
    @current_lap = 0
    @name = options[:name]
    @boxes = options[:boxes]
    @crashed = false
    @boost_cards = []
    @map = nil
 
    @image = Image[options[:car_image]]
    self.factor_x = 0.3
    self.factor_y = 0.3
  end
  
  def move movement, boost_cards
    #TODO make player move
  end
  
  def roll_dice
    @last_dice_roll = RG.get_rand(1..6)
    @dice_record[@last_dice_roll] += 1
    
    #If player got six times one move him back
    if @dice_record[1] == 6
      goes_back = RG.get_rand(1..6)
      #TODO Move player back
      @dice_record[1] = 0
    end
    
    #If player got six times six give a card award
    if @dice_record[6] == 6
      @boost_cards.push RG.get_rand(1..6)
      @dice_record[6] = 0
      #TODO Update view
    end      
  end
end

