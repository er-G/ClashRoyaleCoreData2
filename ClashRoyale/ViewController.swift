//
//  ViewController.swift
//  ClashRoyale
//
//  Created by Jorge MR on 22/10/17.
//  Copyright © 2017 none. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imagen: UIImageView!
    @IBOutlet weak var nombre: UILabel!
    @IBOutlet weak var descripcion: UILabel!
    
    var managedContext : NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagen.isHidden = true
        nombre.isHidden = true
        descripcion.isHidden = true
        managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func Agregar(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let imagen = info[UIImagePickerControllerOriginalImage] as? UIImage {
            picker.dismiss(animated: true, completion: {
                self.crearPersonaje(image : imagen)
            })
        }
    }
    
    func crearPersonaje(image: UIImage){
        
        let alertController = UIAlertController(title: "Nuevo Personaje", message: "Ingresa sus datos", preferredStyle: .alert)
        alertController.addTextField { (textField:UITextField) in
            textField.placeholder = "Nombre"
        }
        alertController.addTextField { (textField:UITextField) in
            textField.placeholder = "Descripcion"
        }
        let guardarAction = UIAlertAction(title: "Guardar", style: .default) { (action:UIAlertAction) in
            let nombreTextField = alertController.textFields?[0]
            let descripcionTextField = alertController.textFields?[1]
            
            if nombreTextField?.text != "" && descripcionTextField?.text != "" {
                self.nombre.text = nombreTextField?.text
                self.descripcion.text = descripcionTextField?.text
                self.imagen.image = image
                self.imagen.isHidden = false
                self.nombre.isHidden = false
                self.descripcion.isHidden = false
                //CORE DATA INSERT
                let entity = NSEntityDescription.entity(forEntityName: "Personaje", in: self.managedContext)!
                let personaje = NSManagedObject(entity: entity,
                                                insertInto: self.managedContext)
                personaje.setValue(nombreTextField?.text, forKeyPath: "nombre")
                personaje.setValue(descripcionTextField?.text, forKeyPath: "descripcion")
                personaje.setValue(NSData(data: UIImageJPEGRepresentation(image, 0.3)!), forKey: "imagen")
                
                do {
                    try self.managedContext.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            }
        }
        let cancelarAction = UIAlertAction(title: "Cancelar", style: .destructive, handler: nil)
        alertController.addAction(guardarAction)
        alertController.addAction(cancelarAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func Buscar(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Buscando Personaje", message: "Ingresa su nombre", preferredStyle: .alert)
        alertController.addTextField { (textField:UITextField) in
            textField.placeholder = "Nombre"
        }
        let guardarAction = UIAlertAction(title: "Buscar", style: .default) { (action:UIAlertAction) in
            let nombreTextField = alertController.textFields?.first
            
            if nombreTextField?.text != "" {
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Personaje")
                let searchName = nombreTextField?.text
                request.predicate = NSPredicate(format: "nombre == %@", searchName!)
                do {
                    let result = try self.managedContext.fetch(request)
                    if result.count > 0 {
                        self.nombre.text = (result[0] as AnyObject).value(forKey: "nombre") as? String
                        self.descripcion.text = (result[0] as AnyObject).value(forKey: "descripcion") as? String
                        self.imagen.image = UIImage(data: ((result[0] as AnyObject).value(forKeyPath: "imagen") as! Data))
                        self.imagen.isHidden = false
                        self.nombre.isHidden = false
                        self.descripcion.isHidden = false
                    }else{
                        self.nombre.text = "No existe el personaje"
                        self.imagen.isHidden = true
                        self.descripcion.isHidden = true
                        self.nombre.isHidden = false
                    }
                }catch {
                    print(error)
                }
            }else {
                self.nombre.text = "Ingresa todos los campos"
                self.imagen.isHidden = true
                self.descripcion.isHidden = true
                self.nombre.isHidden = false
            }
        }
        let cancelarAction = UIAlertAction(title: "Cancelar", style: .destructive, handler: nil)
        alertController.addAction(guardarAction)
        alertController.addAction(cancelarAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func Coleccion(_ sender: UIButton) {
    }
    
    @IBAction func Borrar(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Borrando Personaje", message: "Ingresa su nombre", preferredStyle: .alert)
        alertController.addTextField { (textField:UITextField) in
            textField.placeholder = "Nombre"
        }
        let guardarAction = UIAlertAction(title: "Borrar", style: .default) { (action:UIAlertAction) in
            let nombreTextField = alertController.textFields?.first
            
            if nombreTextField?.text != "" {
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Personaje")
                let searchName = nombreTextField?.text
                request.predicate = NSPredicate(format: "nombre == %@", searchName!)
                do {
                    let result = try self.managedContext.fetch(request)
                    if result.count > 0 {
                        self.managedContext.delete(result[0] as! NSManagedObject)
                        try self.managedContext.save()
                    }else{
                        self.nombre.text = "No existe el personaje"
                        self.imagen.isHidden = true
                        self.descripcion.isHidden = true
                        self.nombre.isHidden = false
                    }
                }catch {
                    print(error)
                }
            }else {
                self.nombre.text = "Ingresa todos los campos"
                self.imagen.isHidden = true
                self.descripcion.isHidden = true
                self.nombre.isHidden = false
            }
        }
        let cancelarAction = UIAlertAction(title: "Cancelar", style: .destructive, handler: nil)
        alertController.addAction(guardarAction)
        alertController.addAction(cancelarAction)
        present(alertController, animated: true, completion: nil)
    }
    
}

