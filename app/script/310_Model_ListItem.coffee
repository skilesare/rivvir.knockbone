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
      @text options.text if options.text?
      @dateAdded options.dateAdded if options.dateAdded?
      @dateComplete options.dateComplete if options.dateComplete?
      @bComplete options.bComplete if options.bComplete?
      @listID options.listID if options.listID?
      @listItemID  options.listItemID if options.listItemID?
    @switchText = ko.computed =>
      if @bComplete()
        "Undo Complete"
      else
        "Complete"
    , @


window.kb = {} if not window.kb?
window.kb.ListItemHelper = ListItemHelper if not window.kb.ListItemHelper?
