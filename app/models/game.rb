require 'rubygems'
require 'rufus-scheduler'


class Game < ActiveRecord::Base
  attr_accessible :dayNightFreq, :dayORnight, :game_state, :kill_radius, :scent_radius
  validates :dayNightFreq, presence: true
  validates :game_state, presence: true
  validates :kill_radius, presence: true
  validates :scent_radius, presence: true


  after_create :set_roles


  protected

  def set_roles

    @cur_game = Game.last                                                         #set cur.game to the last game made
    #puts @cur_game.dayNightFreq

    create_players(@cur_game.id)

    size = Player.count
    #puts size
    num_wolves = (size*3)/10
    i = 0
    while i < num_wolves do

      @curPlayer = Player.offset(rand(Player.count)).first             #randomly selects 30% of players to
      @curPlayer.Alignment = "werewolf"                                #be werewolfs
      @curPlayer.save
      i+=1
    end

    #@cur_time = @cur_game.dayORnight




    @scheduler = Rufus::Scheduler.start_new



    @scheduler.every (Rufus.to_time_string(@cur_game.dayNightFreq*60)) do
=begin
      @cur_time = !@cur_time
      if (@cur_time == true)
        puts "it's nighttime"
        @cur_game.update_attribute(:dayORnight, "true")                    #create new scheduler that

      else                                                             #changes day/night based on the
        @cur_game.update_attribute(:dayORnight, "false")                     #dayNightFreq (in minutes)
        puts  "it's daytime"                                             #true = night, false = day

      end
      @cur_game.save
=end
    timer(@cur_game.id)

    end


=begin
    @players = Player.all                                                #sets all players to "townspeople"
    for player in @players do
      player.Alignment = "townspeople"
      player.isDead = false
      player.lat = rand(max = 100)
      player.lng = rand(max = 100)
      player.save
    end
=end



  end

  def timer(game_id)
    if Game.find(game_id).game_state != "ended"
      @scheduler2 = Rufus::Scheduler.start_new
      @scheduler2.every (Rufus.to_time_string (@cur_game.dayNightFreq*120)) do
        if Game.find(game_id).game_state != "ended"
          poll_votes(game_id)
        else
          @scheduler2.stop
          #puts "stopped scheduler"
        end

      end
    end
  end

  def create_players(game_id)
    Player.delete_all
    User.all.each do |user|
      #puts "making player"
      @new_player = Player.new(:vote_cast => "false", :votes_for => 0, :game_id => game_id, :isDead => "false", :Alignment => "townsperson",
                          :user_id => user.id, :score => 0, :lat => rand(10), :lng => rand(10), :nickname => user.email.split('@')[0])
      @new_player.save
    end
  end

  def poll_votes(game_id)
    most_votes = Player.first

    Player.all.each do |player|
      if player.votes_for > most_votes.votes_for
        most_votes = player
      end

      most_votes.isDead = "true"
      most_votes.save
    end
    Player.all.each do |player|
      if player.isDead == "false"
        player.score += 50
      end
      player.votes_for = 0
      player.vote_cast = "false"
      player.save
    end
    game_checker(game_id)


  end

  def game_checker(game_id)
    @wolves = Player.where(:Alignment => "werewolf",:isDead => "false")
    @towns = Player.where(:Alignment => "townsperson", :isDead => "false")
    #puts @wolves
    #puts @towns
    if (@wolves.length > @towns.length) or (@wolves.length == 0)
      @cur_game = Game.find(game_id)
      @cur_game.game_state = "ended"
      @cur_game.save

      @new_report = Report.new
      if @wolves.length > @towns.length
        @new_report.winners = "Wolves"
        Player.all.each do |player|
          if player.Alignment == "werewolf" and player.isDead == "false"
            player.score += 500
            player.save
          end
        end
      else
        @new_report.winners = "Townspeople"
        Player.all.each do |player|
          if player.Alignment == "townsperson" and player.isDead == "false"
            player.score += 500
            player.save
          end
        end
      end
      @new_report.game_ID = @cur_game.id
      high_score = Player.first

      Player.all.each do |player|
        if player.score > high_score.score
          high_score = player
        end
      end
      @new_report.high_score = high_score.nickname + " : " + high_score.score.to_s
      @new_report.save

      Player.all.each do |player|
        User.find(player.UserID).total_score += player.score
        if player.score > User.find(player.UserID).high_score
          User.find(player.UserID).high_score = player.score
        end
        User.find(player.UserID).save
      end

      Player.delete_all
    end
  end



end
