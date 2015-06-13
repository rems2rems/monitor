fs = require 'fs'
require "../../util/javascript/stringUtils"
arrayUtils = require "../../util/javascript/arrayUtils"
mixin = require "../../util/javascript/mixin"
mixin.include Array,arrayUtils

config = require './config'

userName = process.argv[2]

crontabPath = "/var/spool/cron/crontabs/"+userName
fs.readFile ,'utf8',(err,crontab)->

    lines = crontab.split("\n")

    if lines.some((line)-> line.contain("watchBeehousesConnection"))

        console.log "script is already croned. exiting."
        return

    scriptPath = process.argv[3]

    if config.alerts.connectionTrigger.unit.startWith 'day'

        days = "*/" + config.alerts.connectionTrigger.value
        minutes = "*"

    else

        days = "*"
        minutes = "*/" + config.alerts.connectionTrigger.value

    lines.push "# watchBeehousesConnection.js script checks that openbeelab database is up and every beehouse connected to it uploads data frequently"
    lines.push days + " " + minutes + " * * * node " + scriptPath
    lines.push ""

    fs.writeFile crontabPath,lines.join("\n"),'utf8'