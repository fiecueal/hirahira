GRAVITY = -0.01

def launch args
  args.state.shoots << {
    x: rand(1081) + 100, # cus apparently mruby doesn't accept ranges for rand
    y: 0,
    w: 10,
    h: 10,
    dy: 12,
    ttl: rand(20) + 10,
    start: args.state.tick_count,
    peak: rand(250) + 300,
    r: 222,
    g: 222,
    b: 222,
    primitive_marker: :sprite
  }
end

def calc args
  args.state.sparks.reverse_each do |spark|
    spark.ttl -= 1
    args.state.sparks.delete spark if spark.ttl <= 0
    spark.angle += spark.ttl
    spark.y -= spark.ttl
  end

  args.state.shoots.reverse_each do |shoot|
    shoot.y = shoot.peak * args.easing.ease(shoot.start, args.state.tick_count, shoot.ttl, :flip, :quad, :flip)
    args.state.shoots.delete shoot if shoot.y == shoot.peak
    shoot.x += Math.cos(args.state.tick_count) * 3
    3.times do |i|
      size = rand(20) + 10
      args.state.sparks << {
        x: shoot.x + rand(7) - 3,
        y: shoot.y,
        w: size,
        h: size,
        dy: 1,
        ttl: 12,
        # r: 222,
        # g: 222,
        # b: 222,
        a: 111,
        angle: rand(360),
        path: rand > 0.7 ? "sprites/square/orange.png" : "sprites/square/red.png"
      }
    end
  end
end

def tick args
  unless args.state.initialized
    args.state.blooms = []
    args.state.shoots = []
    args.state.sparks = []
    args.state.initialized = true
  end

  calc args

  launch args if args.inputs.keyboard.key_down.char && args.state.shoots.size < 5

  args.outputs.background_color = [ 11, 17, 23 ]
  args.outputs.sprites << [ args.state.sparks ]
  args.outputs.debug << [ args.state.shoots, args.state.blooms ]
  args.outputs.debug << args.gtk.framerate_diagnostics_primitives
end
