class Kill < ActiveRecord::Base
  attr_accessible :killerID, :lat, :lng, :victimID

  validates :killerID, :presence => true
  validates :victimID, :presence => true
  validates :lat, :presence => true
  validates :lng, :presence => true

  after_save :game_checker


  protected

  def game_checker
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

