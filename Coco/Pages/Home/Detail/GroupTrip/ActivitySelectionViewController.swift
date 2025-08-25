
//
//  ActivitySelectionViewController.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 25/08/25.
//

import UIKit

final class ActivitySelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let activities: [ActivityDetailDataModel]
    private weak var delegate: GroupTripActivityDetailViewDelegate?
    
    private let tableView = UITableView()
    
    init(activities: [ActivityDetailDataModel], delegate: GroupTripActivityDetailViewDelegate?) {
        self.activities = activities
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Select Activity"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(dismissView)
        )
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "activityCell")
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    @objc private func dismissView() {
        dismiss(animated: true)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath)
        let activity = activities[indexPath.row]
        cell.textLabel?.text = activity.title
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedActivity = activities[indexPath.row]
        delegate?.notifySearchActivitySelected(selectedActivity)
        dismiss(animated: true)
    }
}
