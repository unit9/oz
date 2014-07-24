class Circle extends Abstract

  tagName     : "canvas"
  className   : "circularProgress"

  canvas      : null
  context     : null

  radius      : 0
  startAngle  : 0
  endAngle    : 360
  stroke      : 5
  progress    : 0
  cClockwise  : false
  strokeColor : "#FFFFFF"

  initialize: ( params ) =>

    @radius       = params.radius
    @startAngle   = params.startAngle
    @endAngle     = params.endAngle
    @progress     = params.progress
    @stroke       = params.stroke
    @strokeColor  = if params.strokeColor? then params.strokeColor else "#FFFFFF"
    @cClockwise   = if params.cClockwise? then params.cClockwise else false

    super()
    null

  init : =>

    @canvas = @$el[0]
    @context = @canvas.getContext "2d"

    @canvas.width = (@radius * 2) + @stroke
    @canvas.height = (@radius * 2) + @stroke

    @draw()
    null

  draw : =>  
    
    @context.clearRect 0, 0, @canvas.width, @canvas.height

    x = @canvas.width / 2
    y = @canvas.height / 2

    r = @radius
    sAngle = @startAngle
    eAngle = (@progress * (@endAngle) / 100) + @startAngle

    @context.beginPath()
    @context.arc x, y, r, sAngle * Math.PI / 180 , eAngle * Math.PI / 180, @cClockwise
    @context.lineWidth = @stroke;

    @context.strokeStyle = @strokeColor
    @context.stroke()
    null

  setProgress: ( _progress, animate = false, duration = 1000 ) =>

    if !animate

      @progress = _progress
      @draw()
    
    else

      from = { progress: @progress }
      to = { progress: _progress }

      jQuery(from).animate(to, {
        duration: duration,
        step: () =>
          @progress = from.progress
          @draw()
          })

    null
