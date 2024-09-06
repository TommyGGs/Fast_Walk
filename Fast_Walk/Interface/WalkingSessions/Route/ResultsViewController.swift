//
//  ResultsViewController.swift
//  Fast_Walk
//
//  Created by Tom  on 2024/07/25.
//

import UIKit
import GooglePlaces
import CoreLocation

protocol ResultsViewControllerDelegate: AnyObject {
    
    // fix here
    func didTapPlace(with place: GMSPlace, placeName: String)
}

class ResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: ResultsViewControllerDelegate?
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self,
                       forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var places: [Place] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    public func update(with places: [Place]) {
        self.places = places
        self.tableView.isHidden = false  
        tableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = places[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.isHidden = true
        let place = places[indexPath.row]
        
        GooglePlacesManager.shared.resolveLocation(for: place) { result in
            switch result{
            case .success(let result):
                DispatchQueue.main.async {
                    // fix here 
                    self.delegate?.didTapPlace(with: result, placeName: place.name)
                    print("place name is:", place.name, "result place is", result)
                }
            case .failure(let error):
                print(error)
            }
        }
        
    }
}
