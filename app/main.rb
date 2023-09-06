GRAVITY = -2

def launch args
  peak = rand(180) + 360
  colors = [ :r, :g, :b ]
  args.state.shoots << {
    x: rand(1081) + 100, # cus apparently mruby doesn't accept ranges for rand
    y: 0,
    w: 10,
    h: 10,
    ttl: peak / (10 + rand(5)),
    start: args.state.tick_count,
    peak: peak,
    primitive_marker: :solid,
    color1: colors[rand(3)],
    color2: colors[rand(3)]
  }
end

def tick_blooms args
  args.state.blooms.reverse_each do |bloom|
    # puts bloom.class
    percentage = args.easing.ease(bloom.start,
                                  args.state.tick_count,
                                  bloom.ttl,
                                  :flip, bloom.easing)

    if percentage.zero?
      args.state.blooms.delete bloom
      next
    end

    bloom.x += bloom.dx * percentage
    bloom.y += bloom.dy * percentage + GRAVITY * (1 - percentage)

    size = rand(10) + 5
    args.state.sparks << {
      x: bloom.x + rand(13) - 6,
      y: bloom.y + rand(13) - 6,
      w: size,
      h: size,
      ttl: bloom.ttl,
      start: args.state.tick_count,
      a: 111,
      angle: rand(360),
      color1: bloom.color1,
      color2: bloom.color2
    }
  end
end

def tick_shoots args
  args.state.shoots.reverse_each do |shoot|
    percentage = args.easing.ease(shoot.start,
                                  args.state.tick_count,
                                  shoot.ttl,
                                  :flip, :cube, :flip)

    if percentage == 1
      args.state.shoots.delete shoot
      easing = [ :quad, :cube ]
      10.times do |i|
        angle = (36 * i + rand(36)) * Math::PI / 180
        args.state.blooms << {
          x: shoot.x,
          y: shoot.y,
          w: 10,
          h: 10,
          ttl: shoot.ttl * 2,
          start: args.state.tick_count,
          primitive_marker: :solid,
          dx: Math.cos(angle) * (rand(10) + 10),
          dy: Math.sin(angle) * (rand(10) + 10),
          color1: shoot.color1,
          color2: shoot.color2,
          easing: easing[rand(easing.size)],
        }
      end
      next
    end

    shoot.y = shoot.peak * percentage

    2.times do |i|
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
        color1: shoot.color1,
        color2: shoot.color2
      }
    end
  end
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

    spark[spark.color1] = 256 * (rand(2) + 1) * percentage
    spark[spark.color2] = 256 * (rand(2) + 1) * percentage
    spark.a = 111 * percentage
  end
end

def tick args
  args.state.blooms ||= []
  args.state.shoots ||= []
  args.state.sparks ||= []

  tick_blooms args
  tick_shoots args
  tick_sparks args

  launch args if args.state.sparks.empty?

  args.state.max ||= 0
  args.state.max = args.state.sparks.size if args.state.max < args.state.sparks.size

  args.outputs.background_color = [ 11, 17, 23 ]
  args.outputs.sprites << [ args.state.sparks ]
  args.outputs.debug << [ args.state.shoots, args.state.blooms ]
  args.outputs.debug << { y: 100, text: "max sprites: #{args.state.max}", r: 255, g: 255, b: 255 }
  args.outputs.debug << args.gtk.framerate_diagnostics_primitives
end
