
config = require './config'
dbConfig = config.services.database

db = require('../../openbeelab-db-util/javascript/dbDriver').connectToServer(dbConfig.database).useDb(config.database.name + "_config")
#db = require('../../openbeelab-db-util/javascript/mockDbForAlerts')

db.get('_design/ruche2/_view/deltas')
.then (result)->
    
    deltas = result.rows.map (row)->row.value
    for delta in deltas

        do (delta)->

            console.log delta.timestamp
            console.log delta.beehouse_id
            console.log delta.value

            delete delta.absolute_weight_inserted
            # delta.value *= -1
            # delta.raw_value *= -1
            db.save delta

#     if orphans?.rows?.length > 0
#         console.log "orphan found"
#         orphan = orphans.rows[0].value
#         console.log "orphan="
#         console.log orphan._id
#         console.log orphan.beehouse_id
#         console.log orphan.timestamp
#         console.log "-----"

#         lastWeightUrl = '_design/global_weight/_view/by_beehouse_and_date?startkey=["' + orphan.beehouse_id + '",{}]&endkey=["' + orphan.beehouse_id + '"]&descending=true&limit=1'
#         db.get(lastWeightUrl)
#         .then (lastWeight)->

#             if lastWeight?.rows?.length > 0
#                 lastWeight = lastWeight.rows[0].value
#                 console.log "lastWeight="
#                 console.log lastWeight._id
#                 console.log lastWeight.beehouse_id
#                 console.log lastWeight.timestamp
#                 console.log "-----"

#                 delete lastWeight._id
#                 delete lastWeight._rev
                
#                 lastWeight.measure_origin = "computed_from_delta"
#                 lastWeight.value += orphan.value
#                 lastWeight.timestamp = orphan.timestamp

#                 db.save(lastWeight).then ->

#                     console.log "measure uploaded to db " + dbConfig.name

#                     delete orphan._rev
#                     orphan.absolute_weight_inserted = true
#                     db.save(orphan).then ->

#                         console.log "delta " + orphan._id + " updated as ok"
#     else
#         console.log "no orphan-delta found. exiting"
.catch (err)->
    console.log err