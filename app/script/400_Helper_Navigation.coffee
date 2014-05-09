###
This class is derived from the RIVVIR Knockbone framework Navigation class and is liscensed to Ignite Media and UPS under the GPL v.3 framework:
https://www.gnu.org/copyleft/gpl.html
###

class Navigation extends Backbone.Router
  constructor: (viewModel, options) ->
    @viewModel = viewModel
    @options = options
    super()
  routes :
    "" : "showHome" #no route provided defaults to home
    "!hello": "showHello" #show the hello page
    "!home": "showHome" #explicit home route is ok too"
    "!home/:listID" : "showHome" #if we want to load some state into the page
    "*path" : "showHome"  #anything else goes to home
  showPage: (state) =>
    @ensureFixture state, =>
      @viewModel.state state
      setTimeout =>
        window.scroll(0,0)
      , 15
      setTimeout ->
        window.seojsSnapshotReady = true
        return
      , 2000
      if ga?
        loc =window.location.href.split('#!')
        if loc.length is 2
          loc = loc[1]
        else
          loc = ""
        ga 'send','event', 'pageChange',state ,loc
      #if device?
        #@viewModel.googleAnalytics.trackEventWithCategory("pageview", "view", state, 1)
      #@viewModel.trackEvent('pageview', state)
  
  showError: (message) =>
    @ensureSetUpApp =>
      @viewModel.errorMessage = message
      @showPage "error"


  showHello: () =>
    @ensureSetUpApp =>
      @showPage "hello"
  showHome: (listID) =>
    @ensureSetUpApp =>
      if listID?
        @viewModel.activeListID(listID) if listID?
      else
        @viewModel.activeListID("home")
      @viewModel.listItemHelper.getList @viewModel.activeListID(), (data) =>
        loadedItems = _.map data, (o)=>
          new ListItem(o)
        @viewModel.activeList(loadedItems)
        @showPage "home"


  
  ensureFixture: (state, whenInjected) =>
    stateTag = '__state_' + state
    foundFixture = $('#__fixtures').find('#' + stateTag)
    if foundFixture.length is 0
      $.ajax
        url: 'fixtures/state_' + state + '.html'
        cache:false
        success: (data) =>
          resultstring = "<div id='" + stateTag + "'>" + data + "</div>"
          $('#__fixtures').append(resultstring)
          ko.applyBindings(@viewModel, $('#' + stateTag)[0])
          whenInjected() if whenInjected?
    else
      whenInjected() if whenInjected?
  ensureSetUpApp: (whenSetUp) ->
    if not @viewModel.isInit()
      @viewModel.initApp ->
        whenSetUp()
    else
      if @viewModel.utils.foundConnection()
        whenSetUp()
      else
        @viewModel.navigateTo('connection')


window.kb = {} if not window.kb?
window.kb.Navigation = Navigation if not window.kb.Navigation?
