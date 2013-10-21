class PlayersController < ApplicationController

  before_filter :verify_is_admin

  # GET /players
  # GET /players.json
  def index
    @players = Player.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @players }
    end
  end

=begin
  # GET /players/1
  # GET /players/1.json
  def show
    @player = Player.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @player }
    end
  end

  # GET /players/new
  # GET /players/new.json
  def new
    @player = Player.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @player }
    end
  end

  # GET /players/1/edit
  def edit
    @player = Player.find(params[:id])
  end

  # POST /players
  # POST /players.json
  def create
    @player = Player.new(params[:player])

    respond_to do |format|
      if @player.save
        format.html { redirect_to @player, notice: 'Player was successfully created.' }
        format.json { render json: @player, status: :created, location: @player }
      else
        format.html { render action: "new" }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /players/1
  # PUT /players/1.json
  def update
    @player = Player.find(params[:id])

    respond_to do |format|
      if @player.update_attributes(params[:player])
        format.html { redirect_to @player, notice: 'Player was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /players/1
  # DELETE /players/1.json
  def destroy
    @player = Player.find(params[:id])
    @player.destroy

    respond_to do |format|
      format.html { redirect_to players_url }
      format.json { head :no_content }
    end
  end
=end

  def get_possible_kills
    @player = Player.find(params[:id])
    poss_kills = Hash.new
    if (@player.Alignment == "werewolf") and (@player.isDead == "false") and (((Time.now - Game.find(@player.game_id).created_at) %
        (120*Game.find(@player.game_id).dayNightFreq)) > (Game.find(@player.game_id).dayNightFreq*60))
      Player.all.each do |player|
        if (player.UserID != @player.UserID) and (player.Alignment == "townsperson") and (player.isDead == "false")
          if (player.lat - @player.lat).abs + (player.lng - @player.lng).abs < Game.find(@player.game_ID).kill_radius
            poss_kills[player.nickname] = player.UserID
          end
        end
      end
    end
    respond_to do |format|
      format.json { render json: poss_kills}
    end

  end


  def kill_player
    puts params[:nickname]
    @player = Player.find_by_user_id( current_user.id)
    @victim = Player.find_by_nickname(params[:nickname])
    if @player.Alignment == "werewolf" and (((Time.now - Game.last.created_at) % (2*Game.last.dayNightFreq)) > Game.last.dayNightFreq)
      if ((@victim.lat - @player.lat).abs + (@victim.lng - @player.lng).abs < 5) and
          (@victim.Alignment == "townsperson") and (@victim.id != @player.id) and
          (@player.isDead == "false") and (@victim.isDead == "false") #will have to adjust distances

        @victim.isDead = "true"
        @victim.save
        #current_user.total_score += 100     #fix this
        @player.score += 100
        @new_kill = Kill.new(:killerID => @player.UserID, :victimID => @victim.UserID, :lat => @victim.lat, :lng => @victim.lng)

        respond_to do |format|
          format.json { render json: "kill successful"}
        end
        @new_kill.save
      else
        respond_to do |format|
          format.json { render json: "kill unsuccessful"}
        end
      end
    else
      respond_to do |format|
        format.json { render json: "kill unsuccessful"}
      end

    end
  end

  def report_position
    @player = Player.find_by_user_id(current_user.id)
    @player.lat = params[:lat]
    @player.lng = params[:lng]
    @player.save
  end

  def vote_for_player
    @player = Player.find_by_user_id(current_user.id)
    @voted = Player.find_by_nickname(params[:nickname])
    #puts current_user.id
    #puts @player.nickname
    if (@player.isDead == "false") and (@player.vote_cast == "false") and ((Time.now - Game.find(@player.game_id).created_at) > Game.find(@player.game_id).dayNightFreq*60) and
        (((Time.now - Game.find(@player.game_id).created_at) % (120*Game.find(@player.game_id).dayNightFreq)) < (Game.find(@player.game_id).dayNightFreq*60))
      if @voted.isDead == "false"
        @voted.votes_for += 1
        @voted.save
        @player.vote_cast = "true"
        if @voted.Alignment == "werewolf"
          @player.score+=25
        end
        @player.save
        respond_to do |format|
          format.json { render json: "vote successful"}
        end
      else
        respond_to do |format|
          format.json { render json: "vote unsuccessful"}
        end
      end
    else
      respond_to do |format|
        format.json { render json: "vote unsuccessful"}
      end
    end
  end

  def players_alive
    alive = Hash.new
    Player.all.each do |player|
      if player.isDead == "false"
        alive[player.nickname] = player.UserID
      end
    end
    respond_to do |format|
      format.json {render json: alive}
    end
  end


  def get_votables
    poss_votes = Hash.new
    #puts current_user.id
    @player = Player.find_by_user_id(current_user.id)
    if @player.isDead == "false" and @player.vote_cast == "false" and ((Time.now - Game.find(@player.game_id).created_at) > Game.find(@player.game_id).dayNightFreq*60) and
     (((Time.now - Game.find(@player.game_id).created_at) % (120*Game.find(@player.game_id).dayNightFreq)) < (Game.find(@player.game_id).dayNightFreq*60))
      if @player.Alignment == "townsperson"

        Player.all.each do |player|
          if player.isDead == "false"
            poss_votes[player.nickname] = player.UserID
          end
        end
      end
    end
    respond_to do |format|
      format.json {render json: poss_votes}
    end
  end


end









