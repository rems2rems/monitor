
moment = require 'moment'
Promise = require 'promise'
config = require './config'
dbConfig = config.services.database

db = require('../../openbeelab-db-util/javascript/dbDriver').connectToServer(dbConfig.database).useDb(config.database.name + "_config")
#db = require('../../openbeelab-db-util/javascript/mockDbForAlerts')

db.exists()
.then (exists)->

    if not exists

        Promise.reject("db doesnt exist")

    return exists

.then (exists)->

    db.get '_design/apiaries/_view/by_name'
    .then (apiaries)->

        for apiary in apiaries

            do (apiary)->
                apiary = apiary.value

                if apiary.beehouses?

                    for beehouse_id in apiary.beehouses

                        do (beehouse_id)->

                            db.get beehouse_id
                            .then (beehouse)->

                                if beehouse?.isActive

                                    lastMeasureUrl = '_design/' + beehouse.name + '/_view/weight?descending=true&limit=1'

                                    db.get lastMeasureUrl
                                    .then (lastMeasure)->

                                        if lastMeasure?

                                            lastMeasure = lastMeasure.rows[0].value
                                            
                                            now = moment(new Date())
                                            lastMeasureTime = moment(new Date(lastMeasure.timestamp))
                                            trigger = config.alerts.connectionTrigger
                                            alertTime = lastMeasureTime.add(trigger.value,trigger.unit )

                                            if now.isAfter(alertTime)

                                                if apiary.beekeepers? and apiary.beekeepers.length > 0

                                                    for beekeeper_id in apiary.beekeepers

                                                        do (beekeeper_id)->

                                                            db.get beekeeper_id
                                                            .then (beekeeper)->

                                                                mailer = require './mailTransporter'
                                                                
                                                                diff = now.diff(lastMeasureTime,'minutes')
                                                                
                                                                mailOptions = #✔
                                                                    from: 'openbeelab beehouse monitoring ✔ <remy.openbeelab@gmail.com>'
                                                                    to: beekeeper.email
                                                                    subject: 'beehouse disconnected'
                                                                    text: 'beehouse ' + beehouse.name + ' from apiary ' + apiary.name + ' didn\'t send data since ' + diff + ' minutes.'
                                                                    #html: '<b>Hello world ✔</b>'

                                                                mailer.sendMail mailOptions, (error, info)->
                                                                    
                                                                    if error
                                                                        console.log error
                                                                    else
                                                                        console.log 'Message sent: ' + info.response                                               
.catch (err)->

    for admin in config.admins

        do (admin)->

            mailer = require './mailTransporter'
                                                  
            mailOptions = #✔
                from: 'openbeelab beehouse monitoring ✔ <remy.openbeelab@gmail.com>'
                to: admin.email
                subject: 'db down'
                text: 'openbeelab db seems to be down...'# + err + " exists: " + exists

            mailer.sendMail mailOptions, (error, info)->

                if error
                    console.log error
                else
                    console.log 'Message sent: ' + info.response