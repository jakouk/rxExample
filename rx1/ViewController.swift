//
//  ViewController.swift
//  rx1
//
//  Created by unbTech on 2017. 11. 30..
//  Copyright © 2017년 unbTech. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  
  var shownCities = [String]()
  let allCities = ["New York", "London", "Oslo", "Warsaw", "Berlin", "Praga"]
  let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.dataSource = self
    tableView.delegate = self
    
    // 여기서 query 는 searchBar의 text
//    searchBar.rx.text.orEmpty
//      .subscribe(onNext: { [unowned self] query in
//        self.shownCities = self.allCities.filter { $0.hasPrefix(query) }
//        self.tableView.reloadData()
//      }).disposed(by: disposeBag)
    
    searchBar
      .rx.text  // RxCocoa의 Observable 속성
      .orEmpty // 옵셔널이 아니도록 만듭니다.
      .debounce(0.5, scheduler: MainScheduler.instance) // wait 0.5 for chages.
      .distinctUntilChanged() // 새로운 값이 이전의 값과 같은지 확인합니다.
      .filter{ !$0.isEmpty } // 새로운 값이 정말 새롭다면, 비어있지 않은 쿼리를 위해 필터링 합니다.
      .subscribe(onNext: { [unowned self] query in // Here we subscribe to every new value, that is not empty (thanks to filter above).
        self.shownCities = self.allCities.filter { $0.hasPrefix(query) } // 도시를 착기 위한 "API 요청" 작업을 합니다.
        self.tableView.reloadData() // 테이블 뷰를 다시 불러옵니다.
      }).disposed(by: disposeBag)
    
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

extension ViewController: UITableViewDataSource {
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return shownCities.count
  }
  
  
  // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
  // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
  
  @available(iOS 2.0, *)
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cityPrototypeCell", for: indexPath)
    cell.textLabel?.text = shownCities[indexPath.row]
    return cell
  }
  
}

extension ViewController: UITableViewDelegate {
  
}
