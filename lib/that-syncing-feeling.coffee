ThatSyncingFeelingView = require('./that-syncing-feeling-view');
{ CompositeDisposable } = require('atom');
helpers = require './helpers'



module.exports = ThatSyncingFeeling =
  thatSyncingFeelingView: null,
  modalPanel: null,
  subscriptions: null,
  activate: (@state) ->
    @disposables = new CompositeDisposable
    @state.attached ?= true if @shouldAttach()

    @createViews() if @state.attached

    @disposables.add atom.commands.add 'atom-workspace', 'that-syncing-feeling:toggle': => @toggle()

  deactivate: ->
    @disposables.dispose()
    @thatSyncingFeelingView?.deactivate()
    @thatSyncingFeelingView = null

  serialize: ->
    thatSyncingViewState: @thatSyncingFeelingView?.serialize()

  createViews: ->
    unless @thatSyncingViewState?
      @thatSyncingFeelingView = new ThatSyncingFeelingView @state.thatSyncingViewState

    @thatSyncingFeelingView

  shouldAttach: ->
    true

  toggle: ->
    if @thatSyncingFeelingView?.isVisible()
      @thatSyncingFeelingView.toggle()
    else
      @createViews()
      @thatSyncingFeelingView.attach()
