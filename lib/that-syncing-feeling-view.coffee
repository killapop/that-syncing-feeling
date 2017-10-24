{$, $$, ScrollView, SelectListView, View} = require 'atom-space-pen-views'
{ CompositeDisposable } = require 'atom'
path = require('path')
fs = require('fs')
Rsync = require('rsync')
{ helpers } = require './helpers'
RemotesList = require('./remotes-list-view')

module.exports =
class ThatSyncingFeelingView extends ScrollView
  panel: null

  @content: ->
    @div class: 'sync-panel', =>
      @div outlet: 'panelText', class: 'padded', =>
        @div class: 'block sync-title', =>
          @h4 class: 'inline-block', 'That Syncing Feeling'
        @subview 'remotesView', new RemotesList()

  initialize: (state) ->
    @disposables = new CompositeDisposable
    @attach() if state?.attached

  serialize: ->
    attached: @panel?

  deactivate: ->
    @disposables.dispose()
    @detach() if @panel?

  getTitle: ->
    'That Syncing Feeling'

  attach: ->
    if atom.config.get('that-syncing-feeling.panelPosition') == 'right'
      @panel ?= atom.workspace.addRightPanel item: this
    else
      @panel ?= atom.workspace.addLeftPanel item: this

  detach: ->
    @panel.destroy()
    @panel = null

  toggle: ->
    if @isVisible()
      @detach()
    else
      @attach()
