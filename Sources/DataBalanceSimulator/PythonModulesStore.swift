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

    static var dataset = {
        configurePythonEnvIfNecessary()
        return Python.import("dataset")
    }()

    static var sampling = {
        configurePythonEnvIfNecessary()
        return Python.import("sampling")
    }()

    static var builtins = Python.import("builtins")

    public static func configurePythonEnv() {
        let os = Python.import("os")
        let sys = Python.import("sys")
        sys.path.append("\(os.getcwd())/python-modules")
    }

    public static func getPythonId(obj: PythonObject) -> String {
        let idFn = builtins.id
        return "\(idFn(obj))"
    }

    public static func getAttr(obj: PythonObject, attr: String) -> PythonObject {
        return builtins.getattr(obj, attr)
    }
}