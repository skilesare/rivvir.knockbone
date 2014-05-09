# https://github.com/ericclemmons/genesis-skeleton/blob/master/Gruntfile.coffee
#
module.exports = (grunt) ->

  fs = require 'fs'
  path = require 'path'


  try
    shelljs = require 'shelljs/global'
  catch e
    console.log 'shelljs missing. run "npm install shelljs" from repo Directory'

  #-----------------------------------------------------------------------------
  # Task Aliases
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # default - rebuild
  grunt.registerTask "default", [ "rebuild", ]

  #-----------------------------------------------------------------------------
  # rebuild - clean and compile everything
  grunt.registerTask "rebuild", [ "clean", "buildfiles","uglify","compile-web"]

  grunt.registerTask "buildfiles", ["coffee"]

  #-----------------------------------------------------------------------------
  # lint - check everything we can
  # will need --force to get through this
  grunt.registerTask "lint", [
    "clean",
    "buildfiles"
    "coffeelint",
    "jshint",
    "csslint"
  ]

  #-----------------------------------------------------------------------------
  # start - from scratch, log and server
  grunt.registerTask "start", [
    "exec:startlog",
    "exec:startserver",
  ]

  #-----------------------------------------------------------------------------
  # restart - stop and start server, ignore log
  grunt.registerTask "restart", [
    "exec:stopserver",
    "exec:startserver",
  ]

  #-----------------------------------------------------------------------------
  # browse - run the browser in background
  grunt.registerTask "browse", [
    "exec:browse",
  ]

  #-----------------------------------------------------------------------------
  # the config
  #-----------------------------------------------------------------------------
  # constants
  dirs =
      script: __dirname + '/script/'
      testscript: __dirname + '/script/tests/'
      appscript: __dirname + '/app/script/'
      css: __dirname + '/app/css/'
      

  



  #-----------------------------------------------------------------------------
  # What we know how to do
  # the task name is the part after "grunt" or "grunt-contrib"
  # some tasks are multitask, and individual subtasks be run as "exec:startlog"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-jshint"
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-less"
  grunt.loadNpmTasks "grunt-contrib-csslint"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-coffeelint"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-exec"
  grunt.loadNpmTasks "grunt-karma"

  grunt.registerTask "compile-android", "compiles the android index file", ->
    htmlteststring = fs.readFileSync( 'web//app//index_base.html','utf8').toString()
  
    #insert jasmine include
    jasmineinclude = fs.readFileSync 'web//app//script//snippit_android_include.html','utf8'
    jasmineinclude = jasmineinclude.replace(/^\uFEFF/, '')
    htmlteststring = htmlteststring.replace("<!--AndroidInclude-->",jasmineinclude)

    #write file
    fs.writeFileSync path.normalize('web/app/index_android.html'), htmlteststring

  grunt.registerTask "compile-web", "compiles the  index file", ->
    htmlteststring = fs.readFileSync( 'app//index_base.html','utf8').toString()


    htmlteststring = htmlteststring.replace('<script src="script/app.js" type="text/javascript"></script>','<script src="script/app.min.js" type="text/javascript"></script>')

    #write file
    fs.writeFileSync path.normalize('app/index.html'), htmlteststring

  grunt.registerTask "compile-ios", "compiles the ios index file", ->
    htmlteststring = fs.readFileSync( 'web//app//index_base.html','utf8').toString()
  
    #insert jasmine include
    jasmineinclude = fs.readFileSync 'web//app//script//snippit_ios_include.html','utf8'
    jasmineinclude = jasmineinclude.replace(/^\uFEFF/, '')
    

    #write file
    fs.writeFileSync path.normalize('web/app/index_ios.html'), htmlteststring

  grunt.registerTask "pack-phonegap", "copies files to phonegap directories", ->
    grunt.file.copy 'web\\app\\index_ios.html','gapct\\merges\\ios\\index.html'
    grunt.file.copy 'web\\app\\index_android.html','gapct\\merges\\android\\index.html'
    cp '-fR',['web\\app\\script\\*.js'],'gapct\\www\\script\\'
    cp '-fR',['web\\app\\script\\reqs\\*.js'],'gapct\\www\\script\\reqs\\'
    cp '-fR',['web\\app\\images\\*.png','web\\app\\images\\*.jpg'],'gapct\\www\\images\\'
    cp '-fR',['web\\app\\css\\*.css'],'gapct\\www\\css\\'
    cp '-fR',['web\\app\\fixtures\\*.html'],'gapct\\www\\fixtures\\'

  grunt.registerTask "pack", [
    "compile-android",
    "compile-ios"
    "pack-phonegap"
  ]

  #-----------------------------------------------------------------------------
  # config file
  grunt.initConfig

    # need for templates, which are required for targets
    dirs:
      script: dirs.script
      appscript: dirs.appscript
      css: dirs.css
      testscript: dirs.testscript
      fixtures: dirs.fixtures

    #---------------------------------------------------------------------------
    #  cleaner
    clean:
      files: [
        dirs.script + 'app.coffee',
        dirs.script + 'app.js',
        dirs.script + 'app_unit_test.js',
        dirs.script + 'app_e2e_test.js'
        dirs.appscript + 'app.coffee'
        dirs.appscript + 'app.js'
        dirs.appscript + 'app.unit_test.js'
      ]

    #---------------------------------------------------------------------------
    # coffeelint checker
    coffeelint:
      files: [
        'Gruntfile.coffee'
        dirs.script + '*.coffee'
        dirs.testscript + '*.coffee'
        dirs.appscript + '*.coffee'
        '!' + dirs.script + 'app.coffee'
      ]
      options:
        'no_tabs':
          'level': 'ignore'
        'max_line_length':
          'level': 'ignore'
        'no_unnecessary_fat_arrows':
          'level' : 'ignore'

    #---------------------------------------------------------------------------
    # csslint checker
    csslint:
      files: [
        # this target needs template
        '<%= dirs.css %>app.css'
      ]

    #---------------------------------------------------------------------------
    # jshint checker
    jshint:
      # does not use .jshintrc
      options:
        "-W041": false
        "undef": true
        "unused": false
        "shadow":true
        "sub": true
        # /*global */
        "predef": [
          "window",
          "document",
          "$",
          "Backbone",
          "device",
          "setTimeout",
          "Store",
          "_",
          "async",
          "callback",
          "ko",
          "plugins",
          "cordova",
          "Connection",
          "navigator",
          "alert",
          "confirm"
          "Camera",
          "notification",
          "console",
          "require",
          "Math",
          "module",
          "Lazy",
          "parseDate",
          "moment",
          "StripeCheckout",
          "__dirname"
          "ga"

        ]

      files: [
        dirs.script + "app.js"
        dirs.appscript + "app.js"
      ]
    concat:
      options:
        seperator: grunt.util.linefeed + grunt.util.linefeed + grunt.util.linefeed
      dist:
        src: [
          'app/script/reqs/jquery-2.1.0.min.js'
          'app/script/reqs/bootstrap.min.js'
          'app/script/reqs/knockout-3.0.0.js'
          'app/script/reqs/underscore-min.js'
          'app/script/reqs/backbone-min.js'
          'app/script/reqs/lazy.js'

          'app/script/reqs/store.js'
          'app/script/reqs/async.js'
          'app/script/reqs/moment.min.js'
          'app/script/reqs/bootstrap-datepicker.js'
        ]
        dest: 'app/script/reqs.js'
    uglify:
      my_target:
        files:
          'app/script/app.min.js': [
            'app/script/app.js'
          ]
          'app/script/reqs.min.js': [
            'app/script/reqs.js'
          ]
    #---------------------------------------------------------------------------
    # coffee compiler
    coffee:
      compile:
        options:
          join: true
        files:
          '<%= dirs.script %>app.js': [
            dirs.script + '*.coffee',
            '!' + dirs.script + 'app.coffee',
            '!' + dirs.script + 'app_test.coffee',
            '!' + dirs.script + '*_test.coffee',
          ]
          '<%= dirs.script %>app_unit_test.js': [
            dirs.testscript + '*unit_test.coffee',
            '!' + dirs.script + 'app_unit_test.coffee'
          ]
          '<%= dirs.appscript %>app.js': [
            dirs.appscript + '*.coffee',
            '!' + dirs.appscript + 'app.coffee',
            '!' + dirs.appscript + 'app_test.coffee',
            '!' + dirs.appscript + '*_test.coffee',
          ]
          '<%= dirs.appscript %>app_unit_test.js': [
            dirs.appscript + '*unit_test.coffee',
            '!' + dirs.appscript + 'app_unit_test.coffee'
          ]

    #---------------------------------------------------------------------------
    # less compiler
    less:
      compile:
        files:
          '<%= dirs.css %>app.css': [
            dirs.css + '*.less',
          ]
    #---------------------------------------------------------------------------
    # karma runner
    karma:
      continuous:
        configFile: 'karma.unit.conf.js'
        singleRun: true
        browsers: ['Chrome']
        captureTimeout: 60000
      e2e:
        configFile: 'karma.e2e.conf.js'
        singleRun: true
        browsers: ['Chrome']
    watch:
      scripts:
        files: ["**/*.coffee"]
        tasks: ['rebuild','coffeelint','jshint']
      css:
        files: ["**/*.less"]
        tasks: ['rebuild','csslint']

