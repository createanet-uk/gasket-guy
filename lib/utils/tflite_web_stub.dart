enum TensorType { float32, uint8, int8, int32, int64, string, bool, float16, float64 }

class TensorStub {
  List<int> get shape => [];
  TensorType get type => TensorType.float32;
}

class Interpreter {
  static Interpreter fromFile(dynamic file, {dynamic options}) => Interpreter._();
  static Future<Interpreter> fromAsset(String assetName, {dynamic options}) async => Interpreter._();

  Interpreter._();

  TensorStub getInputTensor(int index) => TensorStub();
  TensorStub getOutputTensor(int index) => TensorStub();
  List<TensorStub> get inputTensors => [];
  List<TensorStub> get outputTensors => [];

  void run(dynamic input, dynamic output) {}
  void runForMultipleInputs(List inputs, Map<int, Object> outputs) {}
  void close() {}
  void allocateTensors() {}
  void resizeInputTensor(int index, List<int> shape) {}
}
