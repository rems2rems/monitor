module.exports =
    
    services :

        database :
            host : 'localhost'
            protocol : 'http'
            port : 5984
            name : 'la_mine'
            apiary_name : 'la_mine_rucher_01'

        mailer : 
            service : 'gmail'
            auth :
                user : 'remy.openbeelab'
                pass : 'openbeelabmonitoring'

    admins : [

        name : "remy"
        email : "remy.brousset@gmail.com"
    ]

    alerts :

        connectionTrigger :

            value : 15
            unit : 'minutes'

        honeyProductionTrigger :

            from : 
                month : 6 #june
                day : 1
            to :
                month : 8 #august
                day : 30

            dailyIncrement :

                value : 0.5
                unit : 'Kg'