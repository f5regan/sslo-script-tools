## SSL Orchestrator Use Case: Internal Layered Architecture - Client-Facing Switching iRule
## Version: 2.0
## Date: 2020-11-30
## Author: Kevin Stewart, F5 Networks
## Configuration: see SSLOLIB iRule for build instructions

## Set a default topology assuming no other matches (d not edit)
when CLIENT_ACCEPTED {
    call SSLOLIB::target $static::default_topology
}


#####################################################
## EDIT BELOW THIS BLOCK ############################
#####################################################
when RULE_INIT {
    ## User-defined: DEBUG logging flag (1=on, 0=off)
    set static::SSLODEBUG 1

    ## User-defined: Default topology if no rules match (the topology name as defined in SSLO)
    set static::default_topology "intercept"

    ## User-defined: URL category list (create as many lists as required)
    set static::URLCAT_Finance_Health {
        /Common/Financial_Data_and_Services
        /Common/Health_and_Medicine
    }
}
when CLIENTSSL_CLIENTHELLO {
    ## set local sni variable (for logging)
    set sni ""

    ## Standard certificate Pinners bypass rule (specify your bypass topology)
    if { [call SSLOLIB::SNI CAT:/Common/sslo-urlCatPinners] } { call SSLOLIB::target "bypass" ${sni} "pinners" ; return}


    ################################
    #### SNI CONDITIONS GO HERE ####
    ################################
    #if { [call SSLOLIB::SRCIP IP:10.1.0.0/16] } { call SSLOLIB::target "bypass" ${sni} "SRCIP" ; return }
    #if { [call SSLOLIB::SRCIP DG:my-srcip-dg] } { call SSLOLIB::target "bypass" ${sni} "SRCIP" ; return }

    #if { [call SSLOLIB::SRCPORT PORT:5000] } { call SSLOLIB::target "bypass" ${sni} "SRCPORT" ; return }
    #if { [call SSLOLIB::SRCPORT PORT:1000-60000] } { call SSLOLIB::target "bypass" ${sni} "SRCPORT" ; return }
    
    #if { [call SSLOLIB::DSTIP IP:93.184.216.34] } { call SSLOLIB::target "bypass" ${sni} "DSTIP" ; return }
    #if { [call SSLOLIB::DSTIP DG:my-destip-dg] } { call SSLOLIB::target "bypass" ${sni} "DSTIP" ; return }
    
    #if { [call SSLOLIB::DSTPORT PORT:443] } { call SSLOLIB::target "bypass" ${sni} "DSTPORT" ; return }
    #if { [call SSLOLIB::DSTPORT PORT:443-9999] } { call SSLOLIB::target "bypass" ${sni} "DSTPORT" ; return }
    
    #if { [call SSLOLIB::SNI URL:www.example.com] } { call SSLOLIB::target "bypass" ${sni} "SNIURLGLOB" ; return }
    #if { [call SSLOLIB::SNI URLGLOB:.example.com] } { call SSLOLIB::target "bypass" ${sni} "SNIURLGLOB" ; return }
    
    #if { [call SSLOLIB::SNI CAT:$static::URLCAT_Finance_Health] } { call SSLOLIB::target "bypass" ${sni} "SNICAT" ; return }
    #if { [call SSLOLIB::SNI CAT:/Common/Financial_Data_and_Services] } { call SSLOLIB::target "bypass" ${sni} "SNICAT" ; return }
    
    #if { [call SSLOLIB::SNI DG:my-sni-dg] } { call SSLOLIB::target "bypass" ${sni} "SNIDGGLOB" ; return }
    #if { [call SSLOLIB::SNI DGGLOB:my-sniglob-dg] } { call SSLOLIB::target "bypass" ${sni} "SNIDGGLOB" ; return }

    ## To combine these, you can use smple AND|OR logic:
    #if { ( [call SSLOLIB::DSTIP DG:my-destip-dg] ) and ( [call SSLOLIB::SRCIP DG:my-srcip-dg] ) } { call SSLOLIB::target "bypass" ${sni} "SNIDGGLOB" ; return }
}
