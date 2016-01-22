
moment = require 'moment'

config = require './config'

db = require('../../openbeelab-db-util/javascript/dbDriver').connectToServer(config.services.database)

db.exists (err,exists)->

    if not err and exists

        db.get '_design/apiaries/_view/by_name',(err,apiaries)->

            for apiary in apiaries

                do (apiary)->
                    apiary = apiary.value

                    if apiary.beehouses?

                        for beehouse_id in apiary.beehouses

                            do (beehouse_id)->

                                db.get beehouse_id,(err,beehouse)->

                                    if not err and beehouse?.isActive

                                        lastMeasuresUrl = '_design/' + beehouse.name + '/_view/evening_weight?descending=true&limit=2'

                                        db.get lastMeasuresUrl,(err,lastMeasures)->

                                            if not err and lastMeasures?

                                                todayMeasure = lastMeasures.rows[0].value
                                                yesterdayMeasure = lastMeasures.rows[1].value
                                                
                                                trigger = config.honeyProductionTrigger

                                                now = moment(new Date())

                                                productionStart = moment(new Date(now.getYear(),trigger.from.month,trigger.from.day))
                                                productionEnd = moment(new Date(now.getYear(),trigger.to.month,trigger.to.day))
                                                if productionEnd.isBefore(productionStart)
                                                    productionEnd = moment(new Date(now.getYear()+1,trigger.to.month,trigger.to.day))

                                                beehouseShouldProduce = beehouse.isActive and now.isBetween(productionStart,productionEnd)
                                                
                                                #todo : deal with imperial units (not Kg)
                                                beehouseIsProducing = todayMeasure.value > (yesterdayMeasure.value + trigger.dailyIncrement.value)

                                                if beehouseShouldProduce and not beehouseIsProducing

                                                    if apiary.beekeepers? and apiary.beekeepers.length > 0

                                                        for beekeeper_id in apiary.beekeepers

                                                            do (beekeeper_id)->

                                                                db.get beekeeper_id,(err,beekeeper)->

                                                                    mailer = require './mailTransporter'
                                                                    
                                                                    mailOptions = #✔
                                                                        from: 'openbeelab beehouse monitoring ✔ <remy.openbeelab@gmail.com>'
                                                                        to: beekeeper.email
                                                                        subject: 'beehouse not producing enough'
                                                                        text: 'beehouse ' + beehouse.name + ' from apiary ' + apiary.name + ' is not producing enough. yesterday: ' + yesterdayMeasure.value + yesterdayMeasure.unit + ". today: " + todayMeasure.value + today.unit + "."
                                                                        #html: '<b>Hello world ✔</b>'

                                                                    mailer.sendMail mailOptions, (error, info)->
                                                                        
                                                                        if error
                                                                            console.log error
                                                                        else
                                                                            console.log 'Message sent: ' + info.response