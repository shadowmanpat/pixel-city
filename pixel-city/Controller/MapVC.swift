//
//  MaaVC.swift
//  pixel-city
//
//  Created by macbook on 13/08/2018.
//  Copyright © 2018 macbook. All rights reserved.
//

import UIKit
import MapKit
import  CoreLocation

class MapVC: UIViewController, UIGestureRecognizerDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = UIColor.orange
        pinAnnotation.animatesDrop = true
        
        
        return pinAnnotation
    }
    var flowLayout = UICollectionViewFlowLayout()
    var collectionView: UICollectionView?
    
    var screenSize = UIScreen.main.bounds
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapViewBottomContraint: NSLayoutConstraint!
    @IBOutlet weak var pullupView: UIView!
    var spinner: UIActivityIndicatorView?
    var progressLbl: UILabel?
    
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regioRadius: Double = 1000
    
    @IBAction func centerMapBtnWasPrsd(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addDoubleTap()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = UIColor.green
        
        pullupView.addSubview(collectionView!)
        
    }

    func addDoubleTap(){
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
        
    }
    
    func addSwie(){
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector (animateViewDown))
        swipe.direction = .down
        pullupView.addGestureRecognizer(swipe)
    }
    
    func animateViewUp(){
        mapViewBottomContraint.constant = 300
        UIView.animate(withDuration: 0.3){
             self.view.layoutIfNeeded()
        }
       
    }
    @objc func animateViewDown(){
        mapViewBottomContraint.constant = 0
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()
        }
        
    }
    func addSpinner(){
        spinner = UIActivityIndicatorView()
        spinner?.center =  CGPoint(x: screenSize.width/2 -  (spinner?.frame.width)!/2,y: 150)
        spinner? .activityIndicatorViewStyle = .whiteLarge
        spinner?.startAnimating()
        pullupView.addSubview(spinner!)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func dropPin(sender: UITapGestureRecognizer){
        removePin()
        animateViewUp()
        removeSpinner()
        addSpinner()
        assProgressLbl()
        removeProgressLbl()
        //print ("")
        let touchPoint = sender.location(in: mapView)
        let touchCooordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotaion = DroppablePin(coordinate: touchCooordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotaion)
        
        let coordinateRegio = MKCoordinateRegionMakeWithDistance(touchCooordinate, regioRadius * 2, regioRadius * 2)
        mapView.setRegion(coordinateRegio, animated: true)
        
//        mapView.
    }
    func removeProgressLbl() {
        if progressLbl != nil{
            progressLbl?.removeFromSuperview()
        }
    }
    func removeSpinner(){
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    func removePin(){
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    func assProgressLbl(){
        progressLbl = UILabel()
        progressLbl?.frame = CGRect(x: (screenSize.width/2) - 200 , y: 175, width: 200, height: 40)
        progressLbl?.font = UIFont(name: "Avanir Next", size: 10)
        progressLbl?.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        progressLbl?.textAlignment = .center
        progressLbl?.text = "12/48 Photos Loaded"
        pullupView?.addSubview(progressLbl!)
        
    }


}

extension MapVC: MKMapViewDelegate {
    func centerMapOnUserLocation(){
        guard let coordinate = locationManager.location?.coordinate else {return}
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regioRadius * 2, regioRadius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}

extension MapVC: CLLocationManagerDelegate{
    func configureLocationServices(){
        if authorizationStatus == .notDetermined{
            locationManager.requestAlwaysAuthorization()
        }else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
    
}

extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //number of item in array
        return 4
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell
        return cell!
     //   return UICollectionViewCell()
    }
    
}
