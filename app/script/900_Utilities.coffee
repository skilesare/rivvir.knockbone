class Utils
  constructor: (viewModel, options) ->
    @viewModel = viewModel
  getDateTime: (addDays) =>
    date = new Date()
    if addDays?
      date.setDate(date.getDate() + addDays)
    hour = date.getHours()
    hour = (hour < 10 ? "0" : "") + hour

    min  = date.getMinutes()
    min = (min < 10 ? "0" : "") + min

    sec  = date.getSeconds()
    sec = (sec < 10 ? "0" : "") + sec

    year = date.getFullYear()

    month = date.getMonth() + 1
    
    if month <10
      month = "0" + month.toString()
    

    day  = date.getDate()
    if day < 10
      day = "0" + day.toString()

    return year + ":" + month + ":" + day + ":" + hour + ":" + min + ":" + sec
  convertTimeformat: (format, str)=>
    
    hours = Number(str.match(/^(\d+)/)[1])
    minutes = Number(str.match(/:(\d+)/)[1])
    AMPM = str.match(/\s(.*)$/)[1]
    if (AMPM == "PM" && hours < 12)
      hours = hours + 12
    if (AMPM == "AM" && hours == 12)
      hours = hours - 12
    sHours = hours.toString()
    sMinutes = minutes.toString()
    if (hours < 10)
      sHours = "0" + sHours
    if (minutes < 10)
      sMinutes = "0" + sMinutes
    return sHours + ":" + sMinutes
  back: ->
    window.history.back()
  foundiOS: ->
    return @_foundiOS if @_foundiOS?
    if @foundDevice()
      if device.platform.lastIndexOf("iPhone", 0) is 0 or device.platform.lastIndexOf("iPad", 0) is 0 or device.platform.lastIndexOf("iPhone Simulator", 0) is 0
        @_foundiOS = true
        return @foundiOS()
    @_foundiOS = false
    return @foundiOS()
  foundConnection: ->
    if @foundDevice()
      if navigator.network.connection.type is Connection.UNKNOWN or navigator.network.connection.type is Connection.NONE
        return false
    return true
  foundAndroid: ->
    return @_foundAndroid if @_foundAndroid?
    if @foundDevice()
      if device.platform is "Android"
        @_foundAndroid = true
        return @foundAndroid()
    @_foundAndroid = false
    return @foundAndroid()
  foundDevice: ->
    if device?
      return true
    else
      return false


window.guidGenerator = ->
  S4 = ->
    return (((1+Math.random())*0x10000)|0).toString(16).substring(1)
  return (S4()+S4()+"-"+S4()+"-"+S4()+"-"+S4()+"-"+S4()+S4()+S4())

window.checkdate = (input) ->
  validformat=/^\d{2}\/\d{2}\/\d{4}$/
  returnval=false
  if (!validformat.test(input))
    return false
  else
    monthfield=input.split("/")[0]
    dayfield=input.split("/")[1]
    yearfield=input.split("/")[2]
    dayobj = new Date(yearfield, monthfield-1, dayfield)
    if ((dayobj.getMonth()+1!=monthfield)||(dayobj.getDate()!=dayfield)||(dayobj.getFullYear()!=yearfield))
      return false
    else
      return true
  
  return true

window.validateEmail = (email) ->
  re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
  return re.test(email)

if (typeof String.prototype.startsWith != 'function')
  String.prototype.startsWith = (str) ->
    return this.indexOf(str) == 0

window.isDate = (x) ->
  typeof x is "string" and
  x.startsWith "/Date("

window.deserializeDate = (dateString) ->
  new Date(parseInt(dateString.substr(6),10))

window.isScalar= (x) ->
  x is null or
  typeof x is "string" or
  typeof x is "number" or
  typeof x is "boolean"


if (!Array.prototype.indexOf)
  Array.prototype.indexOf = (obj, start) ->
    start = 0 if not start?
    for i in [start...(this.length -1)]
      if (this[i] is obj)
        return i
    return -1

if (!window.location.origin)
  window.location.origin = window.location.protocol + "//" + window.location.hostname + (if window.location.port? then':' + window.location.port else '')
