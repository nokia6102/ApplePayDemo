//https://medium.com/appcoda-tutorials/integrating-basic-apple-pay-into-your-ios-app-71f17d48fc9b
import UIKit
//1.
import PassKit

class ViewController: UIViewController {
    
    // Data Setup
    
    struct Shoe {
        var name: String
        var price: Double
    }
    
    let shoeData = [
        Shoe(name: "Nike Air Force 1 High LV8", price: 0.00),
        Shoe(name: "adidas Ultra Boost Clima", price: 139.99),
        Shoe(name: "Jordan Retro 10", price: 190.00),
        Shoe(name: "adidas Originals Prophere", price: 49.99),
        Shoe(name: "New Balance 574 Classic", price: 90.00)
    ]
    
    // Storyboard outlets
    
    @IBOutlet weak var shoePickerView: UIPickerView!
    @IBOutlet weak var priceLabel: UILabel!
    
    //1.
    func displayDefaultAlert(title: String?, message: String?) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
    alert.addAction(okAction)
    self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func buyShoeTapped(_ sender: UIButton) {
        //2. 支付卡種
        let paymentNetworks = [PKPaymentNetwork.amex, .discover, .masterCard, .visa]
        
        let selectedIndex = shoePickerView.selectedRow(inComponent: 0)
          let shoe = shoeData[selectedIndex]
          let paymentItem = PKPaymentSummaryItem.init(label: shoe.name, amount: NSDecimalNumber(value: shoe.price))
        
        //測試有沒有可以使用支付功
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) {
        let request = PKPaymentRequest()
            request.currencyCode = "USD" // 1
            request.countryCode = "US" // 2
            request.merchantIdentifier = "merchant.com.apppaytestex.Shoe-Store" // 3
            request.merchantCapabilities = PKMerchantCapability.capability3DS // 4
            request.supportedNetworks = paymentNetworks // 5
            request.paymentSummaryItems = [paymentItem] // 6
            //受權
            guard let paymentVC = PKPaymentAuthorizationViewController(paymentRequest: request) else {
                displayDefaultAlert(title: "Error", message: "Unable to present Apple Pay authorization.")
                return
            }
            paymentVC.delegate = self
            self.present(paymentVC, animated: true, completion: nil)
        }else{
            //無支付功能
            displayDefaultAlert(title: "Error", message: "Unable to make Apple Pay transaction.")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shoePickerView.delegate = self
        shoePickerView.dataSource = self
    }
    
}

//3.實作代理
extension ViewController: PKPaymentAuthorizationViewControllerDelegate {
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        print ("*paymentAuthorizationViewControllerDidFinish")
        dismiss(animated: true, completion: nil)
    }
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        print ("*didAuthorizePayment")
    }
}

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: - Pickerview update
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return shoeData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return shoeData[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let priceString = String(format: "%.02f", shoeData[row].price)
        priceLabel.text = "Price = $\(priceString)"
    }
}
