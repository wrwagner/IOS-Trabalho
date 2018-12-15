//
//  AddTaxedStateViewController.swift
//  AnaCarolinaWagner
//
//  Created by Wagner Rodrigues on 03/09/2018.
//  Copyright © 2018 ComprasUSA. All rights reserved.
//

import UIKit

class AddTaxedStateViewController: UIViewController {

    let KEY_DOLAR = "dolar"
    let KEY_IOF = "iof"
    
    @IBOutlet weak var textFieldValorDolar: UITextField!
    @IBOutlet weak var textFieldValorIOF: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonAddState: UIButton!
    
    var stateManager = StateManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        loadStates()
        // Do any additional setup after loading the view.
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textFieldValorDolar.text = "\(UserDefaults.standard.value(forKey: KEY_DOLAR) as? Double ?? 0)"
        textFieldValorIOF.text = "\(UserDefaults.standard.value(forKey: KEY_IOF) as? Double ?? 0)"
        
        textFieldValorDolar.addTarget(self, action: #selector(updateDolarSetting(_:)), for: UIControlEvents.editingChanged)

        textFieldValorIOF.addTarget(self, action: #selector(updateIOFSetting(_:)), for: UIControlEvents.editingChanged)
    }
    
    func loadStates() {
        stateManager.loadStates(with: context)
        tableView.reloadData()
    }
    
    @objc func updateDolarSetting(_ textField: UITextField) {
        if let textFieldValorDolar = textField.text,
            let dolar = Double(textFieldValorDolar) {
            UserDefaults.standard.set(dolar, forKey: KEY_DOLAR)
        }
    }
    
    @objc func updateIOFSetting(_ textField: UITextField) {
        if let textFieldValorIOF = textField.text,
            let iof = Double(textFieldValorIOF) {
            UserDefaults.standard.set(iof, forKey: KEY_IOF)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addState(_ sender: UIButton) {
        
        showAlert(with: nil)
    }
    
    func showAlert(with state: State?) {
        let title = state == nil ? "Adicionar" : "Editar"
        let alert = UIAlertController(title: title + " estado", message: nil, preferredStyle: .alert)
        alert.addTextField { (textFieldState) in
            textFieldState.placeholder = "DIgite o nome do Estado"
            if let name = state?.name {
                textFieldState.text = name
            }
        }
        alert.addTextField { (textFieldTax) in
            textFieldTax.placeholder = "Digite a taxa"
            if let tax = state?.tax {
                textFieldTax.keyboardType = .numberPad
                textFieldTax.text = tax.description
            }
        }
        alert.addAction(UIAlertAction(title: title, style: .default, handler: { (action) in
            
            guard let name = alert.textFields?.first?.text,
                let tax = alert.textFields?.last?.text,
                !name.isEmpty, !tax.isEmpty else {return}

            let state = state ?? State(context: self.context)
            state.name = alert.textFields?.first?.text
            state.tax = Double(tax) ?? 0
            do {
                try self.context.save()
                self.loadStates()
            } catch {
                debugPrint(error.localizedDescription)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

extension AddTaxedStateViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let count = stateManager.states.count
        
        if count == 0 {
            tableView.separatorStyle = .none
        } else {
            tableView.separatorStyle = .singleLine
        }
        
        return stateManager.states.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let state = stateManager.states[indexPath.row]
        cell.textLabel?.text = state.name
        cell.detailTextLabel?.text = String(format: "U$ %.2f", state.tax)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let state = stateManager.states[indexPath.row]
        showAlert(with: state)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            stateManager.deleteState(index: indexPath.row, context: context)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
}

