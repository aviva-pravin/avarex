import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:avaremp/path_utils.dart';
import 'package:exif/exif.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'app_settings.dart';
import 'db_general.dart';
import 'gps.dart';

class Storage {
  static final Storage _instance = Storage._internal();

  factory Storage() {
    return _instance;
  }

  Storage._internal();

  Future<void> init() async {
    DbGeneral.set(); // set database platform
    WidgetsFlutterBinding.ensureInitialized();
    await WakelockPlus.enable(); // keep screen on
    await Gps.checkPermissions();
    Gps.getUpdates();
    await _settings.initSettings();
  }

  final AppSettings _settings = AppSettings();

  AppSettings get settings => _settings;

  ui.Image? _imagePlate;
  final TransformationController _plateTransformationController = TransformationController();
  Map<String, IfdTag>? _exifPlate;
  String _currentPlate = "";
  String _currentPlateAirport = "";
  String _lastPlateAirport = "";

  set lastPlateAirport(String value) {
    _lastPlateAirport = value;
  }
  String get lastPlateAirport => _lastPlateAirport;

  Future<void> loadPlate() async {
    String path = await PathUtils.getPlateFilePath(_currentPlateAirport, _currentPlate);
    if(_currentPlate.startsWith("CSUP:")) {
      // all CSUP plates are appended by CSUP so remove it
      path = await PathUtils.getCSupFilePath(_currentPlate.replaceFirst("CSUP:", ""));
    }
    File file = File(path);
    Completer<ui.Image> completerPlate = Completer();
    Uint8List bytes;
    try {
      bytes = await file.readAsBytes();
    }
    catch(e) {
      ByteData bd = await rootBundle.load('assets/images/black.png');
      // file bad or not found
      bytes = bd.buffer.asUint8List();
    }
    _exifPlate = await readExifFromBytes(bytes);
    ui.decodeImageFromList(bytes, (ui.Image img) {
      return completerPlate.complete(img);
    });
    if(_imagePlate != null) {
      _imagePlate!.dispose();
      _imagePlate = null;
    }
    _imagePlate = await completerPlate.future;
  }

  ui.Image? get imagePlate => _imagePlate;
  TransformationController get plateTransformationController => _plateTransformationController;
  Map<String, IfdTag>? get exifPlate => _exifPlate;
  String get currentPlate => _currentPlate;
  String get currentPlateAirport => _currentPlateAirport;

  set currentPlate(String value) {
    _currentPlate = value;
  }

  set currentPlateAirport(String value) {
    _lastPlateAirport = _currentPlateAirport;
    _currentPlateAirport = value;
  }


  double _screenTop = 0;

  double get screenTop => _screenTop;
  double _screenBottom = 0;
  void setScreenDims(double? top, double bottom) {
    if(null == top) {
      _screenTop = 0;
    }
    else {
      _screenTop = top;
    }
    _screenBottom = bottom;
  }

  double get screenBottom => _screenBottom;

  resetPlate() {
    _plateTransformationController.value.setEntry(0, 0, 1);
    _plateTransformationController.value.setEntry(1, 1, 1);
    _plateTransformationController.value.setEntry(2, 2, 1);
    _plateTransformationController.value.setEntry(0, 3, 0);
    _plateTransformationController.value.setEntry(1, 3, 0);
  }
}