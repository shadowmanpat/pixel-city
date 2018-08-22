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
import Alamofire
import AlamofireImage

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
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()
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
        registerForPreviewing(with: self, sourceView: collectionView!)
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
        cancelAllSessions()
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
        imageUrlArray = []
        imageArray = []
        
        collectionView?.reloadData()
        cancelAllSessions()
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
        print(flickerUrl(forApiKey: apiKey, withAnntiaon: annotaion, andNumperOfPhotos: 40))
        retrieveUrl(forAnnotation: annotaion) { (finished) in
            if finished {
                self.retriveImages(handler: { (finished) in
                    if finished {
                        self.removeSpinner()
                        self.removeProgressLbl()
                        self.collectionView?.reloadData()
                        //reloadCollection View
                    }
                })
            }
            print(self.imageUrlArray)
        }
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
    
    func retrieveUrl(forAnnotation annotation: DroppablePin, handler: @escaping (_ status: Bool) -> ()){
        imageUrlArray = []
        Alamofire.request(flickerUrl(forApiKey: apiKey, withAnntiaon: annotation, andNumperOfPhotos: 40 )).responseJSON { (response) in
            guard let json = response.result.value as? Dictionary<String, AnyObject> else {return}
            let photosDict = json["photos"] as! Dictionary<String, AnyObject>
            let photosDictionaryArray = photosDict["photo"] as! [Dictionary<String, AnyObject>]
            for photo in photosDictionaryArray{
                let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                self.imageUrlArray.append(postUrl)
            }
            handler(true )
            
        }
     
    }
    func cancelAllSessions(){
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach({ $0.cancel() })
            downloadData.forEach({$0.cancel()})
        }
    }
    func retriveImages(handler: @escaping (_ status: Bool) -> ()){
        imageArray = []
        
        for url in imageUrlArray {
            Alamofire.request(url).responseImage { (response) in
                guard let image  = response.result.value else { return }
                self.imageArray.append(image)
                self.progressLbl?.text = "\(self.imageArray.count)/40 images downloades"
                if(self.imageArray.count == self.imageUrlArray.count){
                    handler(true)
                }
            }
        }
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
        return imageArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else{return UICollectionViewCell()}
        let imageFormIndex = imageArray[indexPath.row]
        let imageView = UIImageView(image: imageFormIndex)
        cell.addSubview(imageView)
        return cell
     //   return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else {return}
        popVC.initData(forImage: imageArray[indexPath.row])
        present(popVC, animated: true, completion: nil)
    }
    
}

extension MapVC: UIViewControllerPreviewingDelegate{
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView?.indexPathForItem(at: location), let cell = collectionView?.cellForItem(at: indexPath) else {
            return nil
        }
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC")as? PopVC else {return nil}
        popVC.initData(forImage: imageArray[indexPath.row])
        
        previewingContext.sourceRect = cell.contentView.frame
        return popVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    
}





