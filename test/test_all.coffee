## ge.js ##
# generated by src/core.coffee
class Game
  constructor: (conf) ->
    my.mes("Welcome to the world!")
    canvas =  document.getElementById conf.CANVAS_NAME
    @g = canvas.getContext '2d'
    @config = conf
    canvas.width = conf.WINDOW_WIDTH;
    canvas.height = conf.WINDOW_HEIGHT;
    @keys =
        left : 0
        right : 0
        up : 0
        down : 0
        space : 0
        one : 0
        two : 0
        three : 0
        four : 0
        five : 0
        six : 0
        seven : 0
        eight : 0
        nine : 0
        zero : 0
    @mouse = x : 0, y : 0
    @scenes =
      "Opening": new OpeningScene()
      "Field": new FieldScene()
    @scene_name = "Opening"
    # @curr_scene = @scenes["Opening"]

  enter: ->
    @scene_name = @scenes[@scene_name].enter(@keys,@mouse)
    @draw(@scenes[@scene_name])

    # while 1
    #   next = @scenes[@scene_name].enter(@keys,@mouse)
    #   if next == @scene_name
    #     @scene_name = @scenes[next].enter(@keys,@mouse)
    #     break
    # @draw(@scenes[@scene_name])

  start: (self) ->
    setInterval ->
      self.enter()
    , 1000 / @config.FPS

  getkey: (self,which,to) ->
    switch which
      when 68,39 then self.keys.right = to
      when 65,37 then self.keys.left = to
      when 87,38 then self.keys.up = to
      when 83,40 then self.keys.down = to
      when 32 then self.keys.space = to
      when 17 then self.keys.ctrl = to
      when 48 then self.keys.zero = to
      when 49 then self.keys.one = to
      when 50 then self.keys.two = to
      when 51 then self.keys.three = to
      when 52 then self.keys.four = to
      when 53 then self.keys.five = to
      when 54 then self.keys.sixe = to
      when 55 then self.keys.seven = to
      when 56 then self.keys.eight = to
      when 57 then self.keys.nine = to

  draw: (scene) ->
    @g.clearRect(0,0,@config.WINDOW_WIDTH ,@config.WINDOW_HEIGHT)
    @g.save()
    scene.render(@g)
    @g.restore()

my =
  mes:(text)->
    elm = $("<li>").text(text)
    $("#message").prepend(elm)
  distance: (x1,y1,x2,y2)->
    xd = Math.pow (x1-x2) ,2
    yd = Math.pow (y1-y2) ,2
    return Math.sqrt xd+yd

  init_cv: (g,color="rgb(255,255,255)",alpha=1)->
    g.beginPath()
    g.strokeStyle = color
    g.fillStyle = color
    g.globalAlpha = alpha

  gen_map:(x,y)->
    map = []
    for i in [0..20]
        map[i] = []
        for j in [0..15]
            if Math.random() > 0.5
                map[i][j] = 0
            else
                map[i][j] = 1
    return map

  draw_line: (g,x1,y1,x2,y2)->
    g.moveTo(x1,y1)
    g.lineTo(x2,y2)
    g.stroke()

  color: (r=255,g=255,b=255,name=null)->
    switch name
        when "red" then return @color(255,0,0)
        when "green" then return @color(0,255,0)
        when "blue" then return @color(0,0,255)
        when "white" then return @color(255,255,255)
        when "black" then return @color(0,0,0)
        when "grey" then return @color(128,128,128)
    return "rgb("+~~(r)+","+~~(g)+","+~~(b)+")"

  draw_cell: (g,x,y,cell,color="grey")->
    g.moveTo(x , y)
    g.lineTo(x+cell , y)
    g.lineTo(x+cell , y+cell)
    g.lineTo(x , y+cell)
    g.lineTo(x , y)
    g.fill()

  mklist :(list,func)->
    buf = []
    for i in list
      buf.push(i) if func(i)
    return buf


rjoin = (map1,map2)->
  map1
  return map1.concat(map2)

sjoin = (map1,map2)->
  if not map1[0].length == map2[0].length
    return false
  y = 0
  buf = []
  for i in [0...map1.length]
    buf[i] = map1[i].concat(map2[i])
    y++
  return buf

String::replaceAll = (org, dest) ->
  return @split(org).join(dest)

randint = (from,to) ->
  if not to?
    to = from
    from = 0
  return ~~( Math.random()*(to-from+1))+from

Array::find = (pos)->
  for i in @
    if i.pos[0] == pos[0] and i.pos[1] == pos[1]
      return i
  return null

Array::remove = (obj)->
  @splice(@indexOf(obj),1)
  @
Array::size = ()-> @.length

clone = (obj)->
  F = ()->
  F.prototype = obj
  new F

Color =
  Red : "rgb(255,0,0)"
  Blue : "rgb(0,0,255)"
  Red : "rgb(0,255,0)"
  White : "rgb(255,255,255)"
  Black : "rgb(0,0,0)"
  i : (r,g,b)->
    "rgb(#{r},#{g},#{b})"
# generated by src/sprites.coffee
class Sprite
  constructor: (@x=0,@y=0,@scale=10) ->
  render: (g)->
    g.beginPath()
    g.arc(@x,@y, 15 - ms ,0,Math.PI*2,true)
    g.stroke()

  get_distance: (target)->
    xd = Math.pow (@x-target.x) ,2
    yd = Math.pow (@y-target.y) ,2
    return Math.sqrt xd+yd

  getpos_relative:(cam)->
    pos =
      vx : 320 + @x - cam.x
      vy : 240 + @y - cam.y
    return pos

  init_cv: (g,color="rgb(255,255,255)",alpha=1)->
    g.beginPath()
    g.strokeStyle = color
    g.fillStyle = color
    g.globalAlpha = alpha

class ItemObject extends Sprite
  constructor: (@x=0,@y=0,@scale=10) ->
    @group = 0
  update:()->

  render: (g,cam)->
    @init_cv(g,color="rgb(0,0,255)")
    pos = @getpos_relative cam
    g.beginPath()
    g.arc(pos.vx,pos.vy, 15 - ms ,0,Math.PI*2,true)
    g.stroke()


class Animation extends Sprite
  constructor: (actor,target) ->
    super 0, 0
    @timer = 0

  render:(g,x,y)->
    @timer++

(Anim = {}).prototype =
  Slash: class Slash extends Animation
    constructor: (@amount) ->
      @timer = 0

    render:(g,x,y)->
      if  @timer < 5
        @init_cv(g,color="rgb(30,55,55)")
        tx = x-10+@timer*3
        ty = y-10+@timer*3
        g.moveTo( tx ,ty )
        g.lineTo( tx-8 ,ty-8 )
        g.lineTo( tx-4 ,ty-8 )
        g.lineTo( tx ,ty )
        g.fill()
        @timer++
        return @
      else
        return false

# generated by src/maps.coffee
class Map extends Sprite
  constructor: (@cell=32) ->
    super 0, 0, @cell
    @_map = @load(maps.debug)

  gen_blocked_map : ()->
    map = @gen_map()
    m = base_block
    m = rjoin(m,m)
    m = sjoin(m,m)
    return map

  load : (text)->
    tmap = text.replaceAll(".","0").replaceAll(" ","1").split("\n")
    max = Math.max.apply null,(row.length for row in tmap)
    map = []
    for y in [0...tmap.length]
      map[y]= ((if i < tmap[y].length then parseInt tmap[y][i] else 1) for i in [0 ... max])

    map = @_rotate90(map)
    map = @_set_wall(map)
    return map

  gen_random_map:(x,y)->
    map = []
    for i in [0 ... x]
      map[i] = []
      for j in [0 ... y]
        if (i == 0 or i == (x-1) ) or (j == 0 or j == (y-1))
          map[i][j] = 1
        else if Math.random() < 0.2
          map[i][j] = 1
        else
          map[i][j] = 0
    return map

  get_point: (x,y)->
    return {x:~~((x+1/2) *  @cell ),y:~~((y+1/2) * @cell) }

  get_cell: (x,y)->
    x = ~~(x / @cell)
    y = ~~(y / @cell)
    return {x:x,y:y}

  get_rand_cell_xy : ()->
    rx = ~~(Math.random()*@_map.length)
    ry = ~~(Math.random()*@_map[0].length)
    if @_map[rx][ry]
      return @get_rand_cell_xy()
    return [rx,ry]

  get_rand_xy: ()->
    rx = ~~(Math.random()*@_map.length)
    ry = ~~(Math.random()*@_map[0].length)
    if @_map[rx][ry]
      return @get_rand_xy()
    return @get_point(rx,ry)


  collide: (x,y)->
    x = ~~(x / @cell)
    y = ~~(y / @cell)
    return @_map[x][y]

  search_min_path: (start,goal)->
    path = []
    Node::start = start
    Node::goal = goal
    open_list = []
    close_list = []

    start_node = new Node(Node::start)
    start_node.fs = start_node.hs
    open_list.push(start_node)

    search_path =[
      [-1,-1], [ 0,-1], [ 1,-1]
      [-1, 0]         , [ 1, 0]
      [-1, 1], [ 0, 1], [ 1, 1]
    ]

    max_depth = 100
    for _ in [1..max_depth]
      return [] if open_list.size() < 1 #探索失敗

      open_list.sort( (a,b)->a.fs-b.fs )
      min_node = open_list[0]
      close_list.push( open_list.shift() )

      if min_node.pos[0] is min_node.goal[0] and min_node.pos[1] is min_node.goal[1]
        path = []
        n = min_node
        while n.parent
          path.push(n.pos)
          n = n.parent
        return path.reverse()

      n_gs = min_node.fs - min_node.hs

      for i in search_path # 8方向探索
        [nx,ny] = [i[0]+min_node.pos[0] , i[1]+min_node.pos[1]]
        if not @_map[nx][ny]
          dist = Math.pow(min_node.pos[0]-nx,2) + Math.pow(min_node.pos[1]-ny,2)

          if obj = open_list.find([nx,ny])
            if obj.fs > n_gs+obj.hs+dist
              obj.fs = n_gs+obj.hs+dist
              obj.parent = min_node
          else if obj = close_list.find([nx,ny])
            if obj.fs > n_gs+obj.hs+dist
                obj.fs = n_gs+obj.hs+dist
                obj.parent = min_node
                open_list.push(obj)
                close_list.remove(obj)
          else
            n = new Node([nx,ny])
            n.fs = n_gs+n.hs+dist
            n.parent = min_node
            open_list.push(n)
    return []

  render: (g,cam)->
    pos = @getpos_relative(cam)
    for i in [0 ... @_map.length]
      for j in [0 ... @_map[i].length]
        if @_map[i][j]

          @init_cv(g, color="rgb(30,30,30)")
          w = 8
          x = pos.vx+i*@cell
          y = pos.vy+j*@cell
          g.moveTo(x         ,y+@cell)
          g.lineTo(x+w       ,y+@cell-w)
          g.lineTo(x+@cell+w ,y+@cell-w)
          g.lineTo(x+@cell   ,y+@cell)
          g.lineTo(x         ,y+@cell)
          g.fill()

          @init_cv(g, color="rgb(40,40,40)")
          g.moveTo(x  ,y+@cell)
          g.lineTo(x  ,y)
          g.lineTo(x+w,y-w)
          g.lineTo(x+w,y-w+@cell)
          g.lineTo(x  ,y+@cell)
          g.fill()

  render_after:(g,cam)->
    pos = @getpos_relative(cam)
    for i in [0 ... @_map.length]
      for j in [0 ... @_map[i].length]
        if @_map[i][j]
          my.init_cv(g , color = "rgb(50,50,50)",alpha=1)
          w = 5
          g.fillRect(
            pos.vx + i * @cell+w,
            pos.vy + j * @cell-w,
            @cell , @cell)

  _rotate90:(map)->
    res = []
    for i in [0...map[0].length]
      res[i] = ( j[i] for j in map)
    res

  _set_wall:(map)->
    x = map.length
    y = map[0].length
    map[0] = (1 for i in [0...map[0].length])
    map[map.length-1] = (1 for i in [0...map[0].length])
    for i in map
      i[0]=1
      i[i.length-1]=1
    map


class SampleMap extends Map
  max_object_count: 4
  frame_count : 0

  constructor: (@context , @cell=32) ->
    super @cell
    @_map = @load(maps.debug)

  update:(objs,camera)->
    @_check_death(objs,camera)
    @_pop_enemy(objs)

  _check_death: (objs,camera)->
    for i in [0 ... objs.length]
      if not objs[i].state.alive
        if objs[i] is camera
          start_point = @get_rand_xy()
          player  =  new Player(start_point.x ,start_point.y, 0)
          @context.set_camera player
          objs.push(player)
          objs.splice(i,1)
        else
          objs.splice(i,1)
        break

  _pop_enemy: (objs) ->
    # リポップ条件確認
    if objs.length < @max_object_count and @frame_count % 24*3 == 0
      group = (if Math.random() > 0.05 then ObjectGroup.Enemy else ObjectGroup.Player )
      random_point  = @get_rand_xy()
      objs.push( new Goblin(random_point.x, random_point.y, group) )
      if Math.random() < 0.3
        objs[objs.length-1].state.leader = 1

class Node
  start: [null,null]
  goal: [null,null]
  constructor:(pos)->
    @pos    = pos
    @owner_list  = null
    @parent = null
    @hs     = Math.pow(pos[0]-@goal[0],2)+Math.pow(pos[1]-@goal[1],2)
    @fs     = 0

  is_goal:(self)->
    return @goal == @pos

maps =
  filed1 : """

                                             .........
                                      ................... .
                                 ...........            ......
                              ....                      ..........
                           .....              .....        ...... .......
                   ..........              .........        ............ .....
                   ............          ...... . ....        ............ . ..
               .....    ..    ...        ..  ..........       . ..................
       ..     ......          .........................       . .......   ...... ..
      .....    ...     ..        .......  ...............      ....        ........
    ...... ......    .....         ..................... ..   ....         ........
    .........   ......  ...............  ................... ....            ......
   ...........    ... ... .... .   ..   .. ........ ............             . .....
   ...........    ...... ...       ....................           ......
  ............   .......... .    .......... ...... .. .       ...........
   .. ........ .......   ....   ...... .   ............      .... .......
   . ..............       .... .. .       ..............   ...... ..... ..
    .............          .......       ......       ......... . ...... .
    ..     .... ..         ... .       ....         .........   ...........
   ...       .......   ........       .. .        .... ....  ... ..........
  .. .         ......  .........      .............. ..  .....  ...    .....
  .....         ......................................      ....        ....
   .....       ........    ... ................... ....     ...        ....
     ....   ........        ...........................  .....        .....
     ...........  ..        ........ .............. ... .. .         .....
         ......                 .........................           .. ..
                                  .....................          .......
                                      ...................        ......
                                          .............
"""
  debug : """
                ....
             ...........
           ..............
         .... ........... .
        .......  ..  ........
   .........    ..     ......
   ........   ......    .......
   .........   .....    .......
    .................. ........
        .......................
        ....................
              .............
                 ......
                  ...

"""
base_block = [
  [ 1,1,0,1,1 ]
  [ 1,0,0,1,1 ]
  [ 0,0,0,0,0 ]
  [ 1,0,0,0,1 ]
  [ 1,1,0,1,1 ]
  ]


# generated by src/char.coffee
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

# generated by src/skills.coffee
class Skill
  constructor: (ct=1, @lv=1) ->
    @MAX_CT = ct * 24
    @ct = @MAX_CT
  do:(actor)->
  charge:(actor)->
    @ct += 1 if @ct < @MAX_CT

class Skill_Heal extends Skill
  constructor: (@lv=1) ->
    super(15 , @lv)
    @name = "Heal"

  do:(actor)->
    target = actor
    if @ct >= @MAX_CT
      target.status.hp += 30
      target.check_state()
      @ct = 0
      console.log "do healing"
    else
      # console.log "wait "+((@MAX_CT-@ct)/24)

class Skill_Smash extends Skill
  constructor: (@lv=1) ->
    super(8 , @lv)
    @name = "Smash"

  do:(actor)->
    target = actor.targeting
    if target
      if @ct >= @MAX_CT
        target.status.hp -= 30
        target.check_state()
        @ct = 0
        console.log "Smash!"

class Skill_Meteor extends Skill
  constructor: (@lv=1) ->
    super(20 , @lv)
    @name = "Meteor"
    @range = 120

  do:(actor,targets)->
    if @ct >= @MAX_CT
      targets_on_focus = actor.get_targets_in_range(targets=targets , @range)
      if targets_on_focus.length
        console.log targets_on_focus.length
        for t in targets_on_focus
          t.status.hp -= 20
          t.check_state()
        @ct = 0
        console.log "Meteor!"


class Skill_ThrowBomb extends Skill
  constructor: (@lv=1) ->
    super(ct=10 , @lv)
    @name = "Throw Bomb"
    @range = 120
    @effect_range = 30

  do:(actor,targets,mouse)->
    if @ct >= @MAX_CT
      targets_on_focus = actor.get_targets_in_range(targets=targets , @range)
      if targets_on_focus.length
        console.log targets_on_focus.length
        for t in targets_on_focus
          t.status.hp -= 20
          t.check_state()
        @ct = 0
        console.log "Meteor!"
# generated by src/scenes.coffee
class Scene
  enter: (keys,mouse) ->
    return @name

  render: (g)->
    @player.render g
    g.fillText(
        @name,
        300,200)

class OpeningScene extends Scene
  name : "Opening"
  constructor: () ->
    @player  =  new Player(320,240)

  enter: (keys,mouse) ->
    if keys.space
      return "Field"
    return @name

  render: (g)->
    my.init_cv(g)
    g.fillText(
        "Opening",
        300,200)
    g.fillText(
        "Press Space",
        300,240)


class FieldScene extends Scene
  name : "Field"
  _camera : null

  constructor: () ->
    @map = new SampleMap(@,32)
    @mouse = new Mouse()

    # mapの中のランダムな空白にプレーヤーを初期化
    start_point = @map.get_rand_xy()
    player  =  new Player(start_point.x ,start_point.y, 0)
    @objs = [player]
    @set_camera( player )

  enter: (keys,mouse) ->
    # @objs.map (i)-> i.update(@objs,@map,keys,mouse)
    obj.update(@objs, @map,keys,mouse) for obj in @objs
    @map.update @objs,@_camera
    @frame_count++
    return @name

  set_camera: (obj)->
    @_camera = obj

  render: (g)->
    @map.render(g, @_camera)
    obj.render(g,@_camera) for obj in @objs
    @map.render_after(g, @_camera)

    player = @_camera

    if player
      player.render_skill_gage(g)
      my.init_cv(g)
      g.fillText(
          "HP "+player.status.hp+"/"+player.status.MAX_HP,
          15,15)
    #
      # if @player.distination
      #   g.fillText(
      #       " "+@player.distination.x+"/"+@player.distination.y,
      #       15,35)

      # if player.mouse
      #   g.fillText(
      #       "p: "+(player.x+player.mouse.x-320)+"."+(player.y+player.mouse.y-240)
      #       15,25)

    # if @player.targeting
    #   g.fillText(
    #       "p: "+@player.targeting.status.hp+"."+@player.targeting.status.MAX_HP
    #       15,35)
vows = require 'vows'
assert = require 'assert'

keys =
   left : 0
   right : 0
   up : 0
   down : 0
mouse =
  x : 320
  y : 240

p = console.log


vows.describe('Game Test').addBatch
  'combat test':
    topic: "astar"
    'test1': ()->
      map = new Map(32)
      s = map.get_rand_cell_xy()
      g = map.get_rand_cell_xy()
      path =  map.search_route( s , g )
      p s
      while path?.length >0
        pos = path.shift()
        dp = map.get_point(pos[0],pos[1])
        p dp

.export module
