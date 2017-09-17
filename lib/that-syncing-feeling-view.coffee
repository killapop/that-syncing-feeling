{$, $$, ScrollView, SelectListView, View} = require 'atom-space-pen-views'
{ CompositeDisposable } = require 'atom'
path = require('path')
fs = require('fs')
Rsync = require('rsync')
{ helpers } = require './helpers'
RemotesView = require('./remotes-view')

module.exports =
class ThatSyncingFeelingView extends ScrollView
  panel: null

  @content: ->
    @div class: 'sync-panel', =>
      @div outlet: 'panelText', class: 'padded', =>
        @div class: 'block gitlab-title', =>
          @h4 class: 'inline-block', 'That Syncing Feeling'
          @span class: 'badge badge-large icon icon-server gitlab-projects-count', outlet: 'remoteCount', 0
        @subview = 'remotesView': new RemotesView()
        @div class: 'btn-toolbar', =>
          @div class: 'block btn-group', =>
            @button class: 'btn icon icon-repo-clone', outlet: 'btnClone', 'Clone'
            @button class: 'btn icon icon-repo-create', outlet: 'btnCreate', 'Create'
            @button class: 'btn icon icon-repo-sync', outlet: 'btnSync', 'Sync'

  initialize: (state) ->
    @disposables = new CompositeDisposable
    @attach() if state?.attached

  serialize: ->
    attached: @panel?

  deactivate: ->
    @disposables.dispose()
    @detach() if @panel?

  getTitle: ->
    "That Syncing Feeling"

  getRemotes: ->
    @cwd = atom.project.getPaths()
    @conf = JSON.parse(fs.readFileSync(path.join(@cwd[0], '.that-syncing-feeling.json')))
    console.log @conf

  updateProjectsCount: ->

    gitlab.getProjects()
      .then (projects) =>
        @repoCount.context.style.display = undefined;
        @repoCount.context.innerHTML = projects.length
      .catch (error) =>
        console.error error
        @repoCount.context.style.display = 'none';

  attach: ->
    if atom.config.get('gitlab.position') == 'right'
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
