class Player
			
  def play_turn(warrior)

  	@health ||= 20		# Defines the initial health variable
  	(@health > warrior.health)?  @in_combat = 1 : @in_combat = 0	# Determine whether we are in combat
    
  	# Game state variable declarations
    @health 				= warrior.health
    @action_performed 		= 0
    @warrior				= warrior

    # Game loop
    check_wiz
    check_health if @warrior.feel.empty? && @action_performed == 0
    check_wall if @action_performed == 0
    rescue_captive if @warrior.feel.captive? && @action_performed == 0
    walk_safely if @action_performed == 0
    attack_safely if @action_performed == 0

  end

  def check_health
    if @health < 20 && @in_combat == 0 then
      @warrior.rest!
      perform_action
	end	
  end

  def check_wall
  	if @warrior.feel.wall? then
  		@warrior.pivot! 
  		perform_action
  	end
  end

  def check_wiz
  	look_f = @warrior.look.to_s

  	# Only shoot them if nothing is in our way
  	if look_f.include?('nothing, Wizard,') || look_f.include?('nothing, nothing, Wizard') then
  		@warrior.shoot!
  		perform_action
  	end
  end

  def rescue_captive
  	@warrior.rescue!
  	perform_action 
  end

  def walk_safely
  	# Keep retreating until we reach the safe spot (wall/captive)
  	if @retreating == 1 then 
  		retreating = 0 if @warrior.feel(:backward).wall? || @warrior.feel(:backward).captive?
  		if retreating == 1 then
	  		@warrior.walk! :backward
	  		perform_action
	  		return
  		end
  	end

  	look_f = @warrior.look.to_s
  	look_b = @warrior.look(:backward).to_s
  	
  	# Here it matters how close (or far away!) the archer is because we are judging whether
  	# we have time to run away and heal back to full
	archers = look_f.include?('Archer, Archer') || look_f.include?('nothing, nothing, Archer')

	# Checking whether we have a safe escape route (3 nothing/captive squares - in front or behind)
  	safe_retreat = look_b.include?('nothing, nothing, nothing') || 
  				   look_b.include?('nothing, nothing, Captive') ||
  				   (look_f.include?('nothing, nothing, Archer') && look_b.include?('nothing,'))

  	if archers && safe_retreat && @health < 8 then
  		@warrior.walk! :backward
  		@retreating = 1
  		perform_action
  	elsif @warrior.feel.empty?
  		@warrior.walk!
  		perform_action
  	end
  end

  def attack_safely
  	look_f = @warrior.look.to_s
  	look_b = @warrior.look(:backward).to_s

  	# Here we don't care how close the archer is because presumably we are already
  	# in attack range so we may as well kill it rather than retreat and heal
  	archers = look_f.include?('Archer') || look_b.include?('Archer')

  	if @health < 5 && !archers then
  		@warrior.walk! :backward
  		perform_action
  	else
	  	@warrior.attack!
	  	perform_action
	end
  end

  def perform_action
  	@action_performed = 1
  end

end
