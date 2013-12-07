class Kill < ActiveRecord::Base
  attr_accessible :killerID, :lat, :lng, :victimID

  validates :killerID, :presence => true
  validates :victimID, :presence => true
  validates :lat, :presence => true
  validates :lng, :presence => true

  after_save :check_game


  protected

  def check_game(game_id)
    @wolves = Player.where(:alignment => "werewolf",:isDead => "false")
    @townies = Player.where(:alignment => "townsperson", :isDead => "false")
    #puts @wolves
    #puts @townies
    if (@wolves.length > @townies.length) or (@wolves.length == 0)
      @cur_game = Game.find(game_id)
      @cur_game.game_state = "ended"
      @cur_game.save

      @new_report = Report.new
      if (@wolves.length > @townies.length)
        @new_report.winners = "Werewolves"
        Player.all.each do |player|
          if player.alignment == "werewolf" and player.isDead == "false"
            player.score += 150
            player.save
          end
        end
      else
        @new_report.winners = "Townspeople"
        Player.all.each do |player|
          if player.alignment == "townsperson" and player.isDead == "false"
            player.score += 150
            player.save
          end
        end
      end
      @new_report.game_ID = @cur_game.id
      @high_score = Player.first
      Player.all.each do |player|
        if player.score > @high_score.score
          @high_score = player
        end
      end
      @new_report.high_score = @high_score.nickname + " : " + @high_score.score.to_s
      @new_report.save

      Player.all.each do |player|
        @userr = User.find(player.user_id)
        @userr.total_score += player.score
        if player.score > @userr.high_score
          @userr.high_score = player.score
        end
        @userr.level = @userr.total_score / 500
        @userr.save
      end

      Player.delete_all
    end
  end
end