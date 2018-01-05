//
//  DragMailCollectionViewCell.swift
//  BusinessCalendar
//
//  Created by Mac on 12/29/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

class DragMailCollectionViewCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate {

    let BOARD_CELL_REUSE_ID = "board_cell_reuse_id"
    
    @IBOutlet weak var boardTableView: UITableView!
    @IBOutlet weak var title: UILabel!
    
    var dragView: UIView? = nil
    
    //MARK:- View Injection
    var data: BoardEmailItem?
    var indexPath: IndexPath?       //CollectionViewCell IndexPath of cell
//    var srcItemIndexPath: IndexPath?
    
    var srcIndexPathInTableView: IndexPath?     //IndexPath of selected item in tableView
    
    weak var dropDelegate: CellDropDelegate?
    weak var cellButtonClickDelegate: CellButtonClickDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.lightGray.cgColor
        
        //TableView delegate and datasource
        boardTableView.delegate = self
        boardTableView.dataSource = self
        
        //TableView configurations
        boardTableView.separatorStyle = .none   //remove separator
        //boardTableView.allowsSelection = false  //disable selection to remove selection color
//        boardTableView.isEditing = true
        
        //Register nib
        boardTableView.register(UINib(nibName: "BoardTableViewCell", bundle: nil), forCellReuseIdentifier: BOARD_CELL_REUSE_ID)

    }

    //MARK:- Tableview delegate and datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (data?.items.count)!
    }
    
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
//        return UITableViewCellEditingStyle.none
//    }
//    
//    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
//        return false
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: BOARD_CELL_REUSE_ID, for: indexPath) as! BoardTableViewCell
        
        //cell.message.text = data?.items[indexPath.row]
        cell.configCell(item: (BoardItemViewModel(mailResult: (data?.items[indexPath.row])!, checkStatus: false)))
        
        let lpGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressCell))
        cell.addGestureRecognizer(lpGestureRecognizer)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
    }
    
    @objc func didLongPressCell(recognizer: UILongPressGestureRecognizer) {
        
//        let placeHolderCell = BoardTableViewCell(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        
        //Get parent view (Collection view)
        let collectionView = self.superview as? UICollectionView
        
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
            
            //AutoScroll of parent collectionview
            dropDelegate?.cellDraggingAt((dragView?.center)!)
            
            //Change in same tableView
            guard let srcIndexPathInTableView = self.srcIndexPathInTableView else { return }
            //get indexpath in tableView cell at drag point
            let pointInTableView = recognizer.location(in: boardTableView)
            guard let destIndexPathInTableView = self.boardTableView.indexPathForRow(at: pointInTableView) else { return }
            
            //print("\(srcIndexPathInTableView) -> \(destIndexPathInTableView)")
            //print(srcItemIndexPath?.row)
            
            if srcIndexPathInTableView != destIndexPathInTableView {
                let srcItem = data?.items[srcIndexPathInTableView.row]
                
                print("\(srcIndexPathInTableView) -> \(destIndexPathInTableView)")

                data?.items.remove(at: srcIndexPathInTableView.row)
                data?.items.insert(srcItem!, at: destIndexPathInTableView.row)
                
                self.boardTableView.moveRow(at: destIndexPathInTableView, to: srcIndexPathInTableView)
                self.boardTableView.reloadRows(at: [srcIndexPathInTableView, destIndexPathInTableView], with: .automatic)
                
                if let cell = self.boardTableView.cellForRow(at: srcIndexPathInTableView) as? BoardTableViewCell {
                    cell.isHidden = false
                } else if let cell = self.boardTableView.cellForRow(at: destIndexPathInTableView) as? BoardTableViewCell {
                    cell.isHidden = true
                }
                
                self.srcIndexPathInTableView = destIndexPathInTableView
            }
            
        case .ended:
            //print("Drag ended")
            
            //stop dragview animation
            dragView?.layer.removeAllAnimations()
            dragView?.transform = CGAffineTransform(rotationAngle: 0)
            
            //do assigning to tableview
            if dragView == nil {
                return
            }
            
            //TODO: check "dragView.center" position in collection view
            if let dropPoint = dragView?.center {                
                //TODO: get indexPath of collectionViewCell and its tableView for ended point of "dragView.center"
                dropDelegate?.cellDroppedAt(dropPoint, srcIndexPath: self.indexPath!, srcItemIndexPath: srcIndexPathInTableView!)
            }
            
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
    
    //MARK:- Configure cell
    func configCell(with data: BoardEmailItem, indexPath: IndexPath) {
        self.title.text = data.boardTitle
        
        self.data = data
        self.indexPath = indexPath
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

//MARK:- Button Actions
extension DragMailCollectionViewCell {
    @IBAction func onRefresh(_ sender: UIButton) {
        self.boardTableView.reloadData()
    }
    
    @IBAction func onEdit(_ sender: UIButton) {
        cellButtonClickDelegate?.onEditClicked(sender)
    }
}

//MARK:- Delegates
protocol CellDropDelegate: class {
    func cellDroppedAt(_ dropPoint: CGPoint, srcIndexPath: IndexPath, srcItemIndexPath: IndexPath)
    func cellDraggingAt(_ dragPoint: CGPoint)
}

protocol CellButtonClickDelegate: class {
    func onEditClicked(_ sender: UIButton)
}








