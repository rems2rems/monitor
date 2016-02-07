
update = (db,objectType,objectId,measureName)->

    console.log("----->")
    endKey = '[' + objectId + ']'
    startKey = '[' + objectId + ',{}]'
    db.get('_design/' + objectType + '/_view/' + measureName + '-delta?startkey='+startKey+'&endkey='+endKey+'&descending=true&limit=1')
    .then (deltas)->
        
        console.log(db.dbs)
        console.log(deltas)
        if deltas.total_rows == 0
            return

        console.log "delta found"
        delta = deltas.rows[0].value
        console.log "delta="
        console.log "id:" + delta._id
        console.log delta.beehouse_id
        console.log delta.timestamp
        console.log "-----"

        db.get('_design/' + objectType + '/_view/' + measureName + '?startkey='+startKey+'&endkey='+endKey+'&descending=true&limit=1')
        .then (absolute)->
        
            return [delta,absolute.rows[0]]

        .then ([delta,absolute])->

            newAbs = absolute.clone()
            delete newAbs._rev
            delete newAbs._id
            
            console.log "absolute ="
            console.log absolute._id
            console.log absolute.beehouse_id
            console.log absolute.timestamp
            console.log "-----"

            newAbs.measureOrigin = "computed"
            newAbs.absoluteSource = absolute._id
            newAbs.relativeSource = delta._id
            newAbs.value = absolute.value + delta.value
            newAbs.timestamp = delta.timestamp

            db.save(newAbs)
            .then (newAbsId)->

                newAbs._id = newAbsId
                return [delta,absolute,newAbs]

            .then ([delta,absolute,newAbs]) ->

                delta.absoluteSource = absolute._id
                delta.absoluteTarget = newAbs._id
                db.save(delta)
    
            .then ->

                console.log("delta updated")
                update(db,objectType,measureName)

    .catch (err)->

        console.log err

module.exports = update
