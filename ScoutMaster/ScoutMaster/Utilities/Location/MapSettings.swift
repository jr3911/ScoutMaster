//
//  MapSettings.swift
//  mapBoxTester
//
//  Created by Sam Roman on 2/3/20.
//  Copyright © 2020 Sam Roman. All rights reserved.
//

import Foundation
import Mapbox



class MapSettings {
    
    //add mapview as property to not call mapview as a parameter on each function
    private init() {}
    
    static let customMap: MGLMapView = {
        let mv = MGLMapView()
               mv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
               mv.styleURL = MGLStyle.lightStyleURL
               mv.userTrackingMode = .followWithHeading
               return mv
    }()
    //then instantiate this map in mapvc
    
    static func toggleMapStyle() -> UIAlertController {
    let actionSheet = UIAlertController(title: "Choose map style", message: nil, preferredStyle: .actionSheet)
    
    let lightStyle = UIAlertAction(title: "Light", style: .default) { (action) in
        customMap.styleURL = MGLStyle.lightStyleURL
    }
    
    let darkStyle = UIAlertAction(title: "Dark", style: .default) { (action) in
        customMap.styleURL = MGLStyle.darkStyleURL
    }
    
    let satelliteStyle = UIAlertAction(title: "Satellite", style: .default) { (action) in
        customMap.styleURL = MGLStyle.satelliteStyleURL
    }
    
    let outdoorsStyle = UIAlertAction(title: "Outdoors", style: .default) { (action) in
        customMap.styleURL = MGLStyle.outdoorsStyleURL
    }
    
    let streetStyle = UIAlertAction(title: "Street", style: .default) { (action) in
       customMap.styleURL = MGLStyle.streetsStyleURL
    }
    
    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    actionSheet.addAction(lightStyle)
    actionSheet.addAction(darkStyle)
    actionSheet.addAction(satelliteStyle)
    actionSheet.addAction(outdoorsStyle)
    actionSheet.addAction(streetStyle)
    actionSheet.addAction(cancel)
        
    return actionSheet
    }
 
    

}
