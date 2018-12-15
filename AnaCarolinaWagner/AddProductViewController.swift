//
//  AddProductViewController.swift
//  AnaCarolinaWagner
//
//  Created by Wagner Rodrigues on 02/09/2018.
//  Copyright © 2018 ComprasUSA. All rights reserved.
//

import UIKit

class AddProductViewController: UIViewController {
    
    @IBOutlet private weak var textFieldNameProduct: UITextField!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textFieldState: UITextField!
    @IBOutlet private weak var textFieldPrice: UITextField!
    @IBOutlet private weak var switchCard: UISwitch!
    @IBOutlet private weak var buttonRegister: UIButton!
    @IBOutlet weak var buttoPhoto: UIButton!
    
    var product: Product!
    lazy var pickerView : UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = .white
        return pickerView
    }()
    
    var stateManager = StateManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if product != nil {
            title = "Editar produto"
            buttonRegister.setTitle("Alterar", for: .normal)
            if product.image != nil {
                buttoPhoto.setTitle(nil, for: .normal)
            }
            textFieldNameProduct.text = product.name
            textFieldState.text = product.product_state?.description
            if let image = product.image as? UIImage {
                imageView.image = image
            } else {
                debugPrint("nao tem imagem ")
            }
            textFieldPrice.text = product.price.description
            textFieldState.text = product.product_state?.name
            switchCard.isOn = product.isCreditCar
            
        }
        
        prepareProductTextField()
        
    }
    
    func prepareProductTextField() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
//        toolbar.tintColor = UIColor(ciColor: CIColor.blue)
        
        let btCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let btDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done ))
        let btFlexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [btCancel, btFlexibleSpace, btDone]
        textFieldState.inputView = pickerView
        textFieldState.inputAccessoryView = toolbar
    }
    
    
    @objc func cancel() {
        textFieldState.resignFirstResponder()
    }
    
    @objc func done() {
        
       textFieldState.text = stateManager.states[pickerView.selectedRow(inComponent: 0)].name
        
        cancel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stateManager.loadStates(with: context)
 
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addPhotoProduct(_ sender: Any) {
        let alert = UIAlertController(title: "Selecione poster", message: "De onde você quer escolher o poster?", preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Câmera", style: .default, handler: { (action: UIAlertAction) in
                self.selectPicture(sourceType: .camera)
            })
            alert.addAction(cameraAction)
        }
        let libaryAction = UIAlertAction(title: "Bibliotteca de fotos", style: .default) { (action: UIAlertAction) in
            self.selectPicture(sourceType: .photoLibrary)
        }
        alert.addAction(libaryAction)

        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    func selectPicture(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func addEditProduct(_ sender: UIButton) {
        
        guard let name = textFieldNameProduct.text, let txtPrice = textFieldPrice.text, let price = Double(txtPrice),let image = imageView.image, !name.isEmpty, !txtPrice.isEmpty
            else {validate(); return}
        
        if product == nil {
            product = Product(context: context)
        }
        product.name = textFieldNameProduct.text
        product.image = image
        product.price = price
        product.isCreditCar = switchCard.isOn
        if !textFieldState.text!.isEmpty {
            let state = stateManager.states[pickerView.selectedRow(inComponent: 0)]
            state.addToState_product(product)
        }
        product.image = imageView.image
        do{
            try context.save()
        } catch {
            debugPrint(error.localizedDescription)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    func validate() {
        let alert = UIAlertController(title: "Aviso!", message: "Todos os campos são obrigatórios", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }

}

extension AddProductViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return stateManager.states.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let state = stateManager.states[row]
        return state.name
    }
   
}

extension AddProductViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let aspectRatio = image.size.width / image.size.height
            let maxSize: CGFloat = 500
            var smallSize: CGSize
            if aspectRatio > 1 {
                smallSize = CGSize(width: maxSize, height: maxSize/aspectRatio)
            } else {
                smallSize = CGSize(width: maxSize*aspectRatio, height: maxSize)
            }
            
            UIGraphicsBeginImageContext(smallSize)
            image.draw(in: CGRect(x: 0, y: 0, width: smallSize.width, height: smallSize.height))
            imageView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        buttoPhoto.setTitle("", for: .normal)
        
        dismiss(animated: true, completion: nil)
    }
}

