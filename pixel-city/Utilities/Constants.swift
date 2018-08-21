//
//  Constants.swift
//  pixel-city
//
//  Created by macbook on 21/08/2018.
//  Copyright © 2018 macbook. All rights reserved.
//

import Foundation

let apiKey = "d30035975330d8f211e884d1ad2dd5f6"

func flickerUrl(forApiKey key: String, withAnntiaon annotation: DroppablePin, andNumperOfPhotos number: Int) -> String
{
        let url =  "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=10&radius_units=km&format=json&nojsoncallback=1"
    return url
}
