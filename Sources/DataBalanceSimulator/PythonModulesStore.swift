import PythonKit

class PythonModulesStore {
    private static var isPythonEnvConfigured: Bool = false

    private static func configurePythonEnvIfNecessary() {
        if !isPythonEnvConfigured {
            configurePythonEnv()
            isPythonEnvConfigured = true
        }
    }

    static var metrics = {
        configurePythonEnvIfNecessary()
        return Python.import("metrics")
    }()

    static var builtins = Python.import("builtins")

    public static func configurePythonEnv() {
        let os = Python.import("os")
        let sys = Python.import("sys")
        sys.path.append("\(os.getcwd())")
    }

    public static func getAttr(module: PythonObject, attr: String) -> PythonObject {
        return builtins.getattr(module, attr)
    }
}