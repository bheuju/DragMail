//
//  DragMailViewController.swift
//  BusinessCalendar
//
//  Created by Mac on 12/29/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

class DragMailViewController: UIViewController {

    let NIB_NAME = "DragMailCollectionViewCell"
    let COLLECTION_VIEW_CELL_REUSE_ID = "collection_view_cell_reuse_id"
    
    @IBOutlet weak var containerCollectionView: CustomCollectionView!
    
    var cellIndexPaths: [IndexPath] = []
    
    var scrollContentOffset: CGFloat = 0.0
    
    let SCREEN_WIDTH = UIScreen.main.bounds.width
    let CELL_WIDTH = 200
    
    let SCROLL_PADDING: CGFloat = 70.0
    let DELTA_OFFSET: CGFloat = 10

    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Config navbar
        self.navigationItem.title = "Drag Mail"
        
        let refreshButton = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(onRefreshVisibleCells))
        let addBoardButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddBoard))
        self.navigationItem.rightBarButtonItems = [refreshButton, addBoardButton]
        
        //collectionview delegate and datasource
        containerCollectionView.delegate = self
        containerCollectionView.dataSource = self
        
//        let cellHeight = UIScreen.main.bounds.height - (self.navigationController?.navigationBar.frame.height)! - 20
        
        //Collectionview layout
        if let layout = containerCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: CELL_WIDTH, height: 400)
            
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
        }
        
        containerCollectionView.register(UINib(nibName: NIB_NAME, bundle: nil), forCellWithReuseIdentifier: COLLECTION_VIEW_CELL_REUSE_ID)
    }
    
    //Refresh visible cells
    @objc func onRefreshVisibleCells() {
        
//        let visibleCells = self.containerCollectionView.visibleCells
//        for cell in visibleCells {
//            if let cell = cell as? DragMailCollectionViewCell {
//                self.containerCollectionView.reloadDataWithCompletion {
//
//                    //Reload all TableViews (visible table views)
//                    for (_, indexPath) in self.cellIndexPaths.enumerated() {
//                        //print("Refreshed: \(i), \(indexPath)")
//                        if let cell = self.containerCollectionView.cellForItem(at: indexPath) as? DragMailCollectionViewCell {
//                            cell.boardTableView.reloadData()
//                        }
//                    }
//                }
//            }
//        }
        
        //remove all index paths; will be populated again on containerCollectionView.reloadData()
        self.cellIndexPaths.removeAll()
        self.containerCollectionView.reloadDataWithCompletion {

            //Reload all TableViews (visible table views)
            for (_, indexPath) in self.cellIndexPaths.enumerated() {
                //print("Refreshed: \(i), \(indexPath)")
                if let cell = self.containerCollectionView.cellForItem(at: indexPath) as? DragMailCollectionViewCell {
                    cell.boardTableView.reloadData()
                }
            }
        }
    }
    
    //
    @objc func onAddBoard() {
        
        let alert = UIAlertController(title: "Input", message: "Enter board name", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert](_) in
            guard let alert = alert else {
                return
            }
            
            //check for empty field
            guard let boardName = alert.textFields![0].text, alert.textFields![0].hasText else {
                //Display cannot be empty
                return
            }
            
            print("Textfield: \(boardName)")
            
            //Add Board to view
            Data.shared.list.append(BoardEmailItem(title: boardName, items: []))
            self.containerCollectionView.reloadData()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK:- CollectionView Delegate and Datasource
extension DragMailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Data.shared.list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        cellIndexPaths.append(indexPath)
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: COLLECTION_VIEW_CELL_REUSE_ID, for: indexPath) as? DragMailCollectionViewCell {
            cell.dropDelegate = self
            cell.configCell(with: Data.shared.list[indexPath.row], indexPath: indexPath)
            
            //print("IndexPath: ", indexPath)
            
            return cell
        }
        return UICollectionViewCell()
    }
   
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let collectionViewCell = cell as? DragMailCollectionViewCell else {
            return
        }
        collectionViewCell.boardTableView.reloadData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print("Did scroll - ", scrollView.contentOffset)
        scrollContentOffset = scrollView.contentOffset.x
    }
}


//MARK:- Cell Dropped Delegate
extension DragMailViewController: CellDropDelegate {
    
    func cellDraggingAt(_ dragPoint: CGPoint) {
        let convertedPoint = self.containerCollectionView.convert(dragPoint, to: UIScreen.main.coordinateSpace)
        
        //LEFT
        if convertedPoint.x < SCROLL_PADDING {
            scrollContentOffset -= DELTA_OFFSET
        }
        //RIGHT
        if convertedPoint.x > (SCREEN_WIDTH - SCROLL_PADDING) {
            scrollContentOffset += DELTA_OFFSET
        }
        
        //Limit scroll content
        if scrollContentOffset > CGFloat(Data.shared.list.count * CELL_WIDTH) - SCREEN_WIDTH {
            scrollContentOffset = CGFloat(Data.shared.list.count * CELL_WIDTH) - SCREEN_WIDTH
        }
        if scrollContentOffset < 0.0 {
            scrollContentOffset = 0
        }
        
        self.containerCollectionView.setContentOffset(CGPoint(x: scrollContentOffset, y: 0), animated: false)
        scrollViewDidScroll(self.containerCollectionView)
    }
    
    func cellDroppedAt(_ dropPoint: CGPoint, srcIndexPath: IndexPath, srcItemIndexPath: IndexPath) {
        //print("Cell is dropped at: ", dropPoint)
        
        if let destIndexPath = containerCollectionView.indexPathForItem(at: dropPoint) {
            
            //Do nothing on dropping to same table
            if destIndexPath == srcIndexPath {
                self.onRefreshVisibleCells()
                return
            }
            //print("Drop Cell IndexPath: ", destIndexPath.row)
            
            //Get the selected item
            let srcItem = Data.shared.list[srcIndexPath.row].items[srcItemIndexPath.row]
            
            //remove from src table
            Data.shared.list[srcIndexPath.row].items.remove(at: srcItemIndexPath.row)
            //add to dest table
            Data.shared.list[destIndexPath.row].items.append(srcItem)
            
            self.onRefreshVisibleCells()
            
        } else {
            //print("Dropped at weird area !")
            self.onRefreshVisibleCells()
        }
    }
}





