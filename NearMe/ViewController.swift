import UIKit
import MapKit

class ViewController: UIViewController {

	//MARK: - properties ============================================
	lazy var mapView: MKMapView = {
		let map = MKMapView()
		map.translatesAutoresizingMaskIntoConstraints = false
		map.showsUserLocation = true
		return map
	}()
	var locationManager: CLLocationManager?
	lazy var searchTextField: UITextField = {
		let tf = UITextField()
		tf.translatesAutoresizingMaskIntoConstraints = false
		tf.delegate = self
		tf.layer.cornerRadius = 10
		tf.clipsToBounds = true
		tf.backgroundColor = .white
		tf.placeholder = "Search"
		tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
		tf.leftViewMode = .always
		tf.returnKeyType = .go
		tf.autocapitalizationType = .none
		return tf
	}()

	//MARK: - lifecycle ============================================
	override func viewDidLoad() {
		super.viewDidLoad()

		layout()
		initLocationManager()
	}

	//MARK: - func ============================================
	private func layout() {
		view.addSubview(mapView)
		view.addSubview(searchTextField)

		// map view
		NSLayoutConstraint.activate([
			mapView.topAnchor.constraint(equalTo: view.topAnchor),
			mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
		])
		// search text field
		NSLayoutConstraint.activate([
			searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
			searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
			searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
			searchTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			searchTextField.heightAnchor.constraint(equalToConstant: 44)
		])
	}
	private func initLocationManager() {
		locationManager = CLLocationManager()
		locationManager?.delegate = self
		locationManager?.requestWhenInUseAuthorization()
		locationManager?.requestLocation()
	}
	private func checkLocationAuthorization() {
		guard let locationManager = locationManager, let location = locationManager.location else { return }

		switch locationManager.authorizationStatus {
		case .denied:
			print("denied")

		case .authorizedAlways, .authorizedWhenInUse:
			let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 750, longitudinalMeters: 750)
			mapView.setRegion(region, animated: true)

		case .notDetermined, .restricted:
			print("not determined or restricted")

		@unknown default:
			break
		}
	}
	private func findNearbyPlaces(by placeName: String) {
		mapView.removeAnnotations(mapView.annotations)

		let request = MKLocalSearch.Request()
		request.naturalLanguageQuery = placeName
		request.region = mapView.region

		let search = MKLocalSearch(request: request)
		search.start { res, err in
			guard let res = res, err == nil else { return }

			let places = res.mapItems.map { item in
				PlaceAnnotation(mapItem: item)
			}

			places.forEach { [weak self] place in
				self?.mapView.addAnnotation(place)
			}
		}
	}
}


//MARK: - CLLocationManagerDelegate ============================================
extension ViewController: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		print("hello world")
	}
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		checkLocationAuthorization()
	}
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print(error)
	}
}

//MARK: - UITextFieldDelegate ============================================
extension ViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		guard let text = textField.text else { return false }
		if !text.isEmpty {
			textField.resignFirstResponder()
			findNearbyPlaces(by: text)
		}
		return true
	}
}

