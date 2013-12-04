class UsersController < ApplicationController
  skip_before_filter :signed_in_user, only: [:new,:create]


  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])
    if @user.id == current_user.id
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @user }
      end
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end


  def create
    @user = User.new(params[:user])
    @user.high_score = 0
    @user.total_score = 0


    if @user.save
      respond_to do |format|
        format.json { render json: "{'message':'user created'}"}
      end
    else
      respond_to do |format|
        format.json { render json: "{'message':'ERROR'}"}
      end

    end
  end


  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  def user_details
    details=Hash.new
    details['vote']="no"
    details['kill']="no"
    details['total_score'] = current_user.total_score
    details['high_score'] = current_user.high_score
    details['username'] = current_user.email.split("@")[0]
    details['rank']=User.order('total_score').all.index(current_user)
    if (!Game.last.nil?) and (Game.last.game_state != "ended")
      details['isgame'] = "playing"
      @player = Player.find_by_user_id(current_user.id)
      if (@player.isDead == "true")
        details['status'] = "Dead"
      else
        details['status'] = "Alive: " + Player.find_by_user_id(current_user.id).alignment.upcase
        if Player.find_by_user_id(current_user.id).alignment == "werewolf"
          details['kill']="yes"
        else
          details['vote']="yes"
        end
      end
      details['game_score'] = Player.find_by_user_id(current_user.id).score
      details['alive'] = Player.find_by_user_id(current_user.id).isDead
      details['werewolf']=0
      details['townsperson']=0
      Player.all.each do |player|
        if player.isDead == "false"
          details[player.alignment] = details[player.alignment] + 1
        end
      end
      if (((Time.now - Game.find(@player.game_ID).created_at) % (120*Game.find(@player.game_ID).dayNightFreq)) < (Game.find(@player.game_ID).dayNightFreq*60))
        details['time'] = 'day'
      else
        details['time'] = 'night'
      end
      details['place']=Player.order('score').all.index(Player.find_by_user_id(current_user.id))
    else
      details['isgame']= "no game"
      details['status']="No Game Playing"
      details['game_score']=""
      details['alive']=""
      details['werewolf']=0
      details['townsperson']=0
      details['time']="ended"
      details['place']=""
    end
    respond_to do |format|
      format.json { render json: details }
    end

  end

  def totalscoreboard
    score_hash = Hash.new
    scores = User.where(:order => 'total_score', :limit => 5).all
    i = 0
    while i < 5
      score_hash[i]=scores[i].email.split("@")[0] + ": " +scores[i].total_score.to_s
      i+=1
    end
#
    respond_to do |format|
      format.json {render json: score_hash}
    end

  end
  def gscoreboard
    score_hash = Hash.new
    if (!Player.first.nil?)
      scores = Player.where(:order => 'score', :limit => 5).all
      i = 0
      while i < 5
        score_hash[i]=scores[i].email.split("@")[0] + ": " + scores[i].high_score.to_s
        i+=1
      end
    else
      score_hash[0] = "No Current Game"
      score_hash[1] = "N/A"
      score_hash[2] = "N/A"
      score_hash[3] = "N/A"
      score_hash[4] = "N/A"
    end


    respond_to do |format|
      format.json {render json: score_hash}
    end

  end
end
