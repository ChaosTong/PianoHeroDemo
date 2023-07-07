//
//  ViewController.swift
//  PianoHero
//
//  Created by ChaosTong on 2023/7/7.
//

import UIKit

let ScreenW = UIScreen.main.bounds.width
let ScreenH = UIScreen.main.bounds.height

class ViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        let tv = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: ScreenW, height: ScreenH))
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()
    
    var dataList: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        
        dataList = Bundle.main.paths(forResourcesOfType: "mid", inDirectory: "")
        dataList.sort()
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "Cell")
            cell?.textLabel?.textColor = .black
        }
        cell?.textLabel?.text = dataList[indexPath.row].components(separatedBy: ".app/").last
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = dataList[indexPath.row]
        let vc = VC_Midi()
        vc.midiPath = model
        navigationController?.pushViewController(vc, animated: true)
    }
}
