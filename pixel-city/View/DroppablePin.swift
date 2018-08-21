//
//  File.swift
//  pixel-city
//
//  Created by macbook on 15/08/2018.
//  Copyright © 2018 macbook. All rights reserved.
//

import Foundation

import UIKit
import MapKit

class DroppablePin : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var identifier: String
    init (coordinate: CLLocationCoordinate2D, identifier: String){
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
}
