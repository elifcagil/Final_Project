//
//  PersonalViewController.swift
//  SnackCheckKategoriler
//
//  Created by ELİF ÇAĞIL on 17.03.2025.
//

import UIKit

class PersonalViewController: UIViewController {
    
    //MARK: -Properties
    
    @IBOutlet var userimage: UIImageView!
    @IBOutlet var settingtableview: UITableView!
    @IBOutlet weak var userNameLabel: UILabel!
    var viewModel:PersonalViewModel!
    var firestoreManager = FirestoreManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = PersonalViewModel(firetoreManager: firestoreManager)
        Reload()
        viewModel.PersonelInfo()
        delegateMethod()
       
        
    }
    
    //MARK: HelperMethods
    
    func Reload(){
        viewModel.onFetched = { [weak self] items in
            DispatchQueue.main.async {
                self?.settingtableview.reloadData()
        }
    }
        viewModel.currenUserInfo { [weak self] result in
            switch result{
            case .success(let user):
                DispatchQueue.main.async {
                    self?.userNameLabel.text = "Merhaba \(user.name) \(user.surname)!"
                }
            case .failure(let error):
                print("kullanıcı bulunamadı \(error.localizedDescription)")
                
            }
            
            
        }
    }

    private func delegateMethod(){
        settingtableview.delegate = self
        settingtableview.dataSource = self
    }
    
    func deleteUser(){
        viewModel.deleteUser { result in
                    switch result {
                    case .success():
                        DispatchQueue.main.async {
                                        if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
                                            loginVC.modalPresentationStyle = .fullScreen
                                            self.present(loginVC, animated: true, completion: nil)
                                        }
                                    }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
    }
    func logOutUser(){
        viewModel.logOutUser { result in
            switch result{
            case .success():
                DispatchQueue.main.async {
                    if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
                        loginVC.modalPresentationStyle = .fullScreen
                        self.present(loginVC, animated: true, completion: nil)
                    }
                }
            case .failure(let error):
                print("\(error.localizedDescription)")
            }
        }
    }
}


//MARK: -TableViewDelegate

extension PersonalViewController : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.personelItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let selectedCell = viewModel.personelItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "personelCell", for: indexPath) as! PersonalTableViewCell
        cell.itemNameLabel.text = selectedCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = viewModel.personelItems[indexPath.row]
        
        print("\(selectedItem) seçildi")
        
        if selectedItem == "Hesabımı Kalıcı Olarak Sil"{
            deleteUser()
        }
        if selectedItem == "Oturumu Kapat" {
            logOutUser()
        }
    }
}
