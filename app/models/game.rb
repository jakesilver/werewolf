require 'rubygems'
require 'rufus-scheduler'


class Game < ActiveRecord::Base
  attr_accessible :createdDate, :dayNightFreq, :dayORnight
  validates :authenticate_user!, :dayNightFreq, presence: true

  after_create :set_roles


  protected

  def set_roles

    @cur_game = Game.last                                                         #set cur.game to the last game made
    puts @cur_game.dayNightFreq

    @cur_time = @cur_game.dayORnight




    scheduler = Rufus::Scheduler.start_new

    scheduler.every (Rufus.to_time_string(@cur_game.dayNightFreq)) do
      @cur_time = !@cur_time
      if (@cur_time == true)
        puts "it's nighttime"
        @cur_game.update_attribute(:dayORnight, "true")                    #create new scheduler that
      else                                                             #changes day/night based on the
        @cur_game.update_attribute(:dayORnight, "false")                     #dayNightFreq (in minutes)
        puts  "it's daytime"                                             #true = night, false = day
      end
      @cur_game.save

    end

    @players = Player.all                                                #sets all players to "townspeople"
    for player in @players do
      player.Alignment = "townspeople"
      player.save
    end

    size = Player.count
    puts size
    num_wolves = (size*3)/10
    i = 0
    while i < num_wolves do

      @curPlayer = Player.offset(rand(Player.count)).first             #randomly selects 30% of players to
      @curPlayer.Alignment = "werewolf"                                #be werewolfs
      @curPlayer.save
      i+=1
    end

  end



end
