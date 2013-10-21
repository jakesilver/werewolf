class GamesController < ApplicationController

  before_filter :verify_is_admin


  # GET /games
  # GET /games.json
  def index
    @games = Game.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @games }
    end
  end

  # GET /games/1
  # GET /games/1.json
  def show
    @game = Game.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @game }
    end
  end

  # GET /games/new
  # GET /games/new.json
  def new
    @game = Game.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @game }
    end
  end

  # GET /games/1/edit
  def edit
    @game = Game.find(params[:id])
  end

  # POST /games
  # POST /games.json
  def create
    @game = Game.new(params[:game])

    respond_to do |format|
      if @game.save
        format.html { redirect_to @game, notice: 'Game was successfully created.' }
        format.json { render json: @game, status: :created, location: @game }
      else
        format.html { render action: "new" }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /games/1
  # PUT /games/1.json
=begin
  def update
    @game = Game.find(params[:id])

    respond_to do |format|
      if @game.update_attributes(params[:game])
        format.html { redirect_to @game, notice: 'Game was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end
=end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game = Game.find(params[:id])
    @game.destroy

    respond_to do |format|
      format.html { redirect_to games_url }
      format.json { head :no_content }
    end
  end

  def restart_game
    @curgame = Game.find(Player.first.game_id)
    @dayNightFreq = @curgame.dayNightFreq
    @kill_radius = @curgame.kill_radius
    @curgame.game_state = "ended"
    @curgame.save
    @newGame = Game.create(:kill_radius => @kill_radius, :dayNightFreq => @dayNightFreq, :game_state => "started")
    respond_to do |format|
      format.html { redirect_to games_url }
      format.json { render json: "game restarted" }
    end

  end

  def start_game
    @new_game = Game.new(:dayNightFreq => params[:dayNightFreq], :game_state => "started", :kill_radius => params[:kill_radius])
    if @new_game.save
      respond_to do |format|
        format.json {render json: "game started"}
      end
    else
      respond_to do |format|
        format.json {render json: "error--game not started"}
      end
    end
  end


end
