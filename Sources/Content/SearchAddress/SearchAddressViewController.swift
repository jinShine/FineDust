//
//  SearchAddressViewController.swift
//  FineDust_Copy
//
//  Created by 승진김 on 28/02/2019.
//  Copyright © 2019 승진김. All rights reserved.
//

import UIKit

final class SearchAddressViewController: UIViewController {
    //MARK:- UI Constant

    private struct UI {
        static let headerConstainerHeight: CGFloat = 200
        static let basicMargin: CGFloat = 16
        static let searchbarMargin: CGFloat = 8
        static let basicImageSize: CGFloat = 20
        static let keyboardShowDuration: TimeInterval = 0.25
    }
    
    private enum Row: Int {
        case currentLocation = 0
        case recentSearch
    }
    
    
    //MARK:- UI Property
    
    let headerContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.fromHexString("#0076FF")
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    let naviRightCloseButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Close_White"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(closeAction), for: UIControl.Event.touchUpInside)
        return button
    }()
    
    let headerTitle: UILabel = {
        let label = UILabel()
        label.text = "위치 설정"
        label.textColor = .white
        label.font = FontName.sfHeavy(35).font
        return label
    }()
    
    lazy var searchAddressSearchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "예) 서울시 서초구 서초동, 서초구 서초동"
        searchBar.barTintColor = .white
        searchBar.backgroundImage = UIImage()
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = .white
        searchBar.delegate = self
        return searchBar
    }()
    
    let separateLine: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .clear
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .interactive
        tableView.register(CurrentLocationCell.self, forCellReuseIdentifier: String(describing: CurrentLocationCell.self))
        tableView.register(SearchedAddressCell.self, forCellReuseIdentifier: String(describing: SearchedAddressCell.self))
        return tableView
    }()

    
    
    //MARK:- Properties
    private var searchAddressService: AddressServiceType?
    private var addressArray = [Juso]()
    
    //MARK:- Initialize
    init(addressService: AddressService) {
        super.init(nibName: nil, bundle: nil)
        
        self.searchAddressService = addressService
        
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupNotification()
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    //MARK:- Setup
    
    private func setupUI() {
        
        view.backgroundColor = UIColor.fromHexString("#0076FF")
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        [tableView, headerContainerView, separateLine].forEach { view.addSubview($0) }
        
        [naviRightCloseButton, headerTitle, searchAddressSearchBar].forEach {
            headerContainerView.addSubview($0)
        }
        
        naviRightCloseButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            naviRightCloseButton.topAnchor.constraint(equalTo: headerContainerView.topAnchor, constant: UI.basicMargin),
            naviRightCloseButton.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor, constant: -UI.basicMargin),
            naviRightCloseButton.heightAnchor.constraint(equalToConstant: UI.basicImageSize),
            naviRightCloseButton.widthAnchor.constraint(equalToConstant: UI.basicImageSize)
        ])
        
        
        headerContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerContainerView.heightAnchor.constraint(equalToConstant: UI.headerConstainerHeight)
        ])
        
        headerTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerTitle.bottomAnchor.constraint(equalTo: searchAddressSearchBar.topAnchor, constant: -UI.basicMargin * 2),
            headerTitle.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor, constant: UI.basicMargin),
            headerTitle.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor, constant: -UI.basicMargin)
        ])
        
        searchAddressSearchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchAddressSearchBar.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: -UI.searchbarMargin),
            searchAddressSearchBar.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor, constant: UI.searchbarMargin),
            searchAddressSearchBar.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor, constant: -UI.searchbarMargin),
            
        ])
        
        separateLine.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            separateLine.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: 0),
            separateLine.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),
            separateLine.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor),
            separateLine.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: separateLine.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIApplication.keyboardWillHideNotification, object: nil)
    }
    
    
}

//MARK:- Action Handle

extension SearchAddressViewController {
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let notiInfo = notification.userInfo else { return }
        guard let keyboardFrame = notiInfo["UIKeyboardFrameEndUserInfoKey"] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        
        UIView.animate(withDuration: UI.keyboardShowDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        UIView.animate(withDuration: UI.keyboardShowDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    // 중복 제거
    private func deduplication(from array: [Juso], with searchText: String) -> [Juso] {
        var set = Set<String>()
        let result = array.filter {
            guard !set.contains($0.emdNm) else { return false }
            set.insert($0.emdNm)
            return true
        }
        return result
    }
    
    private func requestAddress(region: String) {
        searchAddressService?.requestAddress(regionName: region, completion: { [weak self] response in
            switch response {
            case .success(let value):
                guard let self = self else { return }
                print("requestAddress", value)
                self.addressArray = self.deduplication(from: value.results.juso, with: region)
                self.tableView.reloadData()
            case .failure(let error):
                self?.addressArray = []
                print(error)
            }
        })
    }
    
    @objc private func closeAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension SearchAddressViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case Row.currentLocation.rawValue:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CurrentLocationCell.self), for: indexPath) as? CurrentLocationCell else { return UITableViewCell() }
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SearchedAddressCell.self), for: indexPath) as? SearchedAddressCell else { return UITableViewCell() }
            
            let jusos = self.addressArray[indexPath.row - 1]
            cell.configureWith(jusoModel: jusos)
            
            return cell
        }
    }
}

extension SearchAddressViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case Row.currentLocation.rawValue:
            NotificationCenter.default.post(name: NSNotification.Name.init(App.Define.updateRegion.rawValue), object: nil, userInfo: nil)
        default:
            NotificationCenter.default.post(name: NSNotification.Name.init(App.Define.updateRegion.rawValue), object: nil, userInfo: [App.Define.updateRegion.rawValue : self.addressArray[indexPath.row - 1]])
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
}

extension SearchAddressViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            print(searchText)
            if searchText.isEmpty {
                self.addressArray = []
            } else {
                DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                    self.requestAddress(region: searchText)
                })
            }
            self.tableView.reloadData()
        }
    }
}
