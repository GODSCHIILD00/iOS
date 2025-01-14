@objc final class CreateTextFileAlertViewRouter: NSObject, CreateTextFileAlertViewRouting {

    private weak var baseViewController: UIViewController?
    private weak var presenter: UIViewController?
    
    @objc init(presenter: UIViewController?) {
        self.presenter = presenter
    }
    
    func build() -> UIViewController {
        let vm = CreateTextFileAlertViewModel(router: self)
        let vc = CreateTextFileAlertViewController(title: nil, message: nil, preferredStyle: .alert)
        vc.viewModel = vm
        baseViewController = vc
        return vc
    }
    
    @objc func start() {
        guard let presenter = presenter else { return }
        presenter.present(build(), animated: true, completion: nil)
    }
    
    func createTextFile(_ fileName: String) {
        let textFile = TextFile(fileName: fileName)
        guard let presenter = presenter else { return }
        TextEditorViewRouter(textFile: textFile, textEditorMode: .create, presenter: presenter).start()
    }
}
