module.exports =
    
    services :

        database :
            host : '77.207.158.40'
            protocol : 'http'
            port : 5984
            auth :
                username : 'admin'
                password : 'c0uchAdm1n'
            name : 'fred_db'
            apiary_name : 'rucher_001'

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