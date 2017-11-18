{View} = require('atom-space-pen-views')
path = require('path')
_ = require('lodash')
child_process = require('child_process')
Promise = require('bluebird')


fs = Promise.promisifyAll(require('fs-extra'))
cwd = atom.project.getPaths()[0]
filePath = path.join cwd, '.that-syncing-feeling.json'

# conf = Promise.resolve(filePath)
#   .catch atom.notifications.addError("You need to add a config file named .that-syncing-feeling.json to your root. Please see the readme for a sample config file", {dismissable: true, icon: 'x'})
#   .then fs.readFileSync
#   .then JSON.parse
conf = {}
fs.readFile filePath
.then (d) =>
  return _.merge conf, JSON.parse d
.catch (err) ->
  atom.notifications.addError("You need to add a config file named .that-syncing-feeling.json to your root. Please see the readme for a sample config file", {dismissable: true, icon: 'x'})
remotes = conf.remotes


runShell = (cmd) ->
  return new Promise (resolve, reject) ->
    console.log resolve
    shell = child_process.execSync(cmd, { encoding: 'utf8'})
    return parseInt shell

class RemoteItem extends View
  @content: (remoteState) ->
    @div class: "remote", outlet: "#{remoteState.name}", =>
      @div class: 'details', =>
        @strong remoteState.name
        @em remoteState.host
      @div class: 'actions', =>
        @button class: "btn btn-info refresh", click: 'checkFiles', =>
          @span "check status"
        @button class: "btn btn-success upload", disabled: 'true', title: "upload to #{remoteState.name}", outlet: 'uploadButton', click: 'syncUp', =>
          @span "upload"
        @button class: 'btn btn-warning download', disabled: 'true', title: "download from #{remoteState.name}", outlet: 'downloadButton', click: 'syncDown', =>
          @span "download"

  initialize: (remoteState) ->
    @remoteState = remoteState
    @destination = "#{@remoteState.user}@#{@remoteState.host}:#{@remoteState.path}"

  update: () ->

  destinationPath = (remoteState) ->
    return "#{remoteState.user}@#{remoteState.host}:#{remoteState.path}"

  checkFiles: () ->
    cmdUp = "rsync -rvnc --delete #{cwd}/#{conf.path} -e ssh #{destinationPath(@remoteState)}| head -n -3 | tail -n +2 | grep -v ^delet | wc -l"
    cmdDown = "rsync -rvnc --delete #{cwd}/#{conf.path} -e ssh #{destinationPath(@remoteState)}| head -n -3 | tail -n +2 | grep ^delet | wc -l"
    newState = _.merge(@remoteState, {up: runShell(cmdUp) isnt 0, down: runShell(cmdDown) isnt 0})
    @downloadButton.prop("disabled", !@remoteState.down)
    @uploadButton.prop("disabled", !@remoteState.up)

  syncUp: () ->
    cmd = "rsync -au --quiet --partial #{cwd}/#{conf.path} -e ssh #{destinationPath(@remoteState)}"
    syncit = runShell(cmd, '')
    if syncit isnt NaN
      @checkFiles()
      atom.notifications.addSuccess("Successfully synced files to #{@remoteState.name}", {dismissable: true})
    else if syncit is NaN
      @checkFiles()
      atom.notifications.addError("an error occured while attempting to upload files to #{@remoteState.name}. Please contact the maintainer of this project", {dismissable: true, icon: 'x'})
    return

  syncDown: () ->
    cmd = "rsync -au --quiet --partial -e ssh #{destinationPath(@remoteState)} #{cwd}/#{conf.path}"
    syncit = runShell(cmd, '')
    if syncit isnt NaN
      @checkFiles()
      atom.notifications.addSuccess("Successfully synced files from #{remote.name}", {dismissable: true})
    else if syncit is NaN
      @checkFiles()
      atom.notifications.addError("an error occured while attempting to upload files from #{@remote.name}. Please contact the maintainer of this project", {dismissable: true, icon: 'x'})
    return

module.exports =
class RemotesList extends View
  @content: ->
    @div class: 'remotes', =>
      @div class: 'remotes-head', =>
        @h4 'Remotes'
      if conf.remotes?
        for remote in conf.remotes
          @subview remote.name, new RemoteItem(remote)
      else
        @div class: 'no-remotes', 'No remotes have been defined for this project.'

  initialize: () ->
    @remotesState = conf.remotes
