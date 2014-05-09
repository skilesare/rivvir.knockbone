class ListItem
  constructor: (options) ->
    @options = options
    @text = ko.observable("")
    @dateAdded = ko.observable( null)
    @dateComplete =  ko.observable(null)
    @bComplete =  ko.observable(false)
    @listID =  ko.observable(null)
    @listItemID = ko.observable(null)
    if options?
      @text = ko.observable(options.text) if options.text?
      @dateAdded = ko.observable(options.dateAdded) if options.dateAdded?
      @dateComplete =  ko.observable(options.dateComplete) if options.dateComplete?
      @bComplete =  ko.observable(options.bComplete) if options.bComplete?
      @listID =  ko.observable(options.listID) if options.listID?
      @listItemID = ko.observable(options.listItemID) if options.listItemID?
    @switchText = ko.computed =>
      if @bComplete()
        "Undo Complete"
      else
        "Complete"
    , @


window.kb = {} if not window.kb?
window.kb.ListItemHelper = ListItemHelper if not window.kb.ListItemHelper?
