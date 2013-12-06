class KillsController < ApplicationController

    def daily_report
      kills_hash = Hash.new
      if Game.all.length != 0
        if (((Time.now - Game.last.created_at) % (120*Game.last.dayNightFreq)) < (Game.last.dayNightFreq*60))  #daytime
          Kill.all.each do |kill|
            if Time.now - kill.created_at < 120*Game.last.dayNightFreq
              kills_hash[i] = Player.find_by_user_id(@kills[i].victimID).nickname+ " killed at " \
              + @kills[i].created_at.to_s.split("UTC")[0] + " at position : " + @kills[i].lat.to_s + ",  " \
              + @kills[i].lng.to_s
            end
          end
        end
      end
      respond_to do |format|
        format.json {render json: kills_hash}
      end
    end



end