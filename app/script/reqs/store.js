﻿(function () { var a = function (a, b) { return Object.prototype.hasOwnProperty.call(a, b) }; var b = function (b) { var c = 0; for (var d in b) { if (a(b, d)) { c++ } } return c }; var c = function (a, b, c) { var d = a.length >>> 0; for (var e = c < 0 ? Math.max(0, d + c) : c || 0; e < d; e++) { if (a[e] === b) { return e } } return -1 }; var d = function (a, b, d) { return c(a, b, d) !== -1 }; var e = function (a, b) { if (!d(a, b)) { a.push(b) } return a }; var f = this.Store = function (a, b, c) { this.name = a; this.defaults = b || {}; this.watcherSpeed = c || 500; this.listeners = {}; this.applyDefaults() }; f.clear = function () { localStorage.clear() }; f.prototype.applyDefaults = function () { for (var b in this.defaults) { if (a(this.defaults, b) && this.get(b) === undefined) { this.set(b, this.defaults[b]) } } return this }; f.prototype.watcher = function (c) { if (this.watcherTimer) { clearTimeout(this.watcherTimer) } if (b(this.listeners) || c) { this.newObject = this.toObject(); if (this.oldObject) { for (var d in this.newObject) { if (a(this.newObject, d) && this.newObject[d] !== this.oldObject[d]) { this.fireEvent(d, this.newObject[d]) } } for (var d in this.oldObject) { if (a(this.oldObject, d) && !a(this.newObject, d)) { this.fireEvent(d, this.newObject[d]) } } } this.oldObject = this.newObject; var e = this; this.watcherTimer = setTimeout(function () { e.watcher() }, this.watcherSpeed) } return this }; f.prototype.get = function (a) { var b = localStorage.getItem("store." + this.name + "." + a); if (b === null) { return undefined } try { return JSON.parse(b) } catch (c) { return null } }; f.prototype.set = function (a, b) { if (b === undefined) { this.remove(a) } else { if (typeof b === "function") { b = null } try { b = JSON.stringify(b) } catch (c) { b = null } localStorage.setItem("store." + this.name + "." + a, b) } return this }; f.prototype.remove = function (a) { localStorage.removeItem("store." + this.name + "." + a); return this.applyDefaults() }; f.prototype.reset = function () { var a = "store." + this.name + "."; for (var b = localStorage.length - 1; b >= 0; b--) { if (localStorage.key(b).substring(0, a.length) === a) { localStorage.removeItem(localStorage.key(b)) } } return this.applyDefaults() }; f.prototype.toObject = function () { var a = {}; var b = "store." + this.name + "."; for (var c = localStorage.length - 1; c >= 0; c--) { if (localStorage.key(c).substring(0, b.length) === b) { var d = localStorage.key(c).substring(b.length); var e = this.get(d); if (e !== undefined) { a[d] = e } } } return a }; f.prototype.fromObject = function (b, c) { if (!c) { this.reset() } for (var d in b) { if (a(b, d)) { this.set(d, b[d]) } } return this }; f.prototype.addEvent = function (a, b) { this.watcher(true); if (!this.listeners[a]) { this.listeners[a] = [] } e(this.listeners[a], b); return this }; f.prototype.removeEvent = function (a, b) { for (var c = this.listeners[a].length - 1; c >= 0; c--) { if (this.listeners[a][c] === b) { this.listeners[a].splice(c, 1) } } if (!this.listeners[a].length) { delete this.listeners[a] } return this }; f.prototype.fireEvent = function (a, b) { var c = [a, "*"]; for (var d = 0; d < c.length; d++) { var e = c[d]; if (this.listeners[e]) { for (var f = 0; f < this.listeners[e].length; f++) { this.listeners[e][f](b, a, this.name) } } } return this } })()