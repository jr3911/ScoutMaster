import UIKit
import Mapbox
import MapboxAnnotationExtension

class MapVC: UIViewController, MGLMapViewDelegate, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, AddPointViewDelegate {
    
    
    //MARK: Variables
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = .init(white: 0.2, alpha: 0)
        cv.register(MapCell.self, forCellWithReuseIdentifier: "mapCell")
        cv.isScrollEnabled = true
        cv.contentInset = .init(top: 0, left: 4, bottom: 0, right: 4)
        return cv
    }()
    
    lazy var locationButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .init(white: 0.2, alpha: 0.8)
        button.layer.cornerRadius = 25
        button.tintColor = .white
        button.setBackgroundImage(UIImage(systemName: "location.circle"), for: .normal)
        button.addTarget(self, action: #selector(locationButtonTapped(sender:)), for: .touchUpInside)
        return button
    }()
    
    lazy var addAnnotationButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .init(white: 0.2, alpha: 0.8)
        button.layer.cornerRadius = 25
        button.tintColor = .white
        button.setBackgroundImage(UIImage(systemName: "plus.circle"), for: .normal)
        button.addTarget(self, action: #selector(showAddPointView(sender:)), for: .touchUpInside)
        return button
    }()
    
    
    lazy var recordTrailButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 25
        button.backgroundColor = .systemRed
        button.tintColor = .white
        button.setBackgroundImage(UIImage(systemName: "smallcircle.fill.circle"), for: .normal)
        return button
    }()
    
    lazy var addPopUp: AddPointView = {
           let popUp = AddPointView()
           popUp.delegate = self
           return popUp
       }()
    
    //MARK: Map Properties
    var mapView = MapSettings.customMap
    
    var newCoords: [(Double,Double)]! {
        didSet {
            print(newCoords!)
            for i in newCoords {
                coordinates.append(CLLocationCoordinate2D(latitude: i.0, longitude: i.1))
            }
        }
    }
    
    
    var coordinates = [CLLocationCoordinate2D]()
    
    var pointsOfInterest = [PointOfInterest]() {
        didSet {
            self.pointsOfInterest.forEach { (point) in
                let poi = MGLPointAnnotation()
                poi.coordinate = CLLocationCoordinate2D(latitude: point.lat, longitude: point.long)
                poi.title = point.title
                mapView.addAnnotation(poi)
            }
        }
    }
    
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        (40.652106, -73.971206)
        mapView.setCenter(CLLocationCoordinate2D(latitude: 40.668, longitude: -73.9738), zoomLevel: 14, animated: false)
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        drawTrailPolyline()
        constrainMap()
        constrainCV()
        constrainLocationButton()
        constrainAddAnnotationButton()
        constrainRecordTrailButton()
        constrainAddPopUp()
        getPointsOfInterest()
    }
    
    //MARK: Constraint Methods
    
    
    func constrainLocationButton(){
        view.addSubview(locationButton)
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            locationButton.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height / 9),
            locationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            locationButton.heightAnchor.constraint(equalToConstant: 50),
            locationButton.widthAnchor.constraint(equalToConstant: 50)])
    }
    func constrainAddAnnotationButton(){
        view.addSubview(addAnnotationButton)
        addAnnotationButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addAnnotationButton.topAnchor.constraint(equalTo: locationButton.bottomAnchor, constant: 10),
            addAnnotationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            addAnnotationButton.heightAnchor.constraint(equalToConstant: 50),
            addAnnotationButton.widthAnchor.constraint(equalToConstant: 50)])
    }
    
    func constrainRecordTrailButton(){
        view.addSubview(recordTrailButton)
        recordTrailButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recordTrailButton.topAnchor.constraint(equalTo: addAnnotationButton.bottomAnchor, constant: 10),
            recordTrailButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            recordTrailButton.heightAnchor.constraint(equalToConstant: 50),
            recordTrailButton.widthAnchor.constraint(equalToConstant: 50)])
    }
    
    func constrainCV(){
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 90),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50),
            collectionView.heightAnchor.constraint(equalToConstant: 100)])
        
    }
    
    func constrainMap(){
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 30),
            mapView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.widthAnchor.constraint(equalTo: view.widthAnchor)])
        
    }
    
    func constrainAddPopUp(){
        view.addSubview(addPopUp)
        addPopUp.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addPopUp.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hidePopUpTopAnchorConstraint,
            addPopUp.heightAnchor.constraint(equalToConstant: view.frame.height / 2),
            addPopUp.widthAnchor.constraint(equalToConstant: view.frame.width)])
    }
    
    lazy var hidePopUpTopAnchorConstraint: NSLayoutConstraint = {
        return addPopUp.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    }()
    
    lazy var showPopUpTopAnchorConstraint: NSLayoutConstraint = {
        return addPopUp.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
    }()
    
    
    //MARK: Private Methods
    func dismissAddPointView() {
        switchAnimationAddPopUp()
    }
    
    @objc func showAddPointView(sender: UIButton){
        switchAnimationAddPopUp()
        
    }
    
    private func switchAnimationAddPopUp(){
        switch addPopUp.shown {
        case false:
            UIView.animate(withDuration: 0.3) {
                self.hidePopUpTopAnchorConstraint.isActive = false
                self.showPopUpTopAnchorConstraint.isActive = true
                self.view.layoutIfNeeded()
                self.addPopUp.shown = true
            }
        case true:
            UIView.animate(withDuration: 0.3) {
                self.hidePopUpTopAnchorConstraint.isActive = true
                self.showPopUpTopAnchorConstraint.isActive = false
                self.view.layoutIfNeeded()
                self.addPopUp.shown = false
            }
        }
    }
    
    @objc func locationButtonTapped(sender: UIButton) {
        var mode: MGLUserTrackingMode
        switch (mapView.userTrackingMode) {
        case .none:
            mode = .follow
        case .follow:
            mode = .followWithHeading
        case .followWithHeading:
            mode = .followWithCourse
        case .followWithCourse:
            mode = .none
        @unknown default:
            fatalError("Unknown user tracking mode")
        }
        mapView.userTrackingMode = mode
        mapView.setCenter(mapView.userLocation!.coordinate, zoomLevel: 16, animated: true)
    }
    

    private func getCoordinates(data: Data){
        do {
            var coords = [(Double,Double)]()
            let rawCoords = (try LocationData.getCoordinatesFromData(data: data))!
            for i in rawCoords {
                coords.append((i[1],i[0]))
            }
            newCoords = coords
            print("got coordinates")
        }
        catch {
            print("error, could not decode geoJSON")
        }
    }
    
    private func getPointsOfInterest() {
        var poi = [PointOfInterest]()
        do {
            try poi = POIPersistenceHelper.manager.getItems()
        } catch {
            print("unable to fetch points of interest")
        }
        self.pointsOfInterest = poi
    }

    
    
    
    
    //MARK: Visual Map Data
    func addPointOfInterest() {
        let current = mapView.userLocation!.coordinate
        do {
            try POIPersistenceHelper.manager.save(newItem: PointOfInterest(lat: Double(current.latitude), long: Double(current.longitude), type: "Default", title: addPopUp.titleField.text ?? "", desc: addPopUp.descField.text ?? ""))
        } catch {
            print("error, could not save POI")
        }
      
    }
    
    func drawTrailPolyline() {
        DispatchQueue.global(qos: .background).async(execute: {
            // Get the path for example.geojson in the app's bundle
            let jsonPath = Bundle.main.path(forResource: "prospectparkloop", ofType: "geojson")
            let url = URL(fileURLWithPath: jsonPath!)
            
            do {
                // Convert the file contents to a shape collection feature object
                let data = try Data(contentsOf: url)
                self.getCoordinates(data: data)
                guard let shapeCollectionFeature = try MGLShape(data: data, encoding: String.Encoding.utf8.rawValue) as? MGLShapeCollectionFeature else {
                    fatalError("Could not cast to specified MGLShapeCollectionFeature")
                }
                
                if let polyline = shapeCollectionFeature.shapes.first as? MGLPolylineFeature {
                    // Optionally set the title of the polyline, which can be used for:
                    polyline.title = polyline.attributes["name"] as? String
                    // Add the annotation on the main thread
                    DispatchQueue.main.async(execute: {
                        // Unowned reference to self to prevent retain cycle
                        [unowned self] in
                        self.mapView.addAnnotation(polyline)
                    })
                    
                }
            } catch {
                print("GeoJSON parsing failed")
            }
            
        })
        
    }
    
    
    //MARK: CV Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mapCell", for: indexPath) as? MapCell else { return UICollectionViewCell() }
        cell.setIconForIndex(index: indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: 70)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    
    
    
    //MARK: MV Delegate Methods
    func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        return 4.0
    }
    
    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        return .systemBlue
    }
    
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
    }
    
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        let reuseIdentifier = "reusableDotView"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        if annotationView == nil {
            annotationView = MGLAnnotationView(reuseIdentifier: reuseIdentifier)
            annotationView?.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            annotationView?.layer.cornerRadius = (annotationView?.frame.size.width)! / 2
            annotationView?.layer.borderWidth = 2.0
            annotationView?.layer.borderColor = UIColor.white.cgColor
            annotationView!.backgroundColor = UIColor(red: 0.03, green: 0.80, blue: 0.69, alpha: 1.0)
        }
        
        return annotationView
    }
    
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    
    
    
    
    
}


