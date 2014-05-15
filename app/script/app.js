
/*
This class is derived from the RIVVIR Knockbone framework GlobalVM class and is liscensed to Ignite Media and UPS under the GPL v.3 framework:
https://www.gnu.org/copyleft/gpl.html
 */

(function() {
  var KBVM, ListItem, ListItemHelper, Navigation, Utils,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  KBVM = (function() {
    function KBVM(fixture) {
      this.initApp = __bind(this.initApp, this);
      var $this;
      $this = this;
      if (window.constants == null) {
        window.constants = {};
      }
      window.constants.netEnv = "debug";
      window.constants.serviceURL = 'http://localhost:56136';
      if (window.location.protocol === 'file:' || window.location.origin.indexOf('localhost') > -1) {
        if (window.constants.netEnv === 'debug') {
          window.constants.BaseURL = "http://localhost:56136";
        }
        if (window.constants.netEnv === 'production') {
          window.constants.BaseURL = "http://localhost:56136";
        }
      } else {
        if (window.location.origin) {
          window.constants.BaseURL = window.location.origin;
        } else {
          window.constants.BaseURL = window.location.protocol + "//" + window.location.host;
        }
      }
      this.$el = null;
      if (fixture != null) {
        this.$el = $(fixture);
      }
      this.settings = new Store("kb");
      this.namespace = "com.kblist.app";
      this.state = ko.observable("home");
      this.isTestacular = false;
      this.isInit = ko.observable(false);
      this.utils = new Utils(this);
      this.navState = ko.observable();
      this.activeListID = ko.observable("home");
      this.navigation = new Navigation(this);
      this.listItemHelper = new ListItemHelper(this);
      this.listEntry = ko.observable("Enter a new Item");
      this.activeList = ko.observable([]);
      this.errorMessage = ko.observable();
    }

    KBVM.prototype.navigateTo = function(state, addHistory) {
      if (addHistory == null) {
        addHistory = true;
      }
      return Backbone.history.navigate("!" + state, addHistory);
    };

    KBVM.prototype.initApp = function(onInit) {
      this.isInit(true);
      $('.main').show();
      $('.loading').hide();
      async.series({
        getUser: (function(_this) {
          return function(callback) {
            if ((_this.settings.get("userName") != null) && _this.settings.get("userName") !== "" && (_this.settings.get("password") != null) && _this.settings.get("password") !== "") {
              _this.users.userName(_this.settings.get("userName"));
              _this.users.password(_this.settings.get("password"));
              return _this.users.sendLogon(function() {
                return callback(null);
              }, function() {
                return callback("logon failed");
              });
            } else {
              return callback(null);
            }
          };
        })(this),
        applyBinding: (function(_this) {
          return function(callback) {
            if (_this.$el != null) {
              ko.bindingHandlers.fadeOutIn = {
                update: function(element, valueAccessor) {
                  $(element).hide();
                  return setTimeout(function() {
                    return $(element).fadeIn();
                  }, 100);
                }
              };
              ko.bindingHandlers.datepicker = {
                init: function(element, valueAccessor, allBindingsAccessor) {
                  var options;
                  options = allBindingsAccessor().datepickerOptions || {};
                  return $(element).datepicker(options).on("changeDate", function(ev) {
                    var day, month, observable, value, year;
                    value = "";
                    if (ev.date.getDate != null) {
                      day = ev.date.getDate();
                      month = ev.date.getMonth() + 1;
                      year = ev.date.getFullYear();
                      value = month + "/" + day + "/" + year;
                    }
                    observable = valueAccessor();
                    return observable(value);
                  });
                },
                update: function(element, valueAccessor) {
                  var day, month, value, year;
                  value = ko.utils.unwrapObservable(valueAccessor());
                  if (value.getDate != null) {
                    day = value.getDate();
                    month = value.getMonth() + 1;
                    year = value.getFullYear();
                    value = month + "/" + day + "/" + year;
                  } else {
                    if (value.indexOf("-") > -1) {
                      value = value.replace("-", "/").replace("-", "/");
                    }
                  }
                  return $(element).datepicker("setValue", value);
                }
              };
              ko.bindingHandlers.bootstrapPopover = {
                init: function(element, valueAccessor, allBindingsAccessor, viewModel) {
                  var defaultOptions, options;
                  options = valueAccessor();
                  defaultOptions = {};
                  options = $.extend(true, {}, defaultOptions, options);
                  return $(element).popover(options);
                }
              };
              ko.applyBindings(_this, _this.$el[0]);
              return callback(null);
            } else {
              return callback({
                error: "binding element not present for ko"
              });
            }
          };
        })(this),
        setupEvents: (function(_this) {
          return function(callback) {
            document.addEventListener("resume", function() {
              return _this.navigateTo('logon');
            });
            document.addEventListener("online", function() {
              var thisDate;
              thisDate = _this.utils.getDateTime();
              thisDate = thisDate.split(":")[1].toString() + "/" + thisDate.split(":")[2] + "/" + thisDate.split(":")[0];
              return _this.resAvailability.get(thisDate, function(data) {
                return _this.resAvailability.schedule(data.items);
              });
            });
            return callback(null);
          };
        })(this)
      }, (function(_this) {
        return function(error, result) {
          setTimeout(function() {
            Backbone.history.stop();
            return Backbone.history.start();
          }, 1);
          if (onInit != null) {
            return onInit();
          }
        };
      })(this));
      return null;
    };

    return KBVM;

  })();

  if (window.kb == null) {
    window.kb = {};
  }

  if (window.kb.KBVM == null) {
    window.kb.KBVM = KBVM;
  }

  ListItem = (function() {
    function ListItem(options) {
      this.options = options;
      this.text = ko.observable("");
      this.dateAdded = ko.observable(null);
      this.dateComplete = ko.observable(null);
      this.bComplete = ko.observable(false);
      this.listID = ko.observable(null);
      this.listItemID = ko.observable(null);
      if (options != null) {
        if (options.text != null) {
          this.text(options.text);
        }
        if (options.dateAdded != null) {
          this.dateAdded(options.dateAdded);
        }
        if (options.dateComplete != null) {
          this.dateComplete(options.dateComplete);
        }
        if (options.bComplete != null) {
          this.bComplete(options.bComplete);
        }
        if (options.listID != null) {
          this.listID(options.listID);
        }
        if (options.listItemID != null) {
          this.listItemID(options.listItemID);
        }
      }
      this.switchText = ko.computed((function(_this) {
        return function() {
          if (_this.bComplete()) {
            return "Undo Complete";
          } else {
            return "Complete";
          }
        };
      })(this), this);
    }

    return ListItem;

  })();

  if (window.kb == null) {
    window.kb = {};
  }

  if (window.kb.ListItemHelper == null) {
    window.kb.ListItemHelper = ListItemHelper;
  }


  /*
  This class is derived from the RIVVIR Knockbone framework Navigation class and is liscensed to Ignite Media and UPS under the GPL v.3 framework:
  https://www.gnu.org/copyleft/gpl.html
   */

  Navigation = (function(_super) {
    __extends(Navigation, _super);

    function Navigation(viewModel, options) {
      this.ensureFixture = __bind(this.ensureFixture, this);
      this.showHome = __bind(this.showHome, this);
      this.showHello = __bind(this.showHello, this);
      this.showError = __bind(this.showError, this);
      this.showPage = __bind(this.showPage, this);
      this.viewModel = viewModel;
      this.options = options;
      Navigation.__super__.constructor.call(this);
    }

    Navigation.prototype.routes = {
      "": "showHome",
      "!hello": "showHello",
      "!home": "showHome",
      "!home/:listID": "showHome",
      "*path": "showHome"
    };

    Navigation.prototype.showPage = function(state) {
      return this.ensureFixture(state, (function(_this) {
        return function() {
          var loc;
          _this.viewModel.state(state);
          setTimeout(function() {
            return window.scroll(0, 0);
          }, 15);
          setTimeout(function() {
            window.seojsSnapshotReady = true;
          }, 2000);
          if (typeof ga !== "undefined" && ga !== null) {
            loc = window.location.href.split('#!');
            if (loc.length === 2) {
              loc = loc[1];
            } else {
              loc = "";
            }
            return ga('send', 'event', 'pageChange', state, loc);
          }
        };
      })(this));
    };

    Navigation.prototype.showError = function(message) {
      return this.ensureSetUpApp((function(_this) {
        return function() {
          _this.viewModel.errorMessage = message;
          return _this.showPage("error");
        };
      })(this));
    };

    Navigation.prototype.showHello = function() {
      return this.ensureSetUpApp((function(_this) {
        return function() {
          return _this.showPage("hello");
        };
      })(this));
    };

    Navigation.prototype.showHome = function(listID) {
      return this.ensureSetUpApp((function(_this) {
        return function() {
          if (listID != null) {
            if (listID != null) {
              _this.viewModel.activeListID(listID);
            }
          } else {
            _this.viewModel.activeListID("home");
          }
          return _this.viewModel.listItemHelper.getList(_this.viewModel.activeListID(), function(data) {
            var loadedItems;
            loadedItems = _.map(data, function(o) {
              return new ListItem(o);
            });
            _this.viewModel.activeList(loadedItems);
            return _this.showPage("home");
          }, function() {
            return _this.showPage("home");
          });
        };
      })(this));
    };

    Navigation.prototype.ensureFixture = function(state, whenInjected) {
      var foundFixture, stateTag;
      stateTag = '__state_' + state;
      foundFixture = $('#__fixtures').find('#' + stateTag);
      if (foundFixture.length === 0) {
        return $.ajax({
          url: 'fixtures/state_' + state + '.html',
          cache: false,
          success: (function(_this) {
            return function(data) {
              var resultstring;
              resultstring = "<div id='" + stateTag + "'>" + data + "</div>";
              $('#__fixtures').append(resultstring);
              ko.applyBindings(_this.viewModel, $('#' + stateTag)[0]);
              if (whenInjected != null) {
                return whenInjected();
              }
            };
          })(this)
        });
      } else {
        if (whenInjected != null) {
          return whenInjected();
        }
      }
    };

    Navigation.prototype.ensureSetUpApp = function(whenSetUp) {
      if (!this.viewModel.isInit()) {
        return this.viewModel.initApp(function() {
          return whenSetUp();
        });
      } else {
        if (this.viewModel.utils.foundConnection()) {
          return whenSetUp();
        } else {
          return this.viewModel.navigateTo('connection');
        }
      }
    };

    return Navigation;

  })(Backbone.Router);

  if (window.kb == null) {
    window.kb = {};
  }

  if (window.kb.Navigation == null) {
    window.kb.Navigation = Navigation;
  }

  ListItemHelper = (function() {
    function ListItemHelper(viewModel, options) {
      this.save = __bind(this.save, this);
      this.getList = __bind(this.getList, this);
      this.switchComplete = __bind(this.switchComplete, this);
      this.addItem = __bind(this.addItem, this);
      this.viewModel = viewModel;
      this.options = options;
    }

    ListItemHelper.prototype.addItem = function() {
      var newItem, updatedList;
      newItem = {
        listID: this.viewModel.activeListID(),
        listItemID: window.guidGenerator(),
        dateAdded: new Date(),
        dateComplete: null,
        bComplete: false,
        text: this.viewModel.listEntry()
      };
      updatedList = this.viewModel.activeList();
      updatedList.push(new ListItem(newItem));
      this.viewModel.activeList(updatedList);
      return this.save(newItem, null, (function(_this) {
        return function() {
          return _this.viewModel.errorMessage('Opps. Service Failed.');
        };
      })(this));
    };

    ListItemHelper.prototype.switchComplete = function(data) {
      var newItem;
      data.bComplete(data.bComplete() ? false : true);
      newItem = {
        listID: data.listID(),
        listItemID: data.listItemID(),
        dateAdded: data.dateAdded(),
        dateComplete: data.dateComplete(),
        bComplete: data.bComplete(),
        text: data.text()
      };
      return this.save(newItem, (function(_this) {
        return function() {};
      })(this), (function(_this) {
        return function() {
          return _this.viewModel.errorMessage('Opps. Service Failed.');
        };
      })(this));
    };

    ListItemHelper.prototype.getList = function(listID, onSuccess, onError) {
      var formdata;
      formdata = {
        listID: listID
      };
      return $.ajax({
        url: window.constants.serviceURL + "/ListItem/GetAll",
        type: 'post',
        data: formdata,
        dataType: 'json',
        cache: false,
        xhrFields: {
          withCredentials: true
        },
        error: (function(_this) {
          return function() {
            if (onError != null) {
              return onError();
            }
          };
        })(this),
        success: (function(_this) {
          return function(data) {
            if (data.result === "success") {
              if (onSuccess != null) {
                return onSuccess(data.items);
              }
            } else {
              if (onError != null) {
                return onError(data.reason);
              }
            }
          };
        })(this)
      });
    };

    ListItemHelper.prototype.save = function(listItem, onSuccess, onError) {
      var formdata;
      formdata = {
        listID: listItem.listID,
        listItemID: listItem.listItemID,
        dateAdded: listItem.dateAdded != null ? moment(listItem.dateAdded).format() : null,
        dateCompleted: listItem.dateAdded != null ? moment(listItem.dateCompleted).format() : null,
        bComplete: listItem.bComplete,
        text: listItem.text
      };
      return $.ajax({
        url: window.constants.serviceURL + "/listItem/Save",
        type: 'post',
        data: formdata,
        dataType: 'json',
        cache: false,
        xhrFields: {
          withCredentials: true
        },
        error: (function(_this) {
          return function() {
            if (onError != null) {
              return onError();
            }
          };
        })(this),
        success: (function(_this) {
          return function(data) {
            if (data.result === "success") {
              if (onSuccess != null) {
                return onSuccess(data.item);
              }
            } else {
              if (onError != null) {
                return onError(data.reason);
              }
            }
          };
        })(this)
      });
    };

    return ListItemHelper;

  })();

  if (window.kb == null) {
    window.kb = {};
  }

  if (window.kb.ListItemHelper == null) {
    window.kb.ListItemHelper = ListItemHelper;
  }

  Utils = (function() {
    function Utils(viewModel, options) {
      this.convertTimeformat = __bind(this.convertTimeformat, this);
      this.getDateTime = __bind(this.getDateTime, this);
      this.viewModel = viewModel;
    }

    Utils.prototype.getDateTime = function(addDays) {
      var date, day, hour, min, month, sec, year, _ref, _ref1, _ref2;
      date = new Date();
      if (addDays != null) {
        date.setDate(date.getDate() + addDays);
      }
      hour = date.getHours();
      hour = ((_ref = hour < 10) != null ? _ref : {
        "0": ""
      }) + hour;
      min = date.getMinutes();
      min = ((_ref1 = min < 10) != null ? _ref1 : {
        "0": ""
      }) + min;
      sec = date.getSeconds();
      sec = ((_ref2 = sec < 10) != null ? _ref2 : {
        "0": ""
      }) + sec;
      year = date.getFullYear();
      month = date.getMonth() + 1;
      if (month < 10) {
        month = "0" + month.toString();
      }
      day = date.getDate();
      if (day < 10) {
        day = "0" + day.toString();
      }
      return year + ":" + month + ":" + day + ":" + hour + ":" + min + ":" + sec;
    };

    Utils.prototype.convertTimeformat = function(format, str) {
      var AMPM, hours, minutes, sHours, sMinutes;
      hours = Number(str.match(/^(\d+)/)[1]);
      minutes = Number(str.match(/:(\d+)/)[1]);
      AMPM = str.match(/\s(.*)$/)[1];
      if (AMPM === "PM" && hours < 12) {
        hours = hours + 12;
      }
      if (AMPM === "AM" && hours === 12) {
        hours = hours - 12;
      }
      sHours = hours.toString();
      sMinutes = minutes.toString();
      if (hours < 10) {
        sHours = "0" + sHours;
      }
      if (minutes < 10) {
        sMinutes = "0" + sMinutes;
      }
      return sHours + ":" + sMinutes;
    };

    Utils.prototype.back = function() {
      return window.history.back();
    };

    Utils.prototype.foundiOS = function() {
      if (this._foundiOS != null) {
        return this._foundiOS;
      }
      if (this.foundDevice()) {
        if (device.platform.lastIndexOf("iPhone", 0) === 0 || device.platform.lastIndexOf("iPad", 0) === 0 || device.platform.lastIndexOf("iPhone Simulator", 0) === 0) {
          this._foundiOS = true;
          return this.foundiOS();
        }
      }
      this._foundiOS = false;
      return this.foundiOS();
    };

    Utils.prototype.foundConnection = function() {
      if (this.foundDevice()) {
        if (navigator.network.connection.type === Connection.UNKNOWN || navigator.network.connection.type === Connection.NONE) {
          return false;
        }
      }
      return true;
    };

    Utils.prototype.foundAndroid = function() {
      if (this._foundAndroid != null) {
        return this._foundAndroid;
      }
      if (this.foundDevice()) {
        if (device.platform === "Android") {
          this._foundAndroid = true;
          return this.foundAndroid();
        }
      }
      this._foundAndroid = false;
      return this.foundAndroid();
    };

    Utils.prototype.foundDevice = function() {
      if (typeof device !== "undefined" && device !== null) {
        return true;
      } else {
        return false;
      }
    };

    return Utils;

  })();

  window.guidGenerator = function() {
    var S4;
    S4 = function() {
      return (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1);
    };
    return S4() + S4() + "-" + S4() + "-" + S4() + "-" + S4() + "-" + S4() + S4() + S4();
  };

  window.checkdate = function(input) {
    var dayfield, dayobj, monthfield, returnval, validformat, yearfield;
    validformat = /^\d{2}\/\d{2}\/\d{4}$/;
    returnval = false;
    if (!validformat.test(input)) {
      return false;
    } else {
      monthfield = input.split("/")[0];
      dayfield = input.split("/")[1];
      yearfield = input.split("/")[2];
      dayobj = new Date(yearfield, monthfield - 1, dayfield);
      if ((dayobj.getMonth() + 1 !== monthfield) || (dayobj.getDate() !== dayfield) || (dayobj.getFullYear() !== yearfield)) {
        return false;
      } else {
        return true;
      }
    }
    return true;
  };

  window.validateEmail = function(email) {
    var re;
    re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(email);
  };

  if (typeof String.prototype.startsWith !== 'function') {
    String.prototype.startsWith = function(str) {
      return this.indexOf(str) === 0;
    };
  }

  window.isDate = function(x) {
    return typeof x === "string" && x.startsWith("/Date(");
  };

  window.deserializeDate = function(dateString) {
    return new Date(parseInt(dateString.substr(6), 10));
  };

  window.isScalar = function(x) {
    return x === null || typeof x === "string" || typeof x === "number" || typeof x === "boolean";
  };

  if (!Array.prototype.indexOf) {
    Array.prototype.indexOf = function(obj, start) {
      var i, _i, _ref;
      if (start == null) {
        start = 0;
      }
      for (i = _i = start, _ref = this.length(-1); start <= _ref ? _i < _ref : _i > _ref; i = start <= _ref ? ++_i : --_i) {
        if (this[i] === obj) {
          return i;
        }
      }
      return -1;
    };
  }

  if (!window.location.origin) {
    window.location.origin = window.location.protocol + "//" + window.location.hostname + (window.location.port != null ? ':' + window.location.port : '');
  }

}).call(this);
