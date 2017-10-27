# that-syncing-feeling package

atom plugin to sync folders with remote servers over rsync and ssh.

__Please Note:__ This project is in very early development and has only been tested on Linux.

## Requirements
1. [rsync](https://rsync.samba.org/)
2. [ssh](https://www.openssh.com/)
3. ssh access to the server(s) that you want to sync with.

## Configuration

You need to have a configuration filed named `.that-syncing-feeling.json` file in the root of your project.

```
{
  "path": "media/",
  "remotes": [
    {
      "name": "Staging",
      "host": "219.187.187.203",
      "user": "freedom",
      "path": "/srv/media/"
    },
    {
      "name": "Production",
      "host": "219.187.187.223",
      "user": "holiday",
      "path": "/srv/media/"
    },
    {
      "name": "Local-testing",
      "host": "10.0.0.3",
      "user": "minnie",
      "path": "/gitlab/projects/myproject/media/"
    }
  ]
}

```

## Usage

Open the __That Syncing Feeling__ panel either from the atom menu `Packages > that-syncing-feeling > Toggle` or by pressing `Ctrl + Alt + 2`

Click the `check status` button of each remote to check if files need to be uploaded or downloaded.
