//
//  ViewController.swift
//  proy ri
//
//  Created by alumno on 20/06/23.
//

import UIKit

class ViewController: UIViewController {
    // Variables para almacenar los datos del ciclo menstrual
        var startDate: Date?
        var cycleLength: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Crear los elementos de la interfaz de usuario
                createUI()
    }
    func createUI() {
            view.backgroundColor = .white
            
            // Crear una etiqueta para mostrar la fecha de inicio
            let startDateLabel = UILabel(frame: CGRect(x: 50, y: 100, width: 200, height: 30))
            startDateLabel.text = "Fecha de inicio: No definida"
            startDateLabel.textColor = .blue
            view.addSubview(startDateLabel)
            
            // Crear un botón para establecer la fecha de inicio
            let setStartDateButton = UIButton(type: .system)
            setStartDateButton.frame = CGRect(x: 50, y: 150, width: 200, height: 30)
            setStartDateButton.setTitle("Establecer fecha de inicio", for: .normal)
            setStartDateButton.addTarget(self, action: #selector(setStartDate), for: .touchUpInside)
            setStartDateButton.tintColor = .blue
            view.addSubview(setStartDateButton)
            
            // Crear una etiqueta para mostrar la duración del ciclo
            let cycleLengthLabel = UILabel(frame: CGRect(x: 50, y: 200, width: 200, height: 30))
            cycleLengthLabel.text = "Duración del ciclo: No definida"
            cycleLengthLabel.textColor = .green
            view.addSubview(cycleLengthLabel)
            
            // Crear un botón para establecer la duración del ciclo
            let setCycleLengthButton = UIButton(type: .system)
            setCycleLengthButton.frame = CGRect(x: 50, y: 250, width: 200, height: 30)
            setCycleLengthButton.setTitle("Establecer duración del ciclo", for: .normal)
            setCycleLengthButton.addTarget(self, action: #selector(setCycleLength), for: .touchUpInside)
            setCycleLengthButton.tintColor = .green
            view.addSubview(setCycleLengthButton)
            
            // Crear un botón para calcular la fecha del próximo periodo
            let calculateNextPeriodButton = UIButton(type: .system)
            calculateNextPeriodButton.frame = CGRect(x: 50, y: 300, width: 200, height: 30)
            calculateNextPeriodButton.setTitle("Calcular próximo periodo", for: .normal)
            calculateNextPeriodButton.addTarget(self, action: #selector(calculateNextPeriod), for: .touchUpInside)
            calculateNextPeriodButton.tintColor = .red
            view.addSubview(calculateNextPeriodButton)
        }
    @objc func setStartDate() {
            // Mostrar un selector de fecha
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            datePicker.addTarget(self, action: #selector(startDateChanged), for: .valueChanged)
            
            let alertController = UIAlertController(title: "Seleccionar fecha de inicio", message: nil, preferredStyle: .actionSheet)
            alertController.view.addSubview(datePicker)
            
            let doneAction = UIAlertAction(title: "Aceptar", style: .default, handler:

     nil)
            alertController.addAction(doneAction)
            
            present(alertController, animated: true, completion: nil)
        }
    @objc func startDateChanged(datePicker: UIDatePicker) {
            startDate = datePicker.date
            
            if let startDate = startDate {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy"
                let startDateString = formatter.string(from: startDate)
                let startDateLabel = view.subviews.first  as? UILabel
                startDateLabel?.text = "Fecha de inicio: \(startDateString)"
            }
        }
        
        @objc func setCycleLength() {
            // Mostrar un cuadro de diálogo para ingresar la duración del ciclo
            let alertController = UIAlertController(title: "Ingresar duración del ciclo", message: nil, preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.keyboardType = .numberPad
                textField.placeholder = "Duración del ciclo (en días)"
            }
            
            let doneAction = UIAlertAction(title: "Aceptar", style: .default) { [weak self] _ in
                if let textField = alertController.textFields?.first, let cycleLengthText = textField.text, let cycleLength = Int(cycleLengthText) {
                    self?.cycleLength = cycleLength
                    let cycleLengthLabel = self?.view.subviews.first as? UILabel
                    cycleLengthLabel?.text = "Duración del ciclo: \(cycleLength) días"
                }
            }
            
            alertController.addAction(doneAction)
            
            present(alertController, animated: true, completion: nil)
        }
        
        @objc func calculateNextPeriod() {
            guard let startDate = startDate, let cycleLength = cycleLength else {
                // Mostrar una alerta si no se ha establecido la fecha de inicio o la duración del ciclo
                let alertController = UIAlertController(title: "Error", message: "Por favor, establece la fecha de inicio y la duración del ciclo", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
                return
            }
            
            // Calcular la fecha del próximo periodo
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: startDate)
            if components.day != nil {
                let nextPeriodDate = calendar.date(byAdding: .day, value: cycleLength, to: startDate)
                if let nextPeriodDate = nextPeriodDate {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd/MM/yyyy"
                    let nextPeriodDateString = formatter.string(from: nextPeriodDate)
                    
                    // Mostrar la fecha del próximo periodo
                    let alertController = UIAlertController(title: "Próximo periodo", message: nextPeriodDateString, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    present(alertController, animated: true, completion: nil)
                    
                    // Calcular y mostrar los días fértiles
                    if let fertileDays = calculateFertileDays(from: nextPeriodDate) {
                        let fertileDaysString = fertileDays.map { formatter.string(from: $0) }.joined(separator: ", ")
                        let fertileDaysAlert = UIAlertController(title: "Días fértiles", message: fertileDaysString, preferredStyle: .alert)
                        fertileDaysAlert.addAction(okAction)
                        present(fertileDaysAlert, animated: true, completion: nil)
                    }
                }
            }
        }
        


    func calculateFertileDays(from nextPeriodDate: Date) -> [Date]? {
        guard let cycleLength = cycleLength else {
            return nil
        }
        
        let calendar = Calendar.current
        let fertileDaysRange = 4...5 // Considerar los días 4 y 5 después del próximo periodo como días fértiles
        
        var fertileDays: [Date] = []
        
        for day in fertileDaysRange {
            if let fertileDate = calendar.date(byAdding: .day, value: cycleLength - day, to: nextPeriodDate) {
                fertileDays.append(fertileDate)
            }
        }
        
        return fertileDays
    }
            
}

