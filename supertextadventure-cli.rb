#!/usr/bin/env ruby

require 'tty-prompt'
require 'colorize'

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
      menu.choice name: "Add a Room",  value: :add_room
      menu.choice name: "List Rooms", value: :list_rooms
      menu.choice name: "Exit Game Builder",  value: :exit_builder
    end

    case action
    when :add_room
      add_room
    when :list_rooms
      list_rooms
    when :exit_builder
      exit_builder
    end
  end

  def add_room
    p.say("We're working on this part".colorize(:yellow))
    wait
    newline
    build_process
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
