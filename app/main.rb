GRAVITY = -0.01

def launch args
  peak = rand(250) + 300
  args.state.shoots << {
    x: rand(1081) + 100, # cus apparently mruby doesn't accept ranges for rand
    y: 0,
    w: 10,
    h: 10,
    ttl: peak / 13,
    start: args.state.tick_count,
    peak: peak,
    r: 222,
    g: 222,
    b: 222,
    primitive_marker: :sprite
  }
end

def tick_sparks args
  args.state.sparks.reverse_each do |spark|
    spark.a = 111 * args.easing.ease(spark.start,
                                     args.state.tick_count,
                                     spark.ttl,
                                     :flip)
    args.state.sparks.delete spark if spark.a.zero?
    spark.angle += spark.ttl
    spark.y -= spark.ttl
  end
end

def tick_shoots args
  args.state.shoots.reverse_each do |shoot|
    shoot.y = shoot.peak * args.easing.ease(shoot.start,
                                            args.state.tick_count,
                                            shoot.ttl,
                                            :flip, :quad, :flip)
    args.state.shoots.delete shoot if shoot.y == shoot.peak
    shoot.x += Math.cos(args.state.tick_count) * 3
    3.times do |i|
      size = rand(20) + 10
      args.state.sparks << {
        x: shoot.x + rand(7) - 3,
        y: shoot.y,
        w: size,
        h: size,
        ttl: 12,
        start: args.state.tick_count,
        a: 111,
        angle: rand(360),
        path: rand > 0.5 ? "sprites/square/orange.png" : "sprites/square/red.png"
      }
    end
  end
end

def tick_blooms args

end

def tick args
  args.state.blooms ||= []
  args.state.shoots ||= []
  args.state.sparks ||= []

  tick_blooms args
  tick_shoots args
  tick_sparks args

  launch args if args.state.sparks.empty?

  args.outputs.background_color = [ 11, 17, 23 ]
  args.outputs.sprites << [ args.state.sparks ]
  args.outputs.debug << [ args.state.shoots, args.state.blooms ]
  args.outputs.debug << args.gtk.framerate_diagnostics_primitives
end
