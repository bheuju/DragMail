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
    var indexPath: IndexPath?
    var srcItemIndexPath: IndexPath?
    
    weak var dropDelegate: CellDropDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.lightGray.cgColor
        
        //TableView delegate and datasource
        boardTableView.delegate = self
        boardTableView.dataSource = self
        
        //TableView configurations
        boardTableView.separatorStyle = .none   //remove separator
        boardTableView.allowsSelection = false  //disable selection to remove selection color
        
        //Register nib
        boardTableView.register(UINib(nibName: "BoardTableViewCell", bundle: nil), forCellReuseIdentifier: BOARD_CELL_REUSE_ID)
    }

    //MARK:- Tableview delegate and datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (data?.items.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BOARD_CELL_REUSE_ID, for: indexPath) as! BoardTableViewCell
        
        //cell.message.text = data?.items[indexPath.row]
        cell.configCell(item: (BoardItemViewModel(mailResult: (data?.items[indexPath.row])!, checkStatus: false)))
        
        let lpGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressCell))
        cell.addGestureRecognizer(lpGestureRecognizer)
       
        return cell
    }
    
    @objc func didLongPressCell(recognizer: UILongPressGestureRecognizer) {
        
        //Get parent view (Collection view)
        let collectionView = self.superview as? UICollectionView
        
        switch recognizer.state {
        case .began:
            //print("Drag start")
            
            if let cellView: UIView = recognizer.view {
                
                cellView.frame.origin = CGPoint.zero
                dragView = cellView

                dragView?.center = recognizer.location(in: collectionView)  //self.superview is collectionview
                
                //animate drag view
                dragView?.transform = CGAffineTransform(rotationAngle: -0.08)
                UIView.animate(withDuration: 0.1, delay: 0, options: [.repeat, .autoreverse], animations: {
                    self.dragView?.transform = CGAffineTransform(rotationAngle: -0.04)
                }, completion: nil)
                collectionView?.addSubview(dragView!)
                
                //get indexpath of selected item from tableView
                let clickPoint = recognizer.location(in: boardTableView)
                //print("Click Point: ", clickPoint)
                srcItemIndexPath = self.boardTableView.indexPathForRow(at: clickPoint)
                
                //dragged item deleted from delegate when placed in another tableView
            }
            
        case .changed:
            dragView?.center = recognizer.location(in: collectionView)
            //TODO: do checking in ".changed" if need dynamic reordering of tableview cells
            
            //AutoScroll of parent collectionview
            dropDelegate?.cellDraggingAt((dragView?.center)!)
            
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
                dropDelegate?.cellDroppedAt(dropPoint, srcIndexPath: self.indexPath!, srcItemIndexPath: srcItemIndexPath!)
            }
            
            //remove dragview from superview
            dragView?.removeFromSuperview()
            dragView = nil
            
        default:
            print("Any other location")
        }
    }
    
    //MARK:- Configure cell
    func configCell(with data: BoardEmailItem, indexPath: IndexPath) {
        self.title.text = data.boardTitle
        
        self.data = data
        self.indexPath = indexPath
    }
    
    @IBAction func onRefresh(_ sender: UIButton) {
        self.boardTableView.reloadData()
    }
}

protocol CellDropDelegate: class {
    func cellDroppedAt(_ dropPoint: CGPoint, srcIndexPath: IndexPath, srcItemIndexPath: IndexPath)
    func cellDraggingAt(_ dragPoint: CGPoint)
}








