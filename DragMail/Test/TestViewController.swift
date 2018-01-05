//
//  TestViewController.swift
//  DragMail
//
//  Created by Mac on 1/5/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    @IBOutlet weak var boardTableView: UITableView!
    
    var dragView: UIView? = nil
    
    var srcIndexPathInTableView: IndexPath?     //IndexPath of selected item in tableView
    
    var data: [String] = ["", "", "", "", "", "", "", ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        boardTableView.delegate = self
        boardTableView.dataSource = self
        
        boardTableView.separatorStyle = .none
        
        boardTableView.register(UINib(nibName: "SimpleTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        boardTableView.isEditing = true
        
    }

}

extension TestViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BoardTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let lpGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressCell))
        cell.addGestureRecognizer(lpGestureRecognizer)
        
        return cell
    }
    
    @objc func didLongPressCell(recognizer: UILongPressGestureRecognizer) {
        
        //        let placeHolderCell = BoardTableViewCell(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        
        //Get parent view (Collection view)
        let collectionView = self.view
        
        switch recognizer.state {
        case .began:
            //print("Drag start")
            
            if let cellView: UIView = recognizer.view {
                
                //get indexpath of selected item from tableView
                let clickPoint = recognizer.location(in: boardTableView)
                self.srcIndexPathInTableView = self.boardTableView.indexPathForRow(at: clickPoint)
                
                //print("Indexpath: ", srcIndexPathInTableView)
                
                cellView.frame.origin = CGPoint.zero
                dragView = getSnapShotOfView(cellView)
                
                dragView?.center = recognizer.location(in: collectionView)
                
                //animate drag view
                dragView?.transform = CGAffineTransform(rotationAngle: -0.08)
                UIView.animate(withDuration: 0.1, delay: 0, options: [.repeat, .autoreverse], animations: {
                    self.dragView?.transform = CGAffineTransform(rotationAngle: -0.04)
                }, completion: nil)
                collectionView?.addSubview(dragView!)
                
                //hide cell from tableView
                cellView.isHidden = true
                
                //dragged item deleted from delegate when placed in another tableView
            }
            
        case .changed:
            dragView?.center = recognizer.location(in: collectionView)
            //TODO: do checking in ".changed" if need dynamic reordering of tableview cells
            
            //Change in same tableView
            guard let srcIndexPathInTableView = self.srcIndexPathInTableView else { return }
            //get indexpath in tableView cell at drag point
            let pointInTableView = recognizer.location(in: boardTableView)
            guard let destIndexPathInTableView = self.boardTableView.indexPathForRow(at: pointInTableView) else { return }
            
            //print("\(srcIndexPathInTableView) -> \(destIndexPathInTableView)")
            //print(srcItemIndexPath?.row)
            
            if srcIndexPathInTableView != destIndexPathInTableView {
                let srcItem = data[srcIndexPathInTableView.row]
                
                print("\(srcIndexPathInTableView) -> \(destIndexPathInTableView)")
                
                data.remove(at: srcIndexPathInTableView.row)
                data.insert(srcItem, at: destIndexPathInTableView.row)
                
                self.boardTableView.moveRow(at: destIndexPathInTableView, to: srcIndexPathInTableView)
                //self.boardTableView.reloadRows(at: [srcIndexPathInTableView, destIndexPathInTableView], with: .automatic)
                
//                if let cell = self.boardTableView.cellForRow(at: srcIndexPathInTableView) as? BoardTableViewCell {
//                    cell.isHidden = false
//                } else if let cell = self.boardTableView.cellForRow(at: destIndexPathInTableView) as? BoardTableViewCell {
//                    cell.isHidden = true
//                }
                
                self.srcIndexPathInTableView = destIndexPathInTableView
            }
            
        case .ended:
            //print("Drag ended")
            
            boardTableView.reloadRows(at: [srcIndexPathInTableView!], with: .automatic)
            
            //remove dragview from superview
            dragView?.removeFromSuperview()
            dragView = nil
            srcIndexPathInTableView = nil
            
        default:
            print("Any other location")
            dragView?.removeFromSuperview()
            dragView = nil
            srcIndexPathInTableView = nil
        }
    }
    
    func getSnapShotOfView(_ inputView: UIView) -> UIView {
        
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let snapShot : UIView = UIImageView(image: image)
        snapShot.layer.masksToBounds = false
        return snapShot
    }
}
