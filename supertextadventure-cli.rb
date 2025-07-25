#!/usr/bin/env ruby

require 'tty-prompt'
require 'colorize'

DATA = {
  player: {
    name: nil,
  },
  game: {
    rooms: []
  }
}

def newline(x=1)
  x.times { puts }
end

def wait(x=2)
  sleep(x)
end

intro = <<~'INTRO'

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

prompt = TTY::Prompt.new

prompt.ok intro

player_name = prompt.ask("What is your name, adventurer?".colorize(:light_blue))

DATA[:player][:name] = player_name

newline(2)

prompt.ok("Welcome, #{DATA[:player][:name]}!")

newline(2)
wait

selection = prompt.select("What would you like to do?") do |menu|
  menu.choice name: "Build an Adventure",  value: 'build'
  menu.choice name: "Play a Game", value: 'play'
end

prompt.say("You chose to #{selection}.", color: :yellow)
