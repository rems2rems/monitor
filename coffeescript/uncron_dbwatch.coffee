fs = require 'fs'
require "../../util/javascript/stringUtils"
arrayUtils = require "../../util/javascript/arrayUtils"
mixin = require "../../util/javascript/mixin"
mixin.include Array,arrayUtils

userName = process.argv[2]
crontabPath = "/var/spool/cron/crontabs/"+userName

fs.readFile crontabPath,'utf8',(err,crontab)->

    lines = crontab.split("\n")

    scriptIsCroned = lines.filter((line)-> line.startWith("#") and line.contain("watchBeehousesConnection")).length > 0

    if not scriptIsCroned

        console.log "script is not croned. exiting."
        return

    lines = lines.init()
    
    lines = lines.filter((line)-> not line.contain("watchBeehousesConnection"))

    if lines.last().isEmpty()
        lines.pop()
    
    fs.writeFile crontabPath,lines.join("\n"),'utf8'