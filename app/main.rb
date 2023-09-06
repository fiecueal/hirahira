GRAVITY = -0.01

def launch args
  peak = rand(180) + 360
  args.state.shoots << {
    x: rand(1081) + 100, # cus apparently mruby doesn't accept ranges for rand
    y: 0,
    w: 10,
    h: 10,
    ttl: peak / 13,
    start: args.state.tick_count,
    peak: peak,
    primitive_marker: :sprite
  }
end

def tick_sparks args
  args.state.sparks.reverse_each do |spark|
    percentage = args.easing.ease(spark.start,
                                  args.state.tick_count,
                                  spark.ttl,
                                  :flip, :cube)

    if percentage.zero?
      args.state.sparks.delete spark
      next
    end

    spark.a = 111 * percentage
    spark.angle += percentage
  end
end

def tick_shoots args
  args.state.shoots.reverse_each do |shoot|
    shoot.y = shoot.peak * args.easing.ease(shoot.start,
                                            args.state.tick_count,
                                            shoot.ttl,
                                            :flip, :cube, :flip)
    if shoot.y == shoot.peak
      args.state.shoots.delete shoot
      next
    end

    shoot.x += Math.cos(args.state.tick_count) * 3
    11.times do |i|
      size = rand(20) + 10
      args.state.sparks << {
        x: shoot.x + rand(25) - 12,
        y: shoot.y + rand(25) - 12,
        w: size,
        h: size,
        ttl: shoot.ttl,
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

  launch args if args.state.shoots.empty?

  args.outputs.background_color = [ 11, 17, 23 ]
  args.outputs.sprites << [ args.state.sparks ]
  args.outputs.debug << [ args.state.shoots, args.state.blooms ]
  args.outputs.debug << args.gtk.framerate_diagnostics_primitives
end
