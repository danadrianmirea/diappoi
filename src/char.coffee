class Character extends Sprite
  scale : null
  status : {}
  state : null
  constructor: (@x=0,@y=0,@group=ObjectGroup.Enemy ,status={}) ->
    super @x, @y
    @state =
      alive : true
      active : false
    @targeting = null
    @dir = 0
    @cnt = 0
    @id = ~~(Math.random() * 100)

    @animation = []

  has_target:()->
    if @targeting isnt null then true else false

  is_targeted:(objs)->
     @ in (i.targeting? for i in objs)

  is_alive:()->
    if @status.hp > 1
      @state.alive = true
    else
      @state.hp = 0
      @state.alive = false

  is_dead:()->
    not @is_alive()

  find_obj:(group_id,targets, range)->
    targets.filter (t)=>
      t.group is group_id and @get_distance(t) < range and t.is_alive()

  add_animation:(animation)->
    @animation.push(animation)

  render_animation:(g,x, y)->
    for n in [0...@animation.length]
      if not @animation[n].render(g,x,y)
        @animation.splice(n,1)
        @render_animation(g,x,y)
        break

  set_dir: (x,y)->
    rx = x - @x
    ry = y - @y
    if rx >= 0
      @dir = Math.atan( ry / rx  )
    else
      @dir = Math.PI - Math.atan( ry / - rx  )

  _update_state:()->
    if @is_alive()
      @regenerate()
      if @targeting?.is_dead()
         @targeting = null
    else
      @targeting = null

  regenerate: ()->
    r = (if @targeting then 2 else 1)
    if not (@cnt % (24/@status.regenerate*r)) and @state.alive
      if @status.hp < @status.MAX_HP
        @status.hp += 1

  act:(target=@targeting)->
    if @targeting
      d = @get_distance(@targeting)
      if d < @status.atack_range
        if @status.wt < @status.MAX_WT
          @status.wt += 1
        else
          @atack()
          @status.wt = 0
      else
        if @status.wt < @status.MAX_WT
          @status.wt += 1
    else
      @status.wt = 0

  atack: ()->
    amount = ~~(@status.atk * ( @targeting.status.def + Math.random()/4 ))
    @targeting.status.hp -= amount
    my.mes(@name+" atack "+@targeting.name+" "+amount+"damage")
    @targeting.add_animation new Anim::Slash amount
    # @targeting._update_state()

  select_target:(targets)->
    if @has_target() and targets.length > 0
      if not @targeting in targets
        @targeting = targets[0]
        return
      else if targets.size() == 1
        @targeting = targets[0]
        return
      if targets.size() > 1
        cur = targets.indexOf @targeting
        console.log "before: #{cur} #{targets.size()}"
        if cur+1 >= targets.size()
          cur = 0
        else
          cur += 1
        @targeting = targets[cur]
        console.log "after: #{cur}"

  render_reach_circle:(g,pos)->
      @init_cv(g , color = "rgb(250,50,50)",alpha=0.3)
      g.arc( pos.vx, pos.vy, @status.atack_range ,0,Math.PI*2,true)
      g.stroke()
      @init_cv(g , color = "rgb(50,50,50)",alpha=0.3)
      g.arc( pos.vx, pos.vy, @status.sight_range ,0,Math.PI*2,true)
      g.stroke()

  render_dir_allow:(g,pos)->
      nx = ~~(30 * Math.cos(@dir))
      ny = ~~(30 * Math.sin(@dir))
      my.init_cv(g,color="rgb(255,0,0)")
      g.moveTo( pos.vx , pos.vy )
      g.lineTo(pos.vx+nx , pos.vy+ny)
      g.stroke()

  render_targeting:(g,pos,cam)->
    if @targeting?.is_alive()
      @targeting.render_targeted(g,pos)
      @init_cv(g,color="rgb(0,0,255)",alpha=0.5)
      g.moveTo(pos.vx,pos.vy)
      t = @targeting.getpos_relative(cam)
      g.lineTo(t.vx,t.vy)
      g.stroke()

      my.init_cv(g , color = "rgb(255,0,0)",alpha=0.6)
      g.arc(pos.vx, pos.vy , @scale*0.7 ,0,Math.PI*2,true)
      g.fill()

  render_state: (g,pos)->
    @init_cv(g)
    @render_gages(g,pos.vx, pos.vy+15,40 , 6 , @status.hp/@status.MAX_HP)
    @render_gages(g,pos.vx, pos.vy+22,40 , 6 , @status.wt/@status.MAX_WT)

  render_dead: (g,pos)->
    @init_cv(g,color='rgb(55, 55, 55)')
    g.arc(pos.vx,pos.vy, @scale ,0,Math.PI*2,true)
    g.fill()

  render_gages:( g, x , y, w, h ,percent=1) ->
    # my.init_cv(g,"rgb(0, 250, 100)")
    g.moveTo(x-w/2 , y-h/2)
    g.lineTo(x+w/2 , y-h/2)
    g.lineTo(x+w/2 , y+h/2)
    g.lineTo(x-w/2 , y+h/2)
    g.lineTo(x-w/2 , y-h/2)
    g.stroke()

    # rest
    g.beginPath()
    g.moveTo(x-w/2 +1, y-h/2+1)
    g.lineTo(x-w/2+w*percent, y-h/2+1)
    g.lineTo(x-w/2+w*percent, y+h/2-1)
    g.lineTo(x-w/2 +1, y+h/2-1)
    g.lineTo(x-w/2 +1, y-h/2+1)
    g.fill()

  render_targeted: (g,pos,color="rgb(255,0,0)")->
    @init_cv(g)

    beat = 24
    ms = ~~(new Date()/100) % beat / beat
    ms = 1 - ms if ms > 0.5

    @init_cv(g,color=color,alpha=0.7)
    g.moveTo(pos.vx,pos.vy-12+ms*10)
    g.lineTo(pos.vx-6-ms*5,pos.vy-20+ms*10)
    g.lineTo(pos.vx+6+ms*5,pos.vy-20+ms*10)
    g.lineTo(pos.vx,pos.vy-12+ms*10)

    g.fill()

  render: (g,cam)->
    @init_cv(g)
    pos = @getpos_relative(cam)

    if @state.alive
      @render_object(g,pos)
      @render_state(g,pos)
      @render_dir_allow(g,pos)
      @render_reach_circle(g,pos)
      # @render_targeting(g,pos,cam)
    else
      @render_dead(g,pos)

    @render_animation(g, pos.vx , pos.vy )

class Walker extends Character
  following: null
  targeting: null
  constructor: (@x,@y,@group=ObjectGroup.Enemy,status={}) ->
    super(@x,@y,@group,status)
    @cnt = ~~(Math.random() * 24)
    @distination = [@x,@y]
    @_path = []

  update:(objs, cmap, keys, mouse)->
    @cnt += 1
    if @is_alive()
      @_update_state()
      enemies = @find_obj(ObjectGroup.get_against(@),objs,@status.sight_range)
      if @has_target()
        # ターゲットが存在した場合
        if @targeting.is_dead() or @get_distance(@targeting) > @status.sight_range*1.5
          # 死んでる or 感知外
          @targeting = null
      else if enemies.size() > 0
        # ターゲットが存在せず新たに目視した場合
        @targeting = enemies[0]
        my.mes "#{@name} find #{@targeting.name})"

      @move(objs,cmap, keys,mouse)
      @act(keys,objs)

  move: (objs ,cmap)->
    # for wait
    if @has_target()
      return if @get_distance(@targeting) < @status.atack_range

    if @has_target() and @to and not @cnt%24
    # for trace
      @_path = @_get_path(cmap)
      @to = @_path.shift()
    else if @to
      dp = cmap.get_point(@to[0],@to[1])
      [nx,ny] = @_trace( dp.x , dp.y )
      wide = 7
      if dp.x-wide<nx<dp.x+wide and dp.y-wide<ny<dp.y+wide
        if @_path.length > 0
          @to = @_path.shift()
        else
          @to = null
    # for wander
    else
      if @targeting
        @_path = @_get_path(cmap)
        @to = @_path.shift()
      else
        c = cmap.get_cell(@x,@y)
        @to = [c.x+randint(-1,1),c.y+randint(-1,1)]

    # check collidion
    if not cmap.collide( nx,ny )
      @x = nx if nx?
      @y = ny if ny?

    if @x is @_lx_ and @y is @_ly_
      c = cmap.get_cell(@x,@y)
      @to = [c.x+randint(-1,1),c.y+randint(-1,1)]
    @_lx_ = @x
    @_ly_ = @y

  _get_path:(map)->
    from = map.get_cell( @x ,@y)
    to = map.get_cell( @targeting.x ,@targeting.y)
    return map.search_min_path( [from.x,from.y] ,[to.x,to.y] )

  _trace: (to_x , to_y)->
    @set_dir(to_x,to_y)
    nx = @x + ~~(@status.speed * Math.cos(@dir))
    ny = @y + ~~(@status.speed * Math.sin(@dir))
    return [nx ,ny]


class Goblin extends Walker
  name : "Goblin"
  scale : 1
  constructor: (@x,@y,@group) ->
    @dir = 0
    @status = new Status
      hp  : 50
      wt  : 30
      atk : 10
      def : 1.0
      sight_range : 120
    super(@x,@y,@group,status)

  render_object:(g,pos)->
    if @group == ObjectGroup.Player
      color = Color.White
    else if @group == ObjectGroup.Enemy
      color = Color.i 55,55,55
    @init_cv(g,color=color)
    beat = 20
    ms = ~~(new Date()/100) % beat / beat
    ms = 1 - ms if ms > 0.5
    g.arc( pos.vx, pos.vy, ( 1.3 + ms ) * @scale ,0,Math.PI*2,true)
    g.fill()

class Player extends Walker
  scale : 8
  name : "Player"
  constructor: (@x,@y,@group=ObjectGroup.Player) ->
    super(@x,@y,@group)
    @status = new Status
      hp : 120
      wt : 20
      atk : 10
      def: 0.8
      atack_range : 50
      sight_range : 80
      speed : 6

    @binded_skill =
      one: new Skill_Heal()
      two: new Skill_Smash()
      three: new Skill_Meteor()
    @state.leader =true
    @mouse =
      x: 0
      y: 0

  update:(objs, cmap, keys, mouse)->
    super objs, cmap,keys ,mouse

  update:(objs, cmap, keys, mouse)->
    @cnt += 1
    if @is_alive()
      @_update_state()
      enemies = @find_obj(ObjectGroup.get_against(@),objs,@status.sight_range)
      if @has_target()
        # ターゲットが存在した場合
        if @targeting.is_dead() or @get_distance(@targeting) > @status.sight_range*1.5
          # 死んでる or 感知外
          @targeting = null
      else if enemies.size() > 0
        # ターゲットが存在せず新たに目視した場合
        @targeting = enemies[0]
        my.mes "#{@name} find #{@targeting.name})"

      if keys.zero
        @select_target(enemies)

      @move(objs,cmap, keys,mouse)
      @act(keys,objs)

  set_mouse_dir: (x,y)->
    rx = x - 320
    ry = y - 240
    if rx >= 0
      @dir = Math.atan( ry / rx  )
    else
      @dir = Math.PI - Math.atan( ry / - rx  )

  act: (keys,enemies)->
     super()
     @invoke(keys,enemies)


  invoke: (keys,enemies)->
    list = ["zero","one","two","three","four","five","six","seven","eight","nine"]
    for i in list
      if @binded_skill[i]
        if keys[i]
          @binded_skill[i].do(@,enemies,@mouse)
        else
          @binded_skill[i].charge()

  move: (objs,cmap, keys, mouse)->
    @dir = @set_mouse_dir(mouse.x , mouse.y)

    if keys.right + keys.left + keys.up + keys.down > 1
      move = ~~(@status.speed * Math.sqrt(2)/2)
    else
      move = @status.speed
    if keys.right
      if cmap.collide( @x+move , @y )
        @x = (~~(@x/cmap.cell)+1)*cmap.cell-1
      else
        @x += move
    if keys.left
      if cmap.collide( @x-move , @y )
        @x = (~~(@x/cmap.cell))*cmap.cell+1
      else
        @x -= move
    if keys.up
      if cmap.collide( @x , @y-move )
        @y = (~~(@y/cmap.cell))*cmap.cell+1
      else
        @y -= move
    if keys.down
      if cmap.collide( @x , @y+move )
        @y = (~~(@y/cmap.cell+1))*cmap.cell-1
      else
        @y += move

  render_object:(g,pos)->
    beat = 20
    if @group == ObjectGroup.Player
      color = Color.White
    else if @group == ObjectGroup.Enemy
      color = Color.i 55,55,55
    @init_cv(g,color=color)
    ms = ~~(new Date()/100) % beat / beat
    ms = 1 - ms if ms > 0.5
    g.arc( pos.vx, pos.vy, ( 1.3 - ms ) * @scale ,0,Math.PI*2,true)
    g.fill()

    roll = Math.PI * (@cnt % 20) / 10

    my.init_cv(g,"rgb(128, 100, 162)")
    g.arc(320,240, @scale * 0.5,  roll ,Math.PI+roll,true)
    g.stroke()

  render: (g,cam)->
    super(g,cam)
    @render_mouse(g)

  render_skill_gage: (g)->
    c = 0
    for number,skill of @binded_skill
      @init_cv(g)
      g.fillText( skill.name ,20+c*50 ,  460)
      @render_gages(g, 40+c*50 , 470,40 , 6 , skill.ct/skill.MAX_CT)
      c++

  render_mouse: (g)->
    if @mouse
      my.init_cv(g,"rgb(200, 200, 50)")
      g.arc(@mouse.x,@mouse.y,  @scale ,0,Math.PI*2,true)
      g.stroke()

class Mouse extends Sprite
  constructor: () ->
    @x = 0
    @y = 0

  render_object: (g,pos)->
  render: (g,cam)->
    cx = ~~((@x+mouse.x-320)/cmap.cell)
    cy = ~~((@y+mouse.y-240)/cmap.cell)

ObjectGroup =
  Player : 0
  Enemy  : 1
  Item   : 2
  is_battler : (group_id)->
    group_id in [@Player, @Enemy]
  get_against : (obj)->
    switch obj.group
      when @Player
        return @Enemy
      when @Enemy
        return @Player

class Status
  constructor: (params = {}, @lv = 1) ->
    @params = params
    @build_status(params)
    @hp = @MAX_HP
    @sp = @MAX_SP
    @wt = 0
    @exp = 0
    @next_lv = @lv * 50

  build_status:(params={},lv=1)->
    @MAX_HP = params.hp or 30
    @MAX_WT = params.wt or 10
    @MAX_SP = params.sp or 10
    @atk = params.atk or 10
    @def = params.def or 1.0
    @res = params.res or 1.0
    @regenerate = params.regenerate or 3
    @atack_range = params.atack_range or 50
    @sight_range = params.sight_range or 80
    @speed = params.speed or 6

  get_exp:(point)->
    @exp += point
    if @exp >= @next_lv
      @exp = 0
      @lv++
      @build(lv=@lv)
      @set_next_exp()

  set_next_exp:()->
    @next_lv = @lv * 30

