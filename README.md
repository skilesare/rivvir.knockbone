rivvir.knockbone
================

Simplified Single Page Apps using knockout.js and backbone.router

Since early 2013 RIVVIR has been using this framework to build web and mobile SPAs.  Many of these were wrapped in phonegap and deployed to app stores.  This framework has been used to develop(not necessarily by RIVVIR but with at least RIVVIR's guidance:

- IHOP iOS and Android App
- Applebee's iOS and Android App
- Checked Twice iOS and Android App
- Pull Free iOS App
- BettertripLand.com web site

## Why? ##

We've built apps with both Ember(an early version) and Angular.  These frameworks are fragile.  They take you out of the HTML and CSS bare metal of an application and send you into code land.  Coders love this(it seems) but we've experienced that it makes your code very fragile.  Ember has changed their APIs multiple times in the last few years and Angular is already talking about all the changes they will make in 2.0.

We were inspired by the knockback project to take a look at ways we could augment the knockout framework with a few abstraction that wouldn't take us too far away from building what was important.  We had used knockout before and really liked the declarative bindings that allowed our designers to see what was actually happening on a page without having to look at code.  With Ember these had been stuck in Mustache templates and while angular projects would start off in this vein, they would rapidly degenerate into services, and directives that were opaque to outsiders.

We believe this framework is much clearer in what it is trying to achieve.  You aren't and shouldn't write a module system with it, but if you are writing an app with a substantial but limited amount of functionality (5-25 'screens'), this framework will make things much easier on you and any one you hire down the road and you won't have to learn all of Angular or Ember to get started.

## Building ##
You will need to run npm install in the repo directory.

Running the watch.bat will start up watch.  On mac you can just run grunt watch.  This will rebuild your app each time you save a .coffee file.

### Why CoffeeScript? ###

We've found it makes us able to write, debug and read 10x the amount of javascript that we can without it.

### Why ASP.net Project ###

You can ignore this.  This is only if you want persistence.  You can easily simulate this by running a node server that implements ListItem/GetAll(string listID) and ListItem/Save(string listID, string listItemID, string dateAdded, string text, string dateComplete, bool? bComplete).

We are just saving data into Session in this project and we'd be more than happy to accept a pull request that moves this to a node application.

### Why Bootstrap ###

We aren't artists and bootstrap is easy.  It isn't a dependency so feel free to use your own look and feel.

## Running ##
Open the project in Visual Studio.  Run it.  Navigate to localhost:50049/app/index_base.html.  Make lists.

You can also run 'node app/server.js' to start an server on port 557(if you don't use localhost you may get a CORS error).  The service won't run for persistence but the app should work.

## What is What ##

app/index_base.html - This file is the 'shell' of your app. The `<div id="__fixtures"></div>` tag is where your 'fixtures' will be loaded when your application reaches the required state.

### fixtures ###
- `state_home.html`
- `state_hello.html`

You can think of fixtures as 'pages'.  If you want a new page, create a fixture for it.  It is just html code with knockout binding.

    <!--ko if: state() === 'hello' -->
    
    <div class="container" data-bind="fadeOutIn:true">   
    
    <div class="row">
    Hi!<br/>
    <a href="#!home/">Make lists</a>
    </div>
    
    </div>
    
    
    <!-- /ko -->

In the above our fixture will wait until the hello state is reached and then show itself.  Pretty straight forward.  Name the fixture state_hello.html and it will be automatically loaded into the page when that state is reached.  This way you're not loading massive amounts of html until it is time to do something with it.

### scripts ###

All the script/#.coffee files are combined and then compiled into app.js.  Grunt does this.  The numbers at the front of each file are just for listing priority and the types of files in the prefix are just for clarity.  Feel free to use your own convention.

#### gVM ####

- `200_gVM_KBVM.coffee`

The gVM is the Global View Model.  This IS your app.  Everything goes in here.  The framework will bind this object to the body via knock out.  This object is the $root in your fixture knockout bindings.  You will want to reference each of your other classes in here.  So you will see something like this in the constructor:

    @navigation = new Navigation(@)
    @listItemHelper = new ListItemHelper(@)

We are just instantiating our other classes and passing our ViewModel to this. **But you aren't using Inversion of Control or Dependency Injection. Heresy!!**  I'm sorry you feel that way.  If you application becomes so unwieldy that you can't reference all your views and helper classes from the global scope you may be building an application that is too big for this framework.  We've never run into a problem.  We have considered waiting until a view is instantiated to create the object but it hasn't been necessary yet.  Again, we take pull requests.

initApp() is called when the page has all the code loaded.  We do a number of things in here and then when our gVM is ready, we do the knockout binding to the body.  In the Async statement you may want to do things like load your user's data from a server, load look up tables, etc.  You can do these in series or parallel...just do them before you ko.bind().

#### Models and Observable ####

- `300_Model_LineItem.coffee`

A necessary evil of Knockout is the observable object.  Ember has gets and sets and Angular has the requirement of executing changes to your pojos in 'context'.  We wanted angular to solve the observable problem, but we found that we kept ending up out of context and having to cast ourselves back into context.  With knockout's observable we are forced to make ourselves get and set properly.

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

#### Navigation ####

- `400_helper_Navigation.coffee`

This is where the backbone.router comes in.  The navigation class runs most of the app.  It lets us SPAify our app.  When you add a page you need to add the route to the Navigation script and the function to prepare and activate that state:

    routes :
         "" : "showHome" #no route provided defaults to home
         "!hello": "showHello" #show the hello page
         "!home": "showHome" #explicit home route is ok too"
         "!home/:listID" : "showHome" #if we want to load some state into the page
         "*path" : "showHome"  #anything else goes to home

Below we will ensure our app is set up(always do this), get some data we need, set the values and then update our state.  The framework takes care of the rest:

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

#### Helpers ####

- `410_helper_LineItemHelper.coffee`

Helpers are good place to put your code that loads data into your view model and save data back to the server.

#### Views ####

We don't have any 500_Views in the this project, but we have done this in other projects to further abstract away the data to be used in a fixture from the gvm.  When we do this we move the observables into the views and try to keep the observable out of the models and gVMs.

## Summary ##

And that is basically it.  No services, no modules, no directives.  Just write your HTML, bind things that need to change, and route your app.

A fully operating example can be found at https://www.bettertripland.com.  Hint: Hit https://www.bettertripland.com/index_base.html to get the unminified app.js.