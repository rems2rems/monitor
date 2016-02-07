
expect = require 'must'
require('../../../openbeelab-util/javascript/objectUtils').install()
require('../../../openbeelab-util/javascript/arrayUtils').install()

config = require('../config')

dbDriver = require('../../../openbeelab-db-util/javascript/mockDriver')
Promise = require 'promise'

dbServer = dbDriver.connectToServer(config.services.database)
dataDb = dbServer.useDb(config.services.database.name)

createViews = require('../../../openbeelab-db-admin/javascript/create_views')
updateDeltas = require '../update_deltas'
#TimeShift = require('../../../openbeelab-util/externaljs/timeshift')
#console.log TimeShift.Date
#TimeShift = require('timeshift-js')
#Date = TimeShift.Date
sinon = require 'sinon'

weight =
    type : "measure"
    name : 'global-weight'
    value : 45.6
    timestamp : '2016-01-28T10:23:55'
    measureOrigin : "manual"
    beehouse_id : "abeehouse"
            
#TimeShift.setTime(TimeShift.getTime() + 75)

delta1 =
    type : "measure"
    name : 'global-weight-delta'
    value : -5.6
    timestamp : '2016-01-28T10:25:18'
    measureOrigin : "automatic"
    beehouse_id : "abeehouse"

#TimeShift.setTime(TimeShift.getTime() + 90)

delta2 =
    type : "measure"
    name : 'global-weight-delta'
    value : 8.3
    timestamp : '2016-01-28T11:45:09'
    measureOrigin : "automatic"
    beehouse_id : "abeehouse"

db = null

describe "the update delta function:",->

    before (done)->
        
        mockDriver = {}
        mockDriver.connectToServer = sinon.stub({},"connectToServer",()-> 
            db = {}
            db.get = sinon.stub({},"get")
            #db.get.onCall(
            return sinon.)
        db.expects("get").calledWith("
        
        dataDb.create()
        .then ()->
            createViews(dataDb,"data")
        .then ->

            Promise.all([dataDb.save(weight),dataDb.save(delta1),dataDb.save(delta2)])
        
            done()

        .catch (err)-> console.log(err); done(err)

    after (done)->

        dbServer.deleteDb(config.services.database.name)
        done()
    
    it "should update delta, and create new absolute measure", (done)->
        
        console.log(dbServer)
        updateDeltas(dataDb,"beehouse","abeehouse","global-weight")
        .then () ->
       
            dataDb.get '_design/beehouse/_view/global-weight-delta'

        .then (deltas)->
            
            console.log("deltas == 0")
            deltas.total_rows.must.be(0)
            dataDb.get '_design/beehouse/_view/global-weight'

        .then (weights)->
            
            weights.total_rows.must.be(3)
            weights.rows[1].key.must.be(["beehouse",delta1.timestamp])
            done()

        .catch (err)->
            
            console.log('err: ' + err)
            done(err)

