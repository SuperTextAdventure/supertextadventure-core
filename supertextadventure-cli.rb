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

class Room
  attr_accessor :id, :name, :description, :items, :monsters, :doors

  def initialize
    @id = SecureRandom.uuid
    @name = nil
    @description = nil
    @items = []
    @monsters = []
    @doors = []
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
  attr_accessor :direction, :description

  def initialize
    @direction = nil
    @description = nil
  end
end

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
    action = nil
    while action != :exit_builder do
      action = p.select("What would you like to do?") do |menu|
        menu.choice name: "Add a Room",  value: :create_room
        menu.choice name: "List Rooms", value: :list_rooms
        menu.choice name: "Exit Game Builder",  value: :exit_builder
      end

      case action
      when :create_room
        create_room
      when :list_rooms
        list_rooms
      when :exit_builder
        exit_builder
      end
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
        room.items << item
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
        monster.health = p.ask("Enter the monster's health (default 100):".colorize(:light_blue), default: "100", convert: :int) do |q|
          q.default "100"
          q.convert :int
        end
        p.say("Monster health set to '#{monster.health}'.".colorize(:green))
        monster.attack_power = p.ask("Enter the monster's attack power (default 10):".colorize(:light_blue)) do |q|
          q.default "10"
          q.convert :int
        end
        p.say("Monster attack power set to '#{monster.attack_power}'.".colorize(:green))
        room.monsters << monster
        p.ok("Monster '#{monster.name}' added to room '#{room.name}'.")
        newline
      end
    end

    add_doors = true
    while add_doors
      add_doors = p.yes?("Would you like to add doors to this room?")
      if add_doors
        door = Door.new
        
        door.direction = p.select("Select the direction of the door:".colorize(:light_blue)) do |menu|
          menu.choice name: "North", value: "north"
          menu.choice name: "South", value: "south"
          menu.choice name: "East", value: "east"
          menu.choice name: "West", value: "west"
        end
        p.say("Door direction set to '#{door.direction}'.".colorize(:green))
        door.description = p.ask("Enter a description for the door (optional):".colorize(:light_blue))
        p.say("Door description set to '#{door.description}'.".colorize(:green))
        room.doors << door
        p.ok("Door to the '#{door.direction}' added to room '#{room.name}'.")
        newline
      end
    end

    GameData.add_room(room)
    p.ok("Room '#{room.name}' created successfully!")
    newline
  end

  def list_rooms
    if DATA[:game][:rooms].empty?
      p.say("No rooms have been added yet.".colorize(:red))
    else
      p.ok("Current Rooms:")
    end
    wait
    newline
    build_process
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
