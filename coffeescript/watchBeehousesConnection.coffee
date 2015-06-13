
moment = require 'moment'

config = require './config'
dbConfig = config.services.database

db = require('../../dbUtil/javascript/dbUtil').database(dbConfig)
#db = require('../../dbUtil/javascript/mockDbForAlerts')

db.exists (err,exists)->

    if err or not exists

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

    else

        db.get '_design/apiaries/_view/by_name',(err,apiaries)->

            for apiary in apiaries

                do (apiary)->
                    apiary = apiary.value

                    if apiary.beehouses?

                        for beehouse_id in apiary.beehouses

                            do (beehouse_id)->

                                db.get beehouse_id,(err,beehouse)->

                                    if not err and beehouse?.isActive

                                        lastMeasureUrl = '_design/' + beehouse.name + '/_view/weight?descending=true&limit=1'

                                        db.get lastMeasureUrl,(err,lastMeasure)->

                                            if not err and lastMeasure?

                                                lastMeasure = lastMeasure.rows[0].value
                                                
                                                now = moment(new Date())
                                                lastMeasureTime = moment(new Date(lastMeasure.timestamp))
                                                trigger = config.alerts.connectionTrigger
                                                alertTime = lastMeasureTime.add(trigger.value,trigger.unit )

                                                if now.isAfter(alertTime)

                                                    if apiary.beekeepers? and apiary.beekeepers.length > 0

                                                        for beekeeper_id in apiary.beekeepers

                                                            do (beekeeper_id)->

                                                                db.get beekeeper_id,(err,beekeeper)->

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