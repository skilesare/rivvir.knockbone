###
This class is derived from the RIVVIR Knockbone framework GlobalVM class and is liscensed to Ignite Media and UPS under the GPL v.3 framework:
https://www.gnu.org/copyleft/gpl.html
###
class KBVM
  constructor: (fixture) ->
    $this = @
    window.constants = {} if not window.constants?
    window.constants.netEnv = "debug"
    window.constants.serviceURL = 'http://localhost:56136'
    
    if window.location.protocol is 'file:' or window.location.origin.indexOf('localhost') > -1
      
      #window.constants.serviceURL = "http://localhost:56136"
      window.constants.BaseURL = "http://localhost:56136" if window.constants.netEnv is 'debug'
      
      window.constants.BaseURL = "http://localhost:56136" if window.constants.netEnv is 'production'
    else
      if window.location.origin
        window.constants.BaseURL = window.location.origin
      else
        window.constants.BaseURL = window.location.protocol + "//" + window.location.host
    @$el = null
    if fixture?
      @$el = $(fixture)
    @settings = new Store("kb")

    @namespace = "com.kblist.app"
    @state = ko.observable("home")
    @isTestacular = false
    @isInit = ko.observable(false)
    @utils = new Utils(@)
    @navigation = new Navigation(@)
    @navState = ko.observable()
    
    @activeListID = ko.observable("home")
    @listItemHelper = new ListItemHelper(@)
    @listEntry = ko.observable("Enter a new Item") # holds the item value to be added
    @activeList = ko.observable([])
    
    @errorMessage = ko.observable()


  navigateTo: (state, addHistory) ->
    addHistory = true if not addHistory?
    Backbone.history.navigate("!" + state,addHistory)
  initApp: (onInit) =>
    @isInit(true)
    $('.main').show()
    $('.loading').hide()
    async.series
      getUser: (callback) =>
        if @settings.get("userName")? and @settings.get("userName") isnt "" and @settings.get("password")? and @settings.get("password") isnt ""
          @users.userName(@settings.get("userName"))
          @users.password(@settings.get("password"))
          
          @users.sendLogon =>
            callback null
          , =>
            callback "logon failed"
        else
          callback null
      applyBinding: (callback) =>
        if @$el?
          ko.bindingHandlers.fadeOutIn =
            update: (element, valueAccessor) -> #Whenever the value subsequently changes, slowly fade the element in or out
              $(element).hide()
              setTimeout ->
                $(element).fadeIn()
              ,100
          ko.bindingHandlers.datepicker =
            init: (element, valueAccessor, allBindingsAccessor) ->
              #initialize datepicker with some optional options
              options = allBindingsAccessor().datepickerOptions || {}
              $(element).datepicker(options).on "changeDate", (ev) ->
                value = ""
                if ev.date.getDate?
                  day = ev.date.getDate()
                  month = ev.date.getMonth() + 1
                  year = ev.date.getFullYear()
                  value = month + "/" + day + "/" + year
                observable = valueAccessor()
                observable(value)


            update: (element, valueAccessor) ->
              value = ko.utils.unwrapObservable(valueAccessor())
              if value.getDate?
                day = value.getDate()
                month = value.getMonth() + 1
                year = value.getFullYear()
                value = month + "/" + day + "/" + year
              else
                if value.indexOf("-") > -1
                  value = value.replace("-","/").replace("-","/")
              $(element).datepicker("setValue", value)
          ko.bindingHandlers.bootstrapPopover =
            init: (element, valueAccessor, allBindingsAccessor, viewModel) ->
              options = valueAccessor()
              defaultOptions = {}
              options = $.extend(true, {}, defaultOptions, options)
              $(element).popover(options)
          ko.applyBindings(@, @.$el[0])
          callback(null)
        else
          callback {error:"binding element not present for ko"}
      setupEvents: (callback) =>
        document.addEventListener "resume", =>
          @navigateTo('logon')
        document.addEventListener "online", =>
          thisDate = @utils.getDateTime()
          thisDate = thisDate.split(":")[1].toString() + "/" + thisDate.split(":")[2] + "/" + thisDate.split(":")[0]
          @resAvailability.get  thisDate, (data)=>
            @resAvailability.schedule(data.items)
        callback null
    , (error, result) =>
      setTimeout ->
        Backbone.history.stop()
        Backbone.history.start()
      ,1
      onInit() if onInit?
    return null


window.kb = {} if not window.kb?
window.kb.KBVM = KBVM if not window.kb.KBVM?