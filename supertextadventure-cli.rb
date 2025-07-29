#!/usr/bin/env ruby

require 'tty-prompt'
require 'colorize'
require 'securerandom'

DATA = {
  player: {
    name: nil,
  },
  session_mode: nil,
  game: {
    name: nil,
    rooms: []
  }
}

class GameData
  class << self
    def player_name
      DATA[:player][:name]
    end

    def player_name=(name)
      DATA[:player][:name] = name
    end

    def session_mode
      DATA[:session_mode]
    end

    def session_mode=(mode)
      DATA[:session_mode] = mode
    end

    def get_room(id)
      DATA[:game][:rooms].find { |room| room.id == id }
    end

    # Expects an instance of Room
    def add_room(room)
      DATA[:game][:rooms] << room
    end

    def room_name_exists?(name)
      DATA[:game][:rooms].any? { |room| room.name.downcase == name.downcase }
    end

    def all_rooms
      DATA[:game][:rooms]
    end

    def room_list_for_select
      DATA[:game][:rooms].map do |room|
        { name: room.name, value: room.id }
      end
    end
  end
end

def newline(x=1)
  x.times { puts }
end

def wait(x=1)
  sleep(x)
end

INTRO = <<~'INTRO'

Welcome To
_____________________________________________________
|     ____                       _____         _    |
|   / ___| _   _ _ __   ___ _ _|_   _|____  _| |_   |
|   \___ \| | | | '_ \ / _ \ '__|| |/ _ \ \/ / __|  |
|    ___) | |_| | |_) |  __/ |   | |  __/>  <| |_   |
|   |____/ \__,_| .__/ \___|_|   |_|\___/_/\_\\__|  |
|               |_|                                 |
|     _       _                 _                   |
|    / \   __| |_   _____ _ __ | |_ _   _ _ __ ___  |
|   / _ \ / _` \ \ / / _ \ '_ \| __| | | | '__/ _ \ |
|  / ___ \ (_| |\ V /  __/ | | | |_| |_| | | |  __/ |
| /_/   \_\__,_| \_/ \___|_| |_|\__|\__,_|_|  \___| |
|                                                   |
-----------------------------------------------------
                                Your Adventure Awaits

INTRO

PROMPT = TTY::Prompt.new

# Base class for shared functionality
class Base
  attr_accessor :prompt
 
  def initialize
    @prompt = PROMPT
  end

  def p
    @prompt
  end

  def self.run
    new.run
  end
end

# Intro class for staring application
class Intro < Base
  CHOICES = {
    "build" => "Build an Adventure",
    "play" => "Play a Game"
  }

  def run
    p.ok(INTRO)

    player_name = p.ask("What is your name, adventurer?".colorize(:light_blue))

    DATA[:player][:name] = player_name

    newline

    p.ok("Welcome, #{DATA[:player][:name]}!")

    newline
    wait

    selection = p.select("What would you like to do?", CHOICES.invert)

    DATA[:session_mode] = selection

    p.say("You chose to #{CHOICES[selection]}.".colorize(:yellow))

    newline
    wait
  end
end

class GameObject
  def self.prompt_attribut(name)
    define_method(name) do
      details[name.to_s]
    end

    define_method("#{name}=") do |value|
      self.details[name.to_s] = value
    end
  end
end

# Room class that represents items in the DATA[:game][:rooms] array
class Room
  attr_accessor :id, :name, :description, :items, :monsters, :doors

  def initialize
    @id = SecureRandom.uuid
    @name = nil
    @description = nil
    @items = []
    @monsters = []
    @doors = {}
  end

  def add_item(item)
    @items << item
  end

  def add_monster(monster)
    @monsters << monster
  end

  def add_door(door)
    @doors[door.direction] = door
  end

end

class Item
  attr_accessor :id, :name, :description, :room_id, :inventory_item

  def initialize
    @id = SecureRandom.uuid
    @name = nil
    @description = nil
    @room_id = nil
    @inventory_item = false
  end
end

class Monster
  attr_accessor :id, :name, :description, :health, :attack_power, :room_id

  def initialize
    @id = SecureRandom.uuid
    @name = nil
    @description = nil
    @health = 100
    @attack_power = 10
    @room_id = nil
  end

  def self.create_for_room(room_id)
    monster = new
    monster.room_id = room_id
    monster.name = "Default Monster"
    monster.description = "A fearsome creature."
    monster.health = 100
    monster.attack_power = 10
    monster
  end
end

class Door
  attr_accessor :direction, :description, :destination_room_id,

  def initialize
    @direction = nil
    @description = nil
    @destination_room_id = nil
  end
end

# GameBuilder class for adding game data
class GameBuilder < Base
  def run
    p.ok("Starting Game Builder...".colorize(:yellow))
    newline
    wait

    p.say("Let's build your adventure, #{DATA[:player][:name]}!".colorize(:light_blue))
    newline

    name_game if DATA[:game][:name].nil?

    build_process
  end

  def name_game
    game_name = p.ask("What is the name of your game?".colorize(:light_blue))

    DATA[:game][:name] = game_name.strip
    p.ok("Game name set to '#{DATA[:game][:name]}'.")
    newline
  end

  def build_process
    action = p.select("What would you like to do?") do |menu|
      menu.choice name: "Create a Room",  value: :create_room
      menu.choice name: "Change a Room",  value: :edit_room
      menu.choice name: "Create an Item",  value: :create_item
      menu.choice name: "Create a Monster",  value: :create_monster
      menu.choice name: "List Rooms", value: :list_rooms
      menu.choice name: "Exit Game Builder",  value: :exit_builder
    end

    case action
    when :create_room
      create_room
    when :edit_room
      p.say("Room editing functionality is not yet implemented.".colorize(:red))
    when :create_item
      create_item
    when :create_monster
      p.say("Monster creation functionality is not yet implemented.".colorize(:red))
    when :list_rooms
      list_rooms
    when :exit_builder
      exit_builder
    end
  end

  def create_room
    room = Room.new

    room.name = p.ask("Enter the name of the room:".colorize(:light_blue))
    if GameData.room_name_exists?(room.name)
      p.say("A room with that name already exists.".colorize(:red))
      room = nil
      create_room
    end
    p.say("Room name set to '#{room.name}'.".colorize(:green))

    room.description = p.ask("Enter a description for the room:".colorize(:light_blue))
    p.say("Room description set to '#{room.description}'.".colorize(:green))
    
    add_items = true
    while add_items
      add_items = p.yes?("Would you like to add items to this room?")
      if add_items
        item = Item.new
        item.room_id = room.id
        item.name = p.ask("Enter the name of the item:".colorize(:light_blue))
        p.say("Item name set to '#{item.name}'.".colorize(:green))
        item.description = p.ask("Enter a description for the item:".colorize(:light_blue))
        p.say("Item description set to '#{item.description}'.".colorize(:green))
        room.add_item(item)
        p.ok("Item '#{item.name}' added to room '#{room.name}'.")
        newline
      end
    end

    add_monsters = true
    while add_monsters
      add_monsters = p.yes?("Would you like to add monsters to this room?")
      if add_monsters
        monster = Monster.new
        monster.room_id = room.id
        monster.name = p.ask("Enter the name of the monster:".colorize(:light_blue))
        p.say("Monster name set to '#{monster.name}'.".colorize(:green))
        monster.description = p.ask("Enter a description for the monster:".colorize(:light_blue))
        p.say("Monster description set to '#{monster.description}'.".colorize(:green))
        monster.health = p.ask("Enter the monster's health (default 100):".colorize(:light_blue)) do |q|
          q.default = "100"
          q.convert :int
        end
        p.say("Monster health set to '#{monster.health}'.".colorize(:green))
        monster.attack_power = p.ask("Enter the monster's attack power (default 10):".colorize(:light_blue)) do |q|
          q.default = "10"
          q.convert :int
        end
        p.say("Monster attack power set to '#{monster.attack_power}'.".colorize(:green))
        room.add_monster(monster)
        p.ok("Monster '#{monster.name}' added to room '#{room.name}'.")
        newline
      end
    end

    add_doors = true
    while add_doors
      add_doors = p.yes?("Would you like to add doors to this room?")
      if add_doors
        door = Door.new
        
        unless GameData.all_rooms.empty?
          destination_room = p.yes?("Does this door lead to another room?")
          if destination_room
            door.destination_room_id = p.select("Select the destination room:".colorize(:light_blue), GameData.room_list_for_select)
            p.say("Door destination room set to '#{GameData.get_room(door.destination_room_id).name}'.".colorize(:green))
          end
        end

        door.direction = p.select("Select the direction of the door:".colorize(:light_blue)) do |menu|
          menu.choice name: "North", value: "north"
          menu.choice name: "South", value: "south"
          menu.choice name: "East", value: "east"
          menu.choice name: "West", value: "west"
        end
        p.say("Door direction set to '#{door.direction}'.".colorize(:green))
        door.description = p.ask("Enter a description for the door (optional):".colorize(:light_blue))
        p.say("Door description set to '#{door.description}'.".colorize(:green))
        room.add_door(door)
        p.ok("Door to the '#{door.direction}' added to room '#{room.name}'.")
        newline
      end
    end

    GameData.add_room(room)
    p.ok("Room '#{room.name}' created successfully!")
    newline

    list_rooms

    wait
    newline
    build_process
  end

  def edit_room
    if GameData.all_rooms.empty?
      p.say("No rooms available to edit.".colorize(:red))
      build_process
    else
      room_id = p.select("Select a room to edit:", GameData.room_list_for_select)

      room = GameData.get_room(room_id)
      if room.nil?
        p.say("Room not found.".colorize(:red))
        build_process
      else
        p.ok("Editing Room: #{room.name}")
        newline

        room.name = p.ask("Enter the new name of the room (current: #{room.name}):".colorize(:light_blue)) do |q|
          q.default = room.name
        end
        p.say("Room name updated to '#{room.name}'.".colorize(:green))

        room.description = p.ask("Enter a new description for the room (current: #{room.description}):".colorize(:light_blue)) do |q|
          q.default = room.description
        end
        p.say("Room description updated to '#{room.description}'.".colorize(:green))

        # Further editing options can be added here

        p.ok("Room '#{room.name}' updated successfully!")
        newline

        list_rooms
      end
    end
  end

  def list_rooms
    if DATA[:game][:rooms].empty?
      p.say("No rooms have been added yet.".colorize(:red))
    else
      p.ok("Current Rooms:")
      GameData.all_rooms.each do |room|
        p.say("Room ID: #{room.id}".colorize(:light_blue))
        p.say("Name: #{room.name}".colorize(:green))
        p.say("Description: #{room.description}".colorize(:yellow))
        newline
      end
    end
    wait
    newline
  end

  def exit_builder
    p.say("Exiting Game Builder...".colorize(:light_blue))
    newline
    wait
  end
end

# Run The App

Intro.run

if DATA[:session_mode] == "build"
  GameBuilder.run
else
  p.say("Game playing functionality is not yet implemented.".colorize(:red))
end

PROMPT.ok("Thank you for playing Super Text Adventure CLI!")
newline

# Display the DATA hash for debugging purposes
PROMPT.say("Current Session Data:".colorize(:light_blue))

puts DATA
