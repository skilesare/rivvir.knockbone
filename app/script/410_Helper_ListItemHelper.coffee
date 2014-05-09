class ListItemHelper
  constructor: (viewModel, options) ->
    @viewModel = viewModel
    @options = options
  addItem: () =>
    newItem =
      listID: @viewModel.activeListID()
      listItemID: window.guidGenerator()
      dateAdded: new Date()
      dateComplete: null
      bComplete: false
      text: @viewModel.listEntry()
      
    @save newItem, =>
      updatedList = @viewModel.activeList()
      updatedList.push(new ListItem(newItem))
      @viewModel.activeList(updatedList)
    , () =>
      @viewModel.errorMessage('Opps. Service Failed.')
  switchComplete: (data) =>
    data.bComplete(if data.bComplete() then false else true)
    newItem =
      listID: data.listID()
      listItemID: data.listItemID()
      dateAdded: data.dateAdded()
      dateComplete: data.dateComplete()
      bComplete: data.bComplete()
      text: data.text()
      
    @save newItem, =>
      return
    , () =>
      @viewModel.errorMessage('Opps. Service Failed.')
  getList: (listID, onSuccess, onError) =>
    formdata =
      listID : listID
    $.ajax
      url: window.constants.serviceURL + "/ListItem/GetAll"
      type: 'post'
      data: formdata
      dataType: 'json'
      cache: false
      xhrFields:
        withCredentials: true
      error: () =>
        onError() if onError?
      success:(data) =>
        if data.result is "success"
          onSuccess(data.items) if onSuccess?
        else
          onError(data.reason) if onError?
  save: (listItem, onSuccess, onError) =>
    formdata =
      listID : listItem.listID
      listItemID: listItem.listItemID
      dateAdded: if listItem.dateAdded? then moment(listItem.dateAdded).format() else null
      dateCompleted: if listItem.dateAdded? then moment(listItem.dateCompleted).format() else null
      bComplete: listItem.bComplete
      text: listItem.text
    $.ajax
      url: window.constants.serviceURL + "/listItem/Save"
      type: 'post'
      data: formdata
      dataType: 'json'
      cache: false
      xhrFields:
        withCredentials: true
      error: () =>
        onError() if onError?
      success:(data) =>
        if data.result is "success"
          onSuccess(data.item) if onSuccess?
        else
          onError(data.reason) if onError?



window.kb = {} if not window.kb?
window.kb.ListItemHelper = ListItemHelper if not window.kb.ListItemHelper?
