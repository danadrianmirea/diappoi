(function() {
  var FieldScene, OpeningScene, Scene;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  Scene = (function() {
    function Scene(name) {
      this.name = name;
    }
    Scene.prototype.enter = function(keys, mouse) {
      return this.name;
    };
    Scene.prototype.render = function(g) {
      this.player.render(g);
      return g.fillText(this.name, 300, 200);
    };
    return Scene;
  })();
  OpeningScene = (function() {
    __extends(OpeningScene, Scene);
    function OpeningScene() {
      OpeningScene.__super__.constructor.call(this, "Opening");
      this.player = new Player(320, 240);
    }
    OpeningScene.prototype.enter = function(keys, mouse) {
      if (keys.right) {
        return "Filed";
      }
      return this.name;
    };
    OpeningScene.prototype.render = function(g) {
      this.player.render(g);
      return g.fillText("Opening", 300, 200);
    };
    return OpeningScene;
  })();
  FieldScene = (function() {
    __extends(FieldScene, Scene);
    function FieldScene() {
      var i, rpo, start_point;
      FieldScene.__super__.constructor.call(this, "Field");
      this.map = new Map(20, 15, 32);
      start_point = this.map.get_point(8, 3);
      this.player = new Player(start_point.x, start_point.y);
      this.enemies = [];
      for (i = 1; i <= 3; i++) {
        rpo = this.map.get_randpoint();
        this.enemies[this.enemies.length] = new Enemy(rpo.x, rpo.y);
      }
    }
    FieldScene.prototype.enter = function(keys, mouse) {
      var e, p, _i, _j, _len, _len2, _ref, _ref2;
      _ref = [this.player];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        p = _ref[_i];
        p.update(this.enemies, this.map, keys, mouse);
      }
      _ref2 = this.enemies;
      for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
        e = _ref2[_j];
        e.update([this.player], this.map);
      }
      return this.name;
    };
    FieldScene.prototype.render = function(g) {
      var cam, e, enemy, _i, _len, _ref;
      cam = this.player;
      this.map.render(g, cam);
      _ref = this.enemies;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        enemy = _ref[_i];
        enemy.render(g, cam);
      }
      this.player.render(g);
      g.fillText("HP " + this.player.status.hp + "/" + this.player.status.MAX_HP, 15, 15);
      g.fillText("p: " + this.player.x + "." + this.player.y, 15, 25);
      e = this.enemies[0];
      return g.fillText("Enemy Pos :" + e.x + "/" + e.y + ":" + ~~(e.dir / Math.PI * 180), 15, 35);
    };
    return FieldScene;
  })();
}).call(this);
