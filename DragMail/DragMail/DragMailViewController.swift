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
    
    let collectionViewCellCount = Data.shared.list.count
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Config navbar
        self.navigationItem.title = "Drag Mail"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(onRefresh))
        
        //collectionview delegate and datasource
        containerCollectionView.delegate = self
        containerCollectionView.dataSource = self
        
        //Collectionview layout
        if let layout = containerCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: 200, height: 450)
        }
        
        containerCollectionView.register(UINib(nibName: NIB_NAME, bundle: nil), forCellWithReuseIdentifier: COLLECTION_VIEW_CELL_REUSE_ID)
    }
    
    //Refresh visible cells
    @objc func onRefresh() {
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
}

//MARK:- CollectionView Delegate and Datasource
extension DragMailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewCellCount
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
}


//MARK:- Cell Dropped Delegate
extension DragMailViewController: CellDropDelegate {
    
    func cellDroppedAt(_ dropPoint: CGPoint, srcIndexPath: IndexPath, srcItemIndexPath: IndexPath) {
        //print("Cell is dropped at: ", dropPoint)
        
        if let destIndexPath = containerCollectionView.indexPathForItem(at: dropPoint) {
            //print("Drop Cell IndexPath: ", destIndexPath.row)
            
            //Get the selected item
            let srcItem = Data.shared.list[srcIndexPath.row].items[srcItemIndexPath.row]
            
            //remove from src table
            Data.shared.list[srcIndexPath.row].items.remove(at: srcItemIndexPath.row)
            //add to dest table
            Data.shared.list[destIndexPath.row].items.append(srcItem)
            
            self.onRefresh()
            
        } else {
            //print("Dropped at weird area !")
            self.onRefresh()
        }
    }
}





